@isTest(SeeAllData = true)
private class InvoiceProcessForStopSubscriptionTest {

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
    static testmethod void newTest(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Account> accList2 = new List<Account>();
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
        Set<Id> subId = new Set<Id>();
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
        subId.add(zs.Id);
        
        //InvoiceProcessForStopSubscription.invoicePaymentProcess(subId);
        
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
    
    static testmethod void newTestNotDirectCorporate(){
        
        
        List<Contact> lC = new List<Contact>();
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        List<Order__c> lO = new List<Order__c>();
        List<Subscription_Vendor__c> lSV = new List<Subscription_Vendor__c>();
        List<Account> accList = new List<Account>();
        List<Account> accList2 = new List<Account>();
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
        Set<Id> subId = new Set<Id>();
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
        subId.add(zs.Id);
        
        //InvoiceProcessForStopSubscription.invoicePaymentProcess(subId);
    }
}