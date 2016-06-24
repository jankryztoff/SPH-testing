@isTest(SeeAllData = true)
private class EshopSearchSubscriberServiceTest{
     public class SearchSubscriberServiceRequest {
        String icNo;
        String passportNo;
        String email;
        String legacyAccNo;
        String contactNo;
        String status;
        String subscriberType;
        String ldapId;
        String eshopRefNo;
        String addrType;
        String postalCode;
        String blockNo;
        String levelNo;
        String streetName;
        String bldName;
        String unitNo;
        String country;
        String recipientInd;
        String billingInd;
        String subGroup;
       
    }
    static testmethod void myUnitTest1(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SearchSubscriberService';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        SearchSubscriberServiceRequest esReq = new SearchSubscriberServiceRequest();
        esReq.recipientInd = 'N';
        esReq.billingInd = 'N';
        esReq.email = '';
        esReq.ldapId = '';

        EshopSearchSubscriberService.SearchSubscriberServiceRequest esReq2 = new EshopSearchSubscriberService.SearchSubscriberServiceRequest();
        String jsonStr = JSON.serialize(esReq);
        esReq2 = (EshopSearchSubscriberService.SearchSubscriberServiceRequest)JSON.deserialize(jsonStr, EshopSearchSubscriberService.SearchSubscriberServiceRequest.class);
        EshopSearchSubscriberService.SearchSubscriberServiceResponse response = EshopSearchSubscriberService.searchSubscriber(esReq2);
    }
    static testmethod void myUnitTest2(){
    
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
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

        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        insert acc;

        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = TRUE;
        con.HomePhone__c = '123456';
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Subscriber_Charge__c = 10.0;
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = con.id;
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
        
        /**Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Subscriber_Charge__c = 10.00;
        order.Delivery_Charge__c = 10.00;
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        insert order;**/
        
        //Map<String, SObject> sObjMap = new Map<String, SObject>(); 
        //sObjMap = TestDataFactory.createSubscriptionPackage();    
        Test.startTest();    
        /**Zuora__Subscription__c subRecs = (Zuora__Subscription__c ) sObjMap.get('Zuora__Subscription__c');
        subRecs.Contact__c = sObjMap.get('Billing Contact').id;
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Number__c = order.Id;
        insert subRecs;**/
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        //subRecs.Contact__c = sObjMap.get('Billing Contact').id;
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id; 
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Number__c = order.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Number_of_Copies1__c = '100';
        insert subRecs;
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'ldapsample';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        //tmpAsia1.Contact__c = sObjMap.get('Recipient Contact').Id;
        insert tmpAsia1;
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = subRecs.Id;
        asiaSubList[0].Status__c = 'Enabled';
        //asiaSubList[0].Order_Line_Item__c = sObjMap.get('Order_Line_Item__c').Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        insert asiaSubList;      
    
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SearchSubscriberService';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        SearchSubscriberServiceRequest esReq = new SearchSubscriberServiceRequest();
        esReq.ldapId = 'ldapsample';
        esReq.email = 'ldapsample@sample.com';
        esReq.blockNo = 'TEST';
        

        EshopSearchSubscriberService.SearchSubscriberServiceRequest esReq2 = new EshopSearchSubscriberService.SearchSubscriberServiceRequest();
        String jsonStr = JSON.serialize(esReq);
        esReq2 = (EshopSearchSubscriberService.SearchSubscriberServiceRequest)JSON.deserialize(jsonStr, EshopSearchSubscriberService.SearchSubscriberServiceRequest.class);
        EshopSearchSubscriberService.SearchSubscriberServiceResponse response = EshopSearchSubscriberService.searchSubscriber(esReq2);
        Test.stopTest();    
    }
    static testmethod void myUnitTest3(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SearchSubscriberService';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        EshopSearchSubscriberService.SubscriberDetails ess = new EshopSearchSubscriberService.SubscriberDetails();
       
        EshopSearchSubscriberService.SubscriberDetails sd = new EshopSearchSubscriberService.SubscriberDetails();
        EshopSearchSubscriberService.SubscriberDetails sd2 = new EshopSearchSubscriberService.SubscriberDetails('subId', 'active', 'publication','subgroup');
    }


}