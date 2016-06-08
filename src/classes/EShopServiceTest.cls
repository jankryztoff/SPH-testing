/**
* Class Name: EShopServiceTest 
* @author: CV Manawatao
* Date: 1/28/2014
* @Description: This class is used to code coverage of the EShopServiceclass.
*@author: Marjorie Gaelo 
*@Modified Date <2/9/2015>
*@author: JCarlos Aduan 
*@Modified Date <05/13/2016>
*/


@isTest (SeeAllData = False)
private class EShopServiceTest {

    
    static void setCustomSettings() {
    
        //Cir_Planner_Schedule__c
        List<Cir_Planner_Schedule__c> cpsList = new List<Cir_Planner_Schedule__c>{
            new Cir_Planner_Schedule__c(Name='CIR Plan Schedule', Mon_Fri_End_Time__c=Date.today(),
                Mon_Fri_Start_Time__c=Date.today(),Sat_PH_End_Time__c=Date.today(),Sat_PH_Start_Time__c=Date.today(),
                Sun_End_Time__c=Date.today(),Sun_Start_Time__c=Date.today())
        };
        Database.insert(cpsList);
        
        //
        RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Case_TempStop        = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Temp Stop Subscription' LIMIT 1];
        RecordType Contact_VendorStaff     = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Vendor Staff' LIMIT 1];
        RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
        RecordType Case_Stop = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Stop Subscription' LIMIT 1];

        Key_Id__c keyId  = new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER',Id__c='30465208', Type__c='Number');
        insert keyId;
        //Key_Id__c
        //.getInstance('Vendor Rep Role')
        //ConstantsSLB.getKeyId('Contact_Customer Contact');
        /*
        final string AIRLINE = ConstantsSLB.getKeyId('AddAirline');
        final string OVERSEAS = ConstantsSLB.getKeyId('AddOverseas');
        final string LOCAL = ConstantsSLB.getKeyId('AddLocal');
        final string INTERNAL = ConstantsSLB.getKeyId('AddInternal');
        */
        /*
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role',       Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),
            
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id, Type__c='RecordType'),
            new Key_Id__c(Name='Case_Temp Stop',         Id__c=Case_TempStop.id,        Type__c='RecordType'),
            
            new Key_Id__c(Name='Contact_Vendor Staff',     Id__c=Contact_VendorStaff.id,     Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id, Type__c='RecordType'),
            
            new Key_Id__c(Name='Case_Stop', Id__c=Case_Stop.id ,Type__c='RecordType'),
            
            new Key_Id__c(Name='AddInternal', Id__c='Internal', Type__c='Name'),
            new Key_Id__c(Name='AddLocal',    Id__c='Local',     Type__c='Name')
        };
        Database.insert(kisList);
        */
        
        //Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        List<Batch_Configuration_Settings__c> bcsList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name='SP_VendorNotificationsBatch', Batch_Size__c=10, 
                Max_Retries__c=10, Notification_Recipients__c='', Number_Of_Days_To_Retrieve__c=30)
        };
        Database.insert(bcsList);
        
        //Other__c
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'),
            
            new Other__c(Name='Zero Charge Amount',     Value__c='Zero'),
            new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB'),
            new Other__c(Name='APT DELIVERY CHARGE',    Value__c='APT'),
            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='LANDED')
        };        
        Database.insert(otherList);
        
        //Delivery_Charge_Type__c
        List<Delivery_Charge_Type__c> delCharTypeList = new List<Delivery_Charge_Type__c>{
            new Delivery_Charge_Type__c(Name='H', Default_Delivery_Charge_Type__c='H'),
            new Delivery_Charge_Type__c(Name='L', Default_Delivery_Charge_Type__c='L'),
            new Delivery_Charge_Type__c(Name='C', Default_Delivery_Charge_Type__c='C')
        };
        Database.insert(delCharTypeList);
    }
    
    class EShopResponse{
        String svc_status;
        String error_code; 
        String error_message;
        String subscriberId;
        String requestTotalCredit;
        String requestTotalIssue;
        String restartDate;
        String tempStopDate;
        String currentTempStopCount;
    }
    
    class EShopRequest{
        String subscriberId;
        String subscriptionId;
        String tempStopDate;
        String restartDate;
        String remarks;
        String source;
        String quantity;
    }

    /*if(request.subscriberId == '' || request.subscriptionId == '' || request.remarks == '' 
           || request.source == '' || request.quantity == '')*/
    static testMethod void testProcessRequest01() {
        
        System.RunAs(TestDataFactory.prepareTestUsers('System Administrator')) {
            
            //Test Data
            setCustomSettings();
            
            Datetime dateOutput  = Datetime.now();
            String strDateOutput = dateOutput.format('MM/dd/yyyy');
            
            EShopRequest eShopReq   = new EShopRequest();
            eShopReq.subscriberid   = '1';
            eShopReq.subscriptionId = '1';
            eShopReq.tempStopDate   = strDateOutput;
            eShopReq.restartDate    = strDateOutput;
            eShopReq.remarks        = '1';
            eShopReq.source         = '1';
            eShopReq.quantity       = '';
            
            
            //FROM Zuora__Subscription__c
            //FROM Account
            //FROM Zuora__SubscriptionProductCharge__c
            //FROM zqu__ProductRatePlan__c 
            //FROM zqu__ProductRatePlanCharge__c 
            //FROM publication__c 
            //FROM Subscription_Temp_Stop__c 
            
            Test.startTest();
            String JSONData = JSON.serialize(eShopReq);
            EShopService.EShopRequest  esh      = (EShopService.EShopRequest) JSON.deserialize(JSONData, EShopService.EShopRequest.class);
            //EShopService_CT.EShopRequest  esh      = (EShopService_CT.EShopRequest) JSON.deserialize(JSONData, EShopService_CT.EShopRequest.class);
            EShopService.EShopResponse response = EShopService.processRequest(esh);
            //EShopService_CT.EShopResponse response = EShopService_CT.processRequest(esh);
            
            String JSONDataResponse = JSON.serialize(response);
            EShopResponse localResponse = (EShopResponse ) JSON.deserialize(JSONDataResponse, EShopResponse .class);
            System.assertEquals(localResponse.svc_status,    GlobalVariableClass.SVC_STATUS_FAILURE);
            System.assertEquals(localResponse.error_code,    GlobalVariableClass.ERROR_CODE_GENERAL);
            System.assertEquals(localResponse.error_message, GlobalVariableClass.ERROR_MESSAGE_GENERAL);
            Test.stopTest();
        }
    }
    
    
    static testMethod void testProcessRequest02() {
    
        System.RunAs(TestDataFactory.prepareTestUsers('System Administrator')) {
            
            //Test Data
            setCustomSettings();
            
            //>
            //Create an Address record
            List<Address__c> addressList = TestDataFactory.createAddress(1);
            insert addressList;
            
            //Account
            Account acc = new Account();
            acc.Name = 'Vendor Subscriber';
            insert acc;
            
            //Case
            Case ca = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            ca.Account = acc;
            insert ca;
            
            
            //Insert Billing Account *
            Zuora__CustomerAccount__c zCustAcc = TestDataFactory.createBillingAccount(1)[0];
            zCustAcc.Zuora__Account__c = acc.Id;      
            zCustAcc.Zuora__DefaultPaymentMethod__c = 'Credit Card';            
            insert zCustAcc;
            
        
            //Create contact con
            Map <String,Schema.RecordTypeInfo> contactRecordType = contact.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id conRecTypeId = contactRecordType.get('Customer Contact').getRecordTypeId();

            Id rtId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c =addressList[0].id; 
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = rtId; //conRecTypeId;
            insert con;
    
            //Package__c
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
            //insert pack;
            
        
            //Order__c
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.id;     
            order.order_type__c = 'Temp Stop';
            order.temp_stop_type__c = 'New';        
            order.status__c = 'New';
            order.informed_customer__c = true;
            order.case_record_type__c =  'Temp Stop Subscription';        
            order.credit_balance__c = 110;
            order.delivery_charge__c = 1;
            order.monthly_delivery_charge_for_full_payment__c = 100;
            //insert order;
            
        
            //Order_Line_Item__c
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.id;
            oli.Main_Package_ID__c = pack.id;
            oli.Case__c = ca.id;
            oli.Earliest_Start_Date__c = date.Today();
            oli.Start_Date__c = date.Today().addDays(1);
            oli.Main_Package_Period__c = 35;
            oli.Qty__c = 1;
            oli.Delivered_By__c = 'Vendor'; 
            oli.Main_Package_Billing_Type__c = 'Full Prepaid';
            oli.Main_Package_Type__c = 'Base';
            oli.Main_Package_Frequency__c = 'Default';
            //insert oli;
            
        
            //Zuora__Subscription__c
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Name = 'sample';  
            zSub.Number_of_Copies1__c = '2';     
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__CustomerAccount__c = zCustAcc.Id;
            zSub.Order_Line_Item_Number__c = oli.Id;
            zSub.Subscriber_Contact__c = con.Id;
            zSub.Number_of_Copies__c = 5;
            zSub.Recipient_Contact__c = con.Id;
            zSub.Subscription_Charge__c = 123;
            zSub.Term_Length__c = 1;
            zSub.Main_Package_1__c = pack.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number_1__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Year_to_Date_Temp_Stop_Days__c = 2;
            zSub.Previous_Year_Temp_Stop_Days__c = 1;
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Zuora__Zuora_Id__c = '1123';
            zSub.Charity__c = 'false';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Delivery_Charge__c = 100;
            zSub.Sponsor_1__c = true;
            zSub.Year_to_Date_Temp_Stop_Days__c = 999;
            insert zSub;
            
            //Temp_Stop__c
            Temp_Stop__c tempStop = new Temp_Stop__c();
            tempStop.Temp_Stop_Date__c = (System.now()).date();
            tempStop.Restart_Date__c = (System.now()).date()+4;
            tempStop.Cancelled__c = True;
            insert tempStop;
                   
            //Subscription_Temp_Stop__c
            Subscription_Temp_Stop__c subTempStop = new Subscription_Temp_Stop__c();
            subTempStop.Subscription__c = zSub.Id;
            subTempStop.Temp_Stop__c = tempStop.Id;                
            insert subTempStop;
            //<
            
            Datetime dateOutput     = Datetime.now();
            String   strDateOutput  = dateOutput.format('MM/dd/yyyy');
            Datetime dateOutput2    = Datetime.now()+90;
            String   strDateOutput2 = dateOutput2.format('MM/dd/yyyy');
            
            Account accAutoNumber = [SELECT Id, Account_Auto_Number__c FROM Account WHERE Id=:acc.id];
            
            EShopRequest eShopReq   = new EShopRequest();
            eShopReq.subscriberid   = accAutoNumber.Account_Auto_Number__c;
            eShopReq.subscriptionId = zSub.id;
            eShopReq.tempStopDate   = strDateOutput;
            eShopReq.restartDate    = strDateOutput2;
            eShopReq.remarks        = '1';
            eShopReq.source         = '1';
            eShopReq.quantity       = '1';
            
            
            //FROM Zuora__Subscription__c
            //FROM Account
            //FROM Zuora__SubscriptionProductCharge__c  
            //FROM zqu__ProductRatePlan__c 
            //FROM zqu__ProductRatePlanCharge__c 
            //FROM publication__c 
            //FROM Subscription_Temp_Stop__c 
            
            Test.startTest();
            String JSONData = JSON.serialize(eShopReq);
            EShopService.EShopRequest  esh      = (EShopService.EShopRequest) JSON.deserialize(JSONData, EShopService.EShopRequest.class);
            //EShopService_CT.EShopRequest  esh      = (EShopService_CT.EShopRequest) JSON.deserialize(JSONData, EShopService_CT.EShopRequest.class);
            EShopService.EShopResponse response = EShopService.processRequest(esh);
            //EShopService_CT.EShopResponse response = EShopService_CT.processRequest(esh);
            
            String JSONDataResponse = JSON.serialize(response);
            EShopResponse localResponse = (EShopResponse ) JSON.deserialize(JSONDataResponse, EShopResponse .class);
            System.assertEquals(localResponse.svc_status,    GlobalVariableClass.SVC_STATUS_SUCCESS);
            Test.stopTest();
            
        }
    }


}