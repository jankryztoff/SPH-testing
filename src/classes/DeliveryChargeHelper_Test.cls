/**
 * Class Name: <DeliveryChargeHelper_Test>
 * @author: <Jensar Joey Sayson>
 * Date: <7/7/2-15>
 * Requirement/Project Name: <SPH>
 * @description: Test Class for DeliveryChargeHelper
 */

@isTest(seeAllData=true)
global class DeliveryChargeHelper_Test
{
    /*
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createMASS_CONFIG();
        insert CustomSettingsDataFactory.createError_Messages();
    }
    */
    
    //global variables
    static Map<String, SObject> sObjectMap;
    static Map<String, List<SObject>> sObjectListMap;
    static Set<Id> idSet;
    
    //isHigherInHierarchyTest
    @isTest
    static void test01(){
        
        setAllData();
        
        Zuora__Subscription__c zSubs1 = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c0');
        Zuora__Subscription__c zSubs2 = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c1');
        Zuora__Subscription__c zSubs3 = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c2');                    
        Zuora__Subscription__c zSubs4 = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c3');
        
        Test.startTest();
        
            System.assertEquals(false, DeliveryChargeHelper.isHigherInHierarchy(zSubs1, zSubs2));
            System.assertEquals(true, DeliveryChargeHelper.isHigherInHierarchy(zSubs3, zSubs2));
            System.assertEquals(false, DeliveryChargeHelper.isHigherInHierarchy(zSubs3, zSubs3));
            System.assertEquals(false, DeliveryChargeHelper.isHigherInHierarchy(zSubs2, zSubs3));   
        
        Test.stopTest();
    }
    
    //isSubOnContractTest
    @isTest
    static void test02() {

        setAllData();
        
        Zuora__Subscription__c zSubs1 = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c0');
        Zuora__Subscription__c zSubs2 = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c1');   
        
        Test.startTest();
        
            //sub with Billing_Type__c = 'Recurring Prepaid';
            System.assertNotEquals(null, DeliveryChargeHelper.isSubOnContract(zSubs1));
            //sub with Billing_Type__c = 'Recurring Postpaid';
            System.assertNotEquals(null, DeliveryChargeHelper.isSubOnContract(zSubs2));
        
        Test.stopTest();
    }
    
    //createCoverPriceAmendmentReqsTest

    /**
     * Class Name: DeliveryChargeHelper_Test
     * @author : Accenture PH : Aduan, Juan Carlos
     * Date Modified: 11 May 2016
     * Requirement/Project Name: SPH Project
     * @description Test Class for DeliveryChargeHelper
     * 
*/

    @isTest
    static void test03() {
        
        setAllData();
        
        List<Zuora__Subscription__c> zSubsList1 = (List <Zuora__Subscription__c>) sObjectListMap.get('Zuora__SubscriptionList__c0');
        System.debug('zSubsList1: ' + zSubsList1);
        
        List<Zuora__SubscriptionProductCharge__c> zSubsList2 = [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__RatePlanName__c,  
                                                                Zuora__RatePlanId__c, Zuora__ProductSKU__c, Zuora__Subscription__c, 
                                                                Zuora__Model__c, Zuora__Quantity__c, 
                                                                Zuora__EffectiveStartDate__c, Zuora__Price__c 
                                                                FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c in : zSubsList1];
        System.debug('zSubsList2 size: ' + zSubsList2.size());
        System.debug('zSubsList2: ' + zSubsList2);
            
        
        Test.startTest();
        
            System.assertNotEquals(null, DeliveryChargeHelper.createCoverPriceAmendmentReqs(zSubsList1, System.today()));
            DeliveryChargeHelper.createAmendOption();
            DeliveryChargeHelper.createPreviewOption();
            //
        Test.stopTest();
    }
    
    //updateDelSubsActiveFlagTest
    @isTest
    static void test04() {
        
        setAllData();
        
        System.debug('updateDelSubsActiveFlagTest: start ');
        /*
        Zuora__Subscription__c zSubs2 = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c2');
        for(Zuora__Subscription__c sub: [SELECT Id, Name, Subscription_Type_1__c, Is_Active__c, Billing_Type__c, 
                        Recipient_Contact__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Contract_End_Date_1__c
                        FROM Zuora__Subscription__c WHERE Id =: zSubs2.Id])
        {
            System.debug('sub: >>> ' + sub);
            System.debug('sub.Subscription_Type_1__c: ' + sub.Subscription_Type_1__c);
            System.debug('sub.Billing_Type__c: ' + sub.Billing_Type__c);
            System.debug('sub.Zuora__SubscriptionEndDate__c: ' + sub.Zuora__SubscriptionEndDate__c);
        }
        
        System.debug('idSet: >>> ' + idSet);
        */
        Test.startTest();
        
            DeliveryChargeHelper.updateDelSubsActiveFlag(idSet);
            //System.assertNotEquals(null, DeliveryChargeHelper.updateDelSubsActiveFlag(idSet));
            //DeliveryChargeHelper.createAmendOption();
            //DeliveryChargeHelper.createPreviewOption();
        
        Test.stopTest();
    }
    
    //updateAllSubsActiveFlagTest
    @isTest
    static void test05() {

        setAllData();
        System.debug('updateAllSubsActiveFlagTest: start ');

        Test.startTest();
        
             DeliveryChargeHelper.updateAllSubsActiveFlag(idSet, System.today());
            //System.assertNotEquals(null, DeliveryChargeHelper.updateDelSubsActiveFlag(idSet));
            //DeliveryChargeHelper.createAmendOption();
            //DeliveryChargeHelper.createPreviewOption();
         
        Test.stopTest();
    }
    
    //createCODCAmendmentReqsTest1
    @isTest
    static void test06(){
        
        setAllData();
        
        List<Zuora__Subscription__c> zSubsList1 = (List <Zuora__Subscription__c>) sObjectListMap.get('Zuora__SubscriptionList__c0');
        System.debug('zSubsList1: ' + zSubsList1);
        Zuora__SubscriptionProductCharge__c zSubProCharge1 = (Zuora__SubscriptionProductCharge__c) sobjectMap.get('zSubProCharge1');
        zqu__ProductRatePlan__c  zSProdRatePlan = (zqu__ProductRatePlan__c) sobjectMap.get('prp');
        Test.startTest();
        
            //DeliveryChargeHelper.createCODCAmendmentReqs(zSubsList1, zSubProCharge1.Zuora__RatePlanId__c);
            System.assertNotEquals(null, DeliveryChargeHelper.createCODCAmendmentReqs(zSubsList1, zSubProCharge1.Zuora__RatePlanId__c));
            System.assertNotEquals(null, DeliveryChargeHelper.createCODCAmendmentReqs(zSubsList1, zSProdRatePlan.Id));
            //System.assertNotEquals(null, DeliveryChargeHelper.updateDelSubsActiveFlag(idSet));
            //DeliveryChargeHelper.createAmendOption();
            //DeliveryChargeHelper.createPreviewOption();
            
        Test.stopTest();
    }
    
    //createCODCAmendmentReqsTest2
    @isTest
    static void test07() {

        setAllData();
        
        List<Zuora__Subscription__c> zSubsList1 = (List <Zuora__Subscription__c>) sObjectListMap.get('Zuora__SubscriptionList__c0');
        System.debug('zSubsList1: ' + zSubsList1);
        Zuora__SubscriptionProductCharge__c zSubProCharge1 = (Zuora__SubscriptionProductCharge__c) sobjectMap.get('zSubProCharge1');
        
        Test.startTest();
                        
            //DeliveryChargeHelper.createCODCAmendmentReqs(zSubsList1, 'RatePlanName', 'RatePlanName');
            System.assertNotEquals(null, DeliveryChargeHelper.createCODCAmendmentReqs(zSubsList1, 'RatePlanName', 'RatePlanName'));
            //System.assertNotEquals(null, DeliveryChargeHelper.updateDelSubsActiveFlag(idSet));
            //DeliveryChargeHelper.createAmendOption();
            //DeliveryChargeHelper.createPreviewOption();
           
        Test.stopTest();
    }
    
    //sets all prerequisite data    
    static void setAllData(){
        
        sObjectMap = null;
        sObjectListMap = null;
        sObjectMap = new Map<String, SObject>();
        sObjectListMap = new Map<String, List<SObject>>();
        
        Account acc = new Account(Name = 'Test Account', Email__c = 'testcrsm@sph.crsm',
                      RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'));
        sObjectMap.put('Account', acc);
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        sObjectMap.put('Singpost_Address__c', postal);
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        sObjectMap.put('Address__c', addressRec);
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Phone = '1234567';
        con.Address__c = addressRec.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        sObjectMap.put('Contact', con);
        insert con;
 
        Package__c pkg = TestDataFactory.createPackage(1)[0];
        pkg.Subscription_Period__c = '15';            
        sObjectMap.put('Package__c', pkg);
        insert pkg;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con.Id;
        order.Informed_Customer__c = True;
        order.Subscriber_charge__c = 100;
        sObjectMap.put('Order__c', order);
        insert order; 
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0]; 
        oli.Order__c = order.Id; 
        oli.Main_Package_ID__c = pkg.id; 
        sObjectMap.put('Order_Line_Item__c', oli);

        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = acc.id; 
        sObjectMap.put('Zuora__CustomerAccount__c ', defaultPayment);
        insert defaultPayment; 
        
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        //zSub.Subscription_Type__c
        
        List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(4);
        zSubs[0].Zuora__Account__c = acc.id;
        zSubs[0].Order_Line_Item_Number__c = oli.Id;
        zSubs[0].Order_Number__c = order.Id;
        zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
        zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
        zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs[0].Urgent__c = 'false';
        zSubs[0].Vendor_Conversion__c = 'false';
        zSubs[0].Charity__c = 'false';
        zSubs[0].Acquisition_Type__c = 'TEST';            
        zSubs[0].Legacy_Create_Date__c = String.valueof(system.today());
        zSubs[0].Legacy_Create_By__c = 'abcde';
        zSubs[0].Legacy_Update_Date__c = String.valueof(system.today());
        zSubs[0].Legacy_Update_By__c = 'abcde';
        zSubs[0].Legacy_Subscription_ID__c ='abcde'; 
        zSubs[0].Zuora__CustomerAccount__c = defaultPayment.Id;
        zSubs[0].Sponsor_1__c = true;
        zSubs[0].Name = 'Subscription 1';
        zSubs[0].Main_Package_1__c = pkg.id;
        zSubs[0].Billing_Type__c = 'Recurring Prepaid';
        zSubs[0].Contract_End_Date_1__c = date.today()+30;//
        
                
        zSubs[1].Zuora__Account__c = acc.id;
        zSubs[1].Order_Line_Item_Number__c = oli.Id;
        zSubs[1].Order_Number__c = order.Id;
        zSubs[1].Subscriber_Contact__c = con.Id;
        zSubs[1].Recipient_Contact__c = con.Id;
        zSubs[1].Main_Package_1__c = pkg.id;
        zSubs[1].Suppress_Vendor_Start_Notice__c = 'false';
        zSubs[1].Supressed_Acknowledgement_Letter__c = 'false';
        zSubs[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs[1].Urgent__c = 'false';
        zSubs[1].Vendor_Conversion__c = 'false';
        zSubs[1].Charity__c = 'false';
        zSubs[1].Legacy_Create_Date__c = String.valueof(system.today());
        zSubs[1].Legacy_Create_By__c = 'abcde';
        zSubs[1].Legacy_Update_Date__c = String.valueof(system.today());
        zSubs[1].Legacy_Update_By__c = 'abcde';
        zSubs[1].Legacy_Subscription_ID__c ='abcde'; 
        zSubs[1].Zuora__CustomerAccount__c = defaultPayment.Id;
        zSubs[1].Sponsor_1__c = true;
        zSubs[1].Name = 'Subscription 2';
        zSubs[1].Billing_Type__c = 'Recurring Postpaid';
        zSubs[1].Contract_End_Date_1__c = date.today()+30;//
                
        zSubs[2].Zuora__Account__c = acc.id;
        zSubs[2].Order_Line_Item_Number__c = oli.Id;
        zSubs[2].Order_Number__c = order.Id;
        zSubs[2].Subscriber_Contact__c = con.Id;
        zSubs[2].Recipient_Contact__c = con.Id;
        zSubs[2].Main_Package_1__c = pkg.id;
        zSubs[2].Suppress_Vendor_Start_Notice__c = 'false';
        zSubs[2].Supressed_Acknowledgement_Letter__c = 'false';
        zSubs[2].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs[2].Urgent__c = 'false';
        zSubs[2].Vendor_Conversion__c = 'false';
        zSubs[2].Charity__c = 'false';
        zSubs[2].Legacy_Create_Date__c = String.valueof(system.today());
        zSubs[2].Legacy_Create_By__c = 'abcde';
        zSubs[2].Legacy_Update_Date__c = String.valueof(system.today());
        zSubs[2].Legacy_Update_By__c = 'abcde';
        zSubs[2].Legacy_Subscription_ID__c ='abcde'; 
        zSubs[2].Zuora__CustomerAccount__c = defaultPayment.Id;
        zSubs[2].Sponsor_1__c = true;
        zSubs[2].Name = 'Subscription 2';
        zSubs[2].Billing_Type__c = 'Full Prepaid';
        //zSubs[2].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
        //zSubs[2].Subscription_Type_1__c = 'Delivery';
        zSubs[2].Subscription_Type__c = 'Delivery';
        zSubs[2].Subscription_End_Date__c = String.valueof(system.today());
        zSubs[2].Contract_End_Date_1__c = date.today()+30;//
        
        zSubs[3].Zuora__Account__c = acc.id;
        zSubs[3].Order_Line_Item_Number__c = oli.Id;
        zSubs[3].Order_Number__c = order.Id;
        zSubs[3].Subscriber_Contact__c = con.Id;
        zSubs[3].Recipient_Contact__c = con.Id;
        zSubs[3].Main_Package_1__c = pkg.id;
        zSubs[3].Suppress_Vendor_Start_Notice__c = 'false';
        zSubs[3].Supressed_Acknowledgement_Letter__c = 'false';
        zSubs[3].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs[3].Urgent__c = 'false';
        zSubs[3].Vendor_Conversion__c = 'false';
        zSubs[3].Charity__c = 'false';
        zSubs[3].Legacy_Create_Date__c = String.valueof(system.today());
        zSubs[3].Legacy_Create_By__c = 'abcde';
        zSubs[3].Legacy_Update_Date__c = String.valueof(system.today());
        zSubs[3].Legacy_Update_By__c = 'abcde';
        zSubs[3].Legacy_Subscription_ID__c ='abcde'; 
        zSubs[3].Zuora__CustomerAccount__c = defaultPayment.Id;
        zSubs[3].Sponsor_1__c = true;
        zSubs[3].Name = 'Subscription 3';
        zSubs[3].Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
        zSubs[3].Subscription_Type__c = 'Delivery';
        zSubs[3].Subscription_End_Date__c = String.valueof(system.today());
        zSubs[3].Is_Active__c = true;
        zSubs[3].Contract_End_Date_1__c = date.today()+30;//
        
        sObjectListMap.put('Zuora__SubscriptionList__c0', zSubs);     
        sObjectMap.put('Zuora__Subscription__c0', zSubs[0]);
        sObjectMap.put('Zuora__Subscription__c1', zSubs[1]);
        sObjectMap.put('Zuora__Subscription__c2', zSubs[2]);
        sObjectMap.put('Zuora__Subscription__c3', zSubs[3]);
        insert zSubs;   
        
        //================================
        Zuora__SubscriptionProductCharge__c zSubProCharge1 = TestDataFactory.createSubscriptionProductCharge(1)[0];
        zSubProCharge1.Name = 'test';
        zSubProCharge1.Zuora__Zuora_Id__c = '1123';
        zSubProCharge1.Zuora__RatePlanName__c = 'RatePlanName';
        //zSubProCharge1.Zuora__RatePlanId__c = '2311';
        //001N000000IAQpzIAH
        zSubProCharge1.Zuora__RatePlanId__c = '001N000000IAQpzAAA';        
        zSubProCharge1.Zuora__ProductSKU__c = 'ProductSKU';
        zSubProCharge1.Zuora__Subscription__c = zSubs[0].Id;
        zSubProCharge1.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
        zSubProCharge1.Zuora__EffectiveStartDate__c = System.today() + 1;
        zSubProCharge1.Zuora__Price__c = 1000;
        insert zSubProCharge1;
        sObjectMap.put('zSubProCharge1', zSubProCharge1);
        
        Zuora__SubscriptionProductCharge__c zSubProCharge2 = TestDataFactory.createSubscriptionProductCharge(1)[0];
        //zSubProCharge2.Name = 'test';
        zSubProCharge2.Zuora__Zuora_Id__c = '1124';
        zSubProCharge2.Zuora__RatePlanName__c = 'RatePlanName';
        //zSubProCharge2.Zuora__RatePlanId__c = '2411';
        zSubProCharge2.Zuora__RatePlanId__c = '001N000000IAQpzBBB';
        zSubProCharge2.Zuora__ProductSKU__c = 'ProductSKU';
        zSubProCharge2.Zuora__Subscription__c = zSubs[0].Id;
        zSubProCharge2.Zuora__Model__c = 'Model';
        zSubProCharge2.Zuora__EffectiveStartDate__c = System.today() + 1;
        zSubProCharge2.Zuora__Price__c = 1000;
        insert zSubProCharge2;
        sObjectMap.put('zSubProCharge2', zSubProCharge2);

        Zuora__SubscriptionProductCharge__c zSubProCharge3 = TestDataFactory.createSubscriptionProductCharge(1)[0];
        //zSubProCharge2.Name = 'test';
        zSubProCharge3.Zuora__Zuora_Id__c = '1125';
        zSubProCharge3.Zuora__RatePlanName__c = 'RatePlanName';
        //zSubProCharge2.Zuora__RatePlanId__c = '2411';
        zSubProCharge3.Zuora__RatePlanId__c = '001N000000IAQpzBBB';
        zSubProCharge3.Zuora__ProductSKU__c = 'ProductSKU';
        zSubProCharge3.Zuora__Subscription__c = zSubs[0].Id;
        zSubProCharge3.Zuora__Model__c = 'Model';
        zSubProCharge3.Zuora__EffectiveStartDate__c = System.today() + 1;
        zSubProCharge3.Zuora__Price__c = 1000;
        insert zSubProCharge3;
        sObjectMap.put('zSubProCharge3', zSubProCharge3);

        Zuora__SubscriptionProductCharge__c zSubProCharge4 = TestDataFactory.createSubscriptionProductCharge(1)[0];
        //zSubProCharge2.Name = 'test';
        zSubProCharge4.Zuora__Zuora_Id__c = '1126';
        zSubProCharge4.Zuora__RatePlanName__c = 'RatePlanName';
        //zSubProCharge2.Zuora__RatePlanId__c = '2411';
        zSubProCharge4.Zuora__RatePlanId__c = '001N000000IAQpzBBB';
        zSubProCharge4.Zuora__ProductSKU__c = 'ProductSKU';
        zSubProCharge4.Zuora__Subscription__c = zSubs[1].Id;
        zSubProCharge4.Zuora__Model__c = 'Model';
        zSubProCharge4.Zuora__EffectiveStartDate__c = System.today() + 1;
        zSubProCharge4.Zuora__Price__c = 1000;
        zSubProCharge4.Product_Code__c = 'DISC';
        insert zSubProCharge4;
        sObjectMap.put('zSubProCharge4', zSubProCharge4);
        
        //GlobalVariableClass.SPC_MODEL_DISCOUNT
        //================================
        
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        insert zProd;
        //zProd.Name = 'testzProduct';
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zProd.Id;
        insert prp;
        sObjectMap.put('prp', prp);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.Name = zSubProCharge1.Name;
        prpc.zqu__ZuoraId__c = '123123';
        prpc.zqu__UOM__c = 'UOM';
        prpc.zqu__Type__c = 'One-Time';
        //prpc.sum__c = 1010;
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.zqu__Deleted__c = false;
        insert prpc;
        sObjectMap.put('prpc', prpc);
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Name = 'test';
        ili.Invoice_ID__c = 'test2';
        ili.Subscription__c = zSubs[0].id;
        ili.Charge_Amount__c = 1.2;
        insert ili; //

        Invoice_Line_Item__c ili2 = new Invoice_Line_Item__c();
        ili2.Name = 'test1';
        ili2.Invoice_ID__c = 'test3';
        ili2.Subscription__c = zSubs[0].id;
        ili2.Charge_Amount__c = 1.2;
        insert ili2; //
        
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'test';
        inv.Zuora__InvoiceDate__c = date.today();
        inv.Zuora__TargetDate__c =  date.today()+5;
        inv.Zuora__Zuora_Id__c = 'test2';
        insert inv;
        
        idSet = new Set<Id>();
        idSet.add(con.Id);
    }
}