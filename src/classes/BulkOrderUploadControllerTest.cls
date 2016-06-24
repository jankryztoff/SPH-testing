/**
Class Name: BulkOrderUploadControllerTest
@author: Flores, Emmanuel D.
@Date: 10/16/2015
@Project/Requirement: SPH 
@description This class is test class for BulkOrderUploadController
**/
@isTest (Seealldata =true)
private class BulkOrderUploadControllerTest {

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

    static void setUpTestData() {
        
        //CustomSettings
        /*RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
        RecordType Address_Local = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Local' LIMIT 1];
        RecordType addressOverseas = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Overseas' LIMIT 1];
        RecordType directCorporate = [SELECT id, Name FROM RecordType WHERE SobjectType='Account' AND Name='Direct Corporate' LIMIT 1];
        RecordType addressAirline = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Airline' LIMIT 1];
        RecordType addressInternal = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Internal' LIMIT 1];
        RecordType startSub = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Start Subscription'LIMIT 1];
        */
        //Key_Id__c
        /*List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Local', Id__c=Address_Local.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Overseas', Id__c=addressOverseas.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Internal', Id__c=addressInternal.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Airline', Id__c=addressAirline.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Account_Direct Corporate', Id__c=directCorporate.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Start Subscription', Id__c=startSub.id ,Type__c='RecordType')
        };*/
        
        List<Key_Id__c> kisList = new List<Key_Id__c>();
        kislist = CustomSettingsDataFactory.createKey_Id();
        Database.insert(kisList);
        Cir_Planner_Schedule__c cps = new Cir_Planner_Schedule__c();
        cps = CustomSettingsDataFactory.createPlannerSched();
        insert cps;
        List<Record_Type_Field_Setup__c> recordtypeFS = CustomSettingsDataFactory.createRecord_Type_Field_Setup();
        insert recordtypeFS;
        //Other__c
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);
        
        //Setup Country__c records
        cntryList = TestDataFactory.createCountry(2);
        cntryList[0].Country_Name__c = 'Singaspore';
        cntryList[0].Code__c = 'Singaspore';
        cntryList[1].Country_Name__c = 'Philippines';
        cntryList[1].Code__c = 'Philippines';
        insert cntryList;
        
        //Setup Account records
        acnt = TestDataFactory.createAccount(1, 'Direct Individual')[0];
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
        acnt.AccountNumber = '31411552';
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
        cntctList[1].Address__c = addrList[1].Id;
        cntctList[1].AccountId = acnt.Id;
        cntctList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        cntctList[1].Billing_Indicator__c = true;
        cntctList[1].FirstName = 'Test1';
        cntctList[1].LastName = 'Contact';
        cntctList[1].Email = 'test@test.com';
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
        custAccount.Billing_Type__c = 'Recurring Prepaid';
        custAccount.Zuora__DefaultPaymentMethod__c = 'Other';
        custAccount.Zuora__AccountNumber__c = 'Test1';
        
        insert custAccount;

        //Setup Package records
        packge = TestDataFactory.createPackage(1)[0];
        packge.Billing_Type__c = 'Recurring Prepaid';
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
        //orders.Order_Type__c = 'Renewal';
        orders.Status__c = 'Draft';
        orders.Eligible_for_Retention__c = TRUE;
        orders.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orders.Payment_Mode__c = 'Credit Card';
        orders.Billing_Account__c = custAccount.id;
        orders.Billing_Type__c = 'Recurring Prepaid';
        orders.Billing_Contact__c = cntctList[1].id;
        orders.Case_Record_Type__c = 'Complaint - Magazine';
        orders.Category__c = 'Subscription Request';
        orders.Sub_Category__c ='Stop Subscription';
        orders.Credit_Balance__c = 0;
        orders.Delivery_Charge__c = 0;
        orders.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        //orders.Order_Type__c = 'Change of Subscription Package';
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
        
        //Setup Zoura Records
        zuoraSubscription = TestDataFactory.createSubscription(1)[0];
        zuoraSubscription.Zuora__Account__c = acnt.Id;
        zuoraSubscription.Order_Line_Item_Number__c = ordLineItem.Id;
        zuoraSubscription.Subscriber_Contact__c = cntctList[0].Id;
        zuoraSubscription.Recipient_Contact__c = cntctList[0].Id;
        zuoraSubscription.Main_Package_1__c = packge.Id;
        zuoraSubscription.Main_Package__c = packge.Id;
        zuoraSubscription.Zuora__Status__c = 'Active';
        zuoraSubscription.Order_Number__c = orders.Id;
        zuoraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zuoraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zuoraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zuoraSubscription.Urgent__c = 'false';
        zuoraSubscription.Vendor_Conversion__c = 'false';
        zuoraSubscription.Charity__c = 'false';
        zuoraSubscription.Subscription_Type__c = 'Publication';
        zuoraSubscription.Subscription_Type_1__c = 'Publication';
        zuoraSubscription.Zuora__SubscriptionEndDate__c= date.today();
        zuoraSubscription.Zuora__SubscriptionStartDate__c = date.today();
        zuoraSubscription.Zuora__CustomerAccount__c = custAccount.Id;
        zuoraSubscription.Contact__c = cntctList[0].id;
        zuoraSubscription.Zuora__External_Id__c = ZuoraExternalId;
        zuoraSubscription.Zuora__Zuora_Id__c = ZuoraExternalId;
        zuoraSubscription.Order_Line_Item_Number_1__c = ordLineItem.Id;
        zuoraSubscription.Delivered_By__c = 'Vendor';
        insert zuoraSubscription; 

        validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Test_Name';
        validEmailTemplate.DeveloperName = 'Test_Developer';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.HtmlValue = '<html> <table width="100%"> <tr> <td width=68% align=left> <div style = "font-family:Arial; font-size: 9pt;"> {{Insert Table}}<br> <br> {{Contact.FirstName}} {{Contact.LastName}}<br> </div> </html>';

