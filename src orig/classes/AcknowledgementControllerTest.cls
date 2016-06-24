/**
* Class Name: AcknowledgementControllerTest
* @author: Jerome delos Santos
* Date: 1/13/2015
* @Description: This class is used for acceptable code coverage of AcknowledgementController.
* History: 
*
*/
@isTest(SeeAllData=True)

public class AcknowledgementControllerTest
{      
    static testMethod void testAcknowledgementController(){
        
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
     Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
           
            
        System.runAs(testUser){
            Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            Package__c pack = TestDataFactory.createPackage(1)[0];
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert new List<sObject>{venAccount, pack, subsVen};
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                acc.NRIC__c = 'T1234567R';
                insert acc;
                
            Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
                    
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                //addressRec.Level_Number__c = 'AB';
                addressRec.Level_Number__c = null;
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;
                insert addressRec;        
                
            Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.Address__c = addressRec.Id;
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                insert conList;
                
                
            Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
                defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
                defaultPayment.Zuora__Account__c = acc.id;
                defaultPayment.Billing_Type__c = 'Full Prepaid';
                insert defaultPayment;
            
            
            Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.Address__c = addressRec.Id;
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                insert conList2;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                //orderline.End_Date__c = date.newInstance(2015, 5, 14);
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c = 'Magazine';
                insert orderline;
             
              test.startTest();   
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = defaultPayment.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Zuora__TermSettingType__c = 'EVERGREEN'; // jurna added
                sub.Subscription_Type_1__c = 'Publication';// jurna added
                
                sub.Billing_Type__c = 'Recurring Prepaid';
                sub.Payment_Mode_1__c = 'Credit Card';
                sub.Zuora__SubscriptionEndDate__c = date.today()+30;
                sub.Zuora__SubscriptionStartDate__c  = date.today();
                sub.Zuora__TermSettingType__c ='Evergreen';
                sub.Number_of_Copies__c = 12;
                
                insert sub;    
            
            
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',sub.Id);       
            AcknowledgementController ackController = new AcknowledgementController();
            ackController.generateAcknowledgementController();
                      
            String accId = ApexPages.currentPage().getParameters().put('id', defaultPayment.id);         
            Zuora__Subscription__c Subscription = [Select Id, Contact__c, Contact__r.Address__c, Contact__r.Address__r.Block_House_Number__c From Zuora__Subscription__c Where Id =: sub.Id];
             test.stopTest();
         }
          }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  

