/**
 * Class Name: EshopTaggingLDAPTest
 * @author: Accenture IDC (Sudha Kumari)
 * Date: 2/17/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @ test class for EshopTaggingLDAP
 *
 */
@IsTest(seeAllData=true)
global class EshopTaggingLDAPTest {

     public class Request{
        String subscriberId; 
        String asiaOneLdapId;
        }
     public class Response{
        String subscriberId;
        String asiaOneLdapId;
        String svc_status;
        String error_code;
        String error_message;                                     
    }
    
      static testmethod void testInitialize01(){
        
        Test.startTest();   
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTaggingLDAP';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        Request eshMock = new Request();       

        eshMock.subscriberId =''; 
        
        
        String JSONStr = JSON.serialize(eshMock);
        EshopTaggingLDAP.Request esh = (EshopTaggingLDAP.Request) JSON.deserialize(JSONStr, EshopTaggingLDAP.Request.class);
        EshopTaggingLDAP.Response response = EshopTaggingLDAP.processRequest(esh);
        
        Test.stopTest();
    }
    static testMethod void EshopTaggingLDAPTest1() {

     User cso = TestDataFactory.prepareTestUsers();
        // Insert Account
        System.runAs(cso) {
            Account acc = new Account(
                Name = 'Test Account',
                RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                Email__c = 'sample@email.com',
                Mobile__c = '1234567' 
               );
            insert acc;
         String accAutoNumber = [select Account_Auto_Number__c from Account where id =: acc.Id].Account_Auto_Number__c; 
 
        //insert contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.firstName = 'trial';
        con.lastName = 'tail';  
        insert con;
        
        //insert package
        Package__c pkg = TestDataFactory.createPackage(1)[0];
        pkg.Billing_Type__c = 'Add On';
        pkg.Package_Code__c = '5343';
        pkg.name = 'rwere';
        pkg.Effective_Start_Date__c = system.today();
        pkg.Effective_End_Date__c = system.today();
        insert pkg;
        
        //insert Zuora__CustomerAccount__c
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
          billAcc.Name = 'Test Billing Account';
          billAcc.Zuora__Account__c = acc.id;
          billAcc.Billing_Contact__c = con.id;
          billAcc.Zuora__Status__c = 'Active';
        insert billAcc;
        
        // insert Zuora_Subscription__c
        List<Zuora__Subscription__c> zsList = new List<Zuora__Subscription__c>();
        zsList = TestDataFactory.createSubscription(1);
        zsList[0].name = 'abs';
        zsList[0].Zuora__Account__c = acc.id;
        zsList[0].Zuora__CustomerAccount__c = billAcc.id;
        zsList[0].Unique_Address_Id__c='wewe';
        zsList[0].Number_of_Copies__c = 23323223;
        zsList[0].Next_Earliest_Start_Date__c = system.today();
        zsList[0].Year_to_Date_Temp_Stop_Days__c = 3;
        zsList[0].Previous_Year_Temp_Stop_Days__c = 2;
        zsList[0].Legacy_Create_Date__c = 'xc';
        zsList[0].Legacy_Create_By__c = 'wq';
        zsList[0].Legacy_Update_Date__c = 'we';
        zsList[0].Legacy_Update_By__c = 'wer';
        zsList[0].Legacy_Subscription_ID__c = '234';
        zsList[0].Cheque_details__c = 'ew';
        zsList[0].DTL__c = 'rt';
        zsList[0].Paypal_Payment_Profile_Id__c = 're';
        zsList[0].Pub_Tag__c = 'reere';
        zsList[0].Sponsored_Indicator__c = 'er';
        zsList[0].Subscribe_As__c = 'rew';
        zsList[0].Zuora__SubscriptionEndDate__c = system.today().addDays(30);
        zsList[0].Subscription_Grace_Period_End_Date__c = 'rty';
        zsList[0].Gift_ID__c = 'ere';
        zsList[0].Redeem_Date__c = 'ukvvgk';
        zsList[0].Gift_ID_2__c = 'fdfs';
        zsList[0].Redeem_Date_2__c = 'fsf';
        zsList[0].Subscriber_Contact__c = con.id;
        zsList[0].Subscription_Charge__c = 43;
        zsList[0].Term_Length__c = 43;
        zsList[0].Main_Package_1__c = pkg.id;
        zsList[0].Zuora__Zuora_Id__c = 'dsfdd';
        zsList[0].Zuora__Status__c = 'Active';
        insert zsList;     
        
        Publication__c pub = new Publication__c();
        pub.name = 'wow';
        pub.Publication_Code__c = 'qweq';
        pub.Published_Days__c = 'NNYYNNY';
        pub.Publication_Type__c = 'e';
        insert pub;
       
        test.startTest();
       try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());    
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EshopTaggingLDAP';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        Request eshMock =new Request();
        eshMock.subscriberId = accAutoNumber;
        
        //Convert it to the actual Request Stub by using Json.serialize and Json.deserialize.
        EshopTaggingLDAP.Request esReq2 = new EshopTaggingLDAP.Request();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EshopTaggingLDAP.Request)JSON.deserialize(jsonStr, EshopTaggingLDAP.Request.class);
        EshopTaggingLDAP.Response response = EshopTaggingLDAP.processRequest(esReq2);  
        
         Test.stopTest();        
    } 
    catch (Exception e) {}
    }
  }      
        // Insert Subscription related to this Zoura Account
      /*  EshopTaggingLDAP etl = new EshopTaggingLDAP();
        EshopTaggingLDAP.Request testReq = new EshopTaggingLDAP.Request();
        
          testReq.subscriberId = accAutoNumber;     
           //testReq.asiaOneLdapId = '2A.BCXYZ23';
           test.starttest();
           EshopTaggingLDAP.processRequest(testReq);
           system.assertEquals(zsList[0].Zuora__Status__c, 'Active');
           test.stoptest();
           }
        } */
    
      static testMethod void EshopTaggingLDAPTest2() {
      
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            insert pub;
            //Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage();
          // Order_Line_Item__c testAccount = (Order_Line_Item__c) sobjectMap.get('Order_Line_Item__c');
          // testAccount.End_Date__c = date.newInstance(2017, 12, 2);
          // testAccount.
        //    insert testAccount;
            
          //  Account testAccount = (Account) sobjectMap.get('Account');
          //  List<account> a =  [select id,Account_Auto_Number__c from account where id = : testAccount.id];
          //  system.debug('zzzzzzzzzzzzzzzzzzzzzzzzzz'+a);
          //   system.debug('ppppppppppppppppppppppp'+a[0].Account_Auto_Number__c);
            // Insert Subscription related to this Zoura Account
            EshopTaggingLDAP.Request testReq = new EshopTaggingLDAP.Request();
    
        //   testReq.subscriberId = a[0].Account_Auto_Number__c;
           //system.debug('bbbbbbbbbbbbbbbbbbbb'+testReq.subscriberId );     
           //testReq.asiaOneLdapId = 'ABCXYZ';
           //system.debug('vvvvvvvvvvvvvvvvvvvv'+testReq.asiaOneLdapId);
           test.starttest();
           EshopTaggingLDAP.processRequest(testReq);
           
           test.stoptest();
     
      
      } 
      static testMethod void EshopTaggingLDAPTest3() {
          try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
            
            Singpost_Address__c postal = new Singpost_Address__c();
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
            acc.Generate_Account_Number__c = true;
            insert acc;

             Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con; 
                /*
                Contact con = TestDataFactory.createContactRecType(1,'Customer Contact')[0];
                contact.name = acc.id;
                insert con; */
               
            
            
           
            Package__c pack = new Package__c();
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Add On';
            //pack.Product_Family_for_Add_On_Packages_del__c = 'ST';
            pack.Package_Type__c = 'Grace Period';
            pack.Package_Sub_Type__c = 'Extension';
            pack.Subscription_Period__c = '1';
            pack.Subscription_Type__c = 'Termed';
            pack.Product_Family_Current_Package__c ='abc';
            pack.Package_Code__c = 'afds132';
            pack.Effective_Start_Date__c = system.today();
            pack.Effective_End_Date__c = system.today() +360;
            //pack.Subscription_Type__c = 'Termed';
            insert pack;
            
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            insert pub;
            
            zqu__ZProduct__c zp = new zqu__ZProduct__c();
            zp.Name = 'Test1';
            zp.zqu__ZuoraId__c = 'ZId123';
            zp.zqu__SKU__c = 'SKU';
            zp.ProductType__c = 'Bill To';
            zp.ProductCode__c = 'ABC123';
            insert zp;
            
            zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c();
            prp.name = 'Test';
            prp.zqu__ZuoraId__c = 'TestId';
            prp.zqu__ZProduct__c = zp.id;
            prp.RatePlanType__c = 'Proration';
            prp.RatePlanCode__c = 'Test123';
            insert prp;
            
            zqu__ProductRatePlanCharge__c zprpc =  new zqu__ProductRatePlanCharge__c();
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prp.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
            insert zprpc;
            
            Product_Family__c pf = new Product_Family__c();
            pf.Product_Family__c = 'abc';
            insert pf;
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];                                      // new Package_Item__c();
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prp.id;
            pItem.Name = 'Test Pack Item';
            pItem.Product_Family__c = pf.id;
            pItem.Product_Rate_Plan__c = prp.id;
            insert pItem; 
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full';
            insert billAcc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
       // con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
            
            
            Order__c order = TestDataFactory.createOrder(1)[0];
        order.Billing_Type__c = 'Full';
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
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
            
          
         Order_Line_Item__c orderline = new Order_Line_Item__c();
        orderline.Order__c = order.Id;
        //orderline.End_Date__c = date.newInstance(2014, 12, 2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c =date.newInstance(2016, 12, 2);
        orderline.Stop_Request_Date__c = date.newInstance(2016, 12, 2);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        //orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Delivered_By__c = 'Vendor';
        orderline.Main_Package_Type__c = 'Base';
        orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline.End_Date__c = date.newInstance(2016, 12, 2);
        insert orderline;
        
    String accountNum = [Select Account_Auto_Number__c From Account Where Account_Auto_Number__c != NULL and Id =: acc.Id limit 1].Account_Auto_Number__c;
        system.debug('aaaa accountNum'+accountNum);
        //  Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage();
            
        //  Account testAccount = (Account) sobjectMap.get('Account');
       //   Zuora__Subscription__c sub = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c');
       // system.debug('rpr sub '+sub.id);
       // system.debug('rpr testAccount '+testAccount.id);
            
            Zuora__Subscription__c subRecs = new Zuora__Subscription__c();
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Generate_Invoice1__c = 'false';
        subrecs.Zuora__SubscriptionStartDate__c = system.today();
        insert subRecs;
     //   objectMap.put('Zuora__Subscription__c', subRecs);  
   //     system.debug('rrrrrrrrrrrrrrrrrrrrrr object map'+objectMap);
     
            
       //     List<account> a =  [select id,Account_Auto_Number__c from account where id = : testAccount.id];
        //    system.debug('zzzzzzzzzzzzzzzzzzzzzzzzzz'+a);
             
            // Insert Subscription related to this Zoura Account
           EshopTaggingLDAP.Request testReq = new EshopTaggingLDAP.Request();
           //testReq.subscriberId = accountNum ;     
           //testReq.asiaOneLdapId = '2A.BCXYZ23';
           test.starttest();
           EshopTaggingLDAP.processRequest(testReq);
           test.stoptest();
          
          }catch(Exception e) {
          }  
                  
    
  }  
       
    static testMethod void EshopTaggingLDAPTest4() {
    
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            Singpost_Address__c postal = new Singpost_Address__c();
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            insert postal;
            
            Address__c addressRec =  new Address__c();
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            insert addressRec;
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Generate_Account_Number__c = true;
            insert acc;
            
            //System.AssertEquals(null, acc.AccountNumber);
            //System.AssertEquals(null, acc.AccountNumber);

             Contact con = TestDataFactory.createContact(1)[0];
         //    con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
           
            Package__c pack = new Package__c();
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Add On';
            //pack.Product_Family_for_Add_On_Packages_del__c = 'ST';
            pack.Package_Type__c = 'Grace Period';
            pack.Package_Sub_Type__c = 'Extension';
            pack.Subscription_Period__c = '1';
            pack.Subscription_Type__c = 'Termed';
            pack.Product_Family_Current_Package__c ='abc';
            pack.Package_Code__c = 'afds132';
            pack.Effective_Start_Date__c = system.today();
            pack.Effective_End_Date__c = system.today() +360;
            //pack.Subscription_Type__c = 'Termed';
            insert pack;
            
            Publication__c pub = new Publication__c();
            pub.name = 'wow';
            pub.Publication_Code__c = 'qweq';
            pub.Published_Days__c = 'NNYYNNY';
            pub.Publication_Type__c = 'e';
            insert pub;
            
            zqu__ZProduct__c zp = new zqu__ZProduct__c();
            zp.Name = 'Test1';
            zp.zqu__ZuoraId__c = 'ZId123';
            zp.zqu__SKU__c = 'SKU';
            zp.ProductType__c = 'Bill To';
            zp.ProductCode__c = 'ABC123';
            insert zp;
            
            zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c();
            prp.name = 'Test';
            prp.zqu__ZuoraId__c = 'TestId';
            prp.zqu__ZProduct__c = zp.id;
            prp.RatePlanType__c = 'Proration';
           // prp.RatePlanType__c = 'Bill To';
            prp.RatePlanCode__c = 'Test123';
            insert prp;
            
            zqu__ProductRatePlanCharge__c zprpc =  new zqu__ProductRatePlanCharge__c();
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prp.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
            insert zprpc;
            
            Product_Family__c pf = new Product_Family__c();
            pf.Product_Family__c = 'abc';
            insert pf;
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];                                      // new Package_Item__c();
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prp.id;
            pItem.Name = 'Test Pack Item';
            pItem.Product_Family__c = pf.id;
            insert pItem; 
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full';
            insert billAcc;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            insert con1;
                
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Billing_Type__c = 'Full';
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            //order.Postage_Charge__c = 200.00;
            insert order;
          
            Order_Line_Item__c orderline = new Order_Line_Item__c();
            orderline.Order__c = order.Id;
            //orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c =date.newInstance(2016, 12, 2);
            orderline.Stop_Request_Date__c = date.newInstance(2016, 12, 2);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
           // orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Delivered_By__c = 'Vendor';
            orderline.Main_Package_Type__c = 'Base';
            orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline.End_Date__c = date.newInstance(2016, 12, 2);
            insert orderline;
 
            Zuora__Subscription__c subRecs = new Zuora__Subscription__c();
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            //subRecs.Subscriber_Contact__c = con.Id;
            //Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            //subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number_1__c = order.id;
            //subRecs.Zuora__Status__c = 'Active';
            subRecs.Generate_Invoice1__c = 'false';
            subrecs.Zuora__SubscriptionStartDate__c = system.today();
            insert subRecs;

            //String accountNum = [Select Account_Auto_Number__c From Account Where Account_Auto_Number__c != NULL and Id =: acc.Id limit 1].Account_Auto_Number__c;            
            
            Account accountNum = [Select Account_Auto_Number__c From Account Where Id =: acc.Id];        
            
            //joyax
           /* Asia1__c as1 = TestDataFactory.createAsiaOne(1)[0];
            as1.Display_Name__c = 'test';
            insert as1;
            
            Asia1_Subscription__c asia1Sub = new Asia1_Subscription__c();
            asia1Sub.Subscription__c = subRecs.Id;
            asia1Sub.Asia1__c = as1.Id;
            asia1Sub.Status__c = 'Enabled';
            insert asia1Sub;
            
            Set<Id> zSubsId = new Set<Id>();
            zSubsId.add(subRecs.Id);*/
            //joyax
             
            test.starttest();
                
                Request req = new Request();
                //req.subscriberId = acc.AccountNumber;
                req.subscriberId = accountNum.Account_Auto_Number__c;
                system.assertEquals(null,accountNum.Account_Auto_Number__c);
                req.asiaOneLdapId = '2A.BCXYZ23';
                String JSONData = JSON.serialize(req);
                EshopTaggingLDAP.Request requ = (EshopTaggingLDAP.Request) JSON.deserialize(JSONData, EshopTaggingLDAP.Request.class);
                EshopTaggingLDAP.Response respo = EshopTaggingLDAP.processRequest(requ);
                
                EshopTaggingLDAP.checkMandatoryFields(requ);
                
            test.stoptest();
            
            
            
            
          }catch(Exception e) {
          }  
                  
    
  }  
}