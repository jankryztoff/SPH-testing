/**********************************************************************/
/* Class Name:  RenewalControllerTest
/* Author: Marie Kristine Munda 
/* Description: A test class for RenewalController
/* Updated By: Rom Edison Reyes 
/* Date Last Modified: 02/10/2015
/**********************************************************************/
@isTest
private class RenewalControllerTest {
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createPlannerSched(); 
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createRenewal_Notifications(); 
    }  
    
     static testmethod void magazineRenewal() {
    
        /****************************** Test Data Creation ******************************/
        /*   Insert code statements that inserts Data                                   */
        /*   needed by Base Class.                                                      */
        /*   e.g. Base Class Queries Account with                                       */
        /*        Record Type = Direct.                                                 */
        /*                                                                              */
        /*        List<Account> accList = TestDataFactory.createAccount('Direct',5);    */
        /*         Insert accList;                                                      */
        /********************************************************************************/
        
        Manual_Batch_Run_Dates__c mbrDate = new Manual_Batch_Run_Dates__c();
        mbrDate.Name = 'ManualBatchRun';
        mbrDate.Batch_Run_Date__c = Date.Today();
        database.insert(mbrDate);
        
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Subscription_Period_1__c = '3';
        pack.Subscription_Period__c = '3';
        pack.Same_Pck_Renewal_Mag_1_Yr_Base__c = true;
        pack.Same_Pck_Renewal_Mag_1_Yr_Disc__c = true;
        pack.Same_Pck_Renewal_Mag_2_Yr_Base__c = true;
        pack.Same_Pck_Renewal_Mag_2_Yr_Disc__c = true;
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        insert new List<sObject>{venAccount, pack, subsVen};           
    List<RecordType> casrt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Renewal of Subscription'];            
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
            postal.Name = 'Test Postal';
            postal.Building_Name__c = 'Test Building';
            postal.Street_Name__c = 'Test Street';
            insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
        Country__c countr = TestDataFactory.createCountry(1)[0];
            countr.Country_Name__c = 'Test Country';
            insert countr;
                
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            //addressRec.RecordTypeId = '012N00000008idiIAA';
            addressRec.Block_House_Number__c = 'Sample';
            addressRec.Address_Type__c= 'P';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Level_Number__c = 'Ab';
            addressRec.Unit_Number__c = 'ab';
            addressRec.Country__c = countr.Id;
            insert addressRec;        
            
        Contact conList = TestDataFactory.createContact(1)[0];
            conList.LastName = 'Gonzales';
            conList.Address__c = addressRec.Id;
            conList.AccountId = acc.Id;
            conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList.Recipient_Indicator__c = true;
            insert conList;
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = conList.Id;
            insert orderRec;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            cas.recordtypeid = casrt[0].Id;
            insert cas;
            
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.Today() +60;
            orderline.start_date__c = date.Today();
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Case__c = cas.id;
            orderline.Vendor_Mailing_Agent__c = venAccount.Id;
            orderline.Vendor_Subscription_ID__c = subsVen.Id;
            orderline.Start_Date__c = date.today()+1;
            insert orderline;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = '100 YEARS OF ADVENTURE';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Publication_Code__c ='TSSA';
            pub.Publication_Type__c ='M';
            insert pub;

        //START KINGSLEY
        Billing_Batch__c billingBatch = new Billing_Batch__c();
            billingBatch.Next_Batch_Number__c   = 14;
            billingBatch.Batch__c               = '13,14,15';
            billingBatch.Name                   = 'Full Prepaid';
        insert billingBatch;

        //END KINGSLEY
        
        //jurna added    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Billing_Contact__c = conList.Id;
        insert billAcc;
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Order_Number__c = orderRec.Id;
            sub.Contact__c = conList.Id;
            sub.Subscriber_Contact__c = conList.Id;
            sub.Recipient_Contact__c = conList.Id;
            sub.Main_Package_1__c = pack.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Order_Line_Item_Number_1__c = orderline.id;
            sub.Subscription_Type__c = 'Delivery';
            sub.Zuora__SubscriptionStartDate__c = date.today() - 42;
            sub.Term_Length1__c = '6';
            sub.Term_Length__c = 6;
            sub.Zuora__SubscriptionEndDate__c = date.today();          
            sub.Frequency_1__c = 'Mon - Fri';
            sub.Number_of_Copies__c = 3; 
            sub.Number_of_Copies1__c = '3';         
            sub.Zuora__CustomerAccount__c = billAcc.id; //jurna added   
            //insert sub; 
                        
        
        /*************************** Creation of Test User ******************************/
        //User testUser = TestDataFactory.prepareTestusers();
        
        //System.runAs(testUser){
             //This creates a new Heap block Dedicated to your test Run of actual lines in Base Class.
            insert sub;
            
         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(sub.Id);
         letterPrintRequest.Language_Medium__c = 'C';
         Test.startTest();
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Status__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(sub.Id);
         insert letterPrintRequest2;
                         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         //update letterPrintRequest;
          
            PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',letterPrintRequest.id); //add this statement if Base Class contains  "ApexPages.currentPage().getParameters().put"
            RenewalController controller = new RenewalController();
            //try{
               
            //}catch(Exception e){}
            controller.initializeMZ();
            controller.initializeNP();
            ////controller.setFields();
            /*try
            {
                controller.initializeCHNP();
                controller.initializeCHMZ();
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }*/
 
            //karen 04.13.15 compile error fixed
//            controller.initialize();
            
            //System.assertEquals(sub.Contact__r.Address__r.Block_House_Number__c, '');
            //System.assertEquals(sub.Contact__r.Address__r.Block_House_Number__c, 'Sample');
            
            //<Name of Base Class> controller = new <Name of Base Class>(); //FOR CUSTOM CONTROLLERS ONLY
            //<Name of Base Class> controller = new <Name of Base Class>(new ApexPages.StandardController(co));//FOR EXTENSION CONTROLLERS ; co is the SOBJECT Record.
            
            /***************************************** Execution of Methods *****************************************/
            /*  Execute Methods inside Base Class. E.g. Base class has a method,                                    */
            /*  public void Initialize(){                                                                           */
            /*      <<Code Block>>                                                                                  */
            /*  }                                                                                                   */
            /*                                                                                                      */
            /*  In test Method, insert a statement:                                                                 */
            /*  controller.Initialize(); //controller is the alias of the Base Class as instantiated in Line 26/27  */
            /*                                                                                                      */
            /*  Make sure to cover all PUBLIC methods.                                                              */
            /*  Note: Private methods does not need to be called as it is already called in another method.         */
            /********************************************************************************************************/
                 
            Test.stopTest(); //Indicates End of Coverage of Test Method
        //}
    }//END magazineRenewal
    
    static testmethod void magazineRenewal2() {
    
        /****************************** Test Data Creation ******************************/
        /*   Insert code statements that inserts Data                                   */
        /*   needed by Base Class.                                                      */
        /*   e.g. Base Class Queries Account with                                       */
        /*        Record Type = Direct.                                                 */
        /*                                                                              */
        /*        List<Account> accList = TestDataFactory.createAccount('Direct',5);    */
        /*         Insert accList;                                                      */
        /********************************************************************************/
        
        Manual_Batch_Run_Dates__c mbrDate = new Manual_Batch_Run_Dates__c();
        mbrDate.Name = 'ManualBatchRun';
        mbrDate.Batch_Run_Date__c = Date.Today();
        database.insert(mbrDate);
        
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Subscription_Period_1__c = '3';
        pack.Subscription_Period__c = '3';
        pack.Same_Pck_Renewal_Mag_1_Yr_Base__c = true;
        pack.Same_Pck_Renewal_Mag_1_Yr_Disc__c = true;
        pack.Same_Pck_Renewal_Mag_2_Yr_Base__c = true;
        pack.Same_Pck_Renewal_Mag_2_Yr_Disc__c = true;
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        insert new List<sObject>{venAccount, pack, subsVen};
    List<RecordType> casrt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Renewal of Subscription'];   
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
            postal.Name = 'Test Postal';
            postal.Building_Name__c = 'Test Building';
            postal.Street_Name__c = 'Test Street';
            insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
        Country__c countr = TestDataFactory.createCountry(1)[0];
            countr.Country_Name__c = 'Test Country';
            insert countr;
                
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            //addressRec.RecordTypeId = '012N00000008idiIAA';
            addressRec.Block_House_Number__c = 'Sample';
            addressRec.Address_Type__c= 'P';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Level_Number__c = 'Ab';
            addressRec.Unit_Number__c = 'ab';
            addressRec.Country__c = countr.Id;
            insert addressRec;        
            
        Contact conList = TestDataFactory.createContact(1)[0];
            conList.LastName = 'Gonzales';
            conList.Address__c = addressRec.Id;
            conList.AccountId = acc.Id;
            conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList.Recipient_Indicator__c = true;
            insert conList;
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = conList.Id;
            insert orderRec;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            cas.recordtypeid = casrt[0].Id;        
            insert cas;
            
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.Today() +60;
            orderline.start_date__c = date.Today();
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Case__c = cas.id;
            orderline.Vendor_Mailing_Agent__c = venAccount.Id;
            orderline.Vendor_Subscription_ID__c = subsVen.Id;
            orderline.Start_Date__c = date.today()+1;
            insert orderline;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = '100 YEARS OF ADVENTURE';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Publication_Code__c ='TSSA';
            pub.Publication_Type__c ='M';
            insert pub;

        //START KINGSLEY
        Billing_Batch__c billingBatch = new Billing_Batch__c();
            billingBatch.Next_Batch_Number__c   = 14;
            billingBatch.Batch__c               = '13,14,15';
            billingBatch.Name                   = 'Full Prepaid';
        insert billingBatch;

        //END KINGSLEY
        
        //jurna added    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Billing_Contact__c = conList.Id;
        Test.startTest();
        insert billAcc;
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Order_Number__c = orderRec.Id;
            sub.Contact__c = conList.Id;
            sub.Subscriber_Contact__c = conList.Id;
            sub.Recipient_Contact__c = conList.Id;
            sub.Main_Package_1__c = pack.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Order_Line_Item_Number_1__c = orderline.id;
            sub.Subscription_Type__c = 'Delivery';
            sub.Zuora__SubscriptionStartDate__c = date.today() - 42;
            sub.Term_Length1__c = '6';
            sub.Term_Length__c = 6;
            sub.Zuora__SubscriptionEndDate__c = date.today();          
            sub.Frequency_1__c = 'Mon - Fri';
            sub.Number_of_Copies__c = 3;  
            sub.Number_of_Copies1__c = '3';
            sub.Zuora__CustomerAccount__c = billAcc.id; //jurna added   
            //insert sub; 
        
        String prodCode = String.valueOf(pack.Id).subString(0, 14);
        zqu__ZProduct__c zProd = new zqu__ZProduct__c(Name='Test Quote Wizard', zqu__SKU__c='SKU', zqu__ZuoraId__c='ZID',
                                                                   ProductType__c='Product Type',ProductPlatform__c = 'Online', 
                                                                   ProductCode__c=prodCode);
        insert zProd;
        
        /*************************** Creation of Test User ******************************/
        //User testUser = TestDataFactory.prepareTestusers();
        
        //System.runAs(testUser){
             //This creates a new Heap block Dedicated to your test Run of actual lines in Base Class.
            insert sub;
            
            Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(sub.Id);
         letterPrintRequest.Language_Medium__c = 'C';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Status__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(sub.Id);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         //update letterPrintRequest;
          
            PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',letterPrintRequest.id); //add this statement if Base Class contains  "ApexPages.currentPage().getParameters().put"
            RenewalController controller = new RenewalController();
            
            //controller.initializeMZ();
            //controller.initializeNP();
            controller.initializeCHNP();
            controller.initializeCHMZ();
            //controller.setFields();
            //karen 04.13.15 compile error fixed
            //controller.initialize();
            
            //System.assertEquals(sub.Contact__r.Address__r.Block_House_Number__c, '');
            //System.assertEquals(sub.Contact__r.Address__r.Block_House_Number__c, 'Sample');
            
            //<Name of Base Class> controller = new <Name of Base Class>(); //FOR CUSTOM CONTROLLERS ONLY
            //<Name of Base Class> controller = new <Name of Base Class>(new ApexPages.StandardController(co));//FOR EXTENSION CONTROLLERS ; co is the SOBJECT Record.
            
            /***************************************** Execution of Methods *****************************************/
            /*  Execute Methods inside Base Class. E.g. Base class has a method,                                    */
            /*  public void Initialize(){                                                                           */
            /*      <<Code Block>>                                                                                  */
            /*  }                                                                                                   */
            /*                                                                                                      */
            /*  In test Method, insert a statement:                                                                 */
            /*  controller.Initialize(); //controller is the alias of the Base Class as instantiated in Line 26/27  */
            /*                                                                                                      */
            /*  Make sure to cover all PUBLIC methods.                                                              */
            /*  Note: Private methods does not need to be called as it is already called in another method.         */
            /********************************************************************************************************/
                 
            Test.stopTest(); //Indicates End of Coverage of Test Method
        //}
    }//END magazineRenewal
    
    /****************** Create another Test Method as needed ***************/
    /* It is best to have a Test Method for Happy Path (Positive Scenario) */
    /* and another Test Method for the Negative Scenario (catch blocks)    */
    /***********************************************************************/
    
    static testMethod void newspaperRenewal(){
     /****************************** Test Data Creation ******************************/
        /*   Insert code statements that inserts Data                                   */
        /*   needed by Base Class.                                                      */
        /*   e.g. Base Class Queries Account with                                       */
        /*        Record Type = Direct.                                                 */
        /*                                                                              */
        /*        List<Account> accList = TestDataFactory.createAccount('Direct',5);    */
        /*         Insert accList;                                                      */
        /********************************************************************************/
        
        Manual_Batch_Run_Dates__c mbrDate = new Manual_Batch_Run_Dates__c();
        mbrDate.Name = 'ManualBatchRun';
        mbrDate.Batch_Run_Date__c = Date.Today();
        database.insert(mbrDate);

        Zuora__SubscriptionProductCharge__c  prodcharge = TestDataFactory.createSubProductCharge(1)[0];    
        prodcharge.Name = '100% Non Chargeable Proration';
        prodcharge.Zuora__Zuora_Id__c = '2c92c0f84b4e1f29014b534a57e30de8';
    List<RecordType> casrt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Renewal of Subscription'];         
        insert prodcharge;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period'; // jurna added
        pack.Subscription_Period_1__c = '1';
        pack.Subscription_Period__c = '1';
        insert pack;

        String prodCode = String.valueOf(pack.Id).subString(0, 14);
        zqu__ZProduct__c zProd = new zqu__ZProduct__c(Name='Test Quote Wizard', zqu__SKU__c='SKU', zqu__ZuoraId__c='ZID',
                                                                   ProductType__c='Product Type',ProductPlatform__c = 'Online', 
                                                                   ProductCode__c=prodCode);
        insert zProd;
        
        zqu__ProductRatePlan__c prodRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        //prodRatePlan.RatePlanType__c = 'Discount'; //jurna removed
        prodRatePlan.RatePlanType__c = 'Proration'; //jurna added
        prodRatePlan.zqu__ZProduct__c = zProd.id;
        insert prodRatePlan;
        
        
        
        Product_Family__c prodFam = TestDataFactory.createProductFamily(1)[0];
        insert prodFam;

        //Package_Item__c packItem = TestDataFactory.createPackageItem (1, 'Discount')[0]; //jurna removed
        Package_Item__c packItem = TestDataFactory.createPackageItem (1, 'Base Product')[0]; //jurna added
        packItem.Product_Rate_Plan__c = prodRatePlan.id;
        packItem.Package__c = pack.id;
        packItem.Product_Family__c = prodFam.id;
        insert packItem;  
        
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert venAccount;
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0]; 
        insert subsVen;  
              
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
            postal.Name = 'Test';
            postal.Building_Name__c = 'Test Building';
            postal.Street_Name__c = 'Test Street';
            insert postal;
        
        
         Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
        Country__c countr = TestDataFactory.createCountry(1)[0];
            countr.Country_Name__c = 'Test Country';
            insert countr;
                
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            //addressRec.RecordTypeId = '012N00000008idiIAA';
            addressRec.Block_House_Number__c = 'Sample';
            addressRec.Address_Type__c= 'P';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Level_Number__c = 'AB';
            addressRec.Unit_Number__c = 'abcdef';
            addressRec.Country__c = countr.Id;
            insert addressRec;        
            
           Contact conList = TestDataFactory.createContact(1)[0];
            conList.LastName = 'Gonzales';
            conList.Address__c = addressRec.Id;
            conList.AccountId = acc.Id;
            conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList.Recipient_Indicator__c = true;
            insert conList;
 
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = conList.Id;
            insert orderRec;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
           cas.recordtypeid = casrt[0].Id;        
            insert cas;
         
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            //orderline.End_Date__c = date.newInstance(2015, 1, 13);
            orderline.End_Date__c = date.Today()+2;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Case__c = cas.id;
            orderline.Vendor_Mailing_Agent__c = venAccount.Id;
            orderline.Vendor_Subscription_ID__c = subsVen.Id;
            orderline.Start_Date__c = date.today()+1;
            insert orderline;
        
        //START KINGSLEY
        Billing_Batch__c billingBatch = new Billing_Batch__c();
            billingBatch.Next_Batch_Number__c   = 14;
            billingBatch.Batch__c               = '13,14,15';
            billingBatch.Name                   = 'Full Prepaid';
        insert billingBatch;

        //END KINGSLEY
            
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        insert billAcc;

            
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Order_Number__c = orderRec.Id;
            sub.Contact__c = conList.Id;
            sub.Subscriber_Contact__c = conList.Id;
            sub.Recipient_Contact__c = conList.Id;
            sub.Main_Package_1__c = pack.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Frequency_1__c = 'Default';
            sub.Zuora__CustomerAccount__c = billAcc.id;
            sub.Zuora__SubscriptionEndDate__c = date.today();
            sub.Zuora__SubscriptionStartDate__c = date.today() - 42;
            sub.Term_Length1__c = '6';
            sub.Term_Length__c = 6;
            sub.Number_of_Copies__c = 3;
            sub.Number_of_Copies1__c = '3';
            Test.startTest();
          insert sub; 
              RenewalController cont = new RenewalController();
              cont.testCoveragePatch();
              cont.mainpackage = 'test mainpackage';
              cont.subscriptionEndDate = date.today().addDays(1);
              cont.subscriptionCharge = 1.00;
              cont.subAccountNum = 'test subAccountNum';
              cont.accountName = 'test accountName';
              cont.recipientName = 'test recipientName';
              cont.frequency = 'test frequency';
              cont.numberOfCopies = 1.00;
              cont.subscriptionExpiry = 'test subscriptionExpiry';
              cont.dateOutput = date.today();
              cont.MagazineCnt = 1;
              cont.EmailAddress = 'test@EmailAddress.com';
              cont.HomeNumber = 'test HomeNumber';
              cont.OfficeNumber = 'test OfficeNumber';
              cont.MobileNumber = 'test MobileNumber';
              cont.charLength = true;
              cont.charLengthMag = true;
              cont.newsDelCharge = 1.00;
              cont.newsTotal = 1.00;
              cont.lineDetailGroupFirst = 'test lineDetailGroupFirst';
              cont.mobileAdjustment(billAcc);
            Test.stopTest();
          
                                        
        }//END newpaperRenewal
}