/**
* Class Name: CancelSubscriptionBatch_Test
* @author: Accenture IDC - Nilesh
* Date: 26/2/2015
* @Description: This class is used to code coverage of the CancelSubscriptionBatch class.
*
*/
@isTest
private class CancelSubscriptionBatch_Test {
    
    static testmethod void testExecuteBatch(){
        
        String zuoraId = '12345';
        Set<String> orderIdSet = new Set<String>();
        Set<String> subscriptionIdSet = new Set<String>{zuoraId};
        Set<String> accountIdSet = new Set<String>();
        Date stopDate = Date.Today();
        
        try{
        
        defaultCustomSetting();
        
		Map<String, SObject> sObjectMap = TestDataFactory.createSubscriptionPackage();
        
        Account testAccount = (Account) sObjectMap.get('Account');
        
        Order__c testOrder = (Order__c) sObjectMap.get('Order__c');
        
        orderIdSet.add(String.valueOf(testOrder.Id));
                
        Zuora__Subscription__c testSubscription = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
        	testSubscription.Zuora__Zuora_Id__c = zuoraId;
        insert testSubscription;
        
        Order_Line_Item__c testOrderLineItem = (Order_Line_Item__c) sObjectMap.get('Order_Line_Item__c');
        	testOrderLineItem.Subscription__c = testSubscription.Id;
        update testOrderLineItem;
        
        Test.startTest();
        
            CancelSubscriptionBatch batch = new CancelSubscriptionBatch(orderIdSet, subscriptionIdSet, stopDate, accountIdSet, testAccount.Id);
            Database.executebatch(batch,200);
        	
        Test.stopTest();
            
        }catch(Exception exp)
        {
           system.debug('Exception - ' + exp.getMessage());
        }
    }
    
	static void defaultCustomSetting()
    {
        Key_Id__c keyId;
        Other__c otherC;        
        
        String[] keyIdNameArray = new String[]{'Address_Airline','AddAirline','AddInternal','AddLocal','AddOverseas','Package Item_Extension Product','SubTermTypeEvergreen','SubTypeGift','Package Item_Bundle Discount','SubTermTypeTermed','QuoteInvoiceProcessingSubscription','CurrencySGD','Profile_System Administrator','Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008idx','Airline','Internal','Local','Overseas','012N00000008jCnIAI','Evergreen','Gift','012N00000008jCiIAI','Termed','Subscription','SGD','00e90000001VZOq','012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'RecordType','Name','Name','Name','Name','RecordType','Name','Name','RecordType','Name','Name','Name','Profile','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
            insert keyId;
        }
        
        String[] orderCNameArray = new String[]{'LANDED DELIVERY CHARGE','Zero Charge Amount','Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print'};
        String[] orderCValueArray = new String[]{'LANDED DELIVERY CHARGE','Zero Charge Amount','Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print'};
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
            insert otherC;
        }
        
        Cir_Planner_Schedule__c testCirPlannerSchedule = new Cir_Planner_Schedule__c();
            testCirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            testCirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            testCirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Sun_Start_Time__c = System.Now();
            testCirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Name = 'CIR Plan Schedule';
        insert testCirPlannerSchedule;
        
        BatchInterface_Settings__c testBatchInterfaceSetting = new BatchInterface_Settings__c();
            testBatchInterfaceSetting.Name = 'Endpoint Delegator';
            testBatchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert testBatchInterfaceSetting;
        
        Delivery_Charge_Type__c testDeliveryChargeType = new Delivery_Charge_Type__c();
            testDeliveryChargeType.Name = 'L';
            testDeliveryChargeType.Default_Delivery_Charge_Type__c = 'L';
        insert testDeliveryChargeType;      
    }
}