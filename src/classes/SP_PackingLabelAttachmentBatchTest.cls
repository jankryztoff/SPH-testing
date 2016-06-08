/**
@Author Val Lu
@name SP_PackingLabelAttachmentBatchTest
@CreateDate 02/26/2015
@Description To test SP_PackingLabelAttachmentBatch class
@Version <1.0>
*/
@isTest(SeeAllData=True)
private class SP_PackingLabelAttachmentBatchTest {
    /**
*  To test SP_PackingLabelAttachmentBatch class
*  @name testSP_PackingLabelAttachmentBatchTest1
*  @param none
*  @return none
*  @throws na
*/            
    // Test Method for Condition:
    // if(batchObject.Zuora__Account__r.RecordType.Name == 'Direct Corporate' && batchObject.Zuora__Account__r.Airline_Indicator__c && batchObject.Recipient_Contact__r.Address__r.RecordType.Name == 'Airline')
    static testmethod void testSP_PackingLabelAttachmentBatchTest_Trial(){
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
            createCustomSettings();
            
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                ACC.Airline_Indicator__c = true;
                insert acc;
                //objectMap.put('Account', acc);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c = 'A';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                addressRec.RecordTypeId = addRecId;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
                Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;
                //objectMap.put('Billing Contact', con1);   
                
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
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.newInstance(2015, 7, 30);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
            
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
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
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                
                insert subRecs;
                
                System.debug('LILYSTART');
                System.debug([SELECT Id, Name FROM Zuora__Subscription__c WHERE Id =:subRecs.id]);
                System.debug('LILYEND');
                
                //objectMap.put('Zuora__Subscription__c', Subs);  
                
                //Id fromSubs = Subs.id;                                                     
                                                     
                Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
//                packLabel.Account_Name__c = acc.id;
                packLabel.Subscription__c = subRecs.id;
//                packLabel.Subscription__c = 'a0XN0000001JsnM';
                insert packLabel;
                
               
                BATCH_JOB_SCHEDULER__c batchJob = new BATCH_JOB_SCHEDULER__c();
                batchJob.SFDC_Job_id__c = '102547863';
                batchJob.Batch_Run_Date__c = date.Today()+1;
                insert batchJob;
                
                Test.startTest();  
                
                Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
                
                SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch('a',100,'b');
                ID batchprocessid = Database.executeBatch(batch, 100);
                
                system.assertNotEquals(null, batchprocessid);
                
                Test.stopTest(); 
                
            }    
        }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
        
    }
  
    // Test Method for Condition:
    // if(batchObject.Delivered_By_1__c == 'Mailing Agent' && batchObject.Recipient_Contact__r.Address__r.RecordType.Name == 'Overseas')             
    static testmethod void testSP_PackingLabelAttachmentBatchTest_Trial02(){
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                       
            createCustomSettings();
            
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                ACC.Airline_Indicator__c = false;
                insert acc;
                //objectMap.put('Account', acc);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c = 'A';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Overseas' LIMIT 1].Id;
                addressRec.RecordTypeId = addRecId;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
                Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;
                //objectMap.put('Billing Contact', con1);   
                
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
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.newInstance(2015, 7, 30);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
            
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
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
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                
                insert subRecs;
                
                //objectMap.put('Zuora__Subscription__c', Subs);  
                
                //Id fromSubs = Subs.id;                                                     
                                                     
                Packing_Label_Batch__c packLabel = new Packing_Label_Batch__c();
//                packLabel.Account_Name__c = acc.id;
                packLabel.Subscription__c = subRecs.id;
//                packLabel.Subscription__c = 'a0XN0000001JsnM';
                insert packLabel;

                
                BATCH_JOB_SCHEDULER__c batchJob = new BATCH_JOB_SCHEDULER__c();
                batchJob.SFDC_Job_id__c = '102547863';
                batchJob.Batch_Run_Date__c = date.Today()+1;
                insert batchJob;
                

                Test.startTest();  
                
                Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
                
                SP_PackingLabelAttachmentBatch batch = new SP_PackingLabelAttachmentBatch('a',200,'b');
                ID batchprocessid = Database.executeBatch(batch, 200);
                
                system.assertNotEquals(null, batchprocessid);
                
                Test.stopTest(); 
                
            }    
        }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
        
    }

    private static void createCustomSettings(){
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            List<Key_Id__c> keyList = new List<Key_Id__c>();
            List<RecordType> recordTypeList = [Select Id, Name, SObjectType From RecordType];
            Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
            for(RecordType recordType: recordTypeList){
                recordTypeMap.put(recordType.SObjectType+recordType.Name, recordType);
            
            Key_Id__c key = new Key_Id__c();
            key.Name = 'Contact_Customer Contact';
            key.Type__c= 'Record Type';
            key.Id__c = recordTypeMap.get('ContactCustomer Contact').id;
            Key_Id__c key2 = new Key_Id__c();
            key2.Name = 'NEXT_RECIPIENT_NUMBER';
            key2.Id__c = '123457461';
            key2.Type__c = 'Number';
            Key_Id__c key3 = new Key_Id__c();
            key3.Name = 'Address_Local';
            key3.Id__c = recordTypeMap.get('Address__cLocal').id;
            key3.Type__c = 'Record Type';
            Key_Id__c key4 = new Key_Id__c();
            key4.Name = 'Account_Vendor Subscriber';
            key4.Id__c = recordTypeMap.get('AccountVendor Subscriber').id;
            key4.Type__c = 'Record Type';
            Key_Id__c key5 = new Key_Id__c();
            key5.Name = 'Case_Change in Address';
            key5.Id__c = recordTypeMap.get('CaseChange of Address/Vendor').id;
            key5.Type__c = 'Record Type';
            
            keyList.add(key);
            keyList.add(key2);
            keyList.add(key3);
            keyList.add(key4);
            keyList.add(key5);
            insert keyList;
            
            Cir_Planner_Schedule__c cps = new Cir_Planner_Schedule__c();
               cps.Mon_Fri_Start_Time__c = DateTime.newInstance(2015,07,9,08,00,0);
                cps.Sat_PH_Start_Time__c = DateTime.newInstance(2015,07,09,08,00,0);
                cps.Sun_Start_Time__c = DateTime.newInstance(2015,07,09,17,00,0);
                cps.Mon_Fri_End_Time__c = DateTime.newInstance(2015,07,19,22,00,0);
                cps.Sat_PH_End_Time__c = DateTime.newInstance(2015,07,18,17,00,0);
                cps.Sun_End_Time__c = DateTime.newInstance(2015,07,18,17,00,0); 
            cps.Name = 'CIR Plan Schedule';
            insert cps;
        }
        }
           catch(Exception e) {}
    }
}