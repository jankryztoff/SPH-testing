/**
 * Class Name: SP_DeliveryChargesBatchTest
 * @author: George Santos
 * Date: 2/4/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test Class for SP_DeliveryChargesBatch
 */

@isTest(seeAllData = True)
public class SP_DeliveryChargesBatchTest {

    static testmethod void test(){
    
   try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
    
    //Create a new user with Standard User Profile
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );

        System.runAs(u){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert acc;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
            defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
            defaultPayment.Zuora__Account__c = acc.id; 
            defaultPayment.Zuora__AccountNumber__c = '1233';
            insert defaultPayment;
                
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 15;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = con.id;
            zSub.Name = 'S0000000';
            zSub.Order_Number__c = order.id;
            zSub.Zuora__CustomerAccount__c = defaultPayment.id;
            zSub.Subscription_Type__c = 'Delivery';
          
            insert zSub;
            
            List<Zuora__SubscriptionProductCharge__c> subProductChargeList = TestDataFactory.createSubProductCharge(1);
            for(Zuora__SubscriptionProductCharge__c subprodlist : subProductChargeList) {
                //Zuora__SubscriptionProductCharge__c subProductChargeRecord = new Zuora__SubscriptionProductCharge__c(Name='Test Subscription Product Charge'+i, 
                //                                                                                                 Zuora__Zuora_Id__c='ZID'+i, Zuora__Subscription__c = zSub.Id);
                subprodlist.Name = 'S0000000';
                subprodlist.Zuora__Subscription__c = zSub.Id;
                subprodlist.Zuora__UOM__c = 'Test UOM';
                subprodlist.Zuora__Account__c = acc.Id;
                //subprodList.Zuora__Subscription__c = '1233';
                subprodList.Zuora__ChargeNumber__c = '123';
                subprodList.PublicationCode__c = '12456';
                                   
            //subProductChargeList.add(subprodlist);
            }
            insert subProductChargeList;
            
            Temp_Stop__c tempStop = new Temp_Stop__c();
            tempStop.Restart_Date__c = System.Today();
            insert tempStop;
            
            Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
            subTemp.Subscription__c = zSub.id;
            subTemp.Temp_Stop__c = tempStop.id;
            insert subTemp;
            
            
            Test.startTest();
            SP_DeliveryChargesBatch delCharge = new SP_DeliveryChargesBatch();
            String batchId = Database.executeBatch(delCharge);
            //String schedBatchId = System.scheduleBatch(delCharge, 'testJob', 1);
            try 
            {
                Database.BatchableContext BC;
                delCharge.finish(BC);
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
            
            
            BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchId;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;
            Test.stopTest();
         }
          }catch(Zuora.zRemoteException e) {
          }  
    }  
        static testmethod void unitTest1() {  // <-- This is the Original Test Method Signature
        
        
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        /*BT_CO_MIRO_SubscriptionIssueFile__c sif1 = new BT_CO_MIRO_SubscriptionIssueFile__c();
        sif1.Publication_Code__c = 'code';
        sif1.Publication_Issue_Date__c = System.Today();
        sif1.postal_sector__c = 'MN';
        sif1.vendor_number__c = '0001C';
        sif1.office_house_mail_indicator__c = 'Y';
        sif1.house_type__c = 'A';
        sif1.sub_channel_code__c = 'ABC';
        sif1.subscription_copies__c = 200;
        sif1.subscriber_count__c = 100;
        
        insert sif1;*/
        
        SP_DeliveryChargesBatch batch = new SP_DeliveryChargesBatch();
        ID batchprocessid = Database.executeBatch(batch,200);
       // Database.batchableContext bc;
        //batch.finish(bc);
        System.assertNotEquals(null, batchprocessid);
        
        
        }catch(Zuora.zRemoteException e) {
          }  
    }
       
  }