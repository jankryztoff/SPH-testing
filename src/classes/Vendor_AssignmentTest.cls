/*
*@description: Test class for Vendor_Assignment
*/
@isTest (seeAllData = true)
private class Vendor_AssignmentTest{
          private static String sphSysAd = ConstantsSLB.getKeyId('Profile_System Administrator');
          private static User usrTest;   
          static testMethod void createTestData() {
        
       
                //test User - change to appropriate Profile
                usrTest = new User(
                             alias = 'testuser', 
                             email = 'testUser123@salesforce.com', 
                             emailencodingkey = 'UTF-8', 
                             firstname = 'Insert', 
                             lastname = 'Tester', 
                             languagelocalekey = 'en_US', 
                             localesidkey = 'en_US', 
                             profileid = sphSysAd,
                             //UserRoleId = '',
                             timezonesidkey = 'America/Los_Angeles', 
                             username = 'testUser123@salesforce.com');
          }
      
         static testMethod void testCreateVendorEntry() {
         
                  
                    List<Account> accList = TestDataFactory.createAccount(1, 'Vendor');   
                    accList[0].Name = 'mailing Acct';
                    accList[0].Mailing_Agent_Code__c = '0012156';
                    acclist[0].PostalCode__c = '545848';
                    insert accList;
                        
                    System.debug ('Account: ' + [Select Name, PostalCode__c from Account]);
                    
                    Singpost_Address__c singPost = TestDataFactory.createSingpostAddress(1)[0];
                    singPost.Name = '123';
                    singPost.House_Block_Number__c = 'TEST';
                    singPost.Address_Type__c = 'A'; 
                    singPost.SingPost_Key__c = '1212';
                    singPost.Street_Name__c = 'Guada';
                    insert singPost;
                    
                    Address__c addressRec = TestDataFactory.createAddress(1)[0];
                    addressRec.Address_Type__c = 'A';
                    addressRec.Postal_Code__c = singPost.Id;
                    addressRec.Block_House_Number__c ='TEST';
                    addressRec.Level_Number__c ='xx';
                    addressRec.Unit_Number__c = 'yy';
                    insert addressRec;
                    
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.Address__c = addressRec.Id;
                    con.AccountId = accList[0].Id;
                    //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    con.Recipient_Indicator__c = true;
                    insert con;
                    
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].Zuora__Account__c = accList[0].id; 
                    billAccountList[0].Zuora__AccountNumber__c = '001122';
                    insert billAccountList; 
                    
