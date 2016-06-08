/*
 * Class Name: EshopFetchSubscriptionDetailsTest
 * @Author: Accenture IDC (Shruti KIshore, Nilesh)
 * @Date: 04/11/2014
 * @Description: This class is for updating billing account details sent from ARMS
 */    
  @isTest(SeeAllData = True) // JURNA ADDED //JMG changed SeeAllData to TRUE since we're querying in the database
  private class EshopFetchSubscriptionDetailsTest{
       
    static testmethod void testFetchSubscriptionDetailsForSubs()
    {
        String subscriberId;
        defaultCustomSetting();
        
        //Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage(); //JURNA REMOVED
        Set<Id> accId = new Set<Id>();
        //Account testAccount = (Account) sobjectMap.get('Account'); // JURNA REMOVED
        Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        testAccount.NRIC__c = 'T1134567R';
        database.insert(testAccount);
        accId.add(testAccount.Id);
        
        Contact testContact = TestDataFactory.createContact(1)[0];
        testContact.AccountID = testAccount.Id;
        testContact.Billing_Indicator__c = true;
        insert testContact;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = testAccount.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        //billAcc.Name = 'TESTtest';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Billing_Contact__c = testContact.Id;
        billAcc.Zuora__AccountNumber__c = '123456'; //JMG ADDED
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = testAccount.Id;
        order.Informed_Customer__c = TRUE;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c ='Full Prepaid';
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Subscriber_Charge__c = 10.00;
        order.Billing_Contact__c = testContact.Id;
        insert order;
        
        Package__c testPackage = TestDataFactory.createPackage(1)[0];
        testPackage.Package_Code__c = 'testCode';
        insert testPackage;
        
        Order_Line_Item__c testOrderLine = TestDataFactory.createOrderLineItem(1)[0];
        testOrderLine.Order__c = order.Id;
        testOrderLine.Main_Package_ID__c = testPackage.Id;
        testOrderLine.Start_Date__c = date.Today()+1;
        testOrderLine.Contract_End_Date__c = date.Today()+100; //JMG ADDED
        insert testOrderLine;
        
        //Contact testContact = (Contact) sobjectMap.get('Recipient Contact'); // JURNA REMOVED
        
        //Zuora__Subscription__c testSubscription = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c'); // JURNA REMOVED
        
        List<Zuora__Subscription__c> lZS = new List<Zuora__Subscription__c>();
        
        Zuora__Subscription__c testSubscription = testDataFactory.createSubscription(3)[0];
        testSubscription.Zuora__Account__c = testAccount.Id;
        testSubscription.Zuora__CustomerAccount__c = billAcc.Id;
        testSubscription.Recipient_Contact__c = testContact.Id;
        testSubscription.Main_Package_1__c = testPackage.Id; 
        testSubscription.Product_Code__c = 'test';
        testSubscription.zuora__SubscriptionStartDate__c = date.Today()+1;
        //testSubscription.Billing_Type__c = 'Full Prepaid';
        testSubscription.Order_Number__c = order.Id;
        testSubscription.Zuora__TermEndDate__c = date.Today()+30;
        testSubscription.Zuora__Status__c = 'Active';
        testSubscription.Number_of_Copies__c = 10;
        testSubscription.Qty__c = 10;
        testSubscription.Classification__c = 'testClassification';
        testSubscription.Order_Line_Item_Number_1__c = testOrderLine.Id; //JMG ADDED
        testSubscription.Sub_Classification__c = 'testClassification';
        testSubscription.Contract_End_Date_1__c = date.Today()+31;
        testSubscription.Subscription_Type_1__c = 'Publication'; //JMG ADDED
        testSubscription.Subscription_Type__c = 'Publication'; 
        testSubscription.Zuora__SubscriptionEndDate__c = date.Today()+30; //JMG ADDED
        testSubscription.Zuora__Zuora_Id__c ='1123'; //JMG ADDED
        lZS.add(testSubscription);//JMG ADDED
        database.insert(lZS);//JMG ADDED
        //system.assertequals(testSubscription, null);
        /*
        'SELECT Zuora__Account__r.Account_Auto_Number__c, ,Recipient_Contact__r.name,';
            queryString0 += ' Zuora__Zuora_Id__c,Main_Package__c,Product_Code__c,Zuora__CustomerAccount__r.Zuora__AccountNumber__c,';
            queryString0 += ' zuora__SubscriptionStartDate__c,Zuora__SubscriptionEndDate__c,Order_Number__c,Zuora__TermEndDate__c,';
            queryString0 += ' Zuora__Status__c,Number_of_Copies__c,Main_Package_1__r.Package_Code__c,Qty__c,Classification__c,Sub_Classification__c,Order_Line_Item_Number_1__r.Contract_End_Date__c'; //start-end KRITHIKA D D-2113 Fields added
            queryString0 += ' FROM Zuora__Subscription__c';
            queryString0 += ' where zuora__Account__r.Account_Auto_Number__c=:subscriberId';
            queryString0 += ' and Zuora__Status__c=\'Active\'';
            queryString0 += ' ORDER BY CreatedDate ASC NULLS FIRST'; */
        
        subscriberId = [Select Account_Auto_Number__c From Account Where Id IN: accId].Account_Auto_Number__c;
        
        Asia1__c asia1 = new Asia1__c();
            asia1.User_ID_LDAP_ID__c = 'xxxx12112xx';
            asia1.Display_Name__c = 'xxxx12112xx';
            asia1.Password__c = 'xxxx12112xx';
            asia1.Contact__c = testContact.Id;
        insert asia1;
        
        EshopFetchSubscriptionDetails.EshopFetchSubscriptionDetailsRequest testDetailRequest =  new EshopFetchSubscriptionDetails.EshopFetchSubscriptionDetailsRequest();
        testDetailRequest.setSubscriberId(subscriberId);
            
        Test.startTest();
            EshopFetchSubscriptionDetails.fetchSubscriptionDetails(testDetailRequest);
            EshopFetchSubscriptionDetails.fetchSubscriptionDetailsForSubs(testDetailRequest);

        Test.stopTest();
     }  
     
    static testmethod void testFetchSubscriptionDetails()
     { 
        String[] subscriberIdArray = new String[]{null,'','30016949'};
            
        EshopFetchSubscriptionDetails.EshopFetchSubscriptionDetailsRequest testDetailRequest =  new EshopFetchSubscriptionDetails.EshopFetchSubscriptionDetailsRequest();
        testDetailRequest.getSubscriberId();
        
        Test.startTest();
        
            for(Integer count = 0 ; count < subscriberIdArray.size() ; count++ )
            {
                testDetailRequest.setSubscriberId(subscriberIdArray[count]);
                EshopFetchSubscriptionDetails.fetchSubscriptionDetails(testDetailRequest);
            }

        Test.stopTest();
    }
     
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        List<Key_Id__c> keyList = [SELECT Name FROM Key_Id__c];
        Set<String> keyNames = new Set<String>();
        for(Key_Id__c keyRec : keyList) {
            keyNames.add(keyRec.Name);
        }
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            if(!keyNames.contains(keyIdNameArray[i])) {
                keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
                insert keyId;
            }
        }
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = [SELECT Name FROM Other__c];
        Set<String> otherNames = new Set<String>();
        for(Other__c otherRec : otherList) {
            otherNames.add(otherRec.Name);
        }
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            if(!otherNames.contains(orderCNameArray[i])) {
                otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
                insert otherC;
            }
        }
        
        List<Cir_Planner_Schedule__c> cpcList = [SELECT Name FROM Cir_Planner_Schedule__c WHERE Name = 'CIR Plan Schedule'];
        if(cpcList.isEmpty()) {
            Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        }
        
        List<BatchInterface_Settings__c> bitList = [SELECT Name FROM BatchInterface_Settings__c WHERE Name = 'Endpoint Delegator'];
        if(bitList.isEmpty()) {
            BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
            batchInterfaceSetting.Name = 'Endpoint Delegator';
            batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
            insert batchInterfaceSetting;
        }
        
        String[] errorCNameArray = new String[]{'ARMS account too many record','ARMS account is not existing','ARMS Timed-out','ARMS select one Customer only','Invalid Response'};
        String[] errorCValueArray = new String[]{'Too many account type.','ARMS account is not existing.','Timed-out. Please click Search button again.','Please select one Customer only.','Invalid response from server. Please try again later.'};
        
        List<Error_Messages__c> errorList = [SELECT Name FROM Error_Messages__c];
        Set<String> errorNames = new Set<String>();
        for(Error_Messages__c errorRec : errorList) {
            errorNames.add(errorRec.Name);
        }
        
        Error_Messages__c errorRec;
        for(Integer i = 0 ; i < errorCNameArray.size(); i++ )
        {
             if(!errorNames.contains(errorCNameArray[i])) {
                errorRec = new Error_Messages__c();
                errorRec.Name = errorCNameArray[i];
                errorRec.Message__c = errorCValueArray[i];
                insert errorRec;
            }
        }
    }
}