        insert validEmailTemplate;
    }

    static User createUser() {
        UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
                       EmailEncodingKey='UTF-8', LastName='Testing123', 
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                       ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
                       UserName='standardCL07@test.com', Title='Testing123');
        insert usr;

        return usr;
    }

    static testMethod void testProcessDocument() {
        User testUser = createUser();

        System.runAs(testUser) {

          //  setUpTestData();
            /* List <Billing_Batch__c> billingBatches = new List <Billing_Batch__c>();
             billingBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billingBatches;*/
           Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
            config.Name = 'Test';
            config.Field_Name__c = 'Test';
            config.Object_Name__c = 'Test';
            config.Identifier__c = 'Test';
            insert config;
            
            String stringVal = '';
            for (Bulk_Order_Configuration__c BuldOrderConfig:[select name from Bulk_Order_Configuration__c]) {
                stringVal += BuldOrderConfig.name +', ';
            }
                
            /*Integer count;
            String stringVal = '';
            for(count = 0; count <= 5 ; count++){
                stringVal += 'Test Document Body ' + count + ' ';
            }*/
             
            Document doc = new Document();
            doc.FolderId = UserInfo.getUserId();
            doc.Name = 'Test Document Name';
            Blob bodyBlob = Blob.valueOf(stringVal);
            doc.body = bodyBlob;
            doc.Type = 'txt';
            doc.ContentType = 'Text';
            insert doc;
             
            List<Document> doc2 = [SELECT FolderId, Name, Body, BodyLength, Type, ContentType FROM Document WHERE Name = :doc.Name LIMIT 1];

            Test.setMock(WebServiceMock.class, new zLoginMock());
            Test.startTest();
                try { 
                    BulkOrderUploadController bulkorder = new BulkOrderUploadController();
                    bulkorder.orderFile = doc2[0];
                    bulkorder.retrieveReferenceDoc();
                    bulkorder.verifyDocument();
                    bulkorder.processDocument();
                } catch (Exception e) {

                }
            Test.stopTest();
        }
    }

    static testmethod void testRetrieveReferenceDoc() {
        User testUser = createUser();

        System.runAs(testUser) {
              List <Billing_Batch__c> billingBatches = new List <Billing_Batch__c>();
             billingBatches = CustomSettingsDataFactory.createBillingBatch();
            //insert billingBatches;
            Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
            config.Name = 'Test';
            config.Field_Name__c = 'Test';
            config.Object_Name__c = 'Test';
            config.Identifier__c = 'Test';
            insert config;
                      
            String stringVal = '';
            for (Bulk_Order_Configuration__c BuldOrderConfig:[select name from Bulk_Order_Configuration__c]) {
                stringVal += BuldOrderConfig.name +', ';
            }
             
            Document doc = new Document();
            doc.FolderId = UserInfo.getUserId();
            doc.Name = 'BulkOrderUploadTemplate';
            Blob bodyBlob = Blob.valueOf(stringVal);
            doc.body = bodyBlob;
            doc.Type = 'txt';
            doc.ContentType = 'Text';
            insert doc;

            Document docs = new Document();
            docs.FolderId = UserInfo.getUserId();
            docs.Name = 'BulkOrderUploadReference';
            docs.body = bodyBlob;
            docs.Type = 'txt';
            docs.ContentType = 'Text';
            insert docs;
             
            List<Document> docList = [SELECT FolderId, Name, Body, BodyLength, Type, ContentType FROM Document];

            Test.setMock(WebServiceMock.class, new zLoginMock());
            Test.startTest();
                try { 
                    BulkOrderUploadController bulkorder = new BulkOrderUploadController();
                    bulkorder.orderFile = docList[0];
                    bulkorder.retrieveReferenceDoc();
                    bulkorder.verifyDocument();

                    BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
                    bulkorder2.orderFile = docList[1];
                    bulkorder2.retrieveReferenceDoc();
                    bulkorder2.verifyDocument();
                } catch (Exception e) {

                }
            Test.stopTest();
        }
    }

    static testmethod void unitTest1() {
          User testUser = createUser();

      System.runAs(testUser) {
        
          Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
          config.Name = 'Test';
          config.Field_Name__c = 'Test';
         config.Object_Name__c = 'Test';
         config.Identifier__c = 'Test';
         insert config;
         
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Generate_Account_Number__c = true; //fritz
        insert acc;
         
        String stringVal = '';
        for (Bulk_Order_Configuration__c BuldOrderConfig:[select name from Bulk_Order_Configuration__c]) {
            stringVal += BuldOrderConfig.name +', ';
        }
           List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        //database.insert(otherList);
         
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'Test Document Name';
         Blob bodyBlob = Blob.valueOf(stringVal);
         doc.body = bodyBlob;
         doc.Type = 'txt';
         doc.ContentType = 'Text';
         insert doc;
         
       List<Document> doc2 = [SELECT FolderId, Name, Body, BodyLength, Type, ContentType FROM Document WHERE Name = :doc.Name LIMIT 1];
        System.AssertEquals(TRUE, doc2[0].BodyLength <= 10485760);
         
         //String jsonStr = JSON.serialize(doc2[0]);
         //Document docu = (Document)JSON.deserialize(jsonStr, Document.class);

         Test.setMock(WebServiceMock.class, new zLoginMock());
         
         Test.startTest();        
           BulkOrderUploadController bulkorder = new BulkOrderUploadController();
            bulkorder.retrieveReferenceDoc();
           bulkorder.orderFile = doc2[0];
     //        //bulkorder.orderFile = docu;
           bulkorder.verifyDocument();
           bulkorder.processDocument();
           BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
             bulkorder2.orderFile = NULL;
             bulkorder2.verifyDocument();
         Test.stopTest();
         
     }
         
     }
     
         static testmethod void unitTest2() {
            User testUser = createUser();
               
            System.runAs(testUser) {   
            // setUpTestData(); 
                     /*  Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
              config.Name = 'Test';
              config.Field_Name__c = 'Test';
             config.Object_Name__c = 'Test';
             config.Identifier__c = 'Test';
             insert config;*/
           /*  List<Product_Frequency__c> prodfreqs = CustomSettingsDataFactory.createProduct_Frequency();
             insert prodfreqs;
             List <Billing_Batch__c> billingBatches = new List <Billing_Batch__c>();
             billingBatches = CustomSettingsDataFactory.createBillingBatch();
             insert billingBatches;
            List<Bulk_Order_Configuration__c>  boc = new List<Bulk_Order_Configuration__c>();
            boc = CustomSettingsDataFactory.createBulkOrder();*/
             
            // insert boc;
             Test.startTest();
             
             Zone__c zone = new Zone__c();
             zone.Name = '0';
             insert zone;
          
             Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
             postal.Name = '123';
             postal.Name = '100044';
             postal.House_Block_Number__c = '1';
             postal.Address_Type__c = 'A';
             insert postal;
             
            Address_Details__c adDetail = new Address_Details__c();
            adDetail.Postal_Code__c = postal.Id;
            adDetail.Level__c = 'xx';
            adDetail.Unit__c = 'yy';
            insert adDetail;
             
            
             Country__c co = [Select Id,Name, Code__c, Country_Name__c, Zonal_Code__c, Zone__c From Country__c WHERE Name = 'SG' Limit 1];
           //  co.Code__c =  'SG';
          //   co.Name = 'SG';
        //   co.Zonal_Code__c = '0';
           
          //  insert co;
             
             Address__c addressRec = TestDataFactory.createAddress(1)[0];
             addressRec.Address_Type__c = 'A';
             addressRec.Postal_Code__c = postal.Id;
             addressRec.Block_House_Number__c ='TEST';
             addressRec.Level_Number__c ='xx';
             addressRec.Unit_Number__c = 'yy';
             addressRec.Country__c = co.Id;
             addressRec.Address_1__c = 'address1';
             addressRec.Address_2__c = 'address2';
             addressRec.Address_3__c = 'address3';
             addressRec.Address_4__c = 'address4';
             addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
             
             insert addressRec;
             
             Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
             acc.AccountNumber = '91411551';
             acc.Name = 'Bulk Upload Test 1';
             acc.Email__c = 'sample@sph.com';
             acc.Acknowledgement_Letter__c = 'Email';
             acc.Renewal_Letter__c = 'Hard Copy';
             acc.Airline_Indicator__c = false;
             System.debug('account beforeinserted' + acc.AccountNumber);
             acc.Status__c = 'Active';
             acc.Generate_Account_Number__c = false;
             try{
                insert acc;
             }catch(exception e) {
                 system.debug(':::ERROR ' + e);
             }
             
             
             
             Contact con = TestDataFactory.createContact(1)[0];
             con.FirstName = 'Water';
             con.LastName = 'Monkey';
             con.Billing_Account_Name_2__c = 'Bulk Upload Test 1';
             con.Address__c = addressRec.Id;
             con.AccountId = acc.Id;
             con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
             con.Email__c = 'sample@sph.com';
             con.HomePhone__c = '9999222';
             con.Billing_Indicator__c = true;
             con.Recipient_Indicator__c = true;
             insert con; 
             
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             billAcc.Billing_Contact__c = con.Id;
             billAcc.Billing_Type__c = 'Recurring Prepaid';
             billAcc.Zuora__AccountNumber__c = '91411551';
             billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
             billAcc.Other_PaymentMethod__c = 'Internal Storage';
             insert billAcc;
            // System.debug('account inserted' + billAcc.id);
             //String stringVal1 = 'PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,RCAddressRecordType,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,GiftCodes,PromotionCode,GiftCodes,RCAddressRecordType,RCCityCode,RCPackingCode,BCAddressRecordType,BCCityCode,BCPackingCode';
             String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
             //String stringVal2 = 'PackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,123456,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,Other,Invoice,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,Quantity,Internal,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,Internal,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,Gift Codes,PromotionCode,GiftCodes,Test,Airline,RCCityCode,RCPackingCode,Airline,BCCityCode,BCPackingCode';
             String stringVal2 = '91411551,,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,,,, sample@sph.com,,,,,,,,Email,Hard Copy,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,,,,,,,sample@sph.com,,Local,100044,3,3,TestCountry,,,,,,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,9999222,,,,,,sample@sph.com,,Local,100044,3,3,TestCountry,,,,,,,,,,,,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,AddonPackageCode,,,,,1,Mailing Agent,';
             //Test.setMock(WebServiceMock.class, new zLoginMock());
                     
             Document doc = new Document();
             doc.FolderId = UserInfo.getUserId();
             doc.Name = 'BulkOrderUploadTemplate';
             //Blob bodyBlob = Blob.valueOf('PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy\nPackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy');
             Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
             doc.body = bodyBlob;
             doc.Type = 'csv';
             doc.ContentType = 'application/vnd.ms-excel';
             insert doc;
              
             
             //Promotion__c
             prom = TestDataFactory.createPromotion(1)[0];
             prom.Promotion_Code__c = 'PackageCode';
             prom.Contract_Period__c = '30';
             insert prom;
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             pack.Package_Code__c = 'AddonPackageCode';
             pack.Billing_Type__c = 'Recurring Prepaid';
             pack.Subscription_Type__c = 'TERMED';
             pack.Package_Price__c = 3;
             pack.Subscription_Period__c = '30';
             insert pack;
             
             Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
             promPack.Promotion__c = prom.Id;
             promPack.Package_Name__c = pack.ID;
             insert promPack;
             
             zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
             zProduct.ProductPlatform__c = 'All-In-One';
             zProduct.ProductCode__c = 'POSCHG';
             database.insert(zProduct);
             
             Zone_Product__c zoneProd = new Zone_Product__c();
             zoneProd.Zone__c = zone.id;
             zoneProd.Product__c = zProduct.id;
             zoneProd.Effective_Start_Date__c = Date.Today();
             zoneProd.Postage_Charge__c = 5;
             insert zoneProd;
             
             
             zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
             prdRatePlan.zqu__ZProduct__c = zProduct.Id;
             prdRatePlan.RatePlanType__c= 'Bill Plan';
             prdRatePlan.SubscriptionFrequency__c = '1';
             prdRatePlan.RatePlanCode__c = 'CHGPOS';
             prdRatePlan.zqu__Deleted__c = false;
      
             database.insert(prdRatePlan);
             
             Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
             pItem.Package__c = pack.id;
             pItem.Product_Rate_Plan__c = prdRatePlan.Id;
             database.insert(pItem);
             
             Publication__c pub = TestDataFactory.createPublication(1)[0];
             pub.Earliest_Start_Date__c = date.today()+1;
             pub.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
             insert pub;
             
             Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
             pp.ZProduct__c = zProduct.Id;
             pp.Publication_Code__c = pub.Id;
             insert pp;
             
             Order__c order = TestDataFactory.createOrder(1)[0];
             order.Account__c = acc.Id;
             order.Payment_Mode__c = 'Other';
             order.Other_Payment_Mode__c = 'External Parties';
             order.Billing_Account__c = billAcc.id;
             order.Billing_Type__c = 'Recurring Prepaid';
             //order.Order_Type__c = 'Start';
             order.Recipient_Contact__c = con.id;
             order.Billing_Contact__c = con.id;
             insert order;
             
             Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
             orderline.Order__c = order.Id;
             orderline.Main_Package_ID__c = pack.Id;
             orderline.Delivered_By__c = 'Mailing Agent';
             orderline.Qty__c = 1;
             orderline.Main_Package_Frequency__c = 'Default';
             insert orderline;
             
           
             BulkOrderUploadController bulkorder = new BulkOrderUploadController();
             bulkorder.orderFile = doc;
             bulkorder.verifyDocument();         
             bulkorder.processDocument();
             bulkorder.retrieveReferenceDoc();
             bulkorder.cancel();
             //bulkorder.testCoveragePatch();
             
             BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
             bulkorder2.orderFile = NULL;
             bulkorder2.verifyDocument();
             Test.stopTest();
             
             }
            
         }
     
     static testmethod void unitTest4() {
        User testUser = createUser();
           
        System.runAs(testUser) {   
        // setUpTestData(); 
                 /*  Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
          config.Name = 'Test';
          config.Field_Name__c = 'Test';
         config.Object_Name__c = 'Test';
         config.Identifier__c = 'Test';
         insert config;*/
       /*  List<Product_Frequency__c> prodfreqs = CustomSettingsDataFactory.createProduct_Frequency();
         insert prodfreqs;
         List <Billing_Batch__c> billingBatches = new List <Billing_Batch__c>();
         billingBatches = CustomSettingsDataFactory.createBillingBatch();
         insert billingBatches;
        List<Bulk_Order_Configuration__c>  boc = new List<Bulk_Order_Configuration__c>();
        boc = CustomSettingsDataFactory.createBulkOrder();*/
         
        // insert boc;
         Test.startTest();
         
         Zone__c zone = new Zone__c();
         zone.Name = '0';
         insert zone;
      
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Name = '123';
         postal.Name = '100044';
         postal.House_Block_Number__c = '1';
         postal.Address_Type__c = 'A';
         insert postal;
         
        Address_Details__c adDetail = new Address_Details__c();
        adDetail.Postal_Code__c = postal.Id;
        adDetail.Level__c = 'xx';
        adDetail.Unit__c = 'yy';
        insert adDetail;
         
        
         Country__c co = [Select Id,Name, Code__c, Country_Name__c, Zonal_Code__c, Zone__c From Country__c WHERE Name = 'SG' Limit 1];
       //  co.Code__c =  'SG';
      //   co.Name = 'SG';
    //   co.Zonal_Code__c = '0';
       
      //  insert co;
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'A';
         addressRec.Postal_Code__c = postal.Id;
         addressRec.Block_House_Number__c ='TEST';
         addressRec.Level_Number__c ='xx';
         addressRec.Unit_Number__c = 'yy';
         addressRec.Country__c = co.Id;
         addressRec.Address_1__c = 'address1';
         addressRec.Address_2__c = 'address2';
         addressRec.Address_3__c = 'address3';
         addressRec.Address_4__c = 'address4';
         addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
         
         insert addressRec;
         
         Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
         acc.AccountNumber = '91411551';
         acc.Name = 'Bulk Upload Test 1';
         acc.Email__c = 'sample@sph.com';
         acc.Acknowledgement_Letter__c = 'Email';
         acc.Renewal_Letter__c = 'Hard Copy';
         acc.Airline_Indicator__c = false;
         System.debug('account beforeinserted' + acc.AccountNumber);
         acc.Status__c = 'Active';
         acc.Generate_Account_Number__c = false;
         insert acc;
         
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.FirstName = 'Water';
         con.LastName = 'Monkey';
         con.Billing_Account_Name_2__c = 'Bulk Upload Test 1';
         con.Address__c = addressRec.Id;
         con.AccountId = acc.Id;
         con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
         con.Email__c = 'sample@sph.com';
         con.HomePhone__c = '9999222';
         con.Billing_Indicator__c = true;
         con.Recipient_Indicator__c = true;
         insert con; 
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.id;
         billAcc.Billing_Contact__c = con.Id;
         billAcc.Billing_Type__c = 'Recurring Prepaid';
         billAcc.Zuora__AccountNumber__c = '91411551';
         billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
         billAcc.Other_PaymentMethod__c = 'Internal Storage';
         insert billAcc;
        // System.debug('account inserted' + billAcc.id);
         //String stringVal1 = 'PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,RCAddressRecordType,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,GiftCodes,PromotionCode,GiftCodes,RCAddressRecordType,RCCityCode,RCPackingCode,BCAddressRecordType,BCCityCode,BCPackingCode';
         String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
         //String stringVal2 = 'PackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,123456,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,Other,Invoice,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,Quantity,Internal,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,Internal,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,Gift Codes,PromotionCode,GiftCodes,Test,Airline,RCCityCode,RCPackingCode,Airline,BCCityCode,BCPackingCode';
         String stringVal2 = ',,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,,,, sample@sph.com,,,,,,,,Email,Hard Copy,,,,,,,,,Account,New,,,,,,9999222,,,,,,sample@sph.com,,Local,100044,03,03,TestCountry,,,,,,,,,,,,,,Account,New,,,,,,9999222,,,,,,sample@sph.com,,Local,100044,03,03,TestCountry,,,,,,,,,,,,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,AddonPackageCode,,,,,1,Vendor,';
         //Test.setMock(WebServiceMock.class, new zLoginMock());
                 
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'BulkOrderUploadTemplate';
         //Blob bodyBlob = Blob.valueOf('PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy\nPackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy');
         Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
         doc.body = bodyBlob;
         doc.Type = 'csv';
         doc.ContentType = 'application/vnd.ms-excel';
         insert doc;
          
         
         //Promotion__c
         prom = TestDataFactory.createPromotion(1)[0];
         prom.Promotion_Code__c = 'PackageCode';
         prom.Contract_Period__c = '30';
         insert prom;
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Package_Code__c = 'AddonPackageCode';
         pack.Billing_Type__c = 'Recurring Prepaid';
         pack.Subscription_Type__c = 'TERMED';
         pack.Package_Price__c = 3;
         pack.Subscription_Period__c = '30';
         insert pack;
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.ID;
         insert promPack;
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'All-In-One';
         zProduct.ProductCode__c = 'POSCHG';
         database.insert(zProduct);
         
         Zone_Product__c zoneProd = new Zone_Product__c();
         zoneProd.Zone__c = zone.id;
         zoneProd.Product__c = zProduct.id;
         zoneProd.Effective_Start_Date__c = Date.Today();
         zoneProd.Postage_Charge__c = 5;
         insert zoneProd;
         
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.SubscriptionFrequency__c = '1';
         prdRatePlan.RatePlanCode__c = 'CHGPOS';
         prdRatePlan.zqu__Deleted__c = false;
  
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.Id;
         database.insert(pItem);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Vendor';
         insert pub;
         
         Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
         pp.ZProduct__c = zProduct.Id;
         pp.Publication_Code__c = pub.Id;
         insert pp;
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Payment_Mode__c = 'Other';
         order.Other_Payment_Mode__c = 'External Parties';
         order.Billing_Account__c = billAcc.id;
         order.Billing_Type__c = 'Recurring Prepaid';
         //order.Order_Type__c = 'Start';
         order.Recipient_Contact__c = con.id;
         order.Billing_Contact__c = con.id;
         insert order;
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.Delivered_By__c = 'Mailing Agent';
         orderline.Qty__c = 1;
         orderline.Main_Package_Frequency__c = 'Default';
         insert orderline;       
         
       
         BulkOrderUploadController bulkorder = new BulkOrderUploadController();
         bulkorder.orderFile = doc;
         bulkorder.verifyDocument();         
         bulkorder.processDocument();
         bulkorder.retrieveReferenceDoc();
         bulkorder.cancel();
         bulkorder.testCoveragePatch();
         
         BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
         bulkorder2.orderFile = NULL;
         bulkorder2.verifyDocument();
         Test.stopTest();
         
         }
        
     }
     
     static testmethod void unitTest3() {
        User testUser = createUser();
           
        System.runAs(testUser) {   
        // setUpTestData(); 
                 /*  Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
          config.Name = 'Test';
          config.Field_Name__c = 'Test';
         config.Object_Name__c = 'Test';
         config.Identifier__c = 'Test';
         insert config;*/
       /*  List<Product_Frequency__c> prodfreqs = CustomSettingsDataFactory.createProduct_Frequency();
         insert prodfreqs;
         List <Billing_Batch__c> billingBatches = new List <Billing_Batch__c>();
         billingBatches = CustomSettingsDataFactory.createBillingBatch();
         insert billingBatches;
        List<Bulk_Order_Configuration__c>  boc = new List<Bulk_Order_Configuration__c>();
        boc = CustomSettingsDataFactory.createBulkOrder();*/
         
        // insert boc;
         Test.startTest();
         
         Zone__c zone = new Zone__c();
         zone.Name = '0';
         insert zone;
      
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Name = '123';
         postal.Name = '100044';
         postal.House_Block_Number__c = '1';
         postal.Address_Type__c = 'A';
         insert postal;
         
        Address_Details__c adDetail = new Address_Details__c();
        adDetail.Postal_Code__c = postal.Id;
        adDetail.Level__c = 'xx';
        adDetail.Unit__c = 'yy';
        insert adDetail;
         
        
         Country__c co = [Select Id,Name, Code__c, Country_Name__c, Zonal_Code__c, Zone__c From Country__c WHERE Name = 'SG' Limit 1];
       //  co.Code__c =  'SG';
      //   co.Name = 'SG';
    //   co.Zonal_Code__c = '0';
       
      //  insert co;
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'A';
         addressRec.Postal_Code__c = postal.Id;
         addressRec.Block_House_Number__c ='TEST';
         addressRec.Level_Number__c ='xx';
         addressRec.Unit_Number__c = 'yy';
         addressRec.Country__c = co.Id;
         addressRec.Address_1__c = 'address1';
         addressRec.Address_2__c = 'address2';
         addressRec.Address_3__c = 'address3';
         addressRec.Address_4__c = 'address4';
         addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
         
         insert addressRec;
         
         Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
         acc.AccountNumber = '91411551';
         acc.Name = 'Bulk Upload Test 1';
         acc.Email__c = 'sample@sph.com';
         acc.Acknowledgement_Letter__c = 'Email';
         acc.Renewal_Letter__c = 'Hard Copy';
         acc.Airline_Indicator__c = false;
         System.debug('account beforeinserted' + acc.AccountNumber);
         acc.Status__c = 'Active';
         acc.Generate_Account_Number__c = false;
        try{
            insert acc;
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
         
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.FirstName = 'Water';
         con.LastName = 'Monkey';
         con.Billing_Account_Name_2__c = 'Bulk Upload Test 1';
         con.Address__c = addressRec.Id;
         con.AccountId = acc.Id;
         con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
         con.Email__c = 'sample@sph.com';
         con.HomePhone__c = '9999222';
         con.Billing_Indicator__c = true;
         con.Recipient_Indicator__c = true;
         insert con; 
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.id;
         billAcc.Billing_Contact__c = con.Id;
         billAcc.Billing_Type__c = 'Full Prepaid';
         billAcc.Zuora__AccountNumber__c = '91411551';
         billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
         billAcc.Other_PaymentMethod__c = 'Internal Storage';
         insert billAcc;
        // System.debug('account inserted' + billAcc.id);
         //String stringVal1 = 'PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,RCAddressRecordType,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,GiftCodes,PromotionCode,GiftCodes,RCAddressRecordType,RCCityCode,RCPackingCode,BCAddressRecordType,BCCityCode,BCPackingCode';
         String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
         //String stringVal2 = 'PackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,123456,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,Other,Invoice,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,Quantity,Internal,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,Internal,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,Gift Codes,PromotionCode,GiftCodes,Test,Airline,RCCityCode,RCPackingCode,Airline,BCCityCode,BCPackingCode';
         String stringVal2 = ',,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,,,, sample@sph.com,,,,,,,,Email,Hard Copy,,,,,,,,,Account,New,,,,,,9999222,,,,,,sample@sph.com,,Local,100044,03,03,TestCountry,,,,,,,,,,,,,,Account,New,,,,,,9999222,,,,,,sample@sph.com,,Local,100044,03,03,TestCountry,,,,,,,,,,,,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,AddonPackageCode,,,,,1,Mailing Agent,';
         //Test.setMock(WebServiceMock.class, new zLoginMock());
                 
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'BulkOrderUploadTemplate';
         //Blob bodyBlob = Blob.valueOf('PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy\nPackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy');
         Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
         doc.body = bodyBlob;
         doc.Type = 'csv';
         doc.ContentType = 'application/vnd.ms-excel';
         insert doc;
          
         
         //Promotion__c
         prom = TestDataFactory.createPromotion(1)[0];
         prom.Promotion_Code__c = 'PackageCode';
         prom.Contract_Period__c = '30';
         insert prom;
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Package_Code__c = 'AddonPackageCode';
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Subscription_Type__c = 'TERMED';
         pack.Package_Price__c = 3;
         pack.Subscription_Period__c = '30';
         insert pack;
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.ID;
         insert promPack;
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'All-In-One';
         zProduct.ProductCode__c = 'POSCHG';
         database.insert(zProduct);
         
         Zone_Product__c zoneProd = new Zone_Product__c();
         zoneProd.Zone__c = zone.id;
         zoneProd.Product__c = zProduct.id;
         zoneProd.Effective_Start_Date__c = Date.Today();
         zoneProd.Postage_Charge__c = 5;
         insert zoneProd;
         
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.SubscriptionFrequency__c = '1';
         prdRatePlan.RatePlanCode__c = 'CHGPOS';
         prdRatePlan.zqu__Deleted__c = false;
  
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.Id;
         database.insert(pItem);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
         insert pub;
         
         Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
         pp.ZProduct__c = zProduct.Id;
         pp.Publication_Code__c = pub.Id;
         insert pp;
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Payment_Mode__c = 'Other';
         order.Other_Payment_Mode__c = 'External Parties';
         order.Billing_Account__c = billAcc.id;
         order.Billing_Type__c = 'Full Prepaid';
         //order.Order_Type__c = 'Start';
         order.Recipient_Contact__c = con.id;
         order.Billing_Contact__c = con.id;
         insert order;
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.Delivered_By__c = 'Mailing Agent';
         orderline.Qty__c = 1;
         orderline.Main_Package_Frequency__c = 'Default';
         insert orderline;
         
       
         BulkOrderUploadController bulkorder = new BulkOrderUploadController();
         bulkorder.orderFile = doc;
         bulkorder.verifyDocument();         
         bulkorder.processDocument();
         bulkorder.retrieveReferenceDoc();
         bulkorder.cancel();
         //bulkorder.testCoveragePatch();
         
         BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
         bulkorder2.orderFile = NULL;
         bulkorder2.verifyDocument();
         Test.stopTest();
         
         }
        
     }
    
    static testmethod void unitTest5() {
        User testUser = createUser();
           
        System.runAs(testUser) {   
        // setUpTestData(); 
                 /*  Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
          config.Name = 'Test';
          config.Field_Name__c = 'Test';
         config.Object_Name__c = 'Test';
         config.Identifier__c = 'Test';
         insert config;*/
       /*  List<Product_Frequency__c> prodfreqs = CustomSettingsDataFactory.createProduct_Frequency();
         insert prodfreqs;
         List <Billing_Batch__c> billingBatches = new List <Billing_Batch__c>();
         billingBatches = CustomSettingsDataFactory.createBillingBatch();
         insert billingBatches;
        List<Bulk_Order_Configuration__c>  boc = new List<Bulk_Order_Configuration__c>();
        boc = CustomSettingsDataFactory.createBulkOrder();*/
         
        // insert boc;
         Test.startTest();
         
         
         Zone__c zone = new Zone__c();
         zone.Name = '0';
         insert zone;
      
        SPH_Company__c comp = new SPH_Company__c();
        comp.name = 'Company';
        comp.Company_Code__c = 'Company';
        insert comp;
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.name = 'Department';
        dept.Department_Code__c = 'Department';
        insert dept;
        
        SPH_Division__c div = new SPH_Division__c();
        div.name = 'Division';
        div.Department_Code__c = 'Division';
        insert div;
        
        SPH_Location__c loc = new SPH_Location__c();
        loc.name = 'Location';
        loc.Location_Code__c = 'Loc';
        insert loc;
        
        SPH_Section__c sec = new SPH_Section__c();
        sec.name = 'Section';
        sec.Section_Code__c = 'Section';
        insert sec;
        
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Name = '123';
         postal.Name = '100044';
         postal.House_Block_Number__c = '1';
         postal.Address_Type__c = 'A';
         insert postal;
         
        
         Country__c co = [Select Id,Name, Code__c, Country_Name__c, Zonal_Code__c, Zone__c From Country__c WHERE Name = 'SG' Limit 1];
       //  co.Code__c =  'SG';
      //   co.Name = 'SG';
    //   co.Zonal_Code__c = '0';
       
      //  insert co;
      
        
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'A';
         addressRec.Postal_Code__c = postal.Id;
         addressRec.Block_House_Number__c ='TEST';
         addressRec.Level_Number__c ='xx';
         addressRec.Unit_Number__c = 'yy';
         addressRec.Country__c = co.Id;
         addressRec.Address_1__c = 'address1';
         addressRec.Address_2__c = 'address2';
         addressRec.Address_3__c = 'address3';
         addressRec.Address_4__c = 'address4';
         addressRec.Company_Code__c = comp.id;
         addressRec.Department__c = dept.id;
         addressRec.Division_Code__c = div.id;
         addressRec.Location_Code__c = loc.id;
         addressRec.Section_Code__c = sec.id;
         addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
         
         insert addressRec;
         
         Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
         acc.AccountNumber = '91411551';
         acc.Name = 'Bulk Upload Test 1';
         acc.Email__c = 'sample@sph.com';
         acc.Acknowledgement_Letter__c = 'Email';
         acc.Renewal_Letter__c = 'Hard Copy';
         acc.Airline_Indicator__c = false;
         System.debug('account beforeinserted' + acc.AccountNumber);
         acc.Status__c = 'Active';
         acc.Generate_Account_Number__c = false;
         insert acc;
         
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.FirstName = 'Water';
         con.LastName = 'Monkey';
         con.Billing_Account_Name_2__c = 'Bulk Upload Test 1';
         con.Address__c = addressRec.Id;
         con.AccountId = acc.Id;
         con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
         con.Email__c = 'sample@sph.com';
         con.HomePhone__c = '9999222';
         con.Billing_Indicator__c = true;
         con.Recipient_Indicator__c = true;
         insert con; 
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.id;
         billAcc.Billing_Contact__c = con.Id;
         billAcc.Billing_Type__c = 'Full Prepaid';
         billAcc.Zuora__AccountNumber__c = '91411551';
         billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
         billAcc.Other_PaymentMethod__c = 'Internal Storage';
         insert billAcc;
        // System.debug('account inserted' + billAcc.id);
         //String stringVal1 = 'PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,RCAddressRecordType,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,GiftCodes,PromotionCode,GiftCodes,RCAddressRecordType,RCCityCode,RCPackingCode,BCAddressRecordType,BCCityCode,BCPackingCode';
         String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
         //String stringVal2 = 'PackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,123456,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,Other,Invoice,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,Quantity,Internal,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,Internal,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,Gift Codes,PromotionCode,GiftCodes,Test,Airline,RCCityCode,RCPackingCode,Airline,BCCityCode,BCPackingCode';
         String stringVal2 = ',,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,,,, sample@sph.com,,,,,,,,Email,Hard Copy,,,,,,,,,Account,New,,,,,,9999222,,,,,,sample@sph.com,,Internal,100044,03,03,TestCountry,,,,,Company,Department,Division,Loc,Section,,,,,Account,New,,,,,,9999222,,,,,,sample@sph.com,,Internal,100044,03,03,TestCountry,,,,,Company,Department,Division,Loc,Section,,,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,AddonPackageCode,,,,,1,Mailing Agent,';
         //Test.setMock(WebServiceMock.class, new zLoginMock());
                 
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'BulkOrderUploadTemplate';
         //Blob bodyBlob = Blob.valueOf('PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy\nPackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy');
         Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
         doc.body = bodyBlob;
         doc.Type = 'csv';
         doc.ContentType = 'application/vnd.ms-excel';
         insert doc;
          
         
         //Promotion__c
         prom = TestDataFactory.createPromotion(1)[0];
         prom.Promotion_Code__c = 'PackageCode';
         prom.Contract_Period__c = '30';
         insert prom;
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Package_Code__c = 'AddonPackageCode';
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Subscription_Type__c = 'TERMED';
         pack.Package_Price__c = 3;
         pack.Subscription_Period__c = '30';
         insert pack;
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.ID;
         insert promPack;
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'All-In-One';
         zProduct.ProductCode__c = 'POSCHG';
         database.insert(zProduct);
         
         Zone_Product__c zoneProd = new Zone_Product__c();
         zoneProd.Zone__c = zone.id;
         zoneProd.Product__c = zProduct.id;
         zoneProd.Effective_Start_Date__c = Date.Today();
         zoneProd.Postage_Charge__c = 5;
         insert zoneProd;
         
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.SubscriptionFrequency__c = '1';
         prdRatePlan.RatePlanCode__c = 'CHGPOS';
         prdRatePlan.zqu__Deleted__c = false;
  
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.Id;
         database.insert(pItem);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
         insert pub;
         
         Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
         pp.ZProduct__c = zProduct.Id;
         pp.Publication_Code__c = pub.Id;
         insert pp;
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Payment_Mode__c = 'Other';
         order.Other_Payment_Mode__c = 'External Parties';
         order.Billing_Account__c = billAcc.id;
         order.Billing_Type__c = 'Full Prepaid';
         //order.Order_Type__c = 'Start';
         order.Recipient_Contact__c = con.id;
         order.Billing_Contact__c = con.id;
         insert order;
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.Delivered_By__c = 'Mailing Agent';
         orderline.Qty__c = 1;
         orderline.Main_Package_Frequency__c = 'Default';
         insert orderline;
         
       
         BulkOrderUploadController bulkorder = new BulkOrderUploadController();
         bulkorder.orderFile = doc;
         bulkorder.verifyDocument();         
         bulkorder.processDocument();
         bulkorder.retrieveReferenceDoc();
         bulkorder.cancel();
         //bulkorder.testCoveragePatch();
         
         BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
         bulkorder2.orderFile = NULL;
         bulkorder2.verifyDocument();
         Test.stopTest();
         
         }
        
     }
     
     static testmethod void unitTest6() {
        User testUser = createUser();
           
        System.runAs(testUser) {   
        // setUpTestData(); 
                 /*  Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
          config.Name = 'Test';
          config.Field_Name__c = 'Test';
         config.Object_Name__c = 'Test';
         config.Identifier__c = 'Test';
         insert config;*/
       /*  List<Product_Frequency__c> prodfreqs = CustomSettingsDataFactory.createProduct_Frequency();
         insert prodfreqs;
         List <Billing_Batch__c> billingBatches = new List <Billing_Batch__c>();
         billingBatches = CustomSettingsDataFactory.createBillingBatch();
         insert billingBatches;
        List<Bulk_Order_Configuration__c>  boc = new List<Bulk_Order_Configuration__c>();
        boc = CustomSettingsDataFactory.createBulkOrder();*/
         
        // insert boc;
         Test.startTest();
         
         
         Zone__c zone = new Zone__c();
         zone.Name = '0';
         insert zone;
      
        
        Packing_Grp__c  pckgrp = new Packing_Grp__c();
        pckgrp.Name = 'Packing';
        pckgrp.Packing_Group_Code__c = 'Packing';
        insert pckgrp;
        
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Name = '123';
         postal.Name = '100044';
         postal.House_Block_Number__c = '1';
         postal.Address_Type__c = 'A';
         insert postal;
         
        
         Country__c co = [Select Id,Name, Code__c, Country_Name__c, Zonal_Code__c, Zone__c From Country__c WHERE Name = 'SG' Limit 1];
       //  co.Code__c =  'SG';
      //   co.Name = 'SG';
    //   co.Zonal_Code__c = '0';
       
      //  insert co;
      
        City__c city = new City__c();
        city.Name = 'City';
        city.City_Legacy_ID__c = 'City';
        city.Flight_Number_1__c = 'City';
        insert city;
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'A';
         addressRec.Postal_Code__c = postal.Id;
         addressRec.Block_House_Number__c ='TEST';
         addressRec.Level_Number__c ='xx';
         addressRec.Unit_Number__c = 'yy';
         addressRec.Country__c = co.Id;
         addressRec.Address_1__c = 'address1';
         addressRec.Address_2__c = 'address2';
         addressRec.Address_3__c = 'address3';
         addressRec.Address_4__c = 'address4';
         addressRec.City__c = city.id;
         addressRec.Packing_Code__c = pckgrp.id;
         addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
         
         insert addressRec;
         
         Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
         acc.AccountNumber = '91411551';
         acc.Name = 'Bulk Upload Test 1';
         acc.Email__c = 'sample@sph.com';
         acc.Airline_Indicator__c = true;
         acc.Acknowledgement_Letter__c = 'Email';
         acc.Renewal_Letter__c = 'Hard Copy';
         acc.Airline_Indicator__c = true;
         System.debug('account beforeinserted' + acc.AccountNumber);
         acc.Status__c = 'Active';
         acc.Generate_Account_Number__c = false;
         insert acc;
         
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.FirstName = 'Water';
         con.LastName = 'Monkey';
         con.Billing_Account_Name_2__c = 'Bulk Upload Test 1';
         con.Address__c = addressRec.Id;
         con.AccountId = acc.Id;
         con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
         con.Email__c = 'sample@sph.com';
         con.HomePhone__c = '9999222';
         con.Billing_Indicator__c = true;
         con.Recipient_Indicator__c = true;
         insert con; 
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.id;
         billAcc.Billing_Contact__c = con.Id;
         billAcc.Billing_Type__c = 'Full Prepaid';
         billAcc.Zuora__AccountNumber__c = '91411551';
         billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
         billAcc.Other_PaymentMethod__c = 'Internal Storage';
         insert billAcc;
        // System.debug('account inserted' + billAcc.id);
         //String stringVal1 = 'PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,RCAddressRecordType,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,GiftCodes,PromotionCode,GiftCodes,RCAddressRecordType,RCCityCode,RCPackingCode,BCAddressRecordType,BCCityCode,BCPackingCode';
         String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
         //String stringVal2 = 'PackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,123456,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,Other,Invoice,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,Quantity,Internal,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,Internal,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,Gift Codes,PromotionCode,GiftCodes,Test,Airline,RCCityCode,RCPackingCode,Airline,BCCityCode,BCPackingCode';
         String stringVal2 = ',,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,,,, sample@sph.com,,,,,,,,Email,Hard Copy,,,,,,,,,Account,New,,,,,,9999222,,,,,,sample@sph.com,,Airline,100044,03,03,TestCountry,,,,,,,,,,Packing,City,,,Account,New,,,,,,9999222,,,,,,sample@sph.com,,Airline,100044,03,03,TestCountry,,,,,,,,,,Packing,City,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,AddonPackageCode,,,,,1,Mailing Agent,';
         //Test.setMock(WebServiceMock.class, new zLoginMock());
                 
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'BulkOrderUploadTemplate';
         //Blob bodyBlob = Blob.valueOf('PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy\nPackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy');
         Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
         doc.body = bodyBlob;
         doc.Type = 'csv';
         doc.ContentType = 'application/vnd.ms-excel';
         insert doc;
          
         
         //Promotion__c
         prom = TestDataFactory.createPromotion(1)[0];
         prom.Promotion_Code__c = 'PackageCode';
         prom.Contract_Period__c = '30';
         insert prom;
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Package_Code__c = 'AddonPackageCode';
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Subscription_Type__c = 'TERMED';
         pack.Package_Price__c = 3;
         pack.Subscription_Period__c = '30';
         insert pack;
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.ID;
         insert promPack;
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'All-In-One';
         zProduct.ProductCode__c = 'POSCHG';
         database.insert(zProduct);
         
         Zone_Product__c zoneProd = new Zone_Product__c();
         zoneProd.Zone__c = zone.id;
         zoneProd.Product__c = zProduct.id;
         zoneProd.Effective_Start_Date__c = Date.Today();
         zoneProd.Postage_Charge__c = 5;
         insert zoneProd;
         
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.SubscriptionFrequency__c = '1';
         prdRatePlan.RatePlanCode__c = 'CHGPOS';
         prdRatePlan.zqu__Deleted__c = false;
  
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.Id;
         database.insert(pItem);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
         insert pub;
         
         Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
         pp.ZProduct__c = zProduct.Id;
         pp.Publication_Code__c = pub.Id;
         insert pp;
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Payment_Mode__c = 'Other';
         order.Other_Payment_Mode__c = 'External Parties';
         order.Billing_Account__c = billAcc.id;
         order.Billing_Type__c = 'Full Prepaid';
         //order.Order_Type__c = 'Start';
         order.Recipient_Contact__c = con.id;
         order.Billing_Contact__c = con.id;
         insert order;
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.Delivered_By__c = 'Mailing Agent';
         orderline.Qty__c = 1;
         orderline.Main_Package_Frequency__c = 'Default';
         insert orderline;
         
       
         BulkOrderUploadController bulkorder = new BulkOrderUploadController();
         bulkorder.orderFile = doc;
         bulkorder.verifyDocument();         
         bulkorder.processDocument();
         bulkorder.retrieveReferenceDoc();
         bulkorder.cancel();
         //bulkorder.testCoveragePatch();
         
         BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
         bulkorder2.orderFile = NULL;
         bulkorder2.verifyDocument();
         Test.stopTest();
         
         }
        
     }
             static testmethod void unitTest7() {
            User testUser = createUser();
               
            System.runAs(testUser) {   
            // setUpTestData(); 
                     /*  Bulk_Order_Configuration__c config = new Bulk_Order_Configuration__c();
              config.Name = 'Test';
              config.Field_Name__c = 'Test';
             config.Object_Name__c = 'Test';
             config.Identifier__c = 'Test';
             insert config;*/
           /*  List<Product_Frequency__c> prodfreqs = CustomSettingsDataFactory.createProduct_Frequency();
             insert prodfreqs;
             List <Billing_Batch__c> billingBatches = new List <Billing_Batch__c>();
             billingBatches = CustomSettingsDataFactory.createBillingBatch();
             insert billingBatches;
            List<Bulk_Order_Configuration__c>  boc = new List<Bulk_Order_Configuration__c>();
            boc = CustomSettingsDataFactory.createBulkOrder();*/
             
            // insert boc;
             Test.startTest();
             
             Zone__c zone = new Zone__c();
             zone.Name = '0';
             insert zone;
          
             Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
             postal.Name = '123';
             postal.Name = '100044';
             postal.House_Block_Number__c = '1';
             postal.Address_Type__c = 'A';
             insert postal;
             
            Address_Details__c adDetail = new Address_Details__c();
            adDetail.Postal_Code__c = postal.Id;
            adDetail.Level__c = 'xx';
            adDetail.Unit__c = 'yy';
            insert adDetail;
             
            
             Country__c co = [Select Id,Name, Code__c, Country_Name__c, Zonal_Code__c, Zone__c From Country__c WHERE Name = 'SG' Limit 1];
           //  co.Code__c =  'SG';
          //   co.Name = 'SG';
        //   co.Zonal_Code__c = '0';
           
          //  insert co;
             
             Address__c addressRec = TestDataFactory.createAddress(1)[0];
             addressRec.Address_Type__c = 'A';
             addressRec.Postal_Code__c = postal.Id;
             addressRec.Block_House_Number__c ='TEST';
             addressRec.Level_Number__c ='xx';
             addressRec.Unit_Number__c = 'yy';
             addressRec.Country__c = co.Id;
             addressRec.Address_1__c = 'address1';
             addressRec.Address_2__c = 'address2';
             addressRec.Address_3__c = 'address3';
             addressRec.Address_4__c = 'address4';
             addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
             
             insert addressRec;
             
             Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
             acc.AccountNumber = '91411551';
             acc.Name = 'Bulk Upload Test 1';
             acc.Email__c = 'sample@sph.com';
             acc.Acknowledgement_Letter__c = 'Email';
             acc.Renewal_Letter__c = 'Hard Copy';
             acc.Airline_Indicator__c = false;
             System.debug('account beforeinserted' + acc.AccountNumber);
             acc.Status__c = 'Active';
             acc.Generate_Account_Number__c = false;
             insert acc;
             
             
             Contact con = TestDataFactory.createContact(1)[0];
             con.FirstName = 'Water';
             con.LastName = 'Monkey';
             con.Billing_Account_Name_2__c = 'Bulk Upload Test 1';
             con.Address__c = addressRec.Id;
             con.AccountId = acc.Id;
             con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
             con.Email__c = 'sample@sph.com';
             con.HomePhone__c = '9999222';
             con.Billing_Indicator__c = true;
             con.Recipient_Indicator__c = true;
             insert con; 
             
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             billAcc.Billing_Contact__c = con.Id;
             billAcc.Billing_Type__c = 'Recurring Prepaid';
             billAcc.Zuora__AccountNumber__c = '91411551';
             billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
             billAcc.Other_PaymentMethod__c = 'Internal Storage';
             insert billAcc;
            // System.debug('account inserted' + billAcc.id);
             //String stringVal1 = 'PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,RCAddressRecordType,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,GiftCodes,PromotionCode,GiftCodes,RCAddressRecordType,RCCityCode,RCPackingCode,BCAddressRecordType,BCCityCode,BCPackingCode';
             String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
             //String stringVal2 = 'PackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,123456,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,Other,Invoice,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,Quantity,Internal,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,Internal,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,Gift Codes,PromotionCode,GiftCodes,Test,Airline,RCCityCode,RCPackingCode,Airline,BCCityCode,BCPackingCode';
             String stringVal2 = '91411551,91411551,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,,,, sample@sph.com,,,,,,,,Email,Hard Copy,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,,,,,,,sample@sph.com,,Local,100044,3,3,TestCountry,,,,,,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,9999222,,,,,,sample@sph.com,,Local,100044,3,3,TestCountry,,,,,,,,,,,,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,AddonPackageCode,,,,,1,Mailing Agent,';
             //Test.setMock(WebServiceMock.class, new zLoginMock());
                     
             Document doc = new Document();
             doc.FolderId = UserInfo.getUserId();
             doc.Name = 'BulkOrderUploadTemplate';
             //Blob bodyBlob = Blob.valueOf('PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy\nPackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy');
             Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
             doc.body = bodyBlob;
             doc.Type = 'csv';
             doc.ContentType = 'application/vnd.ms-excel';
             insert doc;
              
             
             //Promotion__c
             prom = TestDataFactory.createPromotion(1)[0];
             prom.Promotion_Code__c = 'PackageCode';
             prom.Contract_Period__c = '30';
             insert prom;
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             pack.Package_Code__c = 'AddonPackageCode';
             pack.Billing_Type__c = 'Recurring Prepaid';
             pack.Subscription_Type__c = 'TERMED';
             pack.Package_Price__c = 3;
             pack.Subscription_Period__c = '30';
             insert pack;
             
             Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
             promPack.Promotion__c = prom.Id;
             promPack.Package_Name__c = pack.ID;
             insert promPack;
             
             zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
             zProduct.ProductPlatform__c = 'All-In-One';
             zProduct.ProductCode__c = 'POSCHG';
             database.insert(zProduct);
             
             Zone_Product__c zoneProd = new Zone_Product__c();
             zoneProd.Zone__c = zone.id;
             zoneProd.Product__c = zProduct.id;
             zoneProd.Effective_Start_Date__c = Date.Today();
             zoneProd.Postage_Charge__c = 5;
             insert zoneProd;
             
             
             zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
             prdRatePlan.zqu__ZProduct__c = zProduct.Id;
             prdRatePlan.RatePlanType__c= 'Bill Plan';
             prdRatePlan.SubscriptionFrequency__c = '1';
             prdRatePlan.RatePlanCode__c = 'CHGPOS';
             prdRatePlan.zqu__Deleted__c = false;
      
             database.insert(prdRatePlan);
             
             Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
             pItem.Package__c = pack.id;
             pItem.Product_Rate_Plan__c = prdRatePlan.Id;
             database.insert(pItem);
             
             Publication__c pub = TestDataFactory.createPublication(1)[0];
             pub.Earliest_Start_Date__c = date.today()+1;
             pub.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
             insert pub;
             
             Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
             pp.ZProduct__c = zProduct.Id;
             pp.Publication_Code__c = pub.Id;
             insert pp;
             
             Order__c order = TestDataFactory.createOrder(1)[0];
             order.Account__c = acc.Id;
             order.Payment_Mode__c = 'Other';
             order.Other_Payment_Mode__c = 'External Parties';
             order.Billing_Account__c = billAcc.id;
             order.Billing_Type__c = 'Recurring Prepaid';
             //order.Order_Type__c = 'Start';
             order.Recipient_Contact__c = con.id;
             order.Billing_Contact__c = con.id;
             insert order;
             
             Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
             orderline.Order__c = order.Id;
             orderline.Main_Package_ID__c = pack.Id;
             orderline.Delivered_By__c = 'Mailing Agent';
             orderline.Qty__c = 1;
             orderline.Main_Package_Frequency__c = 'Default';
             insert orderline;
             
           
             BulkOrderUploadController bulkorder = new BulkOrderUploadController();
             bulkorder.orderFile = doc;
             bulkorder.verifyDocument();         
             bulkorder.processDocument();
             bulkorder.retrieveReferenceDoc();
             bulkorder.cancel();
             //bulkorder.testCoveragePatch();
             
             BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
             bulkorder2.orderFile = NULL;
             bulkorder2.verifyDocument();
             Test.stopTest();
             
             }
            
         }

     //static testmethod void unitTest3() { 
     //   User testUser = createUser();
            
     //   System.runAs(testUser) {
         
     //    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
     //    //postal.Name = '123';
     //    postal.Name = 'BCPostalCode';
     //    postal.House_Block_Number__c = '1';
     //    postal.Address_Type__c = 'A';
     //    insert postal;
         
     //    Country__c co = new Country__c();
     //    co.Code__c =  'Singapore';
     //    co.Country_Name__c = 'Singapore';
     //    insert co;
         
     //    Address__c addressRec = TestDataFactory.createAddress(1)[0];
     //    addressRec.Address_Type__c = 'A';
     //    addressRec.Postal_Code__c = postal.Id;
     //    addressRec.Block_House_Number__c ='TEST';
     //    addressRec.Level_Number__c ='xx';
     //    addressRec.Unit_Number__c = 'yy';
     //    addressRec.Country__c = co.Id;
     //    addressRec.Address_1__c = 'address1';
     //    addressRec.Address_2__c = 'address2';
     //    addressRec.Address_3__c = 'address3';
     //    addressRec.Address_4__c = 'address4';
     //    insert addressRec;
         
     //    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     //    acc.AccountNumber = '123456';
     //    insert acc;
         
     //    Contact con = TestDataFactory.createContact(1)[0];
     //    con.Address__c = addressRec.Id;
     //    con.AccountId = acc.Id;
     //    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
     //    insert con; 
         
     //    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
     //    billAcc.Zuora__Account__c = acc.id;
     //    billAcc.Billing_Contact__c = con.Id;
     //    billAcc.Billing_Type__c = 'Full Prepaid';
     //    insert billAcc;
         
     //    String stringVal1 = 'PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,RCAddressRecordType,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,GiftCodes,PromotionCode,GiftCodes,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber';
     //    String stringVal2 = 'PackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,123456,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,Other,Invoice,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,Quantity,Internal,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,Internal,RCCompanyCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCDepartmentCode,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy,Gift Codes,PromotionCode,GiftCodes,Test,,Other,Invoice';
         
     //    Document doc = new Document();
     //    doc.FolderId = UserInfo.getUserId();
     //    doc.Name = 'Test Document Name';
     //    //Blob bodyBlob = Blob.valueOf('PromotionCode,PackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,RCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy\nPackageCode,AddonPackageCode,AddonPackageCode,BCPostalCode,BCCountryCode,AccountName,AccountNumber,RCFirstName,RCLastName,BCFirstName,BCLastName,BillingAccountNumber,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,RCPostalCode,CashAmountPaid,StartDate,NewContractPeriod,BCAddressRecordType,RCAddressRecordType,Quantity,AccountRecordType,DeliveryAmount,DeliveryChargeType,Payment Mode,DeliveredBy');
     //    Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
     //    doc.body = bodyBlob;
     //    doc.Type = 'txt';
     //    doc.ContentType = 'Text';
     //    insert doc;
         
     //    Promotion__c prom = TestDataFactory.createPromotion(1)[0];
     //    prom.Promotion_Code__c = 'PackageCode';
     //    prom.Contract_Period__c = '30';
     //    insert prom;
         
     //    Package__c pack = TestDataFactory.createPackage(1)[0];
     //    pack.Package_Code__c = 'AddonPackageCode';
     //    pack.Billing_Type__c = 'Full Prepaid';
     //    pack.Subscription_Type__c = 'TEREMED';
     //    pack.Package_Price__c = 3;
     //    pack.Subscription_Period__c = '30';
     //    insert pack;
         
     //    Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
     //    promPack.Promotion__c = prom.Id;
     //    promPack.Package_Name__c = pack.ID;
     //    insert promPack;
         
     //    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
     //    zProduct.ProductPlatform__c = 'All-In-One';
     //    database.insert(zProduct);
         
     //    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
     //    prdRatePlan.zqu__ZProduct__c = zProduct.Id;
     //    prdRatePlan.RatePlanType__c= 'Bill Plan';
     //    prdRatePlan.SubscriptionFrequency__c = '1';
     //    database.insert(prdRatePlan);
         
     //    Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
     //    pItem.Package__c = pack.id;
     //    pItem.Product_Rate_Plan__c = prdRatePlan.Id;
     //    database.insert(pItem);
         
     //    Publication__c pub = TestDataFactory.createPublication(1)[0];
     //    pub.Earliest_Start_Date__c = date.today()+1;
     //    insert pub;
         
     //    Product_Publication__c pp = TestDataFactory.createProductPublication(1)[0];
     //    pp.ZProduct__c = zProduct.Id;
     //    pp.Publication_Code__c = pub.Id;
     //    insert pp;
         
     //    Order__c order = TestDataFactory.createOrder(1)[0];
     //    order.Account__c = acc.Id;
     //    order.Payment_Mode__c = 'Credit Card';
     //    order.Billing_Account__c = billAcc.id;
     //    order.Billing_Type__c = 'Full Prepaid';
     //    insert order;
         
     //    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
     //    orderline.Order__c = order.Id;
     //    orderline.Main_Package_ID__c = pack.Id;
     //    orderline.Delivered_By__c = 'Vendor';
     //    insert orderline;
         
     //    Test.setMock(WebServiceMock.class, new zLoginMock());
     //    Test.startTest();        
     //    BulkOrderUploadController bulkorder = new BulkOrderUploadController();
     //    bulkorder.orderFile = doc;
     //    bulkorder.retrieveReferenceDoc();
     //    bulkorder.verifyDocument();
     //    //bulkorder.processDocument();
     //    bulkorder.cancel();
         
     //    BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
     //    bulkorder2.orderFile = NULL;
     //    bulkorder2.verifyDocument();
     //    Test.stopTest();
         
     //    }
         
     //}
     
 
 }