/**
 * Class Name: <DeliveryChargeCheckTest>
 * @author: <Kristina Iranzo>
 * Date: <10/23/2014>
 * Requirement/Project Name: <SPH>
 * @description: Test Class for DeliveryChargeCheck
 *@author: <Marjorie Gaelo>
 *Modified Date <2/5/2015>
 */

@isTest
global class DeliveryChargeCheckTest{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createMASS_CONFIG();
        insert CustomSettingsDataFactory.createError_Messages();
    }
    
    
    static testMethod void testDeliveryChargeCheck(){
    
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    postal.Name = 'SPostal';
    postal.House_Block_Number__c = 'TEST';
    postal.Address_Type__c = 'A';
    
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';
            pack.Name = 'Test Package';
            insert new List<sObject>{postal, pack};
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
            /*
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; // JURNA ADDED
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
            */
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__Credit_Balance__c = 1;
                insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            insert addressRec;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
//START: CCB002 Added by April Banaag - to apply changes to contact record type
        
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
//END: CCB002 Added by April Banaag - to apply changes to contact record type
        
            con.Address_Unique_Id__c = 'TESTx';
            insert con;
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            insert con1;
            Order__c order = TestDataFactory.createOrder(1)[0];
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
            try{
                insert order;
            }catch(exception e){
                
            }
            
            
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.today().addDays(2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            //orderline.Start_date__c = date.today(); // JURNA REMOVED
            orderline.Start_date__c = date.today()+1; // JURNA ADDED
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            //orderline.Fee_Override__c = TRUE; // JURNA REMOVED
            orderline.Fee_Override__c = FALSE; // JURNA ADDED
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
              try{  
            insert orderline;
              }catch(exception e){}
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
                subRecs[0].Zuora__Account__c = acc.Id;
                subRecs[0].Zuora__Zuora_Id__c = '1123';
                subRecs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs[0].Subscriber_Contact__c = con.Id;
                subRecs[0].Recipient_Contact__c = con.Id;
                subRecs[0].Main_Package_1__c = pack.id;
                subRecs[0].Zuora__Status__c = 'Active';
                subRecs[0].Order_Number__c = order.Id;
                subRecs[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs[0].Urgent__c = 'false';
                subRecs[0].Vendor_Conversion__c = 'false';
                subRecs[0].Charity__c = 'false';
                subRecs[0].Billing_Type__c = 'Full Prepaid';
                subRecs[0].Order_Line_Item_Number__c = orderline.id;
                subRecs[0].Subscription_Type_1__c = 'Delivery';
                subRecs[0].Subscription_Type__c = 'Delivery';
                subRecs[0].Zuora__Status__c = 'Active';
                subRecs[0].Order_Number_1__c = order.id;
                subRecs[0].Zuora__CustomerAccount__c = billAcc.Id; // JURNA ADDED
                subRecs[1].Zuora__Account__c = acc.Id;
                subRecs[1].Zuora__Zuora_Id__c = '1123';
                subRecs[1].Zuora__SubscriptionEndDate__c = date.today().addDays(31);
                subRecs[1].Subscriber_Contact__c = con.Id;
                subRecs[1].Recipient_Contact__c = con.Id;
                subRecs[1].Main_Package_1__c = pack.id;
                subRecs[1].Zuora__Status__c = 'Active';
                subRecs[1].Order_Number__c = order.Id;
                subRecs[1].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs[1].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs[1].Urgent__c = 'false';
                subRecs[1].Vendor_Conversion__c = 'false';
                subRecs[1].Charity__c = 'false';
                subRecs[1].Billing_Type__c = 'Full Prepaid';
                subRecs[1].Order_Line_Item_Number__c = orderline.id;
                subRecs[1].Subscription_Type_1__c = 'Delivery';
                subRecs[1].Subscription_Type__c = 'Delivery';
                subRecs[1].Zuora__Status__c = 'Active';
                subRecs[1].Order_Number_1__c = order.id;
                subRecs[1].Sponsor_1__c = FALSE; // JURNA ADDED
                subRecs[1].Zuora__CustomerAccount__c = billAcc.Id; // JURNA ADDED

            Test.startTest();    
            try{
                insert subRecs;
            }catch(exception e){
                
            }
        DeliveryChargeCheck DelChaChe = new DeliveryChargeCheck();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DeliveryChargeCheck';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        DeliveryChargeCheck.DeliveryChargeCheckRequest esh = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        String accountNum = [Select Account_Auto_Number__c From Account Where Id =: acc.Id].Account_Auto_Number__c;
        esh.subscriberid = accountNum;
        esh.unitNo = 'yy';
        esh.postalcode= 'SPostal';
        esh.blkno='TEST';
        esh.levelno='xx';
        DeliveryChargeCheck.DeliveryChargeCheckResponse response = DeliveryChargeCheck.processRequest(esh);
        response = DeliveryChargeCheck.processRequest(esh);
        Test.stopTest();
    
    
    }//END testMethod testDeliveryChargeCheck()
    
    static testMethod void testDeliveryChargeCheck2(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        Test.startTest();
        DeliveryChargeCheck DelChaChe = new DeliveryChargeCheck();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DeliveryChargeCheck';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        DeliveryChargeCheck.DeliveryChargeCheckRequest esh = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        esh.unitNo = 'yy';
        esh.blkno='TEST';
        esh.levelno='xx';
        esh.postalcode = 'SPostal';
        DeliveryChargeCheck.DeliveryChargeCheckResponse response = DeliveryChargeCheck.processRequest(esh);
        response = DeliveryChargeCheck.processRequest(esh);
        Test.stopTest();
    }
    static testMethod void testDeliveryChargeCheck3(){
        Test.startTest();
        DeliveryChargeCheck DelChaChe = new DeliveryChargeCheck();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DeliveryChargeCheck';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        DeliveryChargeCheck.DeliveryChargeCheckRequest esh = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        esh.subscriberid = 'asdasd';
        esh.unitNo = 'yy';
        esh.blkno='TEST';
        esh.levelno='xx';
        DeliveryChargeCheck.DeliveryChargeCheckResponse response = DeliveryChargeCheck.processRequest(esh);
        response = DeliveryChargeCheck.processRequest(esh);
        Test.stopTest();
    }
    static testMethod void testDeliveryChargeCheck4(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        insert postal;
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        Test.startTest();
        DeliveryChargeCheck DelChaChe = new DeliveryChargeCheck();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DeliveryChargeCheck';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        DeliveryChargeCheck.DeliveryChargeCheckRequest esh = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        esh.unitNo = 'yy';
        esh.blkno='TEST';
        esh.levelno='xx';
        esh.postalcode = 'SPostal';
        DeliveryChargeCheck.DeliveryChargeCheckResponse response = DeliveryChargeCheck.processRequest(esh);
        response = DeliveryChargeCheck.processRequest(esh);
        Test.stopTest();
    }
    
    // JURNA ADDED
    static testMethod void testAddressTypeIsH(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'H';
        insert postal;
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        Test.startTest();
        DeliveryChargeCheck DelChaChe = new DeliveryChargeCheck();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DeliveryChargeCheck';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        DeliveryChargeCheck.DeliveryChargeCheckRequest esh = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        esh.unitNo = 'yy';
        esh.blkno='TEST';
        esh.levelno='xx';
        esh.postalcode = 'SPostal';
        DeliveryChargeCheck.DeliveryChargeCheckResponse response = DeliveryChargeCheck.processRequest(esh);
        response = DeliveryChargeCheck.processRequest(esh);
        Test.stopTest();
    }
    
    // JURNA ADDED
    static testMethod void testAddressTypeIsS(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'S';
        insert postal;
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        Test.startTest();
        DeliveryChargeCheck DelChaChe = new DeliveryChargeCheck();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DeliveryChargeCheck';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        DeliveryChargeCheck.DeliveryChargeCheckRequest esh = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        esh.unitNo = 'yy';
        esh.blkno='TEST';
        esh.levelno='xx';
        esh.postalcode = 'SPostal';
        DeliveryChargeCheck.DeliveryChargeCheckResponse response = DeliveryChargeCheck.processRequest(esh);
        response = DeliveryChargeCheck.processRequest(esh);
        Test.stopTest();
    }
    
    // JURNA ADDED
    static testMethod void testNoAddressType(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = NULL;
        insert postal;
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = NULL;
        addressRec.Postal_Code__c = postal.id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        Test.startTest();
        DeliveryChargeCheck DelChaChe = new DeliveryChargeCheck();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DeliveryChargeCheck';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        DeliveryChargeCheck.DeliveryChargeCheckRequest esh = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        esh.unitNo = 'yy';
        esh.blkno='TEST';
        esh.levelno='xx';
        esh.postalcode = 'SPostal';
        DeliveryChargeCheck.DeliveryChargeCheckResponse response = DeliveryChargeCheck.processRequest(esh);
        response = DeliveryChargeCheck.processRequest(esh);
        Test.stopTest();
    }
    
    // JURNA ADDED
    static testMethod void testNoSubscriptionID(){
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Test.startTest();    

        DeliveryChargeCheck DelChaChe = new DeliveryChargeCheck();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DeliveryChargeCheck';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        DeliveryChargeCheck.DeliveryChargeCheckRequest esh = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        String accountNum = [Select Account_Auto_Number__c From Account Where Id =: acc.Id].Account_Auto_Number__c;
        accountNum = NULL;
        esh.subscriberid = 'asb';
        esh.unitNo = 'yy';
        esh.postalcode = 'SPOSTAL';
        esh.blkno ='TEST';
        esh.levelno ='xx';
        DeliveryChargeCheck.DeliveryChargeCheckResponse response = DeliveryChargeCheck.processRequest(esh);
        response = DeliveryChargeCheck.processRequest(esh);
        Test.stopTest();
        }
        
}