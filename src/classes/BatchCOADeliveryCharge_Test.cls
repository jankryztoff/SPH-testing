/**
  * Class Name: BatchCOADeliveryCharge
  * @author: Joyrem Zarmaine D. Ayuman
  * Date: 02 July 2015
  * Requirement/Project Name: SPH Project
  * @description Test Class for BatchCOADeliveryCharge
  * 
  */
  
  
@isTest(seeAllData=true)
public class BatchCOADeliveryCharge_Test{

         static testmethod void testBatchCOADelivery() {     
           
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                insert acc; 
              
                List<Singpost_Address__c> singPost = TestDataFactory.createSingpostAddress(1); 
                insert singPost ;  
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c = 'A';
                //addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                addressRec.Postal_Code__c = singPost[0].id;
                insert addressRec;
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con; 
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Recurring Prepaid'; 
                insert billAcc;
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Name = 'Pack name';
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
            
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
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c = 'Recurring Prepaid';
                order.Subscriber_Charge__c = 15; // added by jjzs
                insert order;
            
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today()+30;
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.Earliest_Start_Date__c = Date.today();
                orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
                orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE; 
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                insert orderline;
               
               
                Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
                subRecord.Zuora__Account__c = acc.Id;
                subRecord.Recipient_Contact__c = con.Id;
                subRecord.Zuora__Zuora_Id__c = 'asdf123';
                subRecord.Delivery_Charge_Type_1__c = '9';
                subRecord.Delivery_Charge_Type__c = '9';
                subRecord.Delivered_By__c = 'B';
                subRecord.Zuora__CustomerAccount__c = billAcc.Id;
                subRecord.Zuora__SubscriptionStartDate__c = date.Today() +1;
                subRecord.Contract_End_Date_1__c = date.Today() +90;
                subRecord.Contract_End_Date__c = '09/30/2015';
                //subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRecord.Zuora__SubscriptionEndDate__c=date.today()+100;
                subRecord.Order_Line_Item_Number_1__c = orderline.id;
                subRecord.Zuora__Status__c = 'Active';
                subRecord.Subscription_Type_1__c = 'Delivery';
                subRecord.Subscription_Type__c = 'Delivery';
                subRecord.Subscriber_Contact__c = con.Id;
                subRecord.Main_Package_1__c = pack.id;
                subRecord.Billing_Type__c = 'Recurring Prepaid';
                //subRecord.Order_Number__c = orderRec.Id;
                subRecord.Suppress_Vendor_Start_Notice__c = 'false';
                subRecord.Supressed_Acknowledgement_Letter__c = 'false';
                subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecord.Urgent__c = 'false';
                subRecord.Vendor_Conversion__c = 'false';
                subRecord.Charity__c = 'false';
                subRecord.Sponsor_1__c = true;
                subRecord.Number_of_Copies__c=100;
                subRecord.Number_of_Copies1__c =  '100';
                subRecord.Qty__c = 20;               
                insert subRecord;
    
    /*
                  List<Zuora__Subscription__c> lstDelSubs = [SELECT Id, Zuora__Account__c, Recipient_Contact__c, Recipient_Contact__r.Address__c, Zuora__Zuora_Id__c, Delivery_Charge_Type_1__c,
                                        Zuora__CustomerAccount__c, Zuora__SubscriptionStartDate__c, Contract_End_Date_1__c,Zuora__SubscriptionEndDate__c, Order_Line_Item_Number_1__c  
                                        FROM Zuora__Subscription__c 
                                        WHERE Zuora__Zuora_Id__c =:con.id AND
                                        Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Delivery' 
                                        AND (Billing_Type__c= 'Recurring Prepaid' OR Billing_Type__c= 'Recurring Postpaid')];
                  
                  System.assertNotEquals(null, lstDelSubs.size());*/
    
    
    
    
                ID jobID;
                jobID = con.id;
                
                Map<ID, String> mapNewContactToSub = new Map<ID, String>();
                mapNewContactToSub.put(con.id, 'asdf123');
                            // add contacts id mapNewContactToSub.put(id,'');
                            
                Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
                mapDelZuoraIdToOldAddressId.put('asdf123',addressRec.Id); 
                
                Set<String> strSet = new Set<String>(); //added by Yng [START]
                strSet.add('sample');
                
                Map<ID, Set<String>> mapNew = new Map<ID, Set<String>>();
                mapNew.put(con.id, strSet); //added by Yng [END]
                
                BatchAddressAssignmentEffectiveDate batchCOA = new BatchAddressAssignmentEffectiveDate(Date.NewInstance(2000,01,01));
                Id batchJobId = Database.executeBatch(batchCOA, 1); //CHA
                
                //BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId, jobID);
                BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNew, mapDelZuoraIdToOldAddressId, batchJobId); //CHA
                ID batchprocessid = Database.executeBatch(batch,1);
                System.assertNotEquals(null, batchprocessid);
    
           }
        
        static testMethod void testConstructor01() {
             // Call other Batch that will throw NullPointerException.
             try {
                /*BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(null, null);
                 ID batchprocessid = Database.executeBatch(batch,1);
                 System.assertNotEquals(null, batchprocessid);*/ //CHA
             }catch(System.NullPointerException e){}
         }
    
        static testmethod void testoldAddType() {  
           
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc; 
          
            List<Singpost_Address__c> singPost = TestDataFactory.createSingpostAddress(1); 
            insert singPost ;  
            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c = 'A';
                //addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                addressRec.Postal_Code__c = singPost[0].id;
                insert addressRec;
                
                Contact con = TestDataFactory.createContact(1)[0];
                //con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con; 
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Recurring Prepaid'; 
                insert billAcc;
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Name = 'Pack name';
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
            
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
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c = 'Recurring Prepaid';
                order.Subscriber_Charge__c = 15; // added by jjzs
                insert order;
            
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today()+30;
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.Earliest_Start_Date__c = Date.today();
                orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
                orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE; 
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                insert orderline;
               
               
                Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
                subRecord.Zuora__Account__c = acc.Id;
                subRecord.Recipient_Contact__c = con.Id;
                subRecord.Zuora__Zuora_Id__c = 'asdf123';
                subRecord.Delivery_Charge_Type_1__c = '9';
                subRecord.Delivery_Charge_Type__c = '9';
                subRecord.Delivered_By__c = 'H';
                subRecord.Zuora__CustomerAccount__c = billAcc.Id;
                subRecord.Zuora__SubscriptionStartDate__c = date.Today() +1;
                subRecord.Contract_End_Date_1__c = date.Today() +90;
                subRecord.Contract_End_Date__c = '09/30/2015';
                //subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRecord.Zuora__SubscriptionEndDate__c=date.today()+100;
                subRecord.Order_Line_Item_Number_1__c = orderline.id;
                subRecord.Zuora__Status__c = 'Active';
                subRecord.Subscription_Type_1__c = 'Delivery';
                subRecord.Subscription_Type__c = 'Delivery';
                subRecord.Subscriber_Contact__c = con.Id;
                subRecord.Main_Package_1__c = pack.id;
                subRecord.Billing_Type__c = 'Recurring Prepaid';
                //subRecord.Order_Number__c = orderRec.Id;
                subRecord.Suppress_Vendor_Start_Notice__c = 'false';
                subRecord.Supressed_Acknowledgement_Letter__c = 'false';
                subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecord.Urgent__c = 'false';
                subRecord.Vendor_Conversion__c = 'false';
                subRecord.Charity__c = 'false';
                subRecord.Sponsor_1__c = true;
                subRecord.Number_of_Copies__c=100;
                subRecord.Number_of_Copies1__c =  '100';
                subRecord.Qty__c = 20;               
                insert subRecord;
    
    
                ID jobID;
                jobID = con.id;
                
                Map<ID, String> mapNewContactToSub = new Map<ID, String>();
                mapNewContactToSub.put(con.id, 'asdf123');
               
                Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
                mapDelZuoraIdToOldAddressId.put('test',con.Id);       
           
                Set<String> strSet = new Set<String>(); //added by Yng [START]
                strSet.add('sample');
                
                Map<ID, Set<String>> mapNew = new Map<ID, Set<String>>();
                mapNew.put(con.id, strSet); //added by Yng [END]
                
                BatchAddressAssignmentEffectiveDate batchCOA = new BatchAddressAssignmentEffectiveDate(Date.NewInstance(2000,01,01));
                Id batchJobId = Database.executeBatch(batchCOA, 1); //CHA
                
                //BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNew, mapDelZuoraIdToOldAddressId, jobID);
                BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNew, mapDelZuoraIdToOldAddressId, batchJobId);
                ID batchprocessid = Database.executeBatch(batch,1);
                System.assertNotEquals(null, batchprocessid);
    
            }
            
            static testmethod void testoldAddType2() {  
           
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc; 
          
            List<Singpost_Address__c> singPost = TestDataFactory.createSingpostAddress(1); 
            insert singPost ;  
            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c = 'A';
                //addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                addressRec.Postal_Code__c = singPost[0].id;
                insert addressRec;
                
                Contact con = TestDataFactory.createContact(1)[0];
                //con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con; 
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Recurring Prepaid'; 
                insert billAcc;
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Name = 'Pack name';
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
            
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
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c = 'Recurring Prepaid';
                order.Subscriber_Charge__c = 15; // added by jjzs
                insert order;
            
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today()+30;
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.Earliest_Start_Date__c = Date.today();
                orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
                orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE; 
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                insert orderline;
               
               
                Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
                subRecord.Zuora__Account__c = acc.Id;
                subRecord.Recipient_Contact__c = con.Id;
                subRecord.Zuora__Zuora_Id__c = 'asdf123';
                subRecord.Delivery_Charge_Type_1__c = '9';
                subRecord.Delivery_Charge_Type__c = '9';
                subRecord.Delivered_By__c = 'H';
                subRecord.Zuora__CustomerAccount__c = billAcc.Id;
                subRecord.Zuora__SubscriptionStartDate__c = date.Today() +1;
                subRecord.Contract_End_Date_1__c = date.Today() +90;
                subRecord.Contract_End_Date__c = '09/30/2015';
                //subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRecord.Zuora__SubscriptionEndDate__c=date.today()+100;
                subRecord.Order_Line_Item_Number_1__c = orderline.id;
                subRecord.Zuora__Status__c = 'Active';
                subRecord.Subscription_Type_1__c = 'Delivery';
                subRecord.Subscription_Type__c = 'Delivery';
                subRecord.Subscriber_Contact__c = con.Id;
                subRecord.Main_Package_1__c = pack.id;
                subRecord.Billing_Type__c = 'Recurring Prepaid';
                //subRecord.Order_Number__c = orderRec.Id;
                subRecord.Suppress_Vendor_Start_Notice__c = 'false';
                subRecord.Supressed_Acknowledgement_Letter__c = 'false';
                subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecord.Urgent__c = 'false';
                subRecord.Vendor_Conversion__c = 'false';
                subRecord.Charity__c = 'false';
                subRecord.Sponsor_1__c = true;
                subRecord.Number_of_Copies__c=100;
                subRecord.Number_of_Copies1__c =  '100';
                subRecord.Qty__c = 20;               
                insert subRecord;
    
    
                ID jobID;
                jobID = con.id;
                
                Map<ID, String> mapNewContactToSub = new Map<ID, String>();
                mapNewContactToSub.put(con.id, 'asdf123');
               
                Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
                mapDelZuoraIdToOldAddressId.put('test',con.Id);       
           
                Set<String> strSet = new Set<String>(); //added by Yng [START]
                strSet.add('sample');
                
                Map<ID, Set<String>> mapNew = new Map<ID, Set<String>>();
                mapNew.put(con.id, strSet); //added by Yng [END]
                     
                BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNew, mapDelZuoraIdToOldAddressId, jobID);
                //BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNew, mapDelZuoraIdToOldAddressId);
                ID batchprocessid = Database.executeBatch(batch,1);
                System.assertNotEquals(null, batchprocessid);
    
            }
            
        static testmethod void testBatchCOADelivery2() {
                  
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc; 
          
            List<Singpost_Address__c> singPostList = TestDataFactory.createSingpostAddress(12); 
            singPostList[0].Address_Type__c = 'B';
            singPostList[1].Address_Type__c = 'A';
            singPostList[2].Address_Type__c = 'H';
            singPostList[3].Address_Type__c = 'P';
            singPostList[4].Address_Type__c = 'S';
            singPostList[5].Address_Type__c = 'G';
            singPostList[6].Address_Type__c = 'K';
            singPostList[7].Address_Type__c = 'u';
            singPostList[8].Address_Type__c = 'C';
            singPostList[9].Address_Type__c = 'P';
            singPostList[10].Address_Type__c = 'H';
            singPostList[11].Address_Type__c = 'G';
            insert singPostList;  
            
            List<Address__c> addressRecList = TestDataFactory.createAddress(12);
            for(Address__c addressRec : addressRecList) {
                //addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
            }
            addressRecList[0].Postal_Code__c = singPostList[0].id;
            addressRecList[1].Postal_Code__c = singPostList[1].id;
            addressRecList[2].Postal_Code__c = singPostList[2].id;
            addressRecList[3].Postal_Code__c = singPostList[3].id;
            addressRecList[4].Postal_Code__c = singPostList[4].id;
            addressRecList[5].Postal_Code__c = singPostList[5].id;
            addressRecList[6].Postal_Code__c = singPostList[6].id;
            addressRecList[7].Postal_Code__c = singPostList[7].id;
            addressRecList[8].Postal_Code__c = singPostList[8].id;
            addressRecList[9].Postal_Code__c = singPostList[9].id;
            addressRecList[10].Postal_Code__c = singPostList[10].id;
            addressRecList[11].Postal_Code__c = singPostList[11].id;
            insert addressRecList;
            
            List<Contact> conList = TestDataFactory.createContact(12);
            for(Contact con:conList){
                con.AccountId = acc.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
            }
            conList[0].Address__c = addressRecList[0].Id;
            conList[1].Address__c = addressRecList[1].Id;
            conList[2].Address__c = addressRecList[2].Id;
            conList[3].Address__c = addressRecList[3].Id;
            conList[4].Address__c = addressRecList[4].Id;
            conList[5].Address__c = addressRecList[5].Id;
            conList[6].Address__c = addressRecList[6].Id;
            conList[7].Address__c = addressRecList[7].Id;
            conList[8].Address__c = addressRecList[8].Id;
            conList[9].Address__c = addressRecList[9].Id;
            conList[10].Address__c = addressRecList[10].Id;
            conList[11].Address__c = addressRecList[11].Id;
            insert conList;         
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Recurring Prepaid'; 
            insert billAcc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
        
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = conList[0].Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = conList[0].id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = 'Recurring Prepaid';
            order.Subscriber_Charge__c = 15; // added by jjzs
            insert order;
        
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; 
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;
           
           
            List<Zuora__Subscription__c> subRecordList = TestDataFactory.createSubscription(12);
            for (Zuora__Subscription__c subRecord : subRecordList ) {
                subRecord.Zuora__Account__c = acc.Id;
                subRecord.Delivery_Charge_Type_1__c = '9';
                subRecord.Delivery_Charge_Type__c = '9';
                subRecord.Delivered_By__c = 'B';
                subRecord.Zuora__CustomerAccount__c = billAcc.Id;
                subRecord.Zuora__SubscriptionStartDate__c = date.Today() +1;
                subRecord.Contract_End_Date_1__c = date.Today() +90;
                subRecord.Contract_End_Date__c = '09/30/2015';
                //subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRecord.Zuora__SubscriptionEndDate__c=date.today()+100;
                subRecord.Order_Line_Item_Number_1__c = orderline.id;
                subRecord.Zuora__Status__c = 'Active';
                subRecord.Subscription_Type_1__c = 'Delivery';
                subRecord.Subscription_Type__c = 'Delivery';
                subRecord.Main_Package_1__c = pack.id;
                subRecord.Billing_Type__c = 'Recurring Prepaid';
                //subRecord.Order_Number__c = orderRec.Id;
                subRecord.Suppress_Vendor_Start_Notice__c = 'false';
                subRecord.Supressed_Acknowledgement_Letter__c = 'false';
                subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecord.Urgent__c = 'false';
                subRecord.Vendor_Conversion__c = 'false';
                subRecord.Charity__c = 'false';
                subRecord.Sponsor_1__c = true;
                subRecord.Number_of_Copies__c=100;
                subRecord.Number_of_Copies1__c =  '100';
                subRecord.Qty__c = 20;           
            }    
            
            subRecordList[0].Zuora__Zuora_Id__c = 'asdf1233';
            subRecordList[0].Recipient_Contact__c = conList[0].Id;
            subRecordList[0].Subscriber_Contact__c = conList[0].Id;
            subRecordList[1].Zuora__Zuora_Id__c = 'asdf1234';
            subRecordList[1].Recipient_Contact__c = conList[1].Id;
            subRecordList[1].Subscriber_Contact__c = conList[1].Id;
            subRecordList[2].Zuora__Zuora_Id__c = 'asdf1235';
            subRecordList[2].Recipient_Contact__c = conList[2].Id;
            subRecordList[2].Subscriber_Contact__c = conList[2].Id;
            subRecordList[3].Zuora__Zuora_Id__c = 'asdf1236';
            subRecordList[3].Recipient_Contact__c = conList[3].Id;
            subRecordList[3].Subscriber_Contact__c = conList[3].Id;        
            subRecordList[4].Zuora__Zuora_Id__c = 'asdf1237';
            subRecordList[4].Recipient_Contact__c = conList[4].Id;
            subRecordList[4].Subscriber_Contact__c = conList[4].Id;
            subRecordList[5].Zuora__Zuora_Id__c = 'asdf1238';
            subRecordList[5].Recipient_Contact__c = conList[5].Id;
            subRecordList[5].Subscriber_Contact__c = conList[5].Id;
            subRecordList[6].Zuora__Zuora_Id__c = 'asdf1239';
            subRecordList[6].Recipient_Contact__c = conList[6].Id;
            subRecordList[6].Subscriber_Contact__c = conList[6].Id;
            subRecordList[7].Zuora__Zuora_Id__c = 'asdf1240';
            subRecordList[7].Recipient_Contact__c = conList[7].Id;
            subRecordList[7].Subscriber_Contact__c = conList[7].Id;        
            subRecordList[8].Zuora__Zuora_Id__c = 'asdf1241';
            subRecordList[8].Recipient_Contact__c = conList[9].Id;
            subRecordList[8].Subscriber_Contact__c = conList[9].Id;
            subRecordList[9].Zuora__Zuora_Id__c = 'asdf1242';
            subRecordList[9].Recipient_Contact__c = conList[10].Id;
            subRecordList[9].Subscriber_Contact__c = conList[10].Id;
            subRecordList[10].Zuora__Zuora_Id__c = 'asdf1243';
            subRecordList[10].Recipient_Contact__c = conList[11].Id;
            subRecordList[10].Subscriber_Contact__c = conList[11].Id;
            subRecordList[11].Zuora__Zuora_Id__c = 'asdf1244';
            subRecordList[11].Recipient_Contact__c = conList[8].Id;
            subRecordList[11].Subscriber_Contact__c = conList[8].Id;
                
            insert subRecordList;
    
    
            ID jobID;
            jobID = conList[0].id;
            
            Map<ID, String> mapNewContactToSub = new Map<ID, String>();
            mapNewContactToSub.put(conList[0].id, 'asdf1233');
            mapNewContactToSub.put(conList[1].id, 'asdf1234');
            mapNewContactToSub.put(conList[2].id, 'asdf1235');
            mapNewContactToSub.put(conList[3].id, 'asdf1236');
            mapNewContactToSub.put(conList[4].id, 'asdf1237');
            mapNewContactToSub.put(conList[5].id, 'asdf1238');
            mapNewContactToSub.put(conList[6].id, 'asdf1239');
            mapNewContactToSub.put(conList[7].id, 'asdf1240');
            mapNewContactToSub.put(conList[8].id, 'asdf1241');
            mapNewContactToSub.put(conList[9].id, 'asdf1242');
            mapNewContactToSub.put(conList[10].id, 'asdf1243');
            mapNewContactToSub.put(conList[11].id, 'asdf1244');
            
            Set<Id> AddressIds = new Set<Id>();
            AddressIds.add(addressRecList[0].id);        
            AddressIds.add(addressRecList[1].id);        
            AddressIds.add(addressRecList[2].id);        
            AddressIds.add(addressRecList[3].id);
            AddressIds.add(addressRecList[4].id);        
            AddressIds.add(addressRecList[5].id);        
            AddressIds.add(addressRecList[6].id);        
            AddressIds.add(addressRecList[7].id);
            AddressIds.add(addressRecList[8].id);        
            AddressIds.add(addressRecList[9].id);        
            AddressIds.add(addressRecList[10].id);        
            AddressIds.add(addressRecList[11].id);
            
            List<Address__c> addressUpdateList = [select Id,Name, Postal_Code__c, Address_Type__c from Address__c where Id in:AddressIds];
            addressUpdateList[0].Postal_Code__c = singPostList[11].id;
            addressUpdateList[1].Postal_Code__c = singPostList[10].id;
            addressUpdateList[2].Postal_Code__c = singPostList[9].id;
            addressUpdateList[3].Postal_Code__c = singPostList[8].id;
            addressUpdateList[4].Postal_Code__c = singPostList[7].id;
            addressUpdateList[5].Postal_Code__c = singPostList[6].id;
            addressUpdateList[6].Postal_Code__c = singPostList[5].id;
            addressUpdateList[7].Postal_Code__c = singPostList[4].id;
            addressUpdateList[8].Postal_Code__c = singPostList[3].id;
            addressUpdateList[9].Postal_Code__c = singPostList[2].id;
            addressUpdateList[10].Postal_Code__c = singPostList[1].id;
            addressUpdateList[11].Postal_Code__c = singPostList[0].id;
            update addressUpdateList;
            
            
            Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
            mapDelZuoraIdToOldAddressId.put('asdf1233',addressRecList[11].Id); 
            mapDelZuoraIdToOldAddressId.put('asdf1234',addressRecList[10].Id);
            mapDelZuoraIdToOldAddressId.put('asdf1235',addressRecList[9].Id); 
            mapDelZuoraIdToOldAddressId.put('asdf1236',addressRecList[8].Id); 
            mapDelZuoraIdToOldAddressId.put('asdf1237',addressRecList[7].Id); 
            mapDelZuoraIdToOldAddressId.put('asdf1238',addressRecList[6].Id);
            mapDelZuoraIdToOldAddressId.put('asdf1239',addressRecList[5].Id); 
            mapDelZuoraIdToOldAddressId.put('asdf1240',addressRecList[4].Id); 
            mapDelZuoraIdToOldAddressId.put('asdf1241',addressRecList[3].Id); 
            mapDelZuoraIdToOldAddressId.put('asdf1242',addressRecList[2].Id);
            mapDelZuoraIdToOldAddressId.put('asdf1243',addressRecList[1].Id); 
            mapDelZuoraIdToOldAddressId.put('asdf1244',addressRecList[0].Id); 
            //mapDelZuoraIdToOldAddressId.put('asdf12345',addressRec2.Id); 
            
            Set<String> strSet = new Set<String>(); //added by Yng [START]
            strSet.add('sample');
                
            Map<ID, Set<String>> mapNew = new Map<ID, Set<String>>();
            mapNew.put(conList[0].id, strSet); //added by Yng [END]
            
            BatchAddressAssignmentEffectiveDate batchCOA = new BatchAddressAssignmentEffectiveDate(Date.NewInstance(2000,01,01));
            Id batchJobId = Database.executeBatch(batchCOA, 1); //CHA
            
            BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNew, mapDelZuoraIdToOldAddressId, batchJobId); //CHA
            //BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId, jobID);
            //BatchCOADeliveryChargeCloneTest batch = new BatchCOADeliveryChargeCloneTest(mapNewContactToSub, mapDelZuoraIdToOldAddressId, jobID);
            ID batchprocessid = Database.executeBatch(batch,50);
            System.assertNotEquals(null, batchprocessid);
           
        }
 }