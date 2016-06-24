/*
* Class Name: <EShopTempStopServiceTest>
* @author: Reszel Garrie Pineda
* Date: 2/26/2015
* Requirement/Project Name: <SPH>
* @description: Test class for EShopTempStopService
*/
@isTest
private class EShopTempStopServiceTest{
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createPlannerSched();      
        insert CustomSettingsDataFactory.createOther(); 
        //START PD-0114 10-May-2016 Added by Raviteja - Creating Custom settings
        insert CustomSettingsDataFactory.createError_Messages();
        insert CustomSettingsDataFactory.createUom();       
        //END PD-0114 10-May-2016 Added by Raviteja -
    }  
    
    public class EShopRequest{
        String actionIndicator;
        String subscriberId; 
        String subscriptionId;
        String tempStopId;
        String tempStopDate;
        String restartDate;
        String remarks;
        String source;
        String tempReasonCode;
    }
    
    public class EShopResponse{
        String svc_status;
        String error_code; 
        String error_message;
        String subscriberId;
        String subscriptionId;
        String tempStopId;                                     
    }
    
    /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testEShopTempStopService1(){
        
        Test.startTest();   
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock =new EShopRequest();       
        eshMock.actionIndicator ='';
        eshMock.subscriptionId='';
        eshMock.subscriberId =''; 
        
        
        String JSONStr = JSON.serialize(eshMock);
        EShopTempStopService.EShopRequest esh = (EShopTempStopService.EShopRequest) JSON.deserialize(JSONStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esh);
        
        Test.stopTest();
    }//end of testEShopTempStopService1
    
    /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testEShopTempStopService2(){
        Test.startTest();    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        
        EShopRequest eshMock =new EShopRequest();
        eshMock.actionIndicator ='ADD';
        eshMock.subscriptionId='';
        eshMock.tempStopId ='';
        eshMock.tempStopDate = '';
        eshMock.restartDate ='';
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();     
        
    }//end of testEShopTempStopService2
    
     /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testEShopTempStopService3(){
        Test.startTest();    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock =new EShopRequest();
        eshMock.actionIndicator ='UPDATE';
        eshMock.subscriptionId='';
        eshMock.tempStopId ='';
        eshMock.tempStopDate ='';
        eshMock.restartDate ='';
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        
        String JSONStr = JSON.serialize(eshMock);
        EShopTempStopService.EShopRequest esh = (EShopTempStopService.EShopRequest) JSON.deserialize(JSONStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esh);
        
        Test.stopTest();     
    }//end of testEShopTempStopService3
    
    /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testEShopTempStopService4(){
        Test.startTest();    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock =new EShopRequest();
        eshMock.actionIndicator ='CANCEL';
        eshMock.subscriberId = '';        
        eshMock.subscriptionId='';
        eshMock.tempStopId ='';
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();     
    }//end of testEShopTempStopService4
    
    /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testEShopTempStopService5(){
        
        //Create account a
       
        Recordtype rectype = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Direct_Corporate'];   
        Account a = new Account();
        a.RecordtypeID = rectype.id;
        a.Name = 'TestAccount';
        a.Email__c = 'aprilgrace@email.com';
        a.Mobile__c = '55555512';
        insert a;
        
        //Create case ca
        Case ca = new Case();
        ca.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
        ca.Account = a;
        insert ca;
        
        //Insert Billing Account *
        Zuora__CustomerAccount__c ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = a.Id;
        insert ba;
        
        
        //Create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        insert addressList;
        
        //Create contact con
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = a.Id;
        con.Address__c = addressList[0].Id;
        con.Recipient_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
        
        //Create order order *
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = a.id;
        order.Subscriber_Charge__c = 100;
        order.Delivery_Charge__c = 100;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 12.00;
        order.Informed_Customer__c = true;
        order.Recipient_Contact__c = con.id;
        order.Credit_Balance__c = 1.00;
        order.Order_Type__c = 'Change of Subscription Package';
        order.Status__c = 'Draft';
        insert order;
        
        //Create package pack
        Package__c pack = new Package__c();
        
        pack.Package_Type__c = 'Base';
        pack.Name = 'TestPackageName';
        pack.Subscription_Type__c = 'Termed';
        pack.Channel_Direct__c = true;
        pack.Channel_E_shop_overseas__c = true;
        pack.Channel_E_shop_private__c = true;
        pack.Channel_E_shop_public__c = true;
        pack.Subscription_Period__c = '35';
        pack.Package_Code__c = 'SamplePackageCode';
        pack.Effective_Start_Date__c = date.Today();
        pack.Effective_End_Date__c = date.Today() + 30;
        insert pack;
        
        //Insert case
        /* Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
cas.Order__c = order.Id;
insert new List<sObject>{cas};*/
        
        //Create order line item
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Case__c = ca.id;
        oli.Earliest_Start_Date__c = date.Today();
        oli.Start_Date__c = date.Today().addDays(1);
        oli.Main_Package_Period__c = 35;
        //oli.Qty__c = 1;
        oli.Main_Package_ID__c = pack.id;
        oli.Delivered_By__c = 'Vendor'; 
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Order__c = order.id;
        
        insert oli;
        
        //Create subscrption Sub
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0]; 
        sub.Name = 'sample';  
        sub.Number_of_Copies1__c = '2';     
        sub.Zuora__Account__c = a.Id;
        sub.Zuora__CustomerAccount__c = ba.Id;
        sub.Order_Line_Item_Number__c = oli.Id;
        sub.Subscriber_Contact__c = con.Id;
        sub.Number_of_Copies__c = 5;
        sub.Recipient_Contact__c = con.Id;
        sub.Subscription_Charge__c = 123;
        sub.Term_Length__c = 12;
        sub.Main_Package_1__c = pack.id;
        sub.Zuora__Status__c = 'Active';
        sub.Order_Number_1__c = order.Id;
        sub.Suppress_Vendor_Start_Notice__c = 'false';
        sub.Supressed_Acknowledgement_Letter__c = 'false';
        sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        sub.Year_to_Date_Temp_Stop_Days__c = 2;
        sub.Previous_Year_Temp_Stop_Days__c = 1;
        sub.Urgent__c = 'false';
        sub.Vendor_Conversion__c = 'false';
        sub.Zuora__Zuora_Id__c = '1123';
        sub.Charity__c = 'false';
        sub.Subscription_Type__c = 'Publication';
        sub.Delivery_Charge__c = 100;
        sub.Sponsor_1__c = true;
        sub.Qty__c = 2; // JURNA ADDED
        insert sub;
        
        Temp_Stop__c tempstop = new Temp_Stop__c();
        tempstop.Order__c=order.Id;
        insert tempstop;
        
        
        List<Subscription_Temp_Stop__c> subTemp = new List<Subscription_Temp_Stop__c>();
        Subscription_Temp_Stop__c subtempstop = new Subscription_Temp_Stop__c(); 
        subtempstop.Subscription__c= sub.id;
        subtempstop.Temp_Stop__c = tempstop.id;
        subTemp.add(subtempstop);    
        //subTemp[0].Temp_Stop__c= tempstop.id;   
        insert subTemp;
        
        
        Test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());    
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock =new EShopRequest();
        
        //Convert it to the actual Request Stub by using Json.serialize and Json.deserialize.
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);  
        
        //EShopTempStopService.EShopRequest validate = new EShopTempStopService.EShopRequest('tempstop',esReq2);
        //EShopTempStopService.validateOverlapping validate2 = new EShopTempStopService.validateOverlapping

    //('tempstop',esReq2);    
        
        Test.stopTest();        
    } catch (Exception e) {
    }
    }//end of testEShopTempStopService5
    
    
    /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testEShopTempStopService6(){
        
        // tempStopDate = restartDate
        Test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock()); 
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock =new EShopRequest();
        eshMock.actionIndicator ='Test';
        eshMock.subscriptionId='';
        eshMock.tempStopId ='';
        eshMock.tempStopDate = '2/25/2015'; 
        eshMock.restartDate = '2/25/2015'; //string.valueOf(date.today().addDays(2));
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();
        } catch (Exception e) {
        }     
        
    }//end of testEShopTempStopService6
    
    /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testEShopTempStopService7(){
        
        
        
        
        //Create account a
        Recordtype rectype = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Direct_Corporate'];   
        Account a = new Account();
        a.RecordtypeId = rectype.id;
        a.Name = 'TestAccount';
        a.Email__c = 'aprilgrace@email.com';
        a.Mobile__c = '55555512';
        insert a;
        
        //Create case ca
        Case ca = new Case();
        ca.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
        ca.Account = a;
        insert ca;
        
        //Create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        insert addressList;
        
        //Create contact con
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = a.Id;
        con.Address__c = addressList[0].Id;
        con.Recipient_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = a.Id;
        insert ba;
        
        //Create order order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = a.id;
        order.Delivery_Charge__c = 1.00;
        order.Subscriber_Charge__c = 200.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 12.00;
        order.Informed_Customer__c = true;
        order.Recipient_Contact__c = con.id;
        order.Credit_Balance__c = 1.00;
        order.Order_Type__c = 'Change of Subscription Package';
        order.Status__c = 'Draft';
        insert order;
        
        //Create package pack
        Package__c pack = new Package__c();
        pack.Package_Type__c = 'Base';
        pack.Name = 'TestPackageName';
        pack.Subscription_Type__c = 'Termed';
        pack.Channel_Direct__c = true;
        pack.Channel_E_shop_overseas__c = true;
        pack.Channel_E_shop_private__c = true;
        pack.Channel_E_shop_public__c = true;
        pack.Subscription_Period__c = '35';
        pack.Package_Code__c = 'SamplePackageCode';
        pack.Effective_Start_Date__c = date.Today();
        pack.Effective_End_Date__c = date.Today() + 30;
        insert pack;
        
        
        //Create order line item
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Case__c = ca.id;
        oli.Earliest_Start_Date__c = date.Today();
        oli.Start_Date__c = date.Today().addDays(1);
        oli.Main_Package_Period__c = 35;
        //oli.Qty__c = 1;
        oli.Main_Package_ID__c = pack.id;
        oli.Delivered_By__c = 'Vendor'; 
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Order__c = order.id;
       
        
        insert oli;
        
        //Create subscrption Sub
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
        sub[0].Zuora__Account__c = a.Id;
        sub[0].Zuora__Zuora_Id__c = '1123';  // JURNA ADDED
        sub[0].Name = 'Zuora1'; // JURNA ADDED  
        sub[0].Number_of_Copies1__c = '2';
        sub[0].Zuora__CustomerAccount__c = ba.id;
        sub[0].Subscriber_Contact__c = con.Id;
        sub[0].Order_Line_Item_Number__c = oli.Id;
        sub[0].Subscriber_Contact__c = con.Id;
        sub[0].Subscription_Charge__c = 100.00;
        sub[0].Recipient_Contact__c = con.Id;
        sub[0].Main_Package_1__c = pack.id;
        sub[0].Delivery_Charge__c = 200.00;
        sub[0].Term_Length__c = 10;
        sub[0].Zuora__Status__c = 'Active';
        sub[0].Order_Number__c = order.Id;
        sub[0].Suppress_Vendor_Start_Notice__c = 'false';
        sub[0].Supressed_Acknowledgement_Letter__c = 'false';
        sub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        sub[0].Urgent__c = 'false';
        sub[0].Vendor_Conversion__c = 'false';
        sub[0].Charity__c = 'false';
        sub[0].Subscription_Type__c = 'Publication';
        sub[0].Zuora__SubscriptionEndDate__c= date.today()+100;
        sub[0].Zuora__SubscriptionStartDate__c = date.today();
        sub[0].Qty__c = 2; // JURNA ADDED
        
        System.debug('sub[0].Delivery_Charge__c' + sub[0].Delivery_Charge__c);
        System.debug('sub[0].Order_Line_Item_Number__c' + sub[0].Order_Line_Item_Number__c);
        
        Test.startTest();        
        insert sub;
        
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock()); 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Test';
        eshMock.subscriptionId=sub[0].id;
        eshMock.subscriberid = a.Account_Auto_Number__c;
        eshMock.tempStopId ='';
        eshMock.tempStopDate = string.valueOf(date.today().addDays(1));
        eshMock.restartDate = string.valueOf(date.today().addDays(2));
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();         
        } catch (Exception e) {
        }     
        
    }//end of testEShopTempStopService7  
    
    /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testAddNotNull(){
        Test.startTest();    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock =new EShopRequest();
        eshMock.actionIndicator ='';
        eshMock.subscriptionId='';
        eshMock.tempStopId ='';
        eshMock.tempStopDate ='';
        eshMock.restartDate ='';
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();   
    }//end of testAddNotNull   
    
    /* @description: This method checks negative scenario (wrong date) of EShopTempStopService methods */ 
    static testmethod void testTempStopDate(){
        Test.startTest();    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock =new EShopRequest();
        eshMock.tempStopDate ='2/2/2014';
        eshMock.restartDate ='2/2/2014';
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        
        String JSONStr = JSON.serialize(eshMock);
        EShopTempStopService.EShopRequest esh = (EShopTempStopService.EShopRequest) JSON.deserialize(JSONStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esh);
        
        Test.stopTest();     
    }//end of testTempStopDate   
    
    /* @description: This method checks postive scenario of EShopTempStopService methods 
     * using Add in actionIndicator*/
    static testmethod void testEShopTempStopServiceAdd(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id].Account_Auto_Number__c;     
          
        
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(1);
        TS.Restart_Date__c = date.today().addDays(2);
        TS.Remarks__c = 'Ok';
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sat';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'Online';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        
        test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Add';
        eshMock.subscriptionId= 'Zuora1';
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = String.valueOf(TS.id);
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();
        } catch (Exception e) {
        }     
        
    }//end of testEShopTempStopServiceAdd
    
      static testmethod void testEShopTempStopServiceAdd2(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id].Account_Auto_Number__c;     
          
        
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(1);
        TS.Restart_Date__c = date.today().addDays(2);
        TS.Remarks__c = 'Ok';
        insert TS;
           
        /*Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;*/
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sat';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'Online';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        
        test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Add';
        eshMock.subscriptionId= 'Zuora1';
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = String.valueOf(TS.id);
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();
        } catch (Exception e) {
        }     
        
    }//end of testEShopTempStopServiceAdd2
    
     static testmethod void testEShopTempStopServiceUpdate(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id].Account_Auto_Number__c;     
          
        
       
        

        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        //Insert Package
        Package__c p = TestDataFactory.createPackage(1)[0];
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Sub_Type__c = 'Single';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        //Contact c = new Contact();
        Contact c = TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        //Order__c o = new Order__c();
        Order__c o = TestDataFactory.createOrder(1)[0];
        o.Account__c = accList[0].id;     
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        lO.add(o);
        Insert lO;
 
        
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        cas.Qty__c = 1;
        cas.Temp_Stop_Type__c = 'Update';
        insert cas;
 
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pub.Platform_Type__c = 'Print';
        insert pub;
 
         
        //Insert 
        //Subscription_Vendor__c sv = new Subscription_Vendor__c();
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];         
        lSV.add(sv);
        Insert lSV;
            
        //Insert Order_Line_Item
        //Order_Line_Item__c oli = new Order_Line_Item__c();
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Main_Package__c = String.valueOf(lPck[0].Id);
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        
        lZS.add(zs);
        Insert lZS;
        
        String zsName = [select Name from Zuora__Subscription__c where id =: zs.Id].Name;
        
                
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(1);
        TS.Restart_Date__c = date.today().addDays(2);
        TS.Remarks__c = 'Ok';
        insert TS;
        String tmpName = [select Name from Temp_Stop__c where id =: TS.Id].Name;     
        
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        
        insert PRPC;
        
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = lPck[0].Id;
        pItem.Product_Rate_Plan__c = PRP.Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        
        test.startTest();
        insert pItem;
        
         
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today().addDays(2);
        npub.Publication_Code__c = '1234';
        insert npub;
        
        //test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());  

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Update';
        eshMock.subscriptionId= zsName;
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = tmpName;
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        Zuora__Subscription__c zSub = [select Id, Name, Main_Package_1__c From Zuora__Subscription__c Where Name= :eshMock.subscriptionId limit 1];        
        //System.assertEquals(zs.Main_Package_1__c,zSub.Main_Package_1__c);        
        List<Package_Item__c> pckItemList = [Select Id, Name, Product_Rate_Plan__c, Package__c From Package_Item__c Where Package__c = :zs.Main_Package_1__c];
        //System.assertEquals(True, pckItemList.size()>0);
        //System.assertEquals(True, pckItemList<>null);
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
         Test.stopTest();
         } catch (Exception e) {
         }     
        
    }//end of testEShopTempStopServiceUpdate   
    
     
    
    /* @description: This method checks postive scenario of EShopTempStopService methods 
     * using Update in actionIndicator*/
    static testmethod void testEShopTempStopServicAdd3(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id].Account_Auto_Number__c;     
          
        
       
        

        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        //Insert Package
        Package__c p = TestDataFactory.createPackage(1)[0];
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Sub_Type__c = 'Single';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        //Contact c = new Contact();
        Contact c = TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        //Order__c o = new Order__c();
        Order__c o = TestDataFactory.createOrder(1)[0];
        o.Account__c = accList[0].id;     
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        lO.add(o);
        Insert lO;
 
        
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        cas.Qty__c = 1;
        cas.Temp_Stop_Type__c = 'Update';
        insert cas;
 
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pub.Platform_Type__c = 'Print';
        insert pub;
 
         
        //Insert 
        //Subscription_Vendor__c sv = new Subscription_Vendor__c();
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];         
        lSV.add(sv);
        Insert lSV;
            
        //Insert Order_Line_Item
        //Order_Line_Item__c oli = new Order_Line_Item__c();
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Main_Package__c = String.valueOf(lPck[0].Id);
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        
        lZS.add(zs);
        Insert lZS;
        
        String zsName = [select Name from Zuora__Subscription__c where id =: zs.Id].Name;
        
                
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(1);
        TS.Restart_Date__c = date.today().addDays(2);
        TS.Remarks__c = 'Ok';
        insert TS;
        String tmpName = [select Name from Temp_Stop__c where id =: TS.Id].Name;     
        
           
        /*Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;*/
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        
        insert PRPC;
        
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = lPck[0].Id;
        pItem.Product_Rate_Plan__c = PRP.Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        
        test.startTest();
        insert pItem;
        
         
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today().addDays(2);
        npub.Publication_Code__c = '1234';
        insert npub;
        
        //test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());  

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Add';
        eshMock.subscriptionId= zsName;
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = tmpName;
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        Zuora__Subscription__c zSub = [select Id, Name, Main_Package_1__c From Zuora__Subscription__c Where Name= :eshMock.subscriptionId limit 1];        
        //System.assertEquals(zs.Main_Package_1__c,zSub.Main_Package_1__c);        
        List<Package_Item__c> pckItemList = [Select Id, Name, Product_Rate_Plan__c, Package__c From Package_Item__c Where Package__c = :zs.Main_Package_1__c];
        //System.assertEquals(True, pckItemList.size()>0);
        //System.assertEquals(True, pckItemList<>null);
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
         Test.stopTest();
         } catch (Exception e) {
         }     
        
    }//end of testEShopTempStopServiceAdd3  
    
    /* @description: This method checks postive scenario of EShopTempStopService methods 
     * using Cancel in actionIndicator*/
    static testmethod void testEShopTempStopServiceCancel(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id limit 1].Account_Auto_Number__c;     
          
        //System.assertEquals('12345', accList[0].AccountNumber);
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;     
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; //JURNA ADDED
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(1);
        TS.Restart_Date__c = date.today().addDays(2);
        TS.Remarks__c = 'Ok';
        insert TS;
        String tmpName = [select Name from Temp_Stop__c where id =: TS.Id limit 1].Name;
             
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        
        test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Cancel';
        eshMock.subscriptionId= 'Zuora1';
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = tmpName;
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        System.assertEquals('Cancel', eshMock.actionIndicator);
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();     
         } catch (Exception e) {
         }
    }//end of testEShopTempStopServiceCancel   
    
    /* @description: This method checks negative scenario of EShopTempStopService methods 
     * using Add in actionIndicator*/
    static testmethod void testEShopTempStopServiceAddError1(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id limit 1].Account_Auto_Number__c;     
          
        //System.assertEquals('12345', accList[0].AccountNumber);
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(4);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(2);
        TS.Restart_Date__c = date.today().addDays(3);
        TS.Remarks__c = 'Ok';
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        
        
        test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Add';
        eshMock.subscriptionId= 'Zuora1'; 
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = String.valueOf(TS.id);
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();
        } catch (Exception e) {
        }     
        
    }//end of testEShopTempStopServiceAddError1
    
    /* @description: This method checks negative scenario of EShopTempStopService methods 
     * using Add in actionIndicator*/
    static testmethod void testEShopTempStopServiceAddError2(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id limit 1].Account_Auto_Number__c;     
          
        System.assertEquals(True, accAutoNumber<>null);
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        Insert zs;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(2);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(2);
        TS.Restart_Date__c = date.today().addDays(4);
        TS.Remarks__c = 'Ok';
        insert TS;
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today();
        npub.Publication_Code__c = '1234';
        insert npub;
        
        test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Add';
        eshMock.subscriptionId= 'Zuora1';
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = String.valueOf(TS.id);
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();  
        } catch (Exception e) {
        }   
        
    }//end of testEShopTempStopServiceAddError2
    
    /* @description: This method checks negative scenario of EShopTempStopService methods 
     * using Update in actionIndicator*/
    static testmethod void testEShopTempStopServiceUpdateError1(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id limit 1].Account_Auto_Number__c;     
          
        //System.assertEquals('12345', accList[0].AccountNumber);
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;     
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        cas.Qty__c = 1;
        cas.Temp_Stop_Type__c = 'Update';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; //JURNA ADDED
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Zuora__Account__c = accList[0].id;
        zs.Number_of_Copies1__c = '2';
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Main_Package__c = String.valueOf(lPck[0].Id);
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        Insert zs;
        String zsName = [select Name from Zuora__Subscription__c where id =: zs.Id].Name;
        
        System.assertEquals(zs.Name, zsName);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(4);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(1);
        TS.Restart_Date__c = date.today().addDays(2);
        TS.Remarks__c = 'Ok';
        insert TS;
        String tmpName = [select Name from Temp_Stop__c where id =: TS.Id limit 1].Name;     
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = lPck[0].Id;
        pItem.Product_Rate_Plan__c = PRP.Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        test.startTest();
        insert pItem;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today().addDays(2);
        npub.Publication_Code__c = '1234';
        insert npub;
        
        
        
        
        //test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Update';
        eshMock.subscriptionId= zsName; 
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = tmpName;
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        Zuora__Subscription__c zSub = [select Id, Name, Main_Package_1__c From Zuora__Subscription__c Where Name= :eshMock.subscriptionId limit 1];        
        //System.assertEquals(zs.Main_Package_1__c,zSub.Main_Package_1__c);        
        List<Package_Item__c> pckItemList = [Select Id, Name, Product_Rate_Plan__c, Package__c From Package_Item__c Where Package__c = :zs.Main_Package_1__c limit 100];
        //System.assertEquals(True, pckItemList.size()>0);
        //System.assertEquals(True, pckItemList<>null);
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();
        } catch (Exception e) {
        }      
        
    }//end of testEShopTempStopServiceUpdateError1 
    
    /* @description: This method checks negative scenario of EShopTempStopService methods 
     * using Update in actionIndicator*/
    static testmethod void testEShopTempStopServiceUpdateError2(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id limit 1].Account_Auto_Number__c;     
          
        //System.assertEquals('12345', accList[0].AccountNumber);
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;     
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        cas.Qty__c = 1;
        cas.Temp_Stop_Type__c = 'Update';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today().addDays(1);        
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Zuora__CustomerAccount__c = lBAcc[0].Id;
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = lOLI[0].Id;
        zs.Order_Number__c = lO[0].Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Main_Package__c = String.valueOf(lPck[0].Id);
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        zs.Ph_e__c = true;
        lZS.add(zs);
        Insert lZS;
        String zsName = [select Name from Zuora__Subscription__c where id =: zs.Id limit 1].Name;
        
        System.assertEquals(zs.Name, zsName);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        //pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(2);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(2);
        TS.Restart_Date__c = date.today().addDays(4);
        TS.Remarks__c = 'Ok';
        insert TS;
        String tmpName = [select Name from Temp_Stop__c where id =: TS.Id].Name;     
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Weekday';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = lPck[0].Id;
        pItem.Product_Rate_Plan__c = PRP.Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        test.startTest();
        insert pItem;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today().addDays(2);
        npub.Publication_Code__c = '1234';
        insert npub;                

        
        //test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Update';
        eshMock.subscriptionId = zsName;
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accList[0].Id; //accAutoNumber;
        eshMock.tempStopId = TS.id; //tmpName;
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        Zuora__Subscription__c zSub = [select Id, Name, Main_Package_1__c From Zuora__Subscription__c Where Name= :eshMock.subscriptionId limit 1];        
        //System.assertEquals(zs.Main_Package_1__c,zSub.Main_Package_1__c);        
        List<Package_Item__c> pckItemList = [Select Id, Name, Product_Rate_Plan__c, Package__c From Package_Item__c Where Package__c = : lPck[0].Id/*zs.Main_Package_1__c limit 100*/];
        //System.assertEquals(True, pckItemList.size()>0);
        //System.assertEquals(True, pckItemList<>null);
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();
        } catch (Exception e) {
        }           
        
    }//end of testEShopTempStopServiceUpdateError2
    
    /* @description: This method checks negative scenario of EShopTempStopService methods */
    static testmethod void testEShopTempStopService7version2(){
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id limit 1].Account_Auto_Number__c;     
          
        //System.assertEquals('12345', accList[0].AccountNumber);
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;     
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        cas.Qty__c = 1;
        cas.Temp_Stop_Type__c = 'Update';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Temp_Stop_Count_Year_to_Date__c = 12; // JURNA ADDED
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today().addDays(1);
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Ph_d__c = true;
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
        
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Vendor_Subscription_To_Convert_1__c = sv.Id; //JURNA ADDED
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Zuora__CustomerAccount__c = lBAcc[0].Id;
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = lOLI[0].Id;
        zs.Order_Number__c = lO[0].Id;
        zs.Vendor_Subscription_To_Convert_1__c = sv.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+10;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Main_Package__c = String.valueOf(lPck[0].Id);
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        //zs.Zuora__Zuora_Id__c = '1123'; JURNA REMOVED
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        zs.Ph_e__c = true;
        //zs.Year_to_Date_Temp_Stop_Days__c = 12; // JURNA ADDED
        zs.Zuora__SubscriptionStartDate__c = date.Today(); //JURNA ADDED
        zs.Next_Year_Temp_Stop_Days__c = 12; //JURNA ADDED
        zs.Order_Line_Item_Number_1__c = lOLI[0].Id; //JURNA ADDED
        zs.Delivery_Charge__c = 100.00; //JURNA ADDED
        zs.Frequency_1__c = 'Default'; //JURNA ADDED
        zs.Number_of_Copies__c = 2; // JURNA ADDED
        lZS.add(zs);
        Insert lZS;
        String zsName = [select Name from Zuora__Subscription__c where id =: zs.Id limit 1].Name;
        
        System.assertEquals(zs.Name, zsName);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        //pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(2);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(2);
        TS.Restart_Date__c = date.today().addDays(4);
        TS.Remarks__c = 'Ok';
        insert TS;
        String tmpName = [select Name from Temp_Stop__c where id =: TS.Id].Name;     
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Weekday';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'Online';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = lPck[0].Id;
        pItem.Product_Rate_Plan__c = PRP.Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        Test.startTest();
        insert pItem;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today().addDays(2);
        npub.Publication_Code__c = '1234';
        insert npub;           
       
        
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock()); 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='';
        //eshMock.subscriptionId=sub[0].id; JURNA REMOVED
        eshMock.subscriptionId = zs.Name;//zs.Id; //'1123'; //lzs[0].Id; // JURNA ADDED
        //eshMock.subscriberid = accList[0].Id; //JURNA ADDED
        //eshMock.subscriberid = a.Account_Auto_Number__c; JURNA REMOVED
        eshMock.subscriberid = accList[0].Id; //JURNA ADDED
       // eshMock.tempStopId =''; JURNA REMOVED
        eshMock.tempStopId = TS.id; //tmpName; JURNA ADDED
        eshMock.tempStopDate = string.valueOf(date.today().addDays(5));
        eshMock.restartDate = string.valueOf(date.today());
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();         
        } catch (Exception e) {
        }     
        
    }//end of testEShopTempStopService7version2  
    
     /* @description: This method checks negative scenario of EShopTempStopService methods */
    static void PublicationListIsNull(){
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id limit 1].Account_Auto_Number__c;     
          
        //System.assertEquals('12345', accList[0].AccountNumber);
       
        
        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        
        //Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        Contact c = new Contact();
        c= TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        Order__c o = new Order__c();
        o.Account__c = accList[0].id;     
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        lO.add(o);
        Insert lO;
 
 
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        cas.Qty__c = 1;
        cas.Temp_Stop_Type__c = 'Update';
        insert cas;
 

        //Insert 
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
        sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Temp_Stop_Count_Year_to_Date__c = 12; // JURNA ADDED
        
        lSV.add(sv);
        Insert lSV;
             
        //Insert Order_Line_Item
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Earliest_Start_Date__c = System.Today().addDays(1);
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Ph_d__c = true;
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
        
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
        zs.Vendor_Subscription_To_Convert_1__c = sv.Id; //JURNA ADDED
        zs.Zuora__Zuora_Id__c = '1123'; // JURNA ADDED
        zs.Zuora__CustomerAccount__c = lBAcc[0].Id;
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = lOLI[0].Id;
        zs.Order_Number__c = lO[0].Id;
        zs.Vendor_Subscription_To_Convert_1__c = sv.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionEndDate__c = date.Today()+10;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Main_Package__c = String.valueOf(lPck[0].Id);
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        //zs.Zuora__Zuora_Id__c = '1123'; JURNA REMOVED
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        zs.Ph_e__c = true;
        //zs.Year_to_Date_Temp_Stop_Days__c = 12; // JURNA ADDED
        zs.Zuora__SubscriptionStartDate__c = date.Today(); //JURNA ADDED
        zs.Next_Year_Temp_Stop_Days__c = 12; //JURNA ADDED
        zs.Order_Line_Item_Number_1__c = lOLI[0].Id; //JURNA ADDED
        zs.Delivery_Charge__c = 100.00; //JURNA ADDED
        zs.Frequency_1__c = 'Default'; //JURNA ADDED
        zs.Number_of_Copies__c = 2; // JURNA ADDED
        lZS.add(zs);
        Insert lZS;
        String zsName = [select Name from Zuora__Subscription__c where id =: zs.Id limit 1].Name;
        
        System.assertEquals(zs.Name, zsName);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        //pub.Publication_Code__c = '1234';
        //pub.Earliest_Start_Date__c = date.today().addDays(2);
        pub.Platform_Type__c = 'Print';
        
        insert pub;
        
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(2);
        TS.Restart_Date__c = date.today().addDays(4);
        TS.Remarks__c = 'Ok';
        insert TS;
        String tmpName = [select Name from Temp_Stop__c where id =: TS.Id].Name;     
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Weekday';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        //PRPC.PublicationCode__c = '1234';
        insert PRPC;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = lPck[0].Id;
        pItem.Product_Rate_Plan__c = PRP.Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        Test.startTest();
        insert pItem;
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today().addDays(2);
        npub.Publication_Code__c = '1234';
        insert npub;           
       
        
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock()); 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EShopTempStopService1';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Test';
        //eshMock.subscriptionId=sub[0].id; JURNA REMOVED
        eshMock.subscriptionId = zs.Zuora__Zuora_Id__c; //'1123'; //lzs[0].Id; // JURNA ADDED
        //eshMock.subscriberid = accList[0].Id; //JURNA ADDED
        //eshMock.subscriberid = a.Account_Auto_Number__c; JURNA REMOVED
        eshMock.subscriberid = accList[0].Id; //JURNA ADDED
       // eshMock.tempStopId =''; JURNA REMOVED
        eshMock.tempStopId = TS.id; //tmpName; JURNA ADDED
        eshMock.tempStopDate = string.valueOf(date.today().addDays(5));
        eshMock.restartDate = string.valueOf(date.today());
        eshMock.source= '';
        eshMock.tempReasonCode ='';
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
        Test.stopTest();         
        } catch (Exception e) {
        }     
        
    }//end of PublicationListIsNull 
    
    static testmethod void newTest(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Package__c> lPck = new List<Package__c>();
        List<Order_Line_Item__c> lOLI = new List<Order_Line_Item__c>();
        List<Zuora__CustomerAccount__c> lBAcc = new List<Zuora__CustomerAccount__c>();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Address_Unique_ID__c = 'Ad123';
        insert addressRec;
        
        //accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        accList = TestDataFactory.createAccount(1, 'Direct Corporate');
        accList[0].Name = 'Test';
        accList[0].NRIC__c = 'T1234567R';
        accList[0].AccountNumber = '12345';
        //accList[0].Generate_Account_Number__c = True;  
        //accList[0].Account_auto_number__c = '12345';
        insert accList;
        String accAutoNumber = [select Account_Auto_Number__c from Account where id =: accList[0].Id].Account_Auto_Number__c;     
          
       
        

        //Insert Billing Account
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = accList[0].Id;
        
        lBAcc.add(ba);        
        Insert lBAcc;    
        //Insert Package
        Package__c p = TestDataFactory.createPackage(1)[0];
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Sub_Type__c = 'Single';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
        
        //Insert Contact
        //Contact c = new Contact();
        Contact c = TestDataFactory.createContact(1)[0];
        c.Recipient_Indicator__c = TRUE;
        c.AccountId = accList[0].id;
        c.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        c.Address__c = addressRec.Id;
        insert c;
        
        //Insert Order
        //Order__c o = new Order__c();
        Order__c o = TestDataFactory.createOrder(1)[0];
        o.Account__c = accList[0].id;     
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        lO.add(o);
        Insert lO;
 
        
        Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cas.Account__c = accList[0].id;
        cas.Origin = 'Web';
        cas.Qty__c = 1;
        cas.Temp_Stop_Type__c = 'Update';
        insert cas;
 
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pub.Platform_Type__c = 'Print';
        insert pub;
 
         
        //Insert 
        //Subscription_Vendor__c sv = new Subscription_Vendor__c();
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];         
        lSV.add(sv);
        Insert lSV;
            
        //Insert Order_Line_Item
        //Order_Line_Item__c oli = new Order_Line_Item__c();
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = System.Today();
        oli.Main_Package_Period__c = 100;
        oli.Order__c = o.Id;
        oli.Qty__c = 1;
        oli.Term_Length__c = 10;
        oli.Main_Package_ID__c = p.Id;
        oli.Delivered_By__c = 'Mailing Agent';
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Sub_Type__c = 'Evergreen';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Start_Date__c = date.Today()+1;
        lOLI.add(oli);
        Insert lOLI;
       
        
        //Insert Zuora Subscrption
        Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
        zs.Name = 'Zuora1';
 
        zs.Number_of_Copies1__c = '2';
        zs.Zuora__CustomerAccount__c = ba.Id;
        zs.Term_Length1__c = '1';
        zs.Term_Length__c = 1;
        zs.Zuora__Account__c = accList[0].id;
        zs.Order_Line_Item_Number__c = oli.Id;
        zs.Order_Number__c = o.Id;
        zs.Suppress_Vendor_Start_Notice__c = 'false';
        zs.Supressed_Acknowledgement_Letter__c = 'false';
        zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zs.Urgent__c = 'false';
        zs.Vendor_Conversion__c = 'false';
        zs.Charity__c = 'false';
        zs.Zuora__SubscriptionStartDate__c = date.Today();
        zs.Zuora__SubscriptionEndDate__c = date.Today()+1;
        zs.Subscription_Type_1__c = 'Publication';
        zs.Zuora__Status__c = 'Active';
        zs.Main_Package_1__c = lPck[0].Id;
        zs.Main_Package__c = String.valueOf(lPck[0].Id);
        zs.Ph_d__c = true;
        zs.Ph_e__c = false;
        zs.Year_to_Date_Temp_Stop_Days__c = 3;
        zs.Previous_Year_Temp_Stop_Days__c = 3;       
        zs.Zuora__Zuora_Id__c = '1123';
        zs.Subscriber_Contact__c = c.Id;
        zs.Recipient_Contact__c = c.Id;
        zs.Billing_Type__c = 'Full Prepaid';
        zs.Subscription_Type__c = 'Publication';      
        zs.Qty__c = 10;
        
        lZS.add(zs);
        Insert lZS;
        
        String zsName = [select Name from Zuora__Subscription__c where id =: zs.Id].Name;
        
                
        Temp_Stop__c TS = new Temp_Stop__c();
        TS.Case__c = cas.Id;
        TS.Order__c = o.Id;
        TS.Temp_Stop_Date__c = date.today().addDays(1);
        TS.Restart_Date__c = date.today().addDays(2);
        TS.Remarks__c = 'Ok';
        insert TS;
        String tmpName = [select Name from Temp_Stop__c where id =: TS.Id].Name;     
        
           
        Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();        
        STS.Subscription__c = zs.Id;
        STS.Temp_Stop__c = TS.Id;
        insert STS;
        
        
        Zuora__SubscriptionProductCharge__c SPC = TestDataFactory.createSubProductCharge(1)[0];
        SPC.Zuora__Subscription__c = zs.Id;
        SPC.Zuora__RatePlanName__c = 'Plan Name';
        SPC.Zuora__ProductSKU__c = 'PUB123';
        SPC.Zuora__UOM__c = 'Copy Sun';
        SPC.Zuora__Price__c = 16;
        insert SPC;
        
        
        zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
        Zprod.zqu__SKU__c = SPC.Zuora__ProductSKU__c;
        Zprod.ProductSubType__c = 'Newspaper';
        Zprod.ProductPlatform__c = 'All-In-One';
        insert Zprod;
        
        
        zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
        PRP.zqu__ZProduct__c = Zprod.Id;
        PRP.RatePlanType__c = 'Bill Plan';
        PRP.Name = SPC.Zuora__RatePlanName__c;
        PRP.SubscriptionFrequency__c = '2';
        insert PRP;
        
        
        zqu__ProductRatePlanCharge__c PRPC = TestDataFactory.createProductRatePlanCharge(1)[0];
        PRPC.zqu__ProductRatePlan__c = PRP.Id;
        PRPC.PublicationCode__c = '1234';
        
        insert PRPC;
        
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = lPck[0].Id;
        pItem.Product_Rate_Plan__c = PRP.Id;
        pItem.Duration_in_months__c = '3';
        pItem.Effective_Start_Month__c = '3';
        
        test.startTest();
        insert pItem;
        
         
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.Id;
        npub.Non_Publication_Date__c = date.today().addDays(2);
        npub.Publication_Code__c = '1234';
        insert npub;
        
        //test.startTest();
        try{                  
        Test.setMock(WebServiceMock.class, new zLoginMock());  

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/EShopTempStopService1/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EShopRequest eshMock = new EShopRequest();
        eshMock.actionIndicator ='Update';
        eshMock.subscriptionId= '1123';
        //eshMock.subscriptionId = zs.Id; JURNA ADDED
        eshMock.subscriberId = accAutoNumber;
        eshMock.tempStopId = tmpName;
        eshMock.tempStopDate = date.today().addDays(2).format();
        eshMock.restartDate = date.today().addDays(4).format();
        eshMock.remarks = 'ok';
        eshMock.source= 'Web';
        eshMock.tempReasonCode = '123';
        
        Zuora__Subscription__c zSub = [select Id, Name, Main_Package_1__c From Zuora__Subscription__c Where Name= :eshMock.subscriptionId limit 1];        
        //System.assertEquals(zs.Main_Package_1__c,zSub.Main_Package_1__c);        
        List<Package_Item__c> pckItemList = [Select Id, Name, Product_Rate_Plan__c, Package__c From Package_Item__c Where Package__c = :zs.Main_Package_1__c];
        //System.assertEquals(True, pckItemList.size()>0);
        //System.assertEquals(True, pckItemList<>null);
        
        
        EShopTempStopService.EShopRequest esReq2 = new EShopTempStopService.EShopRequest();
        
        String JSONStr = JSON.serialize(eshMock);
        esReq2 = (EShopTempStopService.EShopRequest)JSON.deserialize(jsonStr, EShopTempStopService.EShopRequest.class);
        EShopTempStopService.EShopResponse response = EShopTempStopService.processRequest(esReq2);
        
         Test.stopTest();
         } catch (Exception e) {
         }     
        
    }       
    
}//end of EShopTempStopServiceTest/