  static testMethod void testAcknowledgementController2()
    {   
    
         try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
    Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
            
        System.runAs(testUser){
            Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            Package__c pack = TestDataFactory.createPackage(1)[0];
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert new List<sObject>{venAccount, pack, subsVen};
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                acc.NRIC__c = 'T1234567R';
                insert acc;
                
            Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
                    
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;
                insert addressRec;        
                
            Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                insert conList;
                
                Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
                defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
                defaultPayment.Zuora__Account__c = acc.id; 
                insert defaultPayment;
                
            Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                insert conList2;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                //orderline.End_Date__c = date.newInstance(2015, 4, 14);
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
               
                insert orderline;
           
            test.startTest();    
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = defaultPayment.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__TermSettingType__c = 'EVERGREEN'; // jurna added
                
                //sub.Term_Length__c=10;
                sub.Zuora__SubscriptionEndDate__c=null;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                //sub.Zuora__Status__c = 'Cancelled';
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;    
                /*sub.Delivery_Charge__c = 2;
                sub.Subscription_Charge__c = 1;
                sub.Unique_Delivery_Identifier__c = 'test';
                sub.Order_Line_Item_Number_1__c = orderline.Id;
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;*/
                // sub.Classification__c = 'pStop';
                //sub.Sub_Classification__c = 'N/A';
                
                insert sub;    
            
           
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',sub.Id);       
            AcknowledgementController ackController = new AcknowledgementController();
            ackController.generateAcknowledgementController();
            
            //String accountId = ApexPages.currentPage().getParameters().put('accountId', accList[0].id); 
            //String accountId = ApexPages.currentPage().getParameters().put('accountId', acc.id);
            String accId = ApexPages.currentPage().getParameters().put('id', defaultPayment.id);
            
            Zuora__Subscription__c Subscription = [Select Id, Contact__c, Contact__r.Address__c, Contact__r.Address__r.Block_House_Number__c From Zuora__Subscription__c Where Id =: sub.Id];
             
             
             AcknowledgementController ac = new AcknowledgementController ();
             ac.acc = new Account();
             ac.blockHouseNum = 'sdafsdfd';
             //List<Zuora__Subscription__c> SubscriptionList = new List<Zuora__Subscription__c>;
             //ac.SubscriptionList.add(sdfdf);
             //ac.SubscriptionList= new List<sObject>();
             //ac.SubscriptionList.add();
             //ac.List<Zuora__Subscription__c> SubscriptionList = new List<Zuora__Subscription__c>;
             //ac.SubscriptionList.add(sdafds);    
             ac.DateToday = date.Today();
             ac.levelNum = 'asdff';
             ac.unitNum = 'asddd';
             ac.buildingName  = 'asfsf';
             ac.stName = 'asfdf';
             ac.countryName = 'har';
             ac.postalCode= 'adfdf';
             ac.barcodeAttId = 'sada';
             ac.barChecker = true;
             ac.promo = false;
             ac.promoNP = true;
             ac.makePayment = true;
             ac.recurCC = false;
             ac.magazine = true;
             ac.recurInvoice = false;
             ac.everGreen = true;
             ac.strtotalsubprice = 'sdff';
             ac.singleStoryAddrNum = 'sdgdfgf';
             ac.totalsubprice= 1.5;
             
             AcknowledgementController.subsWrapper sw = new AcknowledgementController.subsWrapper ();
             sw.accNum = 'sdgdfg';
             sw.accName = 'dfgdfgh';
             sw.blk = 'dfhfgh';
             sw.bldg = 'sdfd';
             sw.street = 'fghfghh';
             sw.storyAdd = 'dsgdfg';
             sw.country = 'sdgg';
             sw.postal = 'sdgg';
             sw.packName = 'sdgfg';
             sw.startDate = date.today();
             sw.endDate = date.today()+30;
             sw.copyNum = 'sdgg';
             sw.subChrg ='sdgg';
             sw.homeph = 'fgdfg';
             sw.Copies = 1.5;
             sw.delCharge = 2.0;
             sw.withDel = true;
             sw.subChrgChecker = false;
             sw.isMakePayment = true;
             sw.isRecurCC = true;
             sw.isMagazine = false;
             sw.isRecurInvoice = true;
             sw.isEverGreen = false;
             sw.notEverGreen = true;
             sw.isRecur = false;
             sw.recConName = 'dfgfg';
             
             
             AcknowledgementController.innerSubsWrapper isw = new AcknowledgementController.innerSubsWrapper();
             
             
             isw.packNameInner = 'dfsdfd';
             isw.startDateInner = date.today();
             isw.endDateInner = date.today()+30;
             isw.CopiesInner = 3.0;  
             isw.subChrgInner = 'xdgdfg';
             isw.withDelInner = true;
             isw.subChrgCheckerInner = false;
             isw.isMakePaymentInner = true;
             isw.isRecurCCInner = false;
             isw.isMagazineInner = true;
             isw.isRecurInvoiceInner = false;
             isw.isEverGreenInner = true;
             isw.notEverGreenInner = false;
             isw.isRecurInner= true;
             isw.delChargeInner = 1.5;
             isw.paymentmode = 'fdssdf';
             isw.otherpaymentmode = 'sdgg';
             isw.subfreq = 'asfsdf';
             isw.billtype = 'asff';
             isw.contractperiod = 1.5;
             isw.termlength = 2.0;
             
             //AcknowledgementController.List<Id> contact_LIST = new AcknowledgementController.List<Id>();
                   
             
             test.stopTest();
         }
          }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
  