                    Package__c pack = TestDataFactory.createPackage(1)[0];
                    database.insert(pack);
                    
                    Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];
                    zsub.Name = 'Ron';
                    zsub.Zuora__CustomerAccount__c = billAccountList[0].id;
                    zsub.Main_Package_1__c = pack.id;
                    zsub.Main_Package__c = pack.Id;
                    zsub.Zuora__Account__c = acclist[0].id;
                    zsub.Recipient_Contact__c = con.Id;
                    //zsub.Recipient_Contact_1__c = con.Id;
                    zsub.Subscriber_Contact__c = con.Id;
                    //zsub.Subscriber_Contact_1__c = con.Id;
                    zsub.Frequency_1__c = 'Mon - Fri';
                    zsub.Frequency__c = 'Mon - Fri';
                    zsub.Number_of_Copies__c = 2;
                    zsub.Subscription_End_Date__c = string.valueOf(date.today());
                    zSub.Contact__c = con.id;
                    zSub.Subscription_Type_1__c = 'Publication';
                    zSub.Subscription_Type__c = 'Publication';
                    zSub.Delivered_By_1__c = 'Vendor';
                    zSub.Vendor_1__c = accList[0].id;
                    
                    insert zsub; 
                    
                    List<Order__c> orderList = TestDataFactory.createOrder(1);
                    //set order values
                    orderList[0].Account__c = accList[0].id;
                    orderList[0].Status__c = 'Draft';
                    orderList[0].DTL_Date__c = date.today();
                    orderList[0].Account__c = accList[0].id;
                    orderList[0].Status__c = 'Draft';
                    orderList[0].Recipient_Contact__c = con.id;
                    insert orderList;
                    
                    List<Publication__c> npub = TestDataFactory.createPublication(2);                                                     
                    npub[0].Publication_Code__c = 'PUB1';
                    npub[0].Published_Days__c = 'YYYYNNY';
                    npub[0].Publication_Type__c = 'N';
                    npub[0].Publish_Pattern__c = 'Weekdays';
                    npub[0].Platform_Type__c = 'Print';
                    npub[0].Earliest_Start_Date__c = date.today().addDays(2);
                    npub[0].Vendor_Sub_Delivery_Method__c = 'Mailing Agent';
                    
                    npub[1].Publication_Code__c = 'PUB2';
                    npub[1].Published_Days__c = 'YYYYNNY';
                    npub[1].Publication_Type__c = 'N';
                    npub[1].Publish_Pattern__c = 'Weekdays';
                    npub[1].Platform_Type__c = 'Print';
                    npub[1].Earliest_Start_Date__c = date.today().addDays(2);
                    npub[1].Vendor_Sub_Delivery_Method__c = 'Vendor';
                    insert npub;
                    
                    //create oliv
                    List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
                    orderLineItemList[0].Order__c = orderList[0].id;
                    orderLineItemList[0].Start_Date__c = date.today();
                    orderLineItemList[0].Stop_Date__c = date.today().addDays(2);
                    orderLineItemList[0].Order__c = orderList[0].id;
                    orderLineItemList[0].Start_Date__c = date.today().addDays(1);
                    orderLineItemList[0].Stop_Date__c = date.today().addDays(2);
                    orderLineItemList[0].Publication__c = npub[0].Id;
                    
                    orderLineItemList[1].Order__c = orderList[0].id;
                    orderLineItemList[1].Start_Date__c = date.today();
                    orderLineItemList[1].Stop_Date__c = date.today().addDays(2);
                    orderLineItemList[1].Order__c = orderList[0].id;
                    orderLineItemList[1].Start_Date__c = date.today().addDays(1);
                    orderLineItemList[1].Stop_Date__c = date.today().addDays(2);
                    orderLineItemList[1].Publication__c = npub[1].Id;
                    database.insert(orderLineItemList);
                    
                    
                    List<Vendor_Allocation__c> vendorAllocation = TestDataFactory.createVendorAlloc(1);
                    vendorAllocation[0].Vendor_Account__c = accList[0].Id;
                    vendorAllocation[0].Legacy_Created_By__c = 'Alfred';
                    vendorAllocation[0].Legacy_Created_Date__c = '02/17/2015';
                    vendorAllocation[0].Legacy_Updated_By__c = 'Alfred Abrina';
                    vendorAllocation[0].Legacy_Updated_Date__c = '02/19/2015';
                    vendorAllocation[0].Effective_Start_Date__c = date.Today();
                    vendorAllocation[0].SingPost_Address__c = singPost.Id;
                    vendorAllocation[0].Allocated__c = true;
                    insert vendorAllocation;
                    
                    
                    
                    Case cas = TestDataFactory.createCase(1,  'Complaint - Newspaper')[0];
                    cas.Accountid = accList[0].id;
                    cas.Subscription_Name__c = zsub.id;
                    database.insert(cas);
                    
                    List<Order_Line_Item__c> OLItem = TestDataFactory.createOrderLineItem(2);
                    for(Order_Line_Item__c ordItem : OLItem){
                    ordItem.Order__c = orderList[0].id;
                    ordItem.Main_Package_ID__c = pack.Id;
                    ordItem.Case__c = cas.id;
                    
                    }
                    OLItem[0].Delivered_By__c = 'Mailing agent';
                    OLItem[0].Main_Package_Product_Platform__c = 'Print';
                    
                    OLItem[1].Delivered_By__c = 'Vendor';
                    OLItem[1].Main_Package_Product_Platform__c = 'Digital';
                    database.insert(OLItem);
                    
                    set<string> sPostalCode = new set<string>();
                    List<Order_Line_Item_Vendor__c> itv = new List<Order_Line_Item_Vendor__c>();
                    List<Order_Line_Item_Vendor__c> oli = [Select Id, Recipient_Postal_Code__c, Name, Order__c, Publication__c from Order_Line_Item_Vendor__c];    
                    
                    test.starttest();
                    sPostalCode.add (oli[0].Recipient_Postal_Code__c );   
                                        
                    Vendor_Assignment va = new Vendor_Assignment ();
                    va.Assign_Vendor_To_Order_line_Items(orderLineItemList);
                    va.Assign_Vendor_To_Order_line_Items(OLItem);
                    va.assignExistingVendor(OLItem);
                    
                    orderList[0].Recipient_Contact__c = con.Id;
                    database.update(orderList);
                    
                    orderLineItemList[0].Order__c = orderList[0].Id;
                    orderLineItemList[1].Order__c = orderList[0].Id;
                    database.update(orderLineItemList);
                    
                    Set<Id> olivID = new set<Id>();
                    for(Order_Line_Item_Vendor__c idOliv : orderLineItemList){
                    olivID.add(idOliv.Id);
                    }
                                                          
                    orderList[0].Recipient_Contact__c = con.Id;
                    database.update(orderList);
                    
                    //OLItem[0].Order__c = null;
                    //database.update(OLItem);
                    // OLItem[0].Order__c = orderList[0].Id;
                    // database.update(OLItem[0]);
                    //Set<Id> olivID2 = new set<Id>();
                    //for(Order_Line_Item__c idOliv2 : OLItem){
                    //    olivID2.add(idOliv2.Id);
                    //}
                    //List<Order_Line_Item__c> oliv2 = [SELECT Id, Delivered_By__c, Recipient_Postal_Code__c, Case__c FROM Order_Line_Item__c WHERE Id IN: olivID2 AND Recipient_Postal_Code__c <> null];
                    //va.Assign_Vendor_To_Order_Line_Items(oliv2);
                    //OLItem[0].Delivered_By__c = 'Mailing Agent';
                    //database.update(OLItem);
                    //Set<Id> olivID3 = new set<Id>();
                    //for(Order_Line_Item__c idOliv3 : OLItem){
                    //    olivID3.add(idOliv3.Id);
                    //}
                    // List<Order_Line_Item__c> oliv3 = [SELECT Id, Delivered_By__c, Recipient_Postal_Code__c FROM Order_Line_Item__c WHERE Id IN: olivID3 AND Recipient_Postal_Code__c <> null];
                    //   va.Assign_Vendor_To_Order_Line_Items(oliv3);
                    //   va.Assign_Vendor_To_Order_Line_Items(OLItem);
                    test.stopTest();  
     } 
        static testMethod void testCreateVendorEntryDigital() {
                List<Account> accList = TestDataFactory.createAccount(1, 'Vendor');   
                accList[0].Name = 'mailing Acct';
                accList[0].Mailing_Agent_Code__c = '0012156';
                acclist[0].PostalCode__c = '545848';
                insert accList;
                
                System.debug ('Account: ' + [Select Name, PostalCode__c from Account]);
                
                Singpost_Address__c singPost = TestDataFactory.createSingpostAddress(1)[0];
                singPost.Name = '123';
                singPost.House_Block_Number__c = 'TEST';
                singPost.Address_Type__c = 'A'; 
                singPost.SingPost_Key__c = '1212';
                singPost.Street_Name__c = 'Guada';
                insert singPost;
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c = 'A';
                addressRec.Postal_Code__c = singPost.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                insert addressRec;
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = accList[0].Id;
                //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                insert con;
                
                List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                billAccountList[0].Zuora__Account__c = accList[0].id; 
                billAccountList[0].Zuora__AccountNumber__c = '001122';
                insert billAccountList; 
                
                Package__c pack = TestDataFactory.createPackage(1)[0];
                database.insert(pack);
                
                Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];
                zsub.Name = 'Ron';
                zsub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zsub.Main_Package_1__c = pack.id;
                zsub.Main_Package__c = pack.Id;
                zsub.Zuora__Account__c = acclist[0].id;
                zsub.Recipient_Contact__c = con.Id;
                //zsub.Recipient_Contact_1__c = con.Id;
                zsub.Subscriber_Contact__c = con.Id;
                //zsub.Subscriber_Contact_1__c = con.Id;
                zsub.Frequency_1__c = 'Mon - Fri';
                zsub.Frequency__c = 'Mon - Fri';
                zsub.Number_of_Copies__c = 2;
                zsub.Subscription_End_Date__c = string.valueOf(date.today());
                zSub.Contact__c = con.id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Delivered_By_1__c = 'Vendor';
                zSub.Vendor_1__c = accList[0].id;
                
                insert zsub; 
                
                List<Order__c> orderList = TestDataFactory.createOrder(1);
                //set order values
                orderList[0].Account__c = accList[0].id;
                orderList[0].Status__c = 'Draft';
                orderList[0].DTL_Date__c = date.today();
                orderList[0].Account__c = accList[0].id;
                orderList[0].Status__c = 'Draft';
                orderList[0].Recipient_Contact__c = con.id;
                insert orderList;
                
                List<Publication__c> npub = TestDataFactory.createPublication(2);                                                     
                npub[0].Publication_Code__c = 'PUB1';
                npub[0].Published_Days__c = 'YYYYNNY';
                npub[0].Publication_Type__c = 'N';
                npub[0].Publish_Pattern__c = 'Weekdays';
                npub[0].Platform_Type__c = 'Print';
                npub[0].Earliest_Start_Date__c = date.today().addDays(2);
                npub[0].Vendor_Sub_Delivery_Method__c = 'Mailing Agent';
                
                npub[1].Publication_Code__c = 'PUB2';
                npub[1].Published_Days__c = 'YYYYNNY';
                npub[1].Publication_Type__c = 'N';
                npub[1].Publish_Pattern__c = 'Weekdays';
                npub[1].Platform_Type__c = 'Print';
                npub[1].Earliest_Start_Date__c = date.today().addDays(2);
                npub[1].Vendor_Sub_Delivery_Method__c = 'Vendor';
                insert npub;
                
                //create oliv
                List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
                orderLineItemList[0].Order__c = orderList[0].id;
                orderLineItemList[0].Start_Date__c = date.today();
                orderLineItemList[0].Stop_Date__c = date.today().addDays(2);
                orderLineItemList[0].Order__c = orderList[0].id;
                orderLineItemList[0].Start_Date__c = date.today().addDays(1);
                orderLineItemList[0].Stop_Date__c = date.today().addDays(2);
                orderLineItemList[0].Publication__c = npub[0].Id;
                
                orderLineItemList[1].Order__c = orderList[0].id;
                orderLineItemList[1].Start_Date__c = date.today();
                orderLineItemList[1].Stop_Date__c = date.today().addDays(2);
                orderLineItemList[1].Order__c = orderList[0].id;
                orderLineItemList[1].Start_Date__c = date.today().addDays(1);
                orderLineItemList[1].Stop_Date__c = date.today().addDays(2);
                orderLineItemList[1].Publication__c = npub[1].Id;
                database.insert(orderLineItemList);
                
                
                List<Vendor_Allocation__c> vendorAllocation = TestDataFactory.createVendorAlloc(1);
                vendorAllocation[0].Vendor_Account__c = accList[0].Id;
                vendorAllocation[0].Legacy_Created_By__c = 'Alfred';
                vendorAllocation[0].Legacy_Created_Date__c = '02/17/2015';
                vendorAllocation[0].Legacy_Updated_By__c = 'Alfred Abrina';
                vendorAllocation[0].Legacy_Updated_Date__c = '02/19/2015';
                vendorAllocation[0].Effective_Start_Date__c = date.Today();
                vendorAllocation[0].SingPost_Address__c = singPost.Id;
                vendorAllocation[0].Allocated__c = true;
                insert vendorAllocation;
                
                              
                Case cas = TestDataFactory.createCase(1,  'Complaint - Newspaper')[0];
                cas.Accountid = accList[0].id;
                cas.Subscription_Name__c = zsub.id;
                database.insert(cas);
                
                List<Order_Line_Item__c> OLItem = TestDataFactory.createOrderLineItem(2);
                for(Order_Line_Item__c ordItem : OLItem){
                 ordItem.Order__c = orderList[0].id;
                 ordItem.Main_Package_ID__c = pack.Id;
                 ordItem.Case__c = cas.id;
                 
                }
                OLItem[0].Delivered_By__c = 'Mailing agent';
                OLItem[0].Main_Package_Product_Platform__c = 'Digital';
                
                OLItem[1].Delivered_By__c = 'Vendor';
                OLItem[1].Main_Package_Product_Platform__c = 'Digital';
                database.insert(OLItem);
                
                set<string> sPostalCode = new set<string>();
                List<Order_Line_Item_Vendor__c> itv = new List<Order_Line_Item_Vendor__c>();
                List<Order_Line_Item_Vendor__c> oli = [Select Id, Recipient_Postal_Code__c, Name, Order__c, Publication__c from Order_Line_Item_Vendor__c];    
                
                test.starttest();
                
                sPostalCode.add (oli[0].Recipient_Postal_Code__c );   
                            
                Vendor_Assignment va = new Vendor_Assignment ();
                va.Assign_Vendor_To_Order_line_Items(orderLineItemList);
                va.Assign_Vendor_To_Order_line_Items(OLItem);
                
                orderList[0].Recipient_Contact__c = con.Id;
                database.update(orderList);
                
                orderLineItemList[0].Order__c = orderList[0].Id;
                orderLineItemList[1].Order__c = orderList[0].Id;
                database.update(orderLineItemList);
                
                test.stopTest(); 
       }

}