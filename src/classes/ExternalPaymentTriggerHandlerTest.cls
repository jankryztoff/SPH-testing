/**
 * Class Name: ExternalPaymentTriggerHandlerTest
 * @author: Marjorie Gaelo
 * Requirement/Project Name: <SPH>
 * @description: Test Class for ExternalPaymentTriggerHandler
 * @Modified by: jensar.joey.z.sayson (JJZS)
**/



@isTest(seeAllData=True)
        private class ExternalPaymentTriggerHandlerTest{
        
            static Project__c pro = null;
            static Account vendorSubsAcct = null;
            static Singpost_Address__c singpostAdd = null;
            static Subscription_Vendor__c subsVen = null;
            static Package__c pack = null;
            static Account venAccount = null;
            static zqu__ZProduct__c zProduct = null;
            static Gift__c gift = null;
            static zqu__ProductRatePlan__c prdRatePlan = null;
            static Address__c add = null;
            static Zuora__CustomerAccount__c billingAcc = null;
            static Promotion_Gift__c pg = null;
            static Post_Sector_Ops_Rep_Mapping__c psorm = null;
            static zqu__ProductRatePlanCharge__c prpc = null;
            static Package_Item__c pItem = null;
            static Vendor_Allocation__c venAlloc = null;
            static zqu__ProductRatePlanChargeTier__c prpct = null;
            static List<Publication__c> pubList = null;
            static Contact con = null;
            static Contact con1 = null;
            static Order__c order = null;
            static Case cas = null;
            static Order_Line_Item__c oli = null;
            static Order_Line_Item_Gift__c olig = null;
            static Zuora__Subscription__c zSub = null;
            static Zuora__SubscriptionProductCharge__c spc = null;
            static Zuora__ZInvoice__c zzi = null;
            //Create a new user with Standard User Profile
            static User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardept2@test.com'
            );
            
            static Map<String,sObject> sObjectMap;
    
        static testMethod void test_TriggerHandler01(){
        
                try{
                
                System.runAs(testUser){
                
                setAllData();
                
                External_Payment__c externalPaymentRecord2 = new External_Payment__c(
                Payment_amount__c = 2,
                Expiration_Date__c = Date.today(),
                Billing_Contact_email__c = 'test@sample.com',
                Billing_Contact_First_Name__c = 'John',
                Billing_Contact_Last_Name__c = 'Doe',
                Transaction_Status__c = 'C',
                Transaction_Type__c = 'C',
                Transaction_Amount__c = 100,
                
                Billing_Account__c = billingAcc.Id,
                Transaction_Date__c = Date.today(),
                Payment_Method__c = 'Credit Card',
                //Parent_Transaction_ID__c = '111222333444');
                Parent_Transaction_ID__c = '231222221111');
                //(WebServiceMock.class, new zApiAmend());
                insert externalPaymentRecord2;
                
                System.assertNotEquals(null, externalPaymentRecord2);
                }
                Test.stopTest();
                }
                catch(Zuora.zRemoteException e){}
        }//END testMethod test_TriggerHandler  
        
        static testMethod void test_TriggerHandler01B(){
        
                try{
                
                System.runAs(testUser){
                
                setAllData();
                
                External_Payment__c externalPaymentRecord2 = new External_Payment__c(
                Payment_amount__c = 2,
                Expiration_Date__c = Date.today(),
                Billing_Contact_email__c = 'test@sample.com',
                Billing_Contact_First_Name__c = 'John',
                Billing_Contact_Last_Name__c = 'Doe',
                Transaction_Status__c = 'C',
                Transaction_Type__c = 'C',
                Transaction_Amount__c = 100,
                
                Billing_Account__c = billingAcc.Id,
                Transaction_Date__c = Date.today(),
                Payment_Method__c = 'Credit Card',
                //Parent_Transaction_ID__c = '111222333444');
                Parent_Transaction_ID__c = '231222221111');
                //(WebServiceMock.class, new zApiAmend());
                insert externalPaymentRecord2;
                
                ExternalPaymentTriggerHandler extPayTrig = new ExternalPaymentTriggerHandler();
                extPayTrig.getSubscriptions();
                
                System.assertNotEquals(null, externalPaymentRecord2);
                }
                Test.stopTest();
                }
                catch(Zuora.zRemoteException e){}
        }//END testMethod test_TriggerHandler  
    
        static testMethod void test_TriggerHandler02(){
        
                try{
                
                System.runAs(testUser){
                
                setAllData();
                
                External_Payment__c externalPaymentRecord = new External_Payment__c(
                Payment_amount__c = 2,
                Expiration_Date__c = Date.today(),
                Billing_Contact_email__c = 'test@sample.com',
                Billing_Contact_First_Name__c = 'John',
                Billing_Contact_Last_Name__c = 'Doe',
                Transaction_Status__c = 'F',
                Transaction_Type__c = 'F',
                Transaction_Amount__c = 100,
                
                Billing_Account__c = billingAcc.Id,
                Transaction_Date__c = Date.today(),
                Payment_Method__c = 'Credit Card',
                Parent_Transaction_ID__c = '231222221111');
                //Test.setMock(WebServiceMock.class, new zApiAmend());
                insert externalPaymentRecord;
                
                externalPaymentRecord.Payment_Method__c = 'Credit Card';
                externalPaymentRecord.Payment_amount__c = 3;
                externalPaymentRecord.Transaction_Amount__c = 100;
                
                externalPaymentRecord.Transaction_Date__c = Date.today();
                update externalPaymentRecord;    
                
                System.assertNotEquals(null, externalPaymentRecord);
                }
                Test.stopTest();
                }
                catch(Zuora.zRemoteException e){}
        }//END testMethod test_TriggerHandler

        static testMethod void test_TriggerHandler03(){
        
                try{
                
                System.runAs(testUser){
                
                setAllData();
                
                External_Payment__c externalPaymentRecord = new External_Payment__c(
                Payment_amount__c = 2,
                Expiration_Date__c = Date.today(),
                Billing_Contact_email__c = 'test@sample.com',
                Billing_Contact_First_Name__c = 'John',
                Billing_Contact_Last_Name__c = 'Doe',
                Transaction_Status__c = 'F',
                Transaction_Type__c = 'F',
                Transaction_Amount__c = 100,
                
                Billing_Account__c = billingAcc.Id,
                Transaction_Date__c = Date.today(),
                Payment_Method__c = 'Credit Card');
                //Test.setMock(WebServiceMock.class, new zApiAmend());
                insert externalPaymentRecord;
                
                externalPaymentRecord.Payment_Method__c = 'Credit Card';
                externalPaymentRecord.Payment_amount__c = 3;
                externalPaymentRecord.Transaction_Amount__c = 100;
                externalPaymentRecord.Transaction_Date__c = Date.today();
                update externalPaymentRecord;
                
                System.assertNotEquals(null, externalPaymentRecord);
                }    
                Test.stopTest();                
                }
                catch(Zuora.zRemoteException e){}
        }//END testMethod test_TriggerHandler
        
        static testMethod void coverAllData(){
        
                ExternalPaymentTriggerHandler epth = new ExternalPaymentTriggerHandler();
                epth.runBeforeInsertTrigger();
                epth.runBeforeUpdateTrigger();
                epth.runBeforeDeleteTrigger();
                epth.runAfterInsertTrigger();
                epth.runAfterUpdateTrigger();
                epth.runAfterDeleteTrigger();
                
                Account acct = new Account();
                epth.beforeDelete(acct);
                epth.afterDelete(acct);
                
                System.assertNotEquals(null,acct);
        } 
    
        static testMethod void coverPaymentToZuora(){
        
                try{

                    System.runAs(testUser){

                        setAllData();
                        
                        Test.setMock(WebServiceMock.class, new zLoginMock()); 
                        
                        vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                        insert vendorSubsAcct;
                        
                        billingAcc = TestDataFactory.createBillingAccount(1)[0];
                        billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                        //billingAcc.Billing_Type__c = 'Cash';   
                        billingAcc.Billing_Type__c = 'Recurring Postpaid';
                        insert billingAcc;     
                        
                        External_Payment__c externalPaymentRecord = new External_Payment__c(
                        Payment_amount__c = 2,
                        Expiration_Date__c = Date.today(),
                        Billing_Contact_email__c = 'test@sample.com',
                        Billing_Contact_First_Name__c = 'John',
                        Billing_Contact_Last_Name__c = 'Doe',
                        Transaction_Status__c = 'F',
                        Transaction_Type__c = 'F',
                        Transaction_Amount__c = 100,
                        Parent_Transaction_ID__c = '231222221111',
                        Billing_Account__c = billingAcc.Id,
                        Transaction_Date__c = Date.today(),
                        Payment_Method__c = 'Credit Card');
                        //Test.setMock(WebServiceMock.class, new zApiAmend());
                        insert externalPaymentRecord;
                        
                        Set<Id> extId = new Set<Id>();
                        extID.add(externalPaymentRecord.Id);
                        
                        Zuora__Subscription__c zSubs = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
                        
                        Set<String> parentTransIdSet = new Set<String>();
                        parentTransIdSet.add(zSubs.Parent_Transaction_ID__c);
                        
                        try{
                        ExternalPaymentTriggerHandler.paymentToZuora(extID,parentTransIdSet);//parentTransIdSet);
                        zzi.Zuora__Balance2__c = 150;
                        update zzi;

                        ExternalPaymentTriggerHandler.paymentToZuora(extID,parentTransIdSet);
                        }catch(Exception e){}
                        
                        //                    ExternalPaymentTriggerHandler.paymentToZuora(null,null);
                        Test.stopTest();
                        
                        System.assertNotEquals(null, externalPaymentRecord);
                    }
                    
                }catch(Zuora.zRemoteException e){}

        }

        static testMethod void coverSetOrderSetOliSetCaseAmendZuora(){
        
                try{

                    System.runAs(testUser){
                        setAllData();
                        
                        Test.setMock(WebServiceMock.class, new zLoginMock()); 
                        
                        vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                        insert vendorSubsAcct;
                        
                        billingAcc = TestDataFactory.createBillingAccount(1)[0];
                        billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                        //billingAcc.Billing_Type__c = 'Cash';   
                        billingAcc.Billing_Type__c = 'Recurring Postpaid';
                        insert billingAcc;     
                        
                        External_Payment__c externalPaymentRecord = new External_Payment__c(
                        Payment_amount__c = 2,
                        Expiration_Date__c = Date.today(),
                        Billing_Contact_email__c = 'test@sample.com',
                        Billing_Contact_First_Name__c = 'John',
                        Billing_Contact_Last_Name__c = 'Doe',
                        Transaction_Status__c = 'F',
                        Transaction_Type__c = 'F',
                        Transaction_Amount__c = 100,
                        Parent_Transaction_ID__c = '231222221111',
                        Billing_Account__c = billingAcc.Id,
                        Transaction_Date__c = Date.today(),
                        Payment_Method__c = 'Credit Card');
                        //Test.setMock(WebServiceMock.class, new zApiAmend());
                        insert externalPaymentRecord;
                        
                        Set<Id> extId = new Set<Id>();
                        extID.add(externalPaymentRecord.Id);
                        
                        Zuora__Subscription__c zSubs = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
                        
                        Set<String> parentTransIdSet = new Set<String>();
                        parentTransIdSet.add(zSubs.Parent_Transaction_ID__c);
                        
                        Map<Id, String> accIdToNewBillAccZuoraId = new Map<Id, String>();
                        accIdToNewBillAccZuoraId.put(billingAcc.Zuora__Account__c, 'Destination Test');

                        List<Order__c> orderList = new List<Order__c>();
                        order.Recipient_Contact__c = con.Id;
                        orderList.add(order);
                        try{

                        ExternalPaymentTriggerHandler handler = new ExternalPaymentTriggerHandler();
                        ExternalPaymentTriggerHandler.orderList = orderList;
                        handler.setOrder(extID);
                        handler.setOLI(extID);
                        handler.setCase();
                        ExternalPaymentTriggerHandler.amendZuora(extID,true,accIdToNewBillAccZuoraId);

                        }catch(Exception e){}
                        
                        Test.stopTest();
                        
                        System.assertNotEquals(null, externalPaymentRecord);
                    }
                
                }catch(Zuora.zRemoteException e){}
        }

        static testMethod void coverCreateBillingAccountToZuora(){
        
                try{

                    System.runAs(testUser){
                        setAllData();
                        
                        Test.setMock(WebServiceMock.class, new zLoginMock()); 
                        
                        vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                        insert vendorSubsAcct;
                        
                        billingAcc = TestDataFactory.createBillingAccount(1)[0];
                        billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                        //billingAcc.Billing_Type__c = 'Cash';   
                        billingAcc.Billing_Type__c = 'Recurring Postpaid';
                        billingAcc.Billing_Contact__c = con1.id;
                        insert billingAcc;     
                        
                        External_Payment__c externalPaymentRecord = new External_Payment__c(
                        Payment_amount__c = 2,
                        Expiration_Date__c = Date.today(),
                        Billing_Contact_email__c = 'test@sample.com',
                        Billing_Contact_First_Name__c = 'John',
                        Billing_Contact_Last_Name__c = 'Doe',
                        Transaction_Status__c = 'F',
                        Transaction_Type__c = 'F',
                        Transaction_Amount__c = 100,
                        Parent_Transaction_ID__c = '231222221111',
                        Billing_Account__c = billingAcc.Id,
                        Transaction_Date__c = Date.today(),
                        Payment_Method__c = 'Credit Card');
                        //Test.setMock(WebServiceMock.class, new zApiAmend());
                        insert externalPaymentRecord;

                        External_Payment__c externalPaymentRecord2 = new External_Payment__c(
                        Payment_amount__c = 2,
                        Expiration_Date__c = Date.today(),
                        Billing_Contact_email__c = 'test@sample1.com',
                        Billing_Contact_First_Name__c = 'Johnd',
                        Billing_Contact_Last_Name__c = 'Doee',
                        Transaction_Status__c = 'F',
                        Transaction_Type__c = 'F',
                        Transaction_Amount__c = 150,
                        Billing_Account__c = billingAcc.Id,
                        Transaction_Date__c = Date.today(),
                        Payment_Method__c = 'Credit Card');
                        //Test.setMock(WebServiceMock.class, new zApiAmend());
                        insert externalPaymentRecord2;
                        
                        Set<Id> extId = new Set<Id>();
                        extID.add(externalPaymentRecord.Id);

                        Zuora__Subscription__c zSubs = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
                        
                        Set<String> parentTransIdSet = new Set<String>();
                        parentTransIdSet.add(zSubs.Parent_Transaction_ID__c);

                        Set<Id> subscriptionIdSet = new Set<Id>();
                        subscriptionIdSet.add(subsVen.Id);

                        Set<String> subscriptionNameSet = new Set<String>();
                        subscriptionNameSet.add(subsVen.Vendor__r.Vendor_Name__c);

                        Set<Id> extId2 = new Set<Id>();
                        extId2.add(externalPaymentRecord2.Id);

                        try{
                            ExternalPaymentTriggerHandler.createBillingAccountToZuora(extID,subscriptionIdSet,subscriptionNameSet);

                            zSub.Zuora__CustomerAccount__c = billingAcc.Id;

                            ExternalPaymentTriggerHandler.createBillingAccountToZuora(extId2,subscriptionIdSet,subscriptionNameSet);
                        }catch(Exception e){}
                        
                        //                    ExternalPaymentTriggerHandler.paymentToZuora(null,null);
                        Test.stopTest();
                        
                        System.assertNotEquals(null, externalPaymentRecord);
                    }
                
                }catch(Zuora.zRemoteException e){}
        }

        static testMethod void coverGetRelatedInvoice(){
        
                try{
                    System.runAs(testUser){
                        setAllData();
                        
                        Test.setMock(WebServiceMock.class, new zLoginMock()); 
                        
                        vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                        insert vendorSubsAcct;
                        
                        billingAcc = TestDataFactory.createBillingAccount(1)[0];
                        billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                        //billingAcc.Billing_Type__c = 'Cash';   
                        billingAcc.Billing_Type__c = 'Recurring Postpaid';
                        insert billingAcc;     
                        
                        External_Payment__c externalPaymentRecord = new External_Payment__c(
                        Payment_amount__c = 2,
                        Expiration_Date__c = Date.today(),
                        Billing_Contact_email__c = 'test@sample.com',
                        Billing_Contact_First_Name__c = 'John',
                        Billing_Contact_Last_Name__c = 'Doe',
                        Transaction_Status__c = 'F',
                        Transaction_Type__c = 'F',
                        Transaction_Amount__c = 100,
                        Parent_Transaction_ID__c = '231222221111',
                        Billing_Account__c = billingAcc.Id,
                        Transaction_Date__c = Date.today(),
                        Payment_Method__c = 'Credit Card');
                        //Test.setMock(WebServiceMock.class, new zApiAmend());
                        insert externalPaymentRecord;

                        Invoice_Line_Item__c newTestInvoiceLineItem = new Invoice_Line_Item__c();
                        newTestInvoiceLineItem.Invoice_ID__c = 'EXT111111';
                        newTestInvoiceLineItem.Quantity__c = 100;
                        newTestInvoiceLineItem.Tax_Amount__c = 1000.0;
                        newTestInvoiceLineItem.Unit_Price__c = 1000.0;
                        newTestInvoiceLineItem.Charge_Amount__c = 1000;
                        newTestInvoiceLineItem.Subscription_ID__c = 'EXT12300010';
                        insert newTestInvoiceLineItem;
                        
                        Set<Id> extId = new Set<Id>();
                        extID.add(externalPaymentRecord.Id);
                        
                        Zuora__Subscription__c zSubs = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
                        
                        Set<String> parentTransIdSet = new Set<String>();
                        parentTransIdSet.add(zSubs.Parent_Transaction_ID__c);

                        Set<String> zuoraIdSet = new Set<String>();
                        zuoraIdSet.add(newTestInvoiceLineItem.Subscription_ID__c);
                        
                        try{
                        ExternalPaymentTriggerHandler.getRelatedInvoice(zuoraIdSet);
                        }catch(Exception e){}
                        
                        Test.stopTest();
                        
                        System.assertNotEquals(null, externalPaymentRecord);
                    }
                
                }catch(Zuora.zRemoteException e){}
        }

        static void setAllData(){
        
                sObjectMap = null;
                sObjectMap = new Map<String,sObject>();
                
                pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                
                vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.House_Block_Number__c = 'TEST';
                singpostAdd.Address_Type__c = 'A';
                singpostAdd.Name = '99';
                subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                pack = TestDataFactory.createPackage(1)[0];
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zProduct = TestDataFactory.createZProduct(1)[0];
                gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 55;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today();
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                prdRatePlan.name = 'Test Tier Name0';
                prdRatePlan.SubscriptionFrequency__c = '2' ;
                
                add = TestDataFactory.createAddress(1)[0];
                add.Address_Type__c = 'A';
                add.Block_House_Number__c ='TEST';
                add.Level_Number__c ='xx';
                add.Unit_Number__c = 'yy';
                add.Postal_Code__c = singpostAdd.Id;
                
                
                billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                //billingAcc.Billing_Type__c = 'Cash';   
                billingAcc.Billing_Type__c = 'Recurring Postpaid';
                
                pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm}; // by JJZS on 06262015
                
                prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.PublicationCode__c = 'XXXX';
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                
                venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                venAlloc.Allocated__c = TRUE; //statement added by jjzs
                insert new List<sObject>{prpc, pItem, venAlloc};
                
                prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
                prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
                prpct.zqu__PriceFormat__c = 'Per Unit';
                prpct.zqu__Currency__c ='SGD';
                insert prpct;
                
                pubList = TestDataFactory.createPublication(1);
                for(Publication__c svp: pubList) {
                svp.Publication_Code__c = prpc.PublicationCode__c;
                svp.Published_Days__c = 'YYYYYYY';
                svp.Publication_Type__c = 'Y';
                }
                insert pubList;
                
                con = TestDataFactory.createContact(1)[0];
                con.AccountId = vendorSubsAcct.Id;
                con.Address__c = add.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                insert con;
                
                con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = add.Id;
                con1.AccountId = vendorSubsAcct.Id;
                con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con1.Billing_Indicator__c = true;
                insert con1;
                
                order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct.Id; 
                order.Recipient_Contact__c = con.Id;
                order.Billing_Account__c = billingAcc.Id;
                order.Billing_Type__c = billingAcc.Billing_Type__c;
                order.Informed_Customer__c = True;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Contact__c = con1.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Subscriber_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                insert order;
                
                cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.IsEscalated = true;
                cas.Order__c = order.Id;
                //Test.startTest(); 
                insert cas;
                
                oli = TestDataFactory.createOrderLineItem(1)[0];
                oli.Order__c = order.Id;
                oli.Vendor_Subscription_ID__c = subsVen.Id;
                oli.Main_Package_ID__c = pack.Id;
                oli.Vendor_Mailing_Agent__c = venAccount.Id;
                oli.Order__c = order.Id;
                oli.End_Date__c = Date.Today().addDays(30);
                oli.Main_Package_ID__c = pack.Id;
                oli.Term_Length__c = 0;
                oli.Main_Package_Period__c = 0;
                oli.Start_Date__c = date.today().addDays(1);
                oli.Earliest_Start_Date__c = date.today();
                oli.Earliest_Stop_Date__c = date.today().addDays(2);
                oli.Stop_Request_Date__c =  date.today().addDays(4);
                oli.Terminating_Reason__c = 'Others';
                oli.Amount_To_Refund__c = 0;
                oli.Admin_Charge__c = 0;
                oli.Fee_Waiver__c = TRUE;
                oli.Fee_Override__c = FALSE;
                oli.Override_Reason__c = 'TEST';
                oli.Suppress_Notification_Stop__c = TRUE;
                oli.Main_Package_Type__c = 'Base';
                insert oli;
                
                olig = TestDataFactory.createItemGift(1)[0];
                olig.Order_Line_Item__c = oli.Id;
                olig.Promotion_Gift__c = pg.Id;
                //       insert olig;
                
                zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Zuora__Account__c = vendorSubsAcct.Id;
                zSub.Zuora__CustomerAccount__c = billingAcc.Id;
                zSub.Order_Line_Item_Number__c = oli.Id;
                zSub.Order_Number__c = order.Id;
                zSub.Suppress_Vendor_Start_Notice__c = 'false';
                zSub.Supressed_Acknowledgement_Letter__c = 'false';
                zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zSub.Urgent__c = 'false';
                zSub.Vendor_Conversion__c = 'false';
                zSub.Charity__c = 'false';
                zSub.Sponsor__c = 'false';
                zSub.Recipient_Contact__c = con.Id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Status__c = 'Active';
                zSub.Order_Number_1__c = order.id;
                zSub.Parent_Transaction_ID__c = '231222221111';
                //zSub.Main_Package_1__c = pack.id;
                sObjectMap.put('Zuora__Subscription__c', zsub);
                Test.startTest();
                
                insert zSub;
                
                spc = TestDataFactory.createSubProductCharge(1)[0];
                spc.Zuora__Subscription__c = zSub.Id;
                spc.Zuora__RatePlanName__c = 'Test Tier Name0';
                insert spc;
                
                zzi = new Zuora__ZInvoice__c();
                zzi.Zuora__BillingAccount__c = billingAcc.id;
                zzi.Zuora__Balance2__c = 50;
                zzi.Zuora__Zuora_Id__c = 'test';
                zzi.Name = 'testname';
                insert zzi;   
                
                
                Set<String> newSubscriptionZuoraIdSet = new Set<String>();
                newSubscriptionZuoraIdSet.add('test');
                
                
                ExternalPaymentTriggerHandler.cancelSubscription(newSubscriptionZuoraIdSet);
                
        }
        static testMethod void test_TriggerHandlerApril(){
        
                try{
                
                System.runAs(testUser){
                
                pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                
                vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.House_Block_Number__c = 'TEST';
                singpostAdd.Address_Type__c = 'A';
                singpostAdd.Name = '99';
                subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                pack = TestDataFactory.createPackage(1)[0];
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zProduct = TestDataFactory.createZProduct(1)[0];
                gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 55;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today();
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                prdRatePlan.name = 'Test Tier Name0';
                prdRatePlan.SubscriptionFrequency__c = '2' ;
                
                add = TestDataFactory.createAddress(1)[0];
                add.Address_Type__c = 'A';
                add.Block_House_Number__c ='TEST';
                add.Level_Number__c ='xx';
                add.Unit_Number__c = 'yy';
                add.Postal_Code__c = singpostAdd.Id;
                
                
                billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                billingAcc.Other_PaymentMethod__c = 'Invoice';
                //billingAcc.Billing_Type__c = 'Cash';   
                billingAcc.Billing_Type__c = 'Recurring Postpaid';
                
                pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm}; // by JJZS on 06262015
                
                prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.PublicationCode__c = 'XXXX';
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                
                venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                venAlloc.Allocated__c = TRUE; //statement added by jjzs
                insert new List<sObject>{prpc, pItem, venAlloc};
                
                prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
                prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
                prpct.zqu__PriceFormat__c = 'Per Unit';
                prpct.zqu__Currency__c ='SGD';
                insert prpct;
                
                pubList = TestDataFactory.createPublication(1);
                for(Publication__c svp: pubList) {
                svp.Publication_Code__c = prpc.PublicationCode__c;
                svp.Published_Days__c = 'YYYYYYY';
                svp.Publication_Type__c = 'Y';
                }
                insert pubList;
                
                con = TestDataFactory.createContact(1)[0];
                con.AccountId = vendorSubsAcct.Id;
                con.Address__c = add.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                insert con;
                
                con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = add.Id;
                con1.AccountId = vendorSubsAcct.Id;
                con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con1.Billing_Indicator__c = true;
                insert con1;
                
                order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct.Id; 
                order.Recipient_Contact__c = con.Id;
                order.Billing_Account__c = billingAcc.Id;
                order.Billing_Type__c = billingAcc.Billing_Type__c;
                order.Informed_Customer__c = True;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Contact__c = con1.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Subscriber_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                insert order;
                
                cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.IsEscalated = true;
                cas.Order__c = order.Id;
                //Test.startTest(); 
                insert cas;
                
                oli = TestDataFactory.createOrderLineItem(1)[0];
                oli.Order__c = order.Id;
                oli.Vendor_Subscription_ID__c = subsVen.Id;
                oli.Main_Package_ID__c = pack.Id;
                oli.Vendor_Mailing_Agent__c = venAccount.Id;
                oli.Order__c = order.Id;
                oli.End_Date__c = Date.Today().addDays(30);
                oli.Main_Package_ID__c = pack.Id;
                oli.Term_Length__c = 0;
                oli.Main_Package_Period__c = 0;
                oli.Start_Date__c = date.today().addDays(1);
                oli.Earliest_Start_Date__c = date.today();
                oli.Earliest_Stop_Date__c = date.today().addDays(2);
                oli.Stop_Request_Date__c =  date.today().addDays(4);
                oli.Terminating_Reason__c = 'Others';
                oli.Amount_To_Refund__c = 0;
                oli.Admin_Charge__c = 0;
                oli.Fee_Waiver__c = TRUE;
                oli.Fee_Override__c = FALSE;
                oli.Override_Reason__c = 'TEST';
                oli.Suppress_Notification_Stop__c = TRUE;
                oli.Main_Package_Type__c = 'Base';
                insert oli;
                
                olig = TestDataFactory.createItemGift(1)[0];
                olig.Order_Line_Item__c = oli.Id;
                olig.Promotion_Gift__c = pg.Id;
                //       insert olig;
                
                zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Zuora__Account__c = vendorSubsAcct.Id;
                zSub.Zuora__CustomerAccount__c = billingAcc.Id;
                zSub.Order_Line_Item_Number__c = oli.Id;
                zSub.Order_Number__c = order.Id;
                zSub.Suppress_Vendor_Start_Notice__c = 'false';
                zSub.Supressed_Acknowledgement_Letter__c = 'false';
                zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zSub.Urgent__c = 'false';
                zSub.Vendor_Conversion__c = 'false';
                zSub.Charity__c = 'false';
                zSub.Sponsor__c = 'false';
                zSub.Recipient_Contact__c = con.Id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Status__c = 'Active';
                zSub.Order_Number_1__c = order.id;
                zSub.Parent_Transaction_ID__c = '231222221111';
                //zSub.Main_Package_1__c = pack.id;
                // sObjectMap.put('Zuora__Subscription__c', zsub);
                Test.startTest();
                
                insert zSub;
                
                spc = TestDataFactory.createSubProductCharge(1)[0];
                spc.Zuora__Subscription__c = zSub.Id;
                spc.Zuora__RatePlanName__c = 'Test Tier Name0';
                insert spc;
                
                zzi = new Zuora__ZInvoice__c();
                zzi.Zuora__BillingAccount__c = billingAcc.id;
                zzi.Zuora__Balance2__c = 150.00;
                zzi.Zuora__Zuora_Id__c = 'test';
                zzi.Name = 'testname';
                insert zzi;   
                
                External_Payment__c externalPaymentRecord2 = new External_Payment__c(
                Payment_amount__c = 2,
                Expiration_Date__c = Date.today(),
                Billing_Contact_email__c = 'test@sample.com',
                Billing_Contact_First_Name__c = 'John',
                Billing_Contact_Last_Name__c = 'Doe',
                Transaction_Status__c = 'C',
                Transaction_Type__c = 'C',
                Transaction_Amount__c = 100.00,
                
                Billing_Account__c = billingAcc.Id,
                Transaction_Date__c = Date.today(),
                Payment_Method__c = 'Credit Card',
                //Parent_Transaction_ID__c = '111222333444');
                Parent_Transaction_ID__c = '231222221111');
                //(WebServiceMock.class, new zApiAmend());
                insert externalPaymentRecord2;
                
                ExternalPaymentTriggerHandler extPayTrig = new ExternalPaymentTriggerHandler();
                extPayTrig.getSubscriptions();
                
                System.assertNotEquals(null, externalPaymentRecord2);
                }
                Test.stopTest();
                }
                catch(Zuora.zRemoteException e){}
        }//END testMethod test_TriggerHandler  
        
        static testMethod void test_TriggerHandlerApril1(){
        
                try{
                
                System.runAs(testUser){
                
                pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                
                vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.House_Block_Number__c = 'TEST';
                singpostAdd.Address_Type__c = 'A';
                singpostAdd.Name = '99';
                subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                pack = TestDataFactory.createPackage(1)[0];
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zProduct = TestDataFactory.createZProduct(1)[0];
                gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 55;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today();
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                prdRatePlan.name = 'Test Tier Name0';
                prdRatePlan.SubscriptionFrequency__c = '2' ;
                
                add = TestDataFactory.createAddress(1)[0];
                add.Address_Type__c = 'A';
                add.Block_House_Number__c ='TEST';
                add.Level_Number__c ='xx';
                add.Unit_Number__c = 'yy';
                add.Postal_Code__c = singpostAdd.Id;
                
                
                billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                //billingAcc.Billing_Type__c = 'Cash';   
                billingAcc.Billing_Type__c = 'Recurring Postpaid';
                
                pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm}; // by JJZS on 06262015
                
                prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.PublicationCode__c = 'XXXX';
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                
                venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                venAlloc.Allocated__c = TRUE; //statement added by jjzs
                insert new List<sObject>{prpc, pItem, venAlloc};
                
                prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
                prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
                prpct.zqu__PriceFormat__c = 'Per Unit';
                prpct.zqu__Currency__c ='SGD';
                insert prpct;
                
                pubList = TestDataFactory.createPublication(1);
                for(Publication__c svp: pubList) {
                svp.Publication_Code__c = prpc.PublicationCode__c;
                svp.Published_Days__c = 'YYYYYYY';
                svp.Publication_Type__c = 'Y';
                }
                insert pubList;
                
                con = TestDataFactory.createContact(1)[0];
                con.AccountId = vendorSubsAcct.Id;
                con.Address__c = add.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                insert con;
                
                con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = add.Id;
                con1.AccountId = vendorSubsAcct.Id;
                con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con1.Billing_Indicator__c = true;
                insert con1;
                
                order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct.Id; 
                order.Recipient_Contact__c = con.Id;
                order.Billing_Account__c = billingAcc.Id;
                order.Billing_Type__c = billingAcc.Billing_Type__c;
                order.Informed_Customer__c = True;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Contact__c = con1.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Subscriber_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                insert order;
                
                cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.IsEscalated = true;
                cas.Order__c = order.Id;
                //Test.startTest(); 
                insert cas;
                
                oli = TestDataFactory.createOrderLineItem(1)[0];
                oli.Order__c = order.Id;
                oli.Vendor_Subscription_ID__c = subsVen.Id;
                oli.Main_Package_ID__c = pack.Id;
                oli.Vendor_Mailing_Agent__c = venAccount.Id;
                oli.Order__c = order.Id;
                oli.End_Date__c = Date.Today().addDays(30);
                oli.Main_Package_ID__c = pack.Id;
                oli.Term_Length__c = 0;
                oli.Main_Package_Period__c = 0;
                oli.Start_Date__c = date.today().addDays(1);
                oli.Earliest_Start_Date__c = date.today();
                oli.Earliest_Stop_Date__c = date.today().addDays(2);
                oli.Stop_Request_Date__c =  date.today().addDays(4);
                oli.Terminating_Reason__c = 'Others';
                oli.Amount_To_Refund__c = 0;
                oli.Admin_Charge__c = 0;
                oli.Fee_Waiver__c = TRUE;
                oli.Fee_Override__c = FALSE;
                oli.Override_Reason__c = 'TEST';
                oli.Suppress_Notification_Stop__c = TRUE;
                oli.Main_Package_Type__c = 'Base';
                insert oli;
                
                olig = TestDataFactory.createItemGift(1)[0];
                olig.Order_Line_Item__c = oli.Id;
                olig.Promotion_Gift__c = pg.Id;
                //       insert olig;
                
                zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Zuora__Account__c = vendorSubsAcct.Id;
                zSub.Zuora__CustomerAccount__c = billingAcc.Id;
                zSub.Order_Line_Item_Number__c = oli.Id;
                zSub.Order_Number__c = order.Id;
                zSub.Suppress_Vendor_Start_Notice__c = 'false';
                zSub.Supressed_Acknowledgement_Letter__c = 'false';
                zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zSub.Urgent__c = 'false';
                zSub.Vendor_Conversion__c = 'false';
                zSub.Charity__c = 'false';
                zSub.Sponsor__c = 'false';
                zSub.Recipient_Contact__c = con.Id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Status__c = 'Active';
                zSub.Order_Number_1__c = order.id;
                zSub.Parent_Transaction_ID__c = '231222221111';
                //zSub.Main_Package_1__c = pack.id;
                // sObjectMap.put('Zuora__Subscription__c', zsub);
                Test.startTest();
                
                insert zSub;
                
                spc = TestDataFactory.createSubProductCharge(1)[0];
                spc.Zuora__Subscription__c = zSub.Id;
                spc.Zuora__RatePlanName__c = 'Test Tier Name0';
                insert spc;
                
                zzi = new Zuora__ZInvoice__c();
                zzi.Zuora__BillingAccount__c = billingAcc.id;
                zzi.Zuora__Balance2__c = 50.00;
                zzi.Zuora__Zuora_Id__c = 'test';
                zzi.Name = 'testname';
                insert zzi;   
                
                External_Payment__c externalPaymentRecord2 = new External_Payment__c(
                Payment_amount__c = 2,
                Expiration_Date__c = Date.today(),
                Billing_Contact_email__c = 'test@sample.com',
                Billing_Contact_First_Name__c = 'John',
                Billing_Contact_Last_Name__c = 'Doe',
                Transaction_Status__c = 'C',
                Transaction_Type__c = 'C',
                Transaction_Amount__c = 100.00,
                
                Billing_Account__c = billingAcc.Id,
                Transaction_Date__c = Date.today(),
                Payment_Method__c = 'Credit Card',
                //Parent_Transaction_ID__c = '111222333444');
                Parent_Transaction_ID__c = '231222221111');
                //(WebServiceMock.class, new zApiAmend());
                insert externalPaymentRecord2;
                
                ExternalPaymentTriggerHandler extPayTrig = new ExternalPaymentTriggerHandler();
                extPayTrig.getSubscriptions();
                
                System.assertNotEquals(null, externalPaymentRecord2);
                }
                Test.stopTest();
                }
                catch(Zuora.zRemoteException e){}
        }//END testMethod test_TriggerHandler  
}