       static testMethod void testAcknowledgementController3()
    {   
    
         try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
    Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
            
        System.runAs(testUser){
            Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Test Name';
            //pack.Number_Of_Promotions__c = 12;  //
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert new List<sObject>{venAccount, pack, subsVen};
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                //postal.Name = 'Test Postal'; jurna removed
                postal.Name = 'Test'; //jurna added
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                insert acc;
                
           /* Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                acc.Airline_Indicator__c = true;
                insert acc;    */
                
            Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
           
          //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName = 'Airline'];
           
           //RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName = 'Airline'];
          
           //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Airline' LIMIT 1];
             
             //List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Airline' LIMIT 1];
                   
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
               addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;                
                //addressRec.Building_Name__c = postal.Id;
                addressRec.Name ='Test Name';
                //addressRec.RecordTypeId = rt[0].Id;
                //addressRec.Address_Type__c = 'A';
                insert addressRec;        
                
            Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
                Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
                defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
                defaultPayment.Zuora__Account__c = acc.id; 
                insert defaultPayment;
                
            Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                
                insert conList2;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                //orderline.End_Date__c = date.newInstance(2015, 4, 14);
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c ='Test Line';
                insert orderline;
           
            test.startTest();    
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Recipient_Contact_1__c = conList.Id; // jurna added
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = defaultPayment.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__TermSettingType__c = 'EVERGREEN'; // jurna added
                
                
                //sub.Term_Length__c=10;
               // sub.Zuora__SubscriptionEndDate__c=null; //jurna removed
                sub.Zuora__SubscriptionEndDate__c=date.today()+3; //jurna added
                sub.Zuora__SubscriptionStartDate__c=date.today();
                //sub.Zuora__Status__c = 'Cancelled';
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;    
                /*sub.Delivery_Charge__c = 2;
                sub.Subscription_Charge__c = 1;
                sub.Unique_Delivery_Identifier__c = 'test';
                sub.Order_Line_Item_Number_1__c = orderline.Id;
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;*/
                // sub.Classification__c = 'pStop';
                //sub.Sub_Classification__c = 'N/A';
                
                insert sub;
                
               
           
            PageReference pageRef = Page.AcknowledgementLetter;
            
            ApexPages.currentPage().getParameters().put('id',defaultPayment.Id);       
            Test.setCurrentPage(pageRef);
            AcknowledgementController ackController = new AcknowledgementController();
            ackController.generateAcknowledgementController();
            
            
            //String accountId = ApexPages.currentPage().getParameters().put('accountId', accList[0].id); 
            //String accountId = ApexPages.currentPage().getParameters().put('accountId', acc.id);
            //String accId = ApexPages.currentPage().getParameters().put('id', acc.id);
            
            Zuora__Subscription__c Subscription = [Select Id, Contact__c, Contact__r.Address__c, Contact__r.Address__r.Block_House_Number__c From Zuora__Subscription__c Where Id =: sub.Id];
             
                                  
             test.stopTest();
             
              }
              
              }
              catch(Zuora.zRemoteException e) {
          }  
              
           
   }
   
        static testMethod void testAcknowledgementController4()
    {   
    
         try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
    Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
            
        System.runAs(testUser){
            Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Test Name';
            //pack.Number_Of_Promotions__c = 12;  //
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert new List<sObject>{venAccount, pack, subsVen};
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                insert acc;
                
            Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
           
           //RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName = 'Internal' LIMIT 1];
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;                
                //addressRec.Building_Name__c = postal.Id;
                addressRec.Name ='Test Name';
                //addressRec.RecordTypeId = rt.Id;
                insert addressRec;        
                
            Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                //conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
                Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
                defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
                defaultPayment.Zuora__Account__c = acc.id; 
                insert defaultPayment;
                
            Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                conList2.Recipient_Indicator__c = true;
                insert conList2;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                //orderline.End_Date__c = date.newInstance(2015, 4, 14);
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                //orderline.Main_Package_Product_Sub_Type__c ='Test Line';
                orderline.Main_Package_Product_Sub_Type__c ='Newspaper';
                insert orderline;
           
            test.startTest();    
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = defaultPayment.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Delivery';
                sub.Subscription_Type_1__c = 'Delivery';
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                
                
                //sub.Term_Length__c=10;
                sub.Zuora__SubscriptionEndDate__c= date.today()+30;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                sub.Zuora__Status__c = 'Cancelled';
               // sub.Classification__c = 'pStop';
                //sub.Sub_Classification__c = 'N/A';
                
                insert sub; 
                
               
           
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',defaultPayment.Id);       
            AcknowledgementController ackController = new AcknowledgementController();
            ackController.generateAcknowledgementController();
            
            
            //String accountId = ApexPages.currentPage().getParameters().put('accountId', accList[0].id); 
            //String accountId = ApexPages.currentPage().getParameters().put('accountId', acc.id);
            //String accId = ApexPages.currentPage().getParameters().put('id', acc.id);
            
            Zuora__Subscription__c Subscription = [Select Id, Contact__c, Contact__r.Address__c, Contact__r.Address__r.Block_House_Number__c From Zuora__Subscription__c Where Id =: sub.Id];
             
                                  
             test.stopTest();
             
              }
              
              }
              catch(Zuora.zRemoteException e) {
          }  
                  
    
   }
      static testMethod void testAcknowledgementController5()
    {   
    
         try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
    Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
            
        System.runAs(testUser){
            Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Test Name';
            //pack.Number_Of_Promotions__c = 12;  //
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert new List<sObject>{venAccount, pack, subsVen};
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
            /*Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                insert acc;*/
                
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                acc.Airline_Indicator__c = true;
                insert acc;    
                
            Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
           
          //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName = 'Airline'];
           
           //RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName = 'Airline'];
          
           //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Airline' LIMIT 1];
             
             //List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Airline' LIMIT 1];
                
               City__c cit =TestDataFactory.createCity(1)[0];
               cit.City_Name__c = 'Cebu City';
               cit.Flight_Number_1__c = '12';
               cit.Flight_Number_2__c = '10';
               insert cit;                
                
                Packing_Grp__c packgroup =  new Packing_Grp__c();
                packgroup.Airline__c = 'J';
                insert packgroup; 
                   
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
               addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                //addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;                
                //addressRec.Building_Name__c = postal.Id;
                addressRec.Name ='Test Name';
                //addressRec.RecordTypeId = rt[0].Id;
                addressRec.Address_Type__c = 'A';
                addressRec.Packing_Code__c = packgroup.Id;
                addressRec.City__c = cit.Id;
                
                insert addressRec;        
                
            Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
                Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
                defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
                defaultPayment.Zuora__Account__c = acc.id; 
                insert defaultPayment;
                
            Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                insert conList2;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                //orderline.End_Date__c = date.newInstance(2015, 4, 14);
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c ='Test Line';
                insert orderline;
           
            test.startTest();    
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = defaultPayment.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__TermSettingType__c = 'EVERGREEN'; // jurna added
                
                
                //sub.Term_Length__c=10;
                sub.Zuora__SubscriptionEndDate__c=null;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                //sub.Zuora__Status__c = 'Cancelled';
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;    
                /*sub.Delivery_Charge__c = 2;
                sub.Subscription_Charge__c = 1;
                sub.Unique_Delivery_Identifier__c = 'test';
                sub.Order_Line_Item_Number_1__c = orderline.Id;
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;*/
                // sub.Classification__c = 'pStop';
                //sub.Sub_Classification__c = 'N/A';
                
                insert sub; 
               
           
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',defaultPayment.Id);       
            AcknowledgementController ackController = new AcknowledgementController();
            ackController.generateAcknowledgementController();
            
            
            //String accountId = ApexPages.currentPage().getParameters().put('accountId', accList[0].id); 
            //String accountId = ApexPages.currentPage().getParameters().put('accountId', acc.id);
            //String accId = ApexPages.currentPage().getParameters().put('id', acc.id);
            
            Zuora__Subscription__c Subscription = [Select Id, Contact__c, Contact__r.Address__c, Contact__r.Address__r.Block_House_Number__c From Zuora__Subscription__c Where Id =: sub.Id];
             
                                  
             test.stopTest();
             
              }
              
              }
              catch(Zuora.zRemoteException e) {
          }  
              
           
   
   }
       static testMethod void testAcknowledgementController6()
    {   
    
         try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
    Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
            
        System.runAs(testUser){
            Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Test Name';
            //pack.Number_Of_Promotions__c = 12;  //
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert new List<sObject>{venAccount, pack, subsVen};
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
            
                
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                //acc.Airline_Indicator__c = true;
                insert acc;    
                
            Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
           
          
                
               City__c cit =TestDataFactory.createCity(1)[0];
               cit.City_Name__c = 'Cebu City';
               cit.Flight_Number_1__c = '12';
               cit.Flight_Number_2__c = '10';
               insert cit;                
                   
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
               addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                //addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;                
                //addressRec.Building_Name__c = postal.Id;
                addressRec.Name ='Test Name';
                //addressRec.RecordTypeId = rt[0].Id;
                addressRec.Address_Type__c = 'A';
                addressRec.Address_1__c= 'J';
                addressRec.Address_2__c = 'O';
                addressRec.Address_3__c = 'Y';
                addressRec.Address_4__c = 'Z';
                
                addressRec.City__c = cit.Id;
                
                insert addressRec;        
                
            Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
                Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
                defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
                defaultPayment.Zuora__Account__c = acc.id; 
                insert defaultPayment;
                
            Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                insert conList2;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                //orderline.End_Date__c = date.newInstance(2015, 4, 14);
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c =GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER;
                insert orderline;
           
            test.startTest();    
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = defaultPayment.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__TermSettingType__c = 'EVERGREEN'; // jurna added
                
                
                //sub.Term_Length__c=10;
                sub.Zuora__SubscriptionEndDate__c=null;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                //sub.Zuora__Status__c = 'Cancelled';
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;    
                /*sub.Delivery_Charge__c = 2;
                sub.Subscription_Charge__c = 1;
                sub.Unique_Delivery_Identifier__c = 'test';
                sub.Order_Line_Item_Number_1__c = orderline.Id;
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;*/
                // sub.Classification__c = 'pStop';
                //sub.Sub_Classification__c = 'N/A';
                
                insert sub; 
                
               
           
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',defaultPayment.Id);       
            AcknowledgementController ackController = new AcknowledgementController();
            ackController.generateAcknowledgementController();
            
            
            
            
            Zuora__Subscription__c Subscription = [Select Id, Contact__c, Contact__r.Address__c, Contact__r.Address__r.Block_House_Number__c From Zuora__Subscription__c Where Id =: sub.Id];
             
                                  
             test.stopTest();
             
              }
              
              }
              catch(Zuora.zRemoteException e) {
          }  
              
           
   
           }
           
      static testMethod void testAcknowledgementController7()
    {   
    
         try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
    Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
            
        System.runAs(testUser){
            Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Recurring Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            
            
            //pack.Number_Of_Promotions__c = 12;  //
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert new List<sObject>{venAccount, pack, subsVen};
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
            
                
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                //acc.Airline_Indicator__c = true;
                insert acc;    
                
            Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
           
          
                
               City__c cit =TestDataFactory.createCity(1)[0];
               cit.City_Name__c = 'Cebu City';
               cit.Flight_Number_1__c = '12';
               cit.Flight_Number_2__c = '10';
               insert cit;                
                 
                SPH_Section__c sec = new SPH_Section__c();
                sec.Section_Name__c = 'Test Name';
                insert sec;
                 
                SPH_Department__c dept = new SPH_Department__c();
                dept.Department_Name__c = 'test department';
                insert dept;
                
                SPH_Division__c div = new SPH_Division__c();
                div.Name = 'Test Division';
                insert div;
                
                SPH_Company__c comp = new SPH_Company__c();
                comp.Company_Name__c = 'Test Company';
                insert comp;
                
                SPH_Location__c loc = new SPH_Location__c();
                loc.Location_Name__c = 'test location';
                insert loc;
                   
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
               addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                //addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;                
                //addressRec.Building_Name__c = postal.Id;
                addressRec.Name ='Test Name';
                //addressRec.RecordTypeId = rt[0].Id;
                addressRec.Address_Type__c = 'A';
                addressRec.Address_1__c= 'J';
                addressRec.Address_2__c = 'O';
                addressRec.Address_3__c = 'Y';
                addressRec.Address_4__c = 'Z';
                addressRec.Section_Code__c = sec.Id;
                addressRec.Department__c = dept.Id;
                addressRec.Division_Code__c = div.Id;
                addressRec.City__c = cit.Id;
                addressRec.Company_Code__c = comp.Id;
                addressRec.Location_Code__c = loc.Id;
                
                insert addressRec;        
                
            Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
                Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
                defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
                defaultPayment.Zuora__Account__c = acc.id; 
                defaultPayment.Billing_Type__c = 'Recurring Prepaid';
                insert defaultPayment;
                
            Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                insert conList2;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                orderRec.Payment_Mode__c = 'Credit Card';
                insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                //orderline.End_Date__c = date.newInstance(2015, 4, 14);
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c =GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE;
                orderline.DTL_Date__c = Date.today();
                insert orderline;
           
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                insert billAcc;
                       
            test.startTest();    
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                // sub.Zuora__CustomerAccount__c = defaultPayment.id; jurna removed
                sub.Zuora__CustomerAccount__c = billAcc.id; //jurna removed
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__TermSettingType__c = 'EVERGREEN'; // jurna added
                
                
                //sub.Term_Length__c=10;
                sub.Zuora__SubscriptionEndDate__c=null;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                //sub.Zuora__Status__c = 'Cancelled';
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;    
                /*sub.Delivery_Charge__c = 2;
                sub.Subscription_Charge__c = 1;
                sub.Unique_Delivery_Identifier__c = 'test';
                sub.Order_Line_Item_Number_1__c = orderline.Id;
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;*/
                // sub.Classification__c = 'pStop';
                //sub.Sub_Classification__c = 'N/A';
                
                insert sub; 
                
               
           
            PageReference pageRef = Page.AcknowledgementLetter;
            Test.setCurrentPage(pageRef);
            //ApexPages.currentPage().getParameters().put('id',acc.Id);  
            ApexPages.currentPage().getParameters().put('id',defaultPayment.Id);     
            AcknowledgementController ackController = new AcknowledgementController();
            ackController.generateAcknowledgementController();
            
            
            
            
            Zuora__Subscription__c Subscription = [Select Id, Contact__c, Contact__r.Address__c, Contact__r.Address__r.Block_House_Number__c From Zuora__Subscription__c Where Id =: sub.Id];
             
                                  
             test.stopTest();
             
              }
              
              }
              catch(Zuora.zRemoteException e) {
          }  
              
           
   
           }
           
                   }