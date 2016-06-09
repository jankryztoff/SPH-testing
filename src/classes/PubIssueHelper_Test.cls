/**
   @Author Joy Suarez
   @name PubIssueHelper_Test
   @CreateDate 2/24/2015
   @Description test class for PubIssueHelper
   @Version <1.0>
   @reference <Referenced program names>
  */

@isTest (seeAllData= True)
public class PubIssueHelper_Test{
 
    Static testMethod void Test_PubIssueHelper() {  
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock());

        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acct.Vendor_Group__c = 'V';
        acct.AccountNumber = '30017';
        database.insert(acct);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        con[0].Phone = '1234567';
        con[0].AccountId = acct.Id;
        database.insert(con);
       
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Zuora__Account__c = acct.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        database.insert(billAcc);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 1;
        order.Informed_Customer__c = True;
        database.insert(order);        
        
        List<Package__c> pkg = TestDataFactory.createPackage(2);
        //pkg[0].Subscription_Period__c = '15'; 
        //pkg[0].Frequency_Identifier__c = '1';
        pkg[0].Subscription_Period__c = '15'; 
        pkg[0].Frequency_Identifier__c = '0';
        database.insert(pkg);
        
        Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNNY',
        Frequency_Code__c = 'F',
        Public_Holiday_Weekend_Pub_Indicator__c = True,
        Public_Holiday_Weekday_Pub_Indicator__c = True,
        Publication_Type__c = '2',
        Publication_Next_Start_Date__c = date.today()+20      
        );
        database.insert(pub);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today()+2;
        orderline.End_Date__c = Date.Today().addDays(30);
        orderline.Main_Package_ID__c = pkg[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        //orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        database.insert(orderline);
        
        Zuora__Subscription__c zSubs =  TestDataFactory.createSubscription(1)[0];
        zSubs.Zuora__CustomerAccount__c = billAcc.id;
        zSubs.Order_Number__c = order.Id;
        zSubs.Subscriber_Contact__c = con[0].id;
        zSubs.Main_Package_1__c = pkg[0].id ;
        zSubs.Zuora__Account__c = acct.id;
        zSubs.Suppress_Vendor_Start_Notice__c = 'false';
        zSubs.Supressed_Acknowledgement_Letter__c = 'false';
        zSubs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs.Urgent__c = 'false';
        zSubs.Vendor_Conversion__c = 'false';
        zSubs.Charity__c = 'false';
        zSubs.Order_Line_Item_Number__c = orderline.id;
        zSubs.Number_of_Copies__c = 100;
        zSubs.Number_of_Copies1__c =  '100';
        zSubs.Qty__c = 20;

        database.insert(zSubs);     
        
        Test.startTest();
        PubIssueHelper.PublicationPattern pattern = new PubIssueHelper.PublicationPattern();
        
        PubIssueHelper pih = new PubIssueHelper();
        PubIssueHelper.generatePubPattern(pub);
        PubIssueHelper.generateSubPattern(pub, zSubs);
        PubIssueHelper.isHolidayPublishDate(pub, date.today());
        PubIssueHelper.isHolidayPublishDate(pattern, date.today());
        PubIssueHelper.isPublishDate(pattern, date.today()+1);
        PubIssueHelper.isPublishDateForNonDailyPub(pub, date.today());
        
        system.assertNotEquals(zSubs.Main_Package_1__c , null);
        
      
        Test.stopTest();
      }
          catch(Zuora.zRemoteException e) {
          }  
                  
    
  }     
          
    Static testMethod void Test_PubIssueHelper2() {  
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        

        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acct.Vendor_Group__c = 'V';
        acct.AccountNumber = '30017';
        database.insert(acct);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        con[0].Phone = '1234567';
        con[0].AccountId = acct.Id;
         database.insert(con);
        
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Zuora__Account__c = acct.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        database.insert(billAcc);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 2;
        order.Informed_Customer__c = True;
        database.insert(order);       
        
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15'; 
        pkg[0].Frequency_Identifier__c = '1';
        database.insert(pkg);
        
        Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'YYYYYNN',
        Publication_Type__c = '2',
        Frequency_Code__c = 'W',
        Publication_Next_Start_Date__c = date.today().addDays(20)
        );
        database.insert(pub);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today()+2;
        orderline.End_Date__c = Date.Today().addDays(30);
        orderline.Main_Package_ID__c = pkg[0].Id;
        orderline.Term_Length__c = 1;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        database.insert(orderline);
        
        Zuora__Subscription__c zSubs =  TestDataFactory.createSubscription(1)[0];
        zSubs.Zuora__CustomerAccount__c = billAcc.id;
        zSubs.Order_Number__c = order.Id;
        zSubs.Subscriber_Contact__c = con[0].id;
        zSubs.Main_Package_1__c = pkg[0].id;
        zSubs.Zuora__Account__c = acct.id;
        zSubs.Suppress_Vendor_Start_Notice__c = 'false';
        zSubs.Supressed_Acknowledgement_Letter__c = 'false';
        zSubs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs.Urgent__c = 'false';
        zSubs.Vendor_Conversion__c = 'false';
        zSubs.Charity__c = 'false';
        zSubs.Order_Line_Item_Number__c = orderline.id;
        zSubs.Number_of_Copies__c=100;
        zSubs.Number_of_Copies1__c =  '100';
        zSubs.Delivery_Charge__c = 2;
        zSubs.Qty__c = 20;
        database.insert(zSubs);     
        Test.startTest();
     
        
        
        PubIssueHelper.PublicationPattern pattern = new PubIssueHelper.PublicationPattern();
        
        PubIssueHelper pih = new PubIssueHelper();
        PubIssueHelper.generatePubPattern(pub);
        PubIssueHelper.generateSubPattern(pub, zSubs);
        PubIssueHelper.isHolidayPublishDate(pub, date.today());
        PubIssueHelper.isHolidayPublishDate(pattern, date.today());
        PubIssueHelper.isPublishDate(pattern, date.today()+2);
        PubIssueHelper.isPublishDateForNonDailyPub(pub, date.today());
        system.assertNotEquals(zSubs.Main_Package_1__c , null);
        Test.stopTest();
      }
          catch(Zuora.zRemoteException e) {
          }  
                  
    
  }     
    
    Static testMethod void Test_PubIssueHelper3() {  
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acct.Vendor_Group__c = 'V';
        acct.AccountNumber = '30017';
       database.insert(acct);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        con[0].Phone = '1234567';
        con[0].AccountId = acct.Id;
        database.insert(con);
        
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 3;
        order.Informed_Customer__c = True;
        database.insert(order);       
        
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15'; 
        pkg[0].Frequency_Identifier__c = '2';
        database.insert(pkg);
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Zuora__Account__c = acct.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        database.insert(billAcc);
        
        Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNYY',
        Publication_Type__c = '2',
        Frequency_Code__c = 'M',
        Publication_Next_Start_Date__c = date.today()+20 
        );
        database.insert(pub);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today()+2;
        orderline.End_Date__c = Date.Today().addDays(30);
        orderline.Main_Package_ID__c = pkg[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        database.insert(orderline);
        
        Zuora__Subscription__c zSubs =  TestDataFactory.createSubscription(1)[0];
        zSubs.Zuora__CustomerAccount__c = billAcc.id;
        zSubs.Order_Number__c = order.Id;
        zSubs.Subscriber_Contact__c = con[0].id;
        zSubs.Main_Package_1__c = pkg[0].id;
        zSubs.Zuora__Account__c = acct.id;
        zSubs.Suppress_Vendor_Start_Notice__c = 'false';
        zSubs.Supressed_Acknowledgement_Letter__c = 'false';
        zSubs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs.Urgent__c = 'false';
        zSubs.Vendor_Conversion__c = 'false';
        zSubs.Charity__c = 'false';
        zSubs.Order_Line_Item_Number__c = orderline.id;
        zSubs.Number_of_Copies__c = 100;
        zSubs.Number_of_Copies1__c =  '100';
        zSubs.Qty__c = 20;

        database.insert(zSubs); 
        Test.startTest();
           
        
        
        PubIssueHelper.PublicationPattern pattern = new PubIssueHelper.PublicationPattern();
        
        PubIssueHelper pih = new PubIssueHelper();
        PubIssueHelper.generatePubPattern(pub);
        PubIssueHelper.generateSubPattern(pub, zSubs);
        PubIssueHelper.isHolidayPublishDate(pub, date.today());
        PubIssueHelper.isHolidayPublishDate(pattern, date.today());
        PubIssueHelper.isPublishDate(pattern, date.today()+3);
        PubIssueHelper.isPublishDateForNonDailyPub(pub, date.today());
        system.assertNotEquals(zSubs.Main_Package_1__c , null);
        
        
        Test.stopTest();
       }
          catch(Zuora.zRemoteException e) {
          }  
                  
    
  } 
    
    Static testMethod void Test_PubIssueHelper4() {  
       try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acct.Vendor_Group__c = 'V';
        acct.AccountNumber = '30017';
       database.insert(acct);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        con[0].Phone = '1234567';
        con[0].AccountId = acct.Id;
         database.insert(con);
        
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 1;
        order.Informed_Customer__c = True;
        database.insert(order);       
        
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15'; 
        pkg[0].Frequency_Identifier__c = '3';
        database.insert(pkg);
        
        Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'YYYYYYN',
        Publication_Type__c = '2',
        Frequency_Code__c = 'B',   
        Publication_Next_Start_Date__c = date.today()+20
        );
        database.insert(pub);
                
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Zuora__Account__c = acct.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        database.insert(billAcc);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today()+2;
        orderline.End_Date__c = Date.Today().addDays(30);
        orderline.Main_Package_ID__c = pkg[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        database.insert(orderline);
        
        Zuora__Subscription__c zSubs =  TestDataFactory.createSubscription(1)[0];
        zSubs.Zuora__CustomerAccount__c = billAcc.id;
        zSubs.Order_Number__c = order.Id;
        zSubs.Subscriber_Contact__c = con[0].id;
        zSubs.Main_Package_1__c = pkg[0].id;
        zSubs.Zuora__Account__c = acct.id;
        zSubs.Suppress_Vendor_Start_Notice__c = 'false';
        zSubs.Supressed_Acknowledgement_Letter__c = 'false';
        zSubs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs.Urgent__c = 'false';
        zSubs.Vendor_Conversion__c = 'false';
        zSubs.Charity__c = 'false';
        zSubs.Order_Line_Item_Number__c = orderline.id;
        zSubs.Number_of_Copies__c = 100;
        zSubs.Number_of_Copies1__c =  '100';
        zSubs.Qty__c = 20;
        zSubs.Frequency_1__c =GlobalVariableClass.FREQ_MONSAT;

        database.insert(zSubs); 
        Test.startTest();
              
        
        
        PubIssueHelper.PublicationPattern pattern = new PubIssueHelper.PublicationPattern();
        
        PubIssueHelper pih = new PubIssueHelper();
        PubIssueHelper.generatePubPattern(pub);
        PubIssueHelper.generateSubPattern(pub, zSubs);
        PubIssueHelper.isHolidayPublishDate(pub, date.today());
        PubIssueHelper.isHolidayPublishDate(pattern, date.today());
        PubIssueHelper.isPublishDate(pattern, date.today()+4);
        PubIssueHelper.isPublishDateForNonDailyPub(pub, date.today());
        system.assertNotEquals(zSubs.Main_Package_1__c , null);
        Test.stopTest();
       }
          catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
    
    Static testMethod void Test_PubIssueHelper5() {  
       try {
        Test.setMock(WebServiceMock.class, new zLoginMock());

         Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
         acct.Vendor_Group__c = 'V';
         acct.AccountNumber = '30017';
        database.insert(acct);
         
         List<Contact> con = TestDataFactory.createContact(1);
         con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
         con[0].Recipient_Indicator__c = true;
         con[0].Phone = '1234567';
         con[0].AccountId = acct.Id;
          database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Zuora__Account__c = acct.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        database.insert(billAcc);
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acct.Id;
         order.Recipient_Contact__c = con[0].Id;
         order.Subscriber_Charge__c = 3;
         order.Informed_Customer__c = True;
         database.insert(order);       
         
         List<Package__c> pkg = TestDataFactory.createPackage(1);
         pkg[0].Subscription_Period__c = '15'; 
         pkg[0].Frequency_Identifier__c = '4';
         database.insert(pkg);
         
         Publication__c pub = new Publication__c(
         Name = 'Sample Publication',
         Publication_Code__c = 'PUB8',
         Published_Days__c = 'NNNNNNY',
         Publication_Type__c = '2',
         Frequency_Code__c = 'Q',
         Publication_Next_Start_Date__c = date.today()+20
         );
         database.insert(pub);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Start_Date__c = Date.Today();
         orderline.End_Date__c = Date.Today().addDays(30);
         orderline.Main_Package_ID__c = pkg[0].Id;
         orderline.Term_Length__c = 0;
         orderline.Main_Package_Period__c = 0;
         orderline.Earliest_Start_Date__c = date.today();
         orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
         orderline.Stop_Request_Date__c =  date.Today().addDays(4);
         orderline.Terminating_Reason__c = 'Others';
         orderline.Amount_To_Refund__c = 0;
         orderline.Admin_Charge__c = 0;
         orderline.Fee_Waiver__c = TRUE;
         orderline.Fee_Override__c = FALSE;
         orderline.Override_Reason__c = 'TEST';
         orderline.Suppress_Notification_Stop__c = TRUE;
         orderline.Main_Package_Type__c = 'Base';
     
         
         Zuora__Subscription__c zSubs =  TestDataFactory.createSubscription(1)[0];
         zSubs.Zuora__CustomerAccount__c = billAcc.id;
         zSubs.Order_Number__c = order.Id;
         zSubs.Subscriber_Contact__c = con[0].id;
         zSubs.Main_Package_1__c = pkg[0].id;
         zSubs.Zuora__Account__c = acct.id;
         zSubs.Suppress_Vendor_Start_Notice__c = 'false';
         zSubs.Supressed_Acknowledgement_Letter__c = 'false';
         zSubs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
         zSubs.Urgent__c = 'false';
         zSubs.Vendor_Conversion__c = 'false';
         zSubs.Charity__c = 'false';
         zSubs.Order_Line_Item_Number__c = orderline.id;
         zSubs.Number_of_Copies__c = 100;
         zSubs.Number_of_Copies1__c =  '100';
         zSubs.Qty__c = 20;
         zSubs.Frequency_1__c =GlobalVariableClass.FREQ_SATSUN;

        database.insert(zSubs); 
         Test.startTest();
            
         
         
         PubIssueHelper.PublicationPattern pattern = new PubIssueHelper.PublicationPattern();
         
         PubIssueHelper pih = new PubIssueHelper();
         PubIssueHelper.generatePubPattern(pub);
         PubIssueHelper.generateSubPattern(pub, zSubs);
         PubIssueHelper.isHolidayPublishDate(pub, date.today());
         PubIssueHelper.isHolidayPublishDate(pattern, date.today());
         PubIssueHelper.isPublishDate(pattern, date.today()+5);
         PubIssueHelper.isPublishDateForNonDailyPub(pub, date.today());
         system.assertNotEquals(zSubs.Main_Package_1__c , null);
         Test.stopTest();
     }
          catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
    
    Static testMethod void Test_PubIssueHelper6() {  
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acct.Vendor_Group__c = 'V';
        acct.AccountNumber = '30017';
       database.insert(acct);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        con[0].Phone = '1234567';
        con[0].AccountId = acct.Id;
         database.insert(con);
        
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 3;
        order.Informed_Customer__c = True;
        database.insert(order);       
        
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15';
        pkg[0].Frequency_Identifier__c = '5'; 
        database.insert(pkg);
        
        Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNNY',
        Publication_Type__c = '2',
        Frequency_Code__c = 'H',   
        Publication_Next_Start_Date__c = date.today()+20
        );
        database.insert(pub);
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Zuora__Account__c = acct.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        database.insert(billAcc);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today()+2;
        orderline.End_Date__c = Date.Today().addDays(30);
        orderline.Main_Package_ID__c = pkg[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        database.insert(orderline);
       
        
        Zuora__Subscription__c zSubs =  TestDataFactory.createSubscription(1)[0];
        zSubs.Zuora__CustomerAccount__c = billAcc.id;
        zSubs.Order_Number__c = order.Id;
        zSubs.Subscriber_Contact__c = con[0].id;
        zSubs.Main_Package_1__c = pkg[0].id;
        zSubs.Zuora__Account__c = acct.id;
        zSubs.Suppress_Vendor_Start_Notice__c = 'false';
        zSubs.Supressed_Acknowledgement_Letter__c = 'false';
        zSubs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs.Urgent__c = 'false';
        zSubs.Vendor_Conversion__c = 'false';
        zSubs.Charity__c = 'false';
        zSubs.Order_Line_Item_Number__c = orderline.id;
        zSubs.Number_of_Copies__c = 100;
        zSubs.Number_of_Copies1__c =  '100';
        zSubs.Qty__c = 20;
        zSubs.Frequency_1__c = GlobalVariableClass.FREQ_MONFRI;
 
        database.insert(zSubs); 
        Test.startTest();
           
        
        PubIssueHelper.PublicationPattern pattern = new PubIssueHelper.PublicationPattern();
        
        PubIssueHelper pih = new PubIssueHelper();
        PubIssueHelper.generatePubPattern(pub);
        PubIssueHelper.generateSubPattern(pub, zSubs);
        PubIssueHelper.isHolidayPublishDate(pub, date.today());
        PubIssueHelper.isHolidayPublishDate(pattern, date.today());
        PubIssueHelper.isPublishDate(pattern, date.today()+6);
        PubIssueHelper.isPublishDateForNonDailyPub(pub, date.today());
        system.assertNotEquals(zSubs.Main_Package_1__c , null);
        Test.stopTest();
   
          }
          catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
    
    Static testMethod void Test_PubIssueHelper7() {  
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());

        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acct.Vendor_Group__c = 'V';
        acct.AccountNumber = '30017';
       database.insert(acct);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        con[0].Phone = '1234567';
        con[0].AccountId = acct.Id;
         database.insert(con);
        
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 1;
        order.Informed_Customer__c = True;
        database.insert(order);       
        
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15'; 
        pkg[0].Frequency_Identifier__c = '0';
        database.insert(pkg);
        
        Publication__c pub = new Publication__c(
            Name = 'Sample Publication',
            Publication_Code__c = 'PUB8',
            Published_Days__c = 'NNNNNNY',
            Publication_Type__c = '2',
            Frequency_Code__c = 'Y',  
            Publication_Next_Start_Date__c = date.today()+20
        );
        database.insert(pub);
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Zuora__Account__c = acct.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        database.insert(billAcc);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = Date.Today()+2;
        orderline.End_Date__c = Date.Today().addDays(30);
        orderline.Main_Package_ID__c = pkg[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        //orderline.Subscription__c = subRecs[0].id;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        database.insert(orderline);
        
        Zuora__Subscription__c zSubs =  TestDataFactory.createSubscription(1)[0];
        zSubs.Zuora__CustomerAccount__c = billAcc.id;
        zSubs.Order_Number__c = order.Id;
        zSubs.Subscriber_Contact__c = con[0].id;
        zSubs.Main_Package_1__c = pkg[0].id;
        zSubs.Zuora__Account__c = acct.id;
        zSubs.Suppress_Vendor_Start_Notice__c = 'false';
        zSubs.Supressed_Acknowledgement_Letter__c = 'false';
        zSubs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs.Urgent__c = 'false';
        zSubs.Vendor_Conversion__c = 'false';
        zSubs.Charity__c = 'false';
        zSubs.Order_Line_Item_Number__c = orderline.id;
        zSubs.Number_of_Copies__c = 100;
        zSubs.Number_of_Copies1__c =  '100';
        zSubs.Qty__c = 20;
        zSubs.Frequency_1__c = GlobalVariableClass.FREQ_DEFAULT;

        database.insert(zSubs); 
        Test.startTest();
        
         
        
        PubIssueHelper.PublicationPattern pattern = new PubIssueHelper.PublicationPattern();
        
        PubIssueHelper pih = new PubIssueHelper();
        //stopsub.StopSubOrderEntry_ViewVendorController();
        PubIssueHelper.generatePubPattern(pub);
        PubIssueHelper.generateSubPattern(pub, zSubs);
        PubIssueHelper.isHolidayPublishDate(pub, date.today());
        PubIssueHelper.isHolidayPublishDate(pattern, date.today());
        PubIssueHelper.isPublishDate(pattern, date.today()+7);
        PubIssueHelper.isPublishDateForNonDailyPub(pub, date.today());
        system.assertNotEquals(zSubs.Main_Package_1__c , null);
        //stopsub.voidStatus();
        Test.stopTest();
         
          }
          catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
        
}