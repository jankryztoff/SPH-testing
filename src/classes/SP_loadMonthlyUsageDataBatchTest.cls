@isTest

public class SP_loadMonthlyUsageDataBatchTest {
/*
    static testmethod void test() {
    
        //Create a new user with Standard User Profile

        User testUser = new User(
        Alias = 'stndrd',
        Email='standarduser@test.com', 
        EmailEncodingKey='UTF-8',
        LastName='Test',
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
        TimeZoneSidKey='America/Los_Angeles',
        UserName='standard@test.com'
        );

        
        //The test will run as the user created.
        System.runAs(testUser) { 
        
        Account acct = new Account();
        Zuora__CustomerAccount__c billingAcc = new Zuora__CustomerAccount__c();
        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        Contact con = new Contact();
        zqu__ZUnitOfMeasure__c uom = new zqu__ZUnitOfMeasure__c();
                        
        //create vendor subscriber acct
        acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acct.Name = 'Test Account 1';
        insert acct;
        
        //create billing acct
        billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        insert billingAcc;
        
        //create contact
        con = TestDataFactory.createContact(1)[0];
        con.AccountId = acct.Id;
        insert con;
        
        //create order
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acct.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con.Id;
        insert orderRec;
        
        //create case                
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orderRec.Id;
               
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        insert pack;
        
        //create subscription
        subs = TestDataFactory.createSubscription(1)[0];
        subs.Name = 'Test Subs-000001';
        subs.Zuora__Account__c = acct.Id;
        subs.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
        subs.Subscriber_Contact__c = con.Id;
        subs.Recipient_Contact__c = con.Id;
        subs.Main_Package_1__c = pack.id;
        subs.Zuora__Status__c = 'Active';
        subs.Order_Number__c = orderRec.Id;
        subs.Suppress_Vendor_Start_Notice__c = 'false';
        subs.Supressed_Acknowledgement_Letter__c = 'false';
        subs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subs.Urgent__c = 'false';
        subs.Vendor_Conversion__c = 'false';
        subs.Charity__c = 'false';
        subs.Billing_Type__c = 'Full Prepaid';
        insert subs;//
        
        //create subscription
        List <Zuora__Subscription__c> subsList = new List <Zuora__Subscription__c>();
        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        subs.Name = 'Test Subs-000001';
        subs.Zuora__Account__c = acct.Id;
        subs.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
        subs.Subscriber_Contact__c = con.Id;
        subs.Recipient_Contact__c = con.Id;
        subs.Main_Package_1__c = pack.id;
        subs.Zuora__Status__c = 'Active';
        subs.Order_Number__c = orderRec.Id;
        subs.Suppress_Vendor_Start_Notice__c = 'false';
        subs.Supressed_Acknowledgement_Letter__c = 'false';
        subs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subs.Urgent__c = 'false';
        subs.Vendor_Conversion__c = 'false';
        subs.Charity__c = 'false';
        subs.Billing_Type__c = 'Full Prepaid';
        subslist.add(subs);
        insert subslist;
        
        //create Singpost_Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //insert address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        //create case subscription
        Case_Subscription__c casesub = TestDataFactory.createCaseSubscription(1)[0];
        casesub.Subscription__c = subs.Id;
        casesub.Account__c = acct.id;
        casesub.Address__c = addressRec.id;
        insert casesub;
         
        //insert uom
        uom = TestDataFactory.createZUnitOfMeasure(1)[0];
        uom.Name = 'Test ZUnitOfMeasure';
        uom.zqu__Active__c = True;
        uom.zqu__Uom_precision__c = 2;
        uom.zqu__Uom_rounding_mode__c = 'Up';
        insert uom;
        
        //create usage
        Usage__c usage = new Usage__c(
            Unit_of_Measure__c = uom.Id,
            Quantity__c = 10,
            Start_Date__c = date.today(), 
            Account_Id__c = acct.id,
            Subscription_Id__c = subs.id,
            Status__c = 'New',
            Rate_Plan_Charge_Id__c = 'Sample_Rate_Plan_Charge_Id',
            Send_to_Zuora_Time__c = datetime.now()
            );
        Insert usage;
                    
       Test.startTest();
       SP_loadMonthlyUsageDataBatch batch = new SP_loadMonthlyUsageDataBatch();
       ID batchprocessid = Database.executeBatch(batch, 200);
       Test.stopTest(); 
         } //end user


    }// end of testmethod test1 
*/
    
    static testmethod void test2() {
        
            //Create a new user with Standard User Profile
            User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //System.runAs(testUser) {
            
             //create Singpost_Address
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            //create Account
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
            //create Package
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject>{postal, acc, pack};
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-00000072';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '1';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.Name = 'Name';
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
          
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;              
            // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            //insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            //orderRec.Recipient_Contact__c = con.Id;
            //insert orderRec;
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                //subRec.Subscriber_Contact__c = con.Id;
                //subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            //insert new List<sObject>{cas, subrecs[0], subrecs[1], subrecs[2], subrecs[3], orderline};

            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = System.today(),
                    Restart_Date__c = System.today()
                )
            };
            //insert tempStops;
            
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subRecs[0].Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            //insert subTempStops;

           
            //insert  ZUnitOfMeasure
            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test2';
            insert zUOM;            

            List<Zuora__SubscriptionProductCharge__c> spcList = TestDataFactory.createSubProductCharge(1);
            
            
       Test.startTest();
       SP_loadMonthlyUsageDataBatch batch = new SP_loadMonthlyUsageDataBatch();
       ID batchprocessid = Database.executeBatch(batch, 200);
       Test.stopTest(); 
       
       //}
    }//end of testmethod test2
    
}//end of SP_loadMonthlyUsageDataBatchTest