/**
 * Class Name: MigrationNewSubsTriggerHandlerTest
 * @author: April Veloso
 * Date: 8/26/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Test Class for MigrationNewSubscriptionTriggerHandler
 */

@isTest
public with sharing class MigrationNewSubsTriggerHandlerTest{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
    }
    
    //static Other__c otherC;

    static testmethod void test(){
            
            //create values
            //Custom Setting 
            //otherC = new Other__c();
            //otherC.Name = 'DTL';
            //otherC.Value__c = '23:59';
            //insert otherC;
               
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            //acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            insert acc;
                                  
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            insert con;
            
             
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[0].ARMS_Account_Number__c = '027101021';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
            billAccountList[0].Payment_Mode__c = 'CREDITCARD';
            billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Credit Card';
            insert billAccountList;
                
    
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
    
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            List<Promotion__c> promotionList = TestDataFactory.createPromotion(1);
            promotionList[0].Contract_Period__c = '1';
            promotionList[0].Effective_End_Date__c = System.today().addDays(30);
            insert promotionList;
            
            List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
            insert SubVen;
            
            List<Zuora__Subscription__c> zSubList = TestDataFactory.createSubscription(2);
            Integer i = 0;
            for(Zuora__Subscription__c zSub: zSubList)
            {
                zSub.Name = 'NUM124';
                zSub.Subscription_Type__c = 'Full Prepaid';
                zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Account__c = acc.id;
                zSub.Zuora__Status__c = 'Active';
                //zSub.Order_Line_Item_Number__c = orderLineItem.id;
                //zSub.Order_Line_Item_Number_1__c = orderLineItem.id;
                zSub.Recipient_Contact__c = con.id;
                zSub.Order_Number_1__c= order.id;
                zSub.Order_Number__c = order.id;
                zSub.Zuora__SubscriptionStartDate__c = date.today()-10;
                zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
                zSub.Zuora__AutoRenew__c = False;
                zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                zSub.Number_of_Copies__c=100;
                zSub.Number_of_Copies1__c =  '100';
                zSub.Qty__c = 20;
                zSub.Zuora__Version__c = 1;
                zSub.Addon_Package_1__c = pack.id;
                zSub.Billing_Type__c = 'Full Prepaid';
                zSub.Delivered_By_1__c = 'Vendor';
                zSub.Delivered_By__c = 'Vendor';
                zSub.Main_Package_1__c = pack.id;
                zSub.Main_Package__c = pack.id;
                zSub.Promotion_1__c = promotionList[0].id;
                zSub.Promotion__c = promotionList[0].id;
                zSub.Subscriber_Contact__c = con.id;
                zSub.Vendor_1__c = acc.id;
                zSub.Vendor_Subscription_To_Convert_1__c = SubVen[0].id;
                zSub.Legacy_Subscription_ID__c = 'AD1234'; 
                zSub.Term_Length__c = 1;
                zSub.Term_Length1__c = '1';
                i++;
            }
            
            test.startTest();
            insert(zSubList);
            zSubList[0].Legacy_Subscription_ID__c += '5'; 
            database.update(zSubList[0], false);
            system.debug('>>>>> ' + zSubList[0].Legacy_Subscription_ID__c);
            //System.assertEquals(zSubList[1].Zuora__Account__c , null);
            
            order.Base_Subscription__c = zSubList[0].Id;
            update order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            orderLineItem.Start_Date__c = ((date.today()-10).addMonths(1));
            insert orderLineItem;            
            
            //System.assert(1,2);
            /*
            for(Zuora__Subscription__c zSubUpdate: zSubList){
                zSubUpdate.Zuora__Status__c = 'Cancelled';
                
            }*/
            //database.update(zSubList);
            //database.update(zSubList[0]);
            
            //Zuora__Subscription__c zSubRec = TestDataFactory.createSubscription(1)[0];
            //zSubRec.Zuora__Version__c = 2;
            //insert zSubRec;
                        
            MigrationNewSubscriptionTriggerHandler testInstance = new MigrationNewSubscriptionTriggerHandler();
            
            //testInstance.runBeforeInsertTrigger();
            //testInstance.runBeforeUpdateTrigger();
            //testInstance.runBeforeDeleteTrigger();
            //testInstance.runAfterInsertTrigger();
            //testInstance.runAfterUpdateTrigger();
            //testInstance.runAfterDeleteTrigger();
            /*
            testInstance.bulkBefore();       
            testInstance.beforeInsert(zSubList[0]);
            testInstance.beforeUpdate(zSubList[0], zSubList[0]);
            testInstance.beforeDelete(zSubList[0]);
            testInstance.afterInsert(zSubList[0]);
            */
        
            //testInstance.afterDeleteafterDelete(zSubList[0]);
            /*try{
                testInstance.bulkAfter();
            }catch(Exception e){}           
                    
            try{
                testInstance.afterUpdate(zSubList[0], zSubList[1]);
            }catch(Exception e){}
            try{
                testInstance.andFinally();
            }catch(Exception e){}
            */
            

             
            test.stopTest();
    
    }
    
    static testMethod void test1(){
        
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardOP43@test.com'
        );
        
        System.runAs(u){
            //Create Account
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'Test Account';
            insert acc;
            
            //Create Contact   
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acc.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Grace Period';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '1';
            pack.Effective_Start_Date__c = Date.today();
            pack.Effective_End_Date__c = Date.today().addDays(5);
            insert pack;
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            zProd.ProductPlatform__c = 'All-In-One';
            zProd.zqu__SKU__c = 'PRODUCT RATE PLAN';
            insert zProd;
            
            List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
            for(zqu__ProductRatePlan__c prp: prps)
            {     
                prp.Name = 'PRODUCT RATE PLAN';   
                prp.zqu__ZProduct__c = zProd.Id;
                prp.SubscriptionFrequency__c = '1';
                prp.RatePlanType__c = 'Proration';
                prp.RatePlanSubType__c = 'Standard';
                prp.zqu__Deleted__c = false;
            }
            insert prps;        
            
            Product_Family__c prodFam = new Product_Family__c();
            prodFam.Product_Family__c = 'Sample Family';
            insert prodFam;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.Id;
            packItem.Product_Rate_Plan__c = prps[0].Id;
            packItem.Product_Family__c = prodFam.id;
            insert packItem;   
            
            Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
            bill.Zuora__Account__c = acc.Id;
            insert bill; 
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.id;
            order.Delivery_Charge__c = 20; 
            order.Recipient_Contact__c = con.id;
            order.Subscriber_Charge__c = 15;
            insert order;
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Earliest_Start_Date__c = Date.today();
            oli.Start_Date__c = Date.today()+7;
            oli.Order__c = Order.id;
            oli.Main_Package_Period__c = 2;
            oli.Qty__c = 3;
            oli.Term_Length__c = 5;
            oli.Main_Package_ID__c = Pack.id;  
            oli.Main_Package_Frequency__c = 'Default';
            insert oli;
            
            List <Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(1);
            //Zuora__Subscription__c Subs = new Zuora__Subscription__c();
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Name= 'CS0000000110';
            zSubs[0].Number_of_Copies__c= 10;
            zSubs[0].Zuora__CustomerAccount__c = bill.id;
            zSubs[0].Next_Earliest_Start_Date__c= date.today();
            zSubs[0].Unique_Address_Id__c= 'asdasdasd';
            zSubs[0].Year_to_Date_Temp_Stop_Days__c= 2;
            zSubs[0].Previous_Year_Temp_Stop_Days__c= 2;
            zSubs[0].Legacy_Create_Date__c='2014-08-07';
            zSubs[0].Legacy_Create_By__c='test';
            zSubs[0].Legacy_Update_Date__c='test';
            zSubs[0].Legacy_Update_By__c='test';
            zSubs[0].Legacy_Subscription_ID__c='test';
            zSubs[0].Cheque_details__c='test';
            zSubs[0].DTL__c='test';
            zSubs[0].Paypal_Payment_Profile_Id__c='test';
            zSubs[0].Pub_Tag__c='test';
            zSubs[0].Subscribe_As__c='test';
            zSubs[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            zSubs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(2);
            zSubs[0].Subscription_Grace_Period_End_Date__c= 'test';
            zSubs[0].Gift_ID__c= 'test';
            zSubs[0].Redeem_Date__c= 'test';
            zSubs[0].Gift_ID_2__c= 'test';
            zSubs[0].Redeem_Date_2__c= 'test';
            zSubs[0].Subscriber_Contact__c= con.Id;
            zSubs[0].Recipient_Contact__c= con.Id;
            zSubs[0].Subscription_Charge__c= 223.0;
            zSubs[0].Term_Length__c= 2;
            zSubs[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
            zSubs[0].Main_Package__c = pack.id;
            zSubs[0].Main_Package_1__c = pack.id;
            zSubs[0].Billing_Type__c = 'Recurring Prepaid';
            zSubs[0].Delivered_By_1__c = 'Mailing Agent';
            zSubs[0].Order_Line_Item_Number__c =  oli.id; 
            zSubs[0].Order_Line_Item_Number_1__c =  oli.id;
            //zSubs.add(Subs);
            insert zSubs;
        }
    
        Test.startTest();
        MigrationNewSubscriptionTriggerHandler pmth = new MigrationNewSubscriptionTriggerHandler();
        pmth.runBeforeInsertTrigger();
        pmth.runBeforeUpdateTrigger();
        pmth.runBeforeDeleteTrigger();
        pmth.runAfterInsertTrigger();
        pmth.runAfterUpdateTrigger();
        pmth.runAfterDeleteTrigger();
        Test.stopTest();
    }
}