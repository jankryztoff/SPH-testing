/**********************************************************************/
/* Class Name:  SP_SendEmailNotifForFailedCCBatchTest 
/* Author: Marie Kristine Munda 
/* Description: A test class for SP_SendEmailNotifForFailedCCBatch
/* Date Last Modified: 02/23/2015
/**********************************************************************/

@isTest(seeAllData = TRUE)
private class SP_SendEmailNotifForFailedCCBatchTest {

    /************************************/
    /*This method is to execute all the methods in SP_SendEmailNotifForFailedCCBatch Class
    /*Oject Account, Order, SingPost are Package, Case,Ordsubscription Charges,Extenal Payments, Contact created.
    /************************************/
    static testMethod void testSendEmailNofif(){
    /****************************** Test Data Creation ****************************/
    /*   Insert code statements that inserts Data                                 */
    /*   needed by Base Class.                                                    */
    /*****************************************************************************/
     
     //Create a new user with Standard User Profile   
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='GMT',
            UserName='standard@test.com'
        );  
        
        System.runAs(testUser) {
        
        Integer counter;

     // Create Account 
     Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.NRIC__c = 'T1234567R';
     insert acc; 
     
     //create postal
      Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '6000';
        insert postal;

    //START D-4447 Gdelrosario 29.2.2016
    //create country
        Country__c count = TestDataFactory.createCountry(1)[0];
         count.Code__c = 'zz';
         insert count;
    //END D-4447 Gdelrosario 29.2.2016
        
    //Create an Address record
     List<Address__c> addressList = TestDataFactory.createAddress(1);
     addressList[0].Postal_Code__c = postal.Id;
     //START D-4447 Gdelrosario 29.2.2016
     addressList[0].Country__c = count.Id;
     //END D-4447 Gdelrosario 29.2.2016
     insert addressList;
    
    //Create contact con
    Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = addressList[0].Id;
        con.Recipient_Indicator__c = true;
        con.HomePhone__c = '12345';
        con.Office_Number__c = '12345';
        con.Mobile_Number__c = '12345';
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    insert con;
    
    //Create Billing Account
    Zuora__CustomerAccount__c ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = acc.Id;
        ba.Billing_Contact__c = con.Id;
    insert  ba;
    
    //Create Package
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
    System.assertEquals(pack.Name, 'TestPackageName');
    
    //Create Order
     Order__c order= TestDataFactory.createOrder(1)[0];   
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
    insert order;
    
    
    //Create External Payment
    List<External_Payment__c> expayment = TestDataFactory.createExternalPayment(1);
        for(External_Payment__c e : expayment){
            e.Account_Name__c =  acc.Id;
            e.Payment_Method__c ='Credit Card';
            e.Transaction_Status__c = 'F';
            e.Transaction_Type__c = 'F';
            e.Transaction_Date__c = Date.Today().addDays(-1);
            e.Billing_Account__c =ba.Id;
            e.Billing_Contact_email__c ='standard@test.com';
            e.Expiration_Date__c = date.today().addDays(30);
            e.Payment_amount__c = 50;
            e.Payment_Date__c = date.today();
            }
     insert expayment;
     
     List<Id> exID = new List<Id>();
     exID.add(expayment[0].Id);

    //Create Publication
      Publication__c pub = TestDataFactory.createPublication(1)[0];
          pub.Publication_Type__c ='M';
          pub.Published_Days__c ='NNYNNYN';
          pub.Publication_Code__c ='AAAA';
          
      insert pub;
         
    
   //Create subscrption Sub
    List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
    for(Zuora__Subscription__c sub: subList){
        sub.Zuora__Account__c = acc.Id;
        sub.Subscriber_Contact__c = con.Id;
        sub.Recipient_Contact__c = con.Id;
        sub.Main_Package_1__c = pack.id;
        sub.Main_Package__c = pack.id;
        sub.Zuora__Status__c = 'Active';
        sub.Zuora__CustomerAccount__c = ba.Id;
        sub.Order_Number__c = order.Id;
        sub.Suppress_Vendor_Start_Notice__c = 'false';
        sub.Supressed_Acknowledgement_Letter__c = 'false';
        sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Urgent__c = 'false';
        sub.Vendor_Conversion__c = 'false';
        sub.Charity__c = 'false';
        sub.Subscription_Type__c = 'Publication';
    }
        //insert sub;
        //System.assertEquals(sub.Subscription_Type__c , 'Publication');
    
    //List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
    //subList.add(sub);
    insert subList;
    
     //Create Subscription Charges
        Zuora__SubscriptionProductCharge__c subchar = TestDataFactory.createSubProductCharge(1)[0];
            subchar.Zuora__Zuora_Id__c = subList[0].id;
            subchar.Product_Code__c ='Sample Product Code';
            subchar.PublicationCode__c ='AAAA';
            subchar.Zuora__Subscription__c = subList[0].id;
         insert subchar;   
        System.assertEquals(subchar.Zuora__Zuora_Id__c, subList[0].id);
    
    
    //create Zuora__ZInvoice__c
    Zuora__ZInvoice__c zi = TestDataFactory.createInvoice(1)[0];
    zi.Zuora__BillingAccount__c = ba.Id;
    zi.Zuora__Zuora_Id__c = '123456';
    insert zi;
    
    List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
    Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
    ili.Invoice_ID__c = zi.Zuora__Zuora_Id__c;
    ili.Subscription__c = subList[0].id;
    ili.Charge_Amount__c = 100;
    insert ili;
    
    Invoice_Line_Item__c ili2 = new Invoice_Line_Item__c();
    ili2.Invoice_ID__c = zi.Zuora__Zuora_Id__c;
    ili2.Subscription__c = subList[1].id;
    ili2.Charge_Amount__c = 100;
    insert ili2;
    

  Test.startTest();
    //insert e;
    
    Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
    
    SP_SendEmailNotifForFailedCCBatch batch = new SP_SendEmailNotifForFailedCCBatch(exID);
    SP_SendEmailNotifForFailedCCBatch batch2 = new SP_SendEmailNotifForFailedCCBatch();
    SP_SendEmailNotifForFailedCCBatch batch3 = new SP_SendEmailNotifForFailedCCBatch(date.today());
                
    ID batchprocessid = Database.executeBatch(batch, 200); 
  
    BATCH_JOB_SCHEDULER__c batchScheduler1 = new BATCH_JOB_SCHEDULER__c();
            batchScheduler1.Status__c = 'ACTIVE';
            batchScheduler1.Batch_Code__c = 'ASM02';
            batchScheduler1.Batch_Run_Date__c = Date.today();
            batchScheduler1.SFDC_Job_id__c = batchprocessid ;      
            insert batchScheduler1;  
            
    /*Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
    
    SP_SendEmailNotifForFailedCCBatch batch2= new SP_SendEmailNotifForFailedCCBatch ();             
    ID batchprocessid2 = Database.executeBatch(batch2, 200); 
      
    BATCH_JOB_SCHEDULER__c batchScheduler2 = new BATCH_JOB_SCHEDULER__c();
            batchScheduler2.Status__c = 'ACTIVE';
            batchScheduler2.Batch_Code__c = 'ASM02';
            batchScheduler2.Batch_Run_Date__c = Date.today();
            batchScheduler2.SFDC_Job_id__c = batchprocessid2;       
            insert batchScheduler2;*/        
              
  Test.stopTest();
  
        
        }//End of System.runAs  
    }//End of testSendEmailNofif
    
    static testMethod void testSendEmailNofif2(){
    /****************************** Test Data Creation ****************************/
    /*   Insert code statements that inserts Data                                 */
    /*   needed by Base Class.                                                    */
    /*****************************************************************************/
     
     //Create a new user with Standard User Profile   
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='GMT',
            UserName='standard@test.com'
        );  
        
        System.runAs(testUser) {
        
        Integer counter;

     // Create Account 
     Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.NRIC__c = 'T1234567R';
     insert acc; 
     
     //create postal
      Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '6000';
        insert postal;

    //START D-4447 Gdelrosario 29.2.2016
    //create country
        Country__c count = TestDataFactory.createCountry(1)[0];
         count.Code__c = 'zz';
         insert count;
    //END D-4447 Gdelrosario 29.2.2016
        
    //Create an Address record
     List<Address__c> addressList = TestDataFactory.createAddress(1);
     addressList[0].Postal_Code__c = postal.Id;
     //START D-4447 Gdelrosario 29.2.2016
     addressList[0].Country__c = count.Id;
     //END D-4447 Gdelrosario 29.2.2016
     insert addressList;
    
    //Create contact con
    Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = addressList[0].Id;
        con.Recipient_Indicator__c = true;
        con.HomePhone__c = '12345';
        con.Office_Number__c = '12345';
        con.Mobile_Number__c = '12345';
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    insert con;
    
    //Create Billing Account
    Zuora__CustomerAccount__c ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = acc.Id;
        ba.Billing_Contact__c = con.Id;
    insert  ba;
    
    //Create Package
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
    System.assertEquals(pack.Name, 'TestPackageName');
    
    //Create Order
     Order__c order= TestDataFactory.createOrder(1)[0];   
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
    insert order;
    
    
    //Create External Payment
    List<External_Payment__c> expayment = TestDataFactory.createExternalPayment(1);
        for(External_Payment__c e : expayment){
            e.Account_Name__c =  acc.Id;
            e.Payment_Method__c ='Credit Card';
            e.Transaction_Status__c = 'F';
            e.Transaction_Type__c = 'F';
            e.Transaction_Date__c = Date.Today().addDays(-1);
            e.Billing_Account__c =ba.Id;
            e.Billing_Contact_email__c ='standard@test.com';
            e.Expiration_Date__c = date.today().addDays(30);
            e.Payment_amount__c = 50;
            e.Payment_Date__c = date.today();
            }
     insert expayment;
     
     List<Id> exID = new List<Id>();
     exID.add(expayment[0].Id);

    //Create Publication
      Publication__c pub = TestDataFactory.createPublication(1)[0];
          pub.Publication_Type__c ='M';
          pub.Published_Days__c ='NNYNNYN';
          pub.Publication_Code__c ='AAAA';
          
      insert pub;
         
    
   //Create subscrption Sub
    List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
    for(Zuora__Subscription__c sub: subList){
        sub.Zuora__Account__c = acc.Id;
        sub.Subscriber_Contact__c = con.Id;
        sub.Recipient_Contact__c = con.Id;
        sub.Main_Package_1__c = pack.id;
        sub.Main_Package__c = pack.id;
        sub.Zuora__Status__c = 'Active';
        sub.Zuora__CustomerAccount__c = ba.Id;
        sub.Order_Number__c = order.Id;
        sub.Suppress_Vendor_Start_Notice__c = 'false';
        sub.Supressed_Acknowledgement_Letter__c = 'false';
        sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Urgent__c = 'false';
        sub.Vendor_Conversion__c = 'false';
        sub.Charity__c = 'false';
        sub.Subscription_Type__c = 'Publication';
    }
        //insert sub;
        //System.assertEquals(sub.Subscription_Type__c , 'Publication');
    
    //List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
    //subList.add(sub);
    insert subList;
    
     //Create Subscription Charges
        Zuora__SubscriptionProductCharge__c subchar = TestDataFactory.createSubProductCharge(1)[0];
            subchar.Zuora__Zuora_Id__c = subList[0].id;
            subchar.Product_Code__c ='Sample Product Code';
            subchar.PublicationCode__c ='AAAA';
            subchar.Zuora__Subscription__c = subList[0].id;
         insert subchar;   
        System.assertEquals(subchar.Zuora__Zuora_Id__c, subList[0].id);
    
    
    //create Zuora__ZInvoice__c
    Zuora__ZInvoice__c zi = TestDataFactory.createInvoice(1)[0];
    zi.Zuora__BillingAccount__c = ba.Id;
    zi.Zuora__Zuora_Id__c = '123456';
    insert zi;
    
    List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
    Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
    ili.Invoice_ID__c = zi.Zuora__Zuora_Id__c;
    ili.Subscription__c = subList[0].id;
    ili.Charge_Amount__c = 100;
    insert ili;
    
    Invoice_Line_Item__c ili2 = new Invoice_Line_Item__c();
    ili2.Invoice_ID__c = zi.Zuora__Zuora_Id__c;
    ili2.Subscription__c = subList[1].id;
    ili2.Charge_Amount__c = 100;
    insert ili2;
    

  Test.startTest();
    //insert e;
    
    Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
    
    SP_SendEmailNotifForFailedCCBatch batch = new SP_SendEmailNotifForFailedCCBatch(exID);
    SP_SendEmailNotifForFailedCCBatch batch2 = new SP_SendEmailNotifForFailedCCBatch();
    SP_SendEmailNotifForFailedCCBatch batch3 = new SP_SendEmailNotifForFailedCCBatch(date.today());
                
    ID batchprocessid = Database.executeBatch(batch, 200); 
  
    BATCH_JOB_SCHEDULER__c batchScheduler1 = new BATCH_JOB_SCHEDULER__c();
            batchScheduler1.Status__c = 'ACTIVE';
            batchScheduler1.Batch_Code__c = 'ASM02';
            batchScheduler1.Batch_Run_Date__c = Date.today();
            batchScheduler1.SFDC_Job_id__c = batchprocessid ;      
            insert batchScheduler1;  
            
    /*Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
    
    SP_SendEmailNotifForFailedCCBatch batch2= new SP_SendEmailNotifForFailedCCBatch ();             
    ID batchprocessid2 = Database.executeBatch(batch2, 200); 
      
    BATCH_JOB_SCHEDULER__c batchScheduler2 = new BATCH_JOB_SCHEDULER__c();
            batchScheduler2.Status__c = 'ACTIVE';
            batchScheduler2.Batch_Code__c = 'ASM02';
            batchScheduler2.Batch_Run_Date__c = Date.today();
            batchScheduler2.SFDC_Job_id__c = batchprocessid2;       
            insert batchScheduler2;*/        
              
  Test.stopTest();
  
        
        }//End of System.runAs  
    }//End of testSendEmailNofif2
    
    static testMethod void testSendEmailNofif3(){
    
      Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
    
        SP_SendEmailNotifForFailedCCBatch batch = new SP_SendEmailNotifForFailedCCBatch(date.today());
        ID batchprocessid = Database.executeBatch(batch, 200); 
              
      Test.stopTest();
    }//End of testSendEmailNofif2
}//End of SP_SendEmailNotifForFailedCCBatchTest