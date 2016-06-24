@isTest (seeAllData= False)
public class PromotionEligibilityRuleTest {

        @testSetup static void methodName() {
            // Populate needed Custom Settings
            insert(CustomSettingsDataFactory.createKey_Id());
            insert(CustomSettingsDataFactory.createOther());
            insert(CustomSettingsDataFactory.createError_Messages());
        } 

        static testMethod void testPromoEligibility2(){
        
        //Create a new user with Standard User Profile
            User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardPHwe23@test.com'
            );

        //The test will run as the user created.
        System.runAs(u) {
        
            Account acct = new Account();
            List<Zuora__CustomerAccount__c> billingAcc = new List<Zuora__CustomerAccount__c>();
            Singpost_Address__c singpostAdd = new Singpost_Address__c();
            Address__c add = new Address__c();
            List<Contact> con = new List<Contact>();
            List<Order__c> order = new List<Order__c>();
            Subscription_Vendor__c subsVen = new Subscription_Vendor__c();
            List<Package__c> pack = new List<Package__c>();
            
            List<Order_Line_Item__c> oli = new List<Order_Line_Item__c>();
            //Account venAccount = new Account();
            //Vendor_Allocation__c venAlloc = new Vendor_Allocation__c();
            Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
            Case cas = new Case();
            
            List<Promotion__c> Promo = TestDataFactory.createPromotion(2);
            Promo[0].Name = 'Test Promo0';
            //Promo[0].Promotion_Code__c = 'TESTx';
            Promo[0].Contract__c='Yes';
            Promo[0].Contract_Period__c = '15';
            Promo[0].Effective_End_Date__c=date.today()+100;
            Promo[0].Effective_Start_Date__c=date.today();
            //Promo.add(Promo[0]);
            
            Promo[1].Name = 'Test Promo1';
            Promo[1].Promotion_Code__c = 'TESTx';
            Promo[1].Contract__c='Yes';
            Promo[1].Contract_Period__c = '20';
            Promo[1].Effective_End_Date__c=date.today()+100;
            Promo[1].Effective_Start_Date__c=date.today().addDays(-3);
            //Promo.add(Promo[1]);
            
            insert Promo;
            
            List<Eligibility_Rule__c> eRule = TestDataFactory.createEligibilityRule(2);
            eRule[0].Contract_Subscription_Rule__c = 'Contract End Date';
            eRule[0].Action__c = 'Add';
            eRule[0].Current_Platform__c = 'Online';
            eRule[0].Condition__c = '>=';
            eRule[0].Contract_Type__c = 'NA';
            eRule[0].Subsciber_Status__c = 'New Subscriber';
            eRule[0].Customer_Status__c = 'New customer';
            eRule[0].Date__c = Date.today();
            eRule[0].Contract_Subscription_Rule__c = 'NA';

            insert eRule;
            //create account
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert acct;
            
            Account Venacct = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert Venacct;
                 
            //create billing acct
            billingAcc = TestDataFactory.createBillingAccount(2);
            billingAcc[0].Zuora__Account__c = acct.Id;
            billingAcc[1].Zuora__Account__c = Venacct.Id;
            billingAcc[0].Billing_Type__c = 'Full Prepaid';
            billingAcc[1].Billing_Type__c = 'Recurring Prepaid';
            insert billingAcc;
            
            //create singpost address
            singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert singpostAdd;
            
            //create address
            add = TestDataFactory.createAddress(1)[0];
            add.Postal_Code__c = singpostAdd.Id;
            insert add;
            
            //create contact
            con = TestDataFactory.createContact(2);
            con[0].AccountId = acct.Id;
            con[0].Recipient_Indicator__c = true;
          
            con[1].AccountId = Venacct.Id;
            con[1].Recipient_Indicator__c = true;
            insert con;

            //Begin Added by Francis to relate atleast one subcription related to newly create Order__c
            List<Zuora__Subscription__c> tmpsubs = new List<Zuora__Subscription__c>();
            tmpsubs = TestDataFactory.createSubscription(1);
            tmpsubs[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            tmpsubs[0].Zuora__CustomerAccount__c = billingAcc[0].Id;
            insert tmpsubs;
            //Begin Added by Francis to relate atleast one subcription related to newly create Order__c
            
            //create order
            order = TestDataFactory.createOrder(2);
            order[0].Account__c = acct.Id;
            order[0].Recipient_Contact__c = con[0].Id;
            order[0].Billing_Account__c = billingAcc[0].Id;
            order[0].Billing_Type__c = billingAcc[0].Billing_Type__c;
            order[0].Informed_Customer__c = True;
            order[0].Subscriber_Charge__c = 900.00;
            order[0].Base_Subscription__c  = tmpsubs[0].id;
            
            order[1].Account__c = Venacct.Id;
            order[1].Recipient_Contact__c = con[1].Id;
            order[1].Billing_Account__c = billingAcc[1].Id;
            order[1].Billing_Type__c = billingAcc[1].Billing_Type__c;
            order[1].Informed_Customer__c = True;
            insert order;
            
            //create case
            cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order[0].Id;
            //insert cas;
            
            //create subscription vendor
            subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert subsVen;
                
            //create package
            pack = TestDataFactory.createPackage(2);
            insert pack;
            
            //create order line item
            oli = TestDataFactory.createOrderLineItem(2);
            oli[0].Order__c = order[0].Id;
            oli[0].Vendor_Subscription_ID__c = subsVen.Id;
            oli[0].Main_Package_ID__c = pack[0].Id;
            
            oli[1].Order__c = order[1].Id;
            oli[1].Vendor_Subscription_ID__c = subsVen.Id;
            oli[1].Main_Package_ID__c = pack[1].Id;
            insert oli;
             
                
            //create subscription
            List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
            subs = TestDataFactory.createSubscription(2);
            subs[0].Zuora__CustomerAccount__c = billingAcc[0].Id;
            subs[0].Zuora__Account__c = acct.Id;
            subs[0].Order_Line_Item_Number__c = oli[0].Id;
            subs[0].Order_Number__c = order[0].Id;
            //subs[0].Order_Number_1__c = order[0].Id;
            subs[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            subs[0].Promotion_1__c = Promo[0].Id;
            //subs[0].Promotion__c = 'Test Promo0';
            subs[0].Contract_End_Date_1__c = date.newInstance(2014, 12, 30);
            subs[0].Legacy_Create_Date__c = 'Date';
            subs[0].Legacy_Create_By__c = 'a';
            subs[0].Legacy_Update_By__c = 'a';
            subs[0].Legacy_Subscription_ID__c = 'a';
            subs[0].Legacy_Update_Date__c = 'a';
            subs[0].Legacy_Update_By__c = 'a';
            subs[0].Legacy_Subscription_ID__c = 'a';
             
            
            subs[1].Zuora__CustomerAccount__c = billingAcc[1].Id;
            subs[1].Zuora__Account__c = Venacct.Id;
            subs[1].Order_Line_Item_Number__c = oli[1].Id;
            subs[1].Order_Number__c = order[0].Id;
            subs[1].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 11, 2);
            subs[1].Promotion_1__c = Promo[1].Id;
            subs[1].Contract_End_Date_1__c = date.newInstance(2014, 12, 30);
            subs[1].Legacy_Create_Date__c = 'Date';
            subs[1].Legacy_Create_By__c = 'a';
            subs[1].Legacy_Update_By__c = 'a';
            subs[1].Legacy_Subscription_ID__c = 'a';
            subs[1].Legacy_Update_Date__c = 'a';
            subs[1].Legacy_Update_By__c = 'a';
            subs[1].Legacy_Subscription_ID__c = 'a';
            
            insert subs;

            
            Set<Id> eligibilityRuleIds = new Set<Id>();
            eligibilityRuleIds.add(eRule[0].Id);
            eligibilityRuleIds.add(eRule[1].Id);
            
            Set<String> promoCodes = new Set<String> ();
            promoCodes.add('TESTx');
            promoCodes.add(Promo[0].Promotion_Code__c);
            promoCodes.add(Promo[1].Promotion_Code__c);
            
            //create Promotion eligibility rule
            List<Promotion_Eligibility_Rule__c> promoEli = TestDataFactory.createPromEligibilityRule(2);
            promoEli[0].Promotion__c = Promo[0].Id;
            promoEli[0].Eligibility_Rule__c = eRule[0].Id;
            promoEli[0].Package_List__c = 'Test package';
            promoEli[0].Product_Family__c = 'ST';
            promoEli[0].Date__c = Date.today();
            
            promoEli[1].Promotion__c = Promo[1].Id;
            promoEli[1].Eligibility_Rule__c = eRule[1].Id;
            promoEli[1].Package_List__c = 'Test package';
            promoEli[1].Product_Family__c = 'ST';
            promoEli[1].Date__c = Date.today().addDays(-2);
            insert promoEli;
                        
            eRule[0].Eligibility_Rule__c = promoEli[0].Id;
            update eRule[0];
             
            
            eRule[1].Eligibility_Rule__c = promoEli[1].Id;
            update eRule[1];
            
           
            Map<String, List<Zuora__Subscription__c>> mapPromocodeSubscription = new Map<String, List<Zuora__Subscription__c>>(); 
            Map<Id, Eligibility_Rule__c> eRuleMap = new Map<Id, Eligibility_Rule__c>();
            Map<String, List<Eligibility_Rule__c>> mapPromoCodeEligRule = new Map<String, List<Eligibility_Rule__c>>();

            
            eRuleMap.put(eRule[0].Id,eRule[0]);
            //mapPromocodeSubscription.put('TESTx', subs);
            //system.assert(eligibilityRuleIds.contains(eRule[0].Id));
            //system.assert(eRuleMap.contains(eRule[0].Id,eRule[0]));
            //system.assertEquals(set<string>, promoCodes);
            
            Test.startTest();
            
            PromotionEligibilityRule.getEligibility(acct.Id, eRule[0].Action__c, promoCodes, pack[0].Package_Code__c, subs[0].Id );
            PromotionEligibilityRule.getEligibility(Venacct.Id, eRule[1].Action__c, promoCodes, pack[1].Package_Code__c, subs[1].Id );
//            PromotionEligibilityRule.getPackageEligibility(Promo[0].Promotion_Code__c, pack[0].Name, Date.today());
            Test.stopTest();
            
    
        }
    }   

}