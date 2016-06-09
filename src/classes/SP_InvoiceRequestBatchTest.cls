/**
@Author Alfed Abrina
@name SP_InvoiceRequestBatchTest
@CreateDate 02/12/2015
@Description Test class for SP_InvoiceRequestBatch
@Version <1.0>
@reference SP_InvoiceRequestBatch
//Start/End PD-0027 Raviteja 16May2016 - Restructre the class by removing seeAllData True
*/  

@isTest (seeAllData = false)
public class SP_InvoiceRequestBatchTest { 
   
   
   static List<Contact> contactList;
   
   static List<City__c> cityList;
   static City__c city;
   public static Set<Id> inv = new Set<Id>();
   
    /*@testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
    }*/  
   
   static testMethod void test1(){
       Test.StartTest();
           dataPreparation('N/A', 0, 0, 100);
           SP_InvoiceRequestBatch batch = new SP_InvoiceRequestBatch('A', 4, 'abbs', inv);
           ID batchprocessid = Database.executeBatch(batch, 200); 
       Test.StopTest(); 
   }
   
   static testMethod void testChargeAmountZero(){
       Test.StartTest();
           dataPreparation('N/A', 0, 0, 0);
           SP_InvoiceRequestBatch batch = new SP_InvoiceRequestBatch('A', 4, 'abbs', inv);
           ID batchprocessid = Database.executeBatch(batch, 200); 
       Test.StopTest(); 
   }
   
   static testMethod void test1Negative(){
       Test.StartTest();
           dataPreparation('N/A', null, null, 100);
           SP_InvoiceRequestBatch batch = new SP_InvoiceRequestBatch('A', 4, 'abbs', inv);
           ID batchprocessid = Database.executeBatch(batch, 200); 
       Test.StopTest(); 
   }
   
   static testMethod void paymentMethodInvoice(){
       Test.StartTest();
           dataPreparation('Invoice', 0, 0, 100);
           SP_InvoiceRequestBatch batch = new SP_InvoiceRequestBatch('A', 4, 'abbs', inv);
           ID batchprocessid = Database.executeBatch(batch, 200); 
       Test.StopTest(); 
   }
   
   
    
    static void dataPreparation(String paymentMethod, Integer zuoraBalance, Integer zuoraPaymentAmount, integer invoiceLIChargeAmount){
        defaultCustomSetting();
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.GST_Invoice__c = 'Yes';
        insert acc;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        insert pack;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
        
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            insert pItem; 
        
        //create zuora account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        billAcc.Other_PaymentMethod__c = paymentMethod;
        billAcc.Zuora__Balance__c = zuoraBalance;
        insert billAcc;
        
          
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        cityList = TestDataFactory.createCity(1);
        city = cityList.get(0);
        city.City_Name__c = 'cityName_test';
        city.Flight_Number_1__c = 'cityFlightNumber1_test';
        city.Flight_Number_2__c = 'cityFlightNumber2_test';
        insert city;   
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '123457397';
        key.Type__c = 'Number';
        insert key; 
        */
        
        List<Contact> con = TestDataFactory.createContactRecType(1, 'Contact Customer_Contact');  
        con[0].FirstName = 'TestContactFirstname';
        con[0].LastName = 'MyLastname';
        con[0].Salutation = 'Mr.';
        con[0].Email = 'test@yahoo.com';        
        con[0].Phone= '1112485454';
        con[0].Recipient_Indicator__c = true;
        con[0].AccountId = acc.id;
        con[0].Address__c = addressRec.Id;                                                
        insert con;
        
            
         List<Contact> con1 = new List<Contact>(); 
         List<RecordType> rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: '' LIMIT 1]; 
         for(Integer i=0;i<3;i++){
             Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);
          if(rt2.size() > 0){
                   contactRecord.RecordTypeId = rt2[0].Id;
          }
              contactRecord.Billing_Indicator__c = true;
              contactRecord.AccountId = acc.id;
              contactRecord.Address__c = addressRec.Id;                                           
              con1.add(contactRecord);  
            }   
            insert con1;
                 
        Order__c order = TestDataFactory.createOrder(1)[0]; 
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con[0].Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1[0].id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        
        order.ARMS_Account_Number__c = '1110000';
        order.ARMS_Account_ID__c = '00000';
        order.ARMS_Credit_Term__c = 'ABC';
        
        //additional fields        
        order.Customer_No__c = '12345';
        order.Debt_Management_Treatment__c = 'asdfg';
        order.Business_Profile__c = 'sample business profile';
        order.Cust_Giro_Acct_Number__c = '110000000';
        order.Cust_Giro_Bank_Number__c = 'BANK-00100';
        order.Credit_Limit_External_Limit__c = '250000.00';
        order.Credit_Limit_Internal_Limit__c = '560000.00';
        order.Credit_Term_Reference__c = '0';
        order.Customer_No__c = '000000069';

        order.Payment_Mode__c = 'Other';
        order.Other_Payment_Mode__c = 'Invoice';        
        order.Approved_Debt_Exposure_Amount__c = '12345';
        order.Business_Sector__c = 'IT';
        order.Company_Code__c = 'ACN';
        order.SOA_Suppression_Indicator__c = 'A';
        order.Transient_Indicator__c = 'A';            
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = true;
        order.isOrderLegacy__c = true;
        insert order;        
       
        
                    
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();  
        for(Integer i=0;i<5;i++){   
            Order_Line_Item__c orderLineItemRecord = new Order_Line_Item__c
            (New_Contract_Period__c=30, 
            DTL_Date__c=date.today(),
            Earliest_Start_Date__c=date.today(), 
            Start_Date__c=date.today()+1,   
            End_Date__c=date.today()+100, 
            Main_Package_Period__c=100,      
            Qty__c=100, 
            Term_Length__c=100,          
            Delivered_By__c='Vendor', 
            Main_Package_Billing_Type__c='Full Prepaid',        
            Main_Package_Frequency__c='Default', 
            Main_Package_Sub_Type__c='Termed',        
            Main_Package_Type__c='Base',
            Generate_Invoice__c = true,
            Order__c = order.Id,
            Main_Package_ID__c = pack.Id);            
            orderLineItemList.add(orderLineItemRecord);}
            insert orderLineItemList;         
       
        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = GlobalVariableClass.ENDPOINTDELEGATOR;
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';       
        insert bis;*/
       
        Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
        zInv.Zuora__BillingAccount__c = billAcc.id;
        zInv.Zuora__Account__c = acc.id;
        zInv.Zuora__AmountWithoutTax__c = 100;
        zInv.Zuora__TaxAmount__c = 100;
        zInv.Zuora__Zuora_Id__c = 'ABC123456';
        zinv.Zuora__TotalAmount__c = 110;
        zinv.Zuora__PaymentAmount__c = zuoraPaymentAmount;
        insert zInv;
        
        
        inv.add(zInv.Id);
        
        
        Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
        invoiceLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
        invoiceLineItem.Charge_Amount__c = invoiceLIChargeAmount;
        invoiceLineItem.Tax_Amount__c = 10;
        invoiceLineItem.UOM__c = 'testInvoiceItem';
        insert invoiceLineItem;
                     
            Zuora__Subscription__c subRec = new Zuora__Subscription__c();
            subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acc.Id;
            subRec.Order_Number__c = order.Id;
            subRec.Subscriber_Contact__c = con[0].Id;
            subRec.Recipient_Contact__c = con[0].Id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Vendor__c = 'test123';
            subRec.Vendor_1__c = acc.Id;
            subRec.Order_Line_Item_Number_1__c = orderLineItemList[0].Id;
            subRec.Zuora__CustomerAccount__c = billAcc.Id ;            
            insert subRec;
            System.assertEquals(subRec.Vendor__c, 'test123');              
       
        
  
       /* BATCH_JOB_SCHEDULER__c batchJobScheduler = new BATCH_JOB_SCHEDULER__c();
        batchJobScheduler.Status__c = 'STARTED';         
        batchJobScheduler.Batch_Run_Date__c = Date.today();  
        batchJobScheduler.End_Time__c = DateTime.now();
        batchJobScheduler.SFDC_Job_id__c = batchprocessid;
        insert batchJobScheduler;*/

        
    }
    
    static testMethod void test(){
        defaultCustomSetting();
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        insert pack;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
        
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            insert pItem; 
        
        //create zuora account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        billAcc.Other_PaymentMethod__c = 'Invoice';
        insert billAcc;
        
          
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        cityList = TestDataFactory.createCity(1);
        city = cityList.get(0);
        city.City_Name__c = 'cityName_test';
        city.Flight_Number_1__c = 'cityFlightNumber1_test';
        city.Flight_Number_2__c = 'cityFlightNumber2_test';
        insert city;   
        

        
        List<Contact> con = TestDataFactory.createContactRecType(1, 'Contact Customer_Contact');  
        con[0].FirstName = 'TestContactFirstname';
        con[0].LastName = 'MyLastname';
        con[0].Salutation = 'Mr.';
        con[0].Email = 'test@yahoo.com';        
        con[0].Phone= '1112485454';
        con[0].Recipient_Indicator__c = true;
        con[0].AccountId = acc.id;
        con[0].Address__c = addressRec.Id;                                                
        insert con;
        
            
         List<Contact> con1 = new List<Contact>(); 
         List<RecordType> rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: '' LIMIT 1]; 
         for(Integer i=0;i<3;i++){
             Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);
          if(rt2.size() > 0){
                   contactRecord.RecordTypeId = rt2[0].Id;
          }
              contactRecord.Billing_Indicator__c = true;
              contactRecord.AccountId = acc.id;
              contactRecord.Address__c = addressRec.Id;                                           
              con1.add(contactRecord);  
            }   
            insert con1;
                 
        Order__c order = TestDataFactory.createOrder(1)[0]; 
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con[0].Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1[0].id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        
        order.ARMS_Account_Number__c = '1110000';
        order.ARMS_Account_ID__c = '00000';
        order.ARMS_Credit_Term__c = 'ABC';
        
        //additional fields        
        order.Customer_No__c = '12345';
        order.Debt_Management_Treatment__c = 'asdfg';
        order.Business_Profile__c = 'sample business profile';
        order.Cust_Giro_Acct_Number__c = '110000000';
        order.Cust_Giro_Bank_Number__c = 'BANK-00100';
        order.Credit_Limit_External_Limit__c = '250000.00';
        order.Credit_Limit_Internal_Limit__c = '560000.00';
        order.Credit_Term_Reference__c = '0';
        order.Customer_No__c = '000000069';

        order.Payment_Mode__c = 'Other';
        order.Other_Payment_Mode__c = 'Invoice';        
        order.Approved_Debt_Exposure_Amount__c = '12345';
        order.Business_Sector__c = 'IT';
        order.Company_Code__c = 'ACN';
        order.SOA_Suppression_Indicator__c = 'A';
        order.Transient_Indicator__c = 'A';            
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = true;
        order.isOrderLegacy__c = true;
        insert order;        
       
        Test.StartTest();
                    
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();  
        for(Integer i=0;i<5;i++){   
            Order_Line_Item__c orderLineItemRecord = new Order_Line_Item__c
            (New_Contract_Period__c=30, 
            DTL_Date__c=date.today(),
            Earliest_Start_Date__c=date.today(), 
            Start_Date__c=date.today()+1,   
            End_Date__c=date.today()+100, 
            Main_Package_Period__c=100,      
            Qty__c=100, 
            Term_Length__c=100,          
            Delivered_By__c='Vendor', 
            Main_Package_Billing_Type__c='Full Prepaid',        
            Main_Package_Frequency__c='Default', 
            Main_Package_Sub_Type__c='Termed',        
            Main_Package_Type__c='Base',
            Generate_Invoice__c = true,
            Order__c = order.Id,
            Main_Package_ID__c = pack.Id);            
            orderLineItemList.add(orderLineItemRecord);}
            insert orderLineItemList;         
      
       
        Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
        zInv.Zuora__BillingAccount__c = billAcc.id;
        zInv.Zuora__AmountWithoutTax__c = 100;
        zInv.Zuora__TaxAmount__c = 100;
        zInv.Zuora__Zuora_Id__c = 'ABC123456';
        zinv.Zuora__TotalAmount__c = 110;
        zinv.Previous_Balance__c = '29';
        zinv.Is_PDF_Generated__c = False; 
        insert zInv;
        
        Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
        invoiceLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
        invoiceLineItem.Charge_Amount__c = 100;
        invoiceLineItem.Tax_Amount__c = 10;           
        invoiceLineItem.UOM__c = 'testInvoiceItem';
        insert invoiceLineItem;
                     
            Zuora__Subscription__c subRec = new Zuora__Subscription__c();
            subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acc.Id;
            subRec.Order_Number__c = order.Id;
            subRec.Subscriber_Contact__c = con[0].Id;
            subRec.Recipient_Contact__c = con[0].Id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Vendor__c = 'test123';
            subRec.Vendor_1__c = acc.Id;
            subRec.Order_Line_Item_Number_1__c = orderLineItemList[0].Id;
            subRec.Zuora__CustomerAccount__c = billAcc.Id ;            
            insert subRec;
            System.assertEquals(subRec.Vendor__c, 'test123');              
        
       //START EGC 4/9/2016
        Test.setMock(WebServiceMock.class, new zLoginMock());
       //END EGC 4/9/2016
        
        SP_InvoiceRequestBatch batch = new SP_InvoiceRequestBatch('A', 4, 'abbs', true);
        ID batchprocessid = Database.executeBatch(batch, 1000); 
       
       

        Test.StopTest(); 
    }
    
    
    static testMethod void test2(){
        defaultCustomSetting();
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        insert pack;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
        
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            insert pItem; 
        
        //create zuora account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.Other_Payment_Method__c = 'Invoice';        
        billAcc.ARMS_Account_Number__c = '1110000';
        insert billAcc;
        
          
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        cityList = TestDataFactory.createCity(1);
        city = cityList.get(0);
        city.City_Name__c = 'cityName_test';
        city.Flight_Number_1__c = 'cityFlightNumber1_test';
        city.Flight_Number_2__c = 'cityFlightNumber2_test';
        insert city;   
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '123457397';
        key.Type__c = 'Number';
        insert key; */

        
        List<Contact> con = TestDataFactory.createContactRecType(1, 'Contact Customer_Contact');  
        con[0].FirstName = 'TestContactFirstname';
        con[0].LastName = 'MyLastname';
        con[0].Salutation = 'Mr.';
        con[0].Email = 'test@yahoo.com';        
        con[0].Phone= '1112485454';
        con[0].Recipient_Indicator__c = true;
        con[0].AccountId = acc.id;
        con[0].Address__c = addressRec.Id;                                                
        insert con;
        
            
         List<Contact> con1 = new List<Contact>(); 
         List<RecordType> rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: '' LIMIT 1]; 
         for(Integer i=0;i<3;i++){
             Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);
          if(rt2.size() > 0){
                   contactRecord.RecordTypeId = rt2[0].Id;
          }
              contactRecord.Billing_Indicator__c = true;
              contactRecord.AccountId = acc.id;
              contactRecord.Address__c = addressRec.Id;                                           
              con1.add(contactRecord);  
            }   
            insert con1;
                 
        Order__c order = TestDataFactory.createOrder(1)[0]; 
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con[0].Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1[0].id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        
        order.ARMS_Account_Number__c = '1110000';
        order.ARMS_Account_ID__c = '00000';
        order.ARMS_Credit_Term__c = 'ABC';
        
        //additional fields        
        order.Customer_No__c = '12345';
        order.Debt_Management_Treatment__c = 'asdfg';
        order.Business_Profile__c = 'sample business profile';
        order.Cust_Giro_Acct_Number__c = '110000000';
        order.Cust_Giro_Bank_Number__c = 'BANK-00100';
        order.Credit_Limit_External_Limit__c = '250000.00';
        order.Credit_Limit_Internal_Limit__c = '560000.00';
        order.Credit_Term_Reference__c = '0';
        order.Customer_No__c = '000000069';

        order.Payment_Mode__c = 'Other';
        order.Other_Payment_Mode__c = 'Invoice';        
        order.Approved_Debt_Exposure_Amount__c = '12345';
        order.Business_Sector__c = 'IT';
        order.Company_Code__c = 'ACN';
        order.SOA_Suppression_Indicator__c = 'A';
        order.Transient_Indicator__c = 'A';            
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = true;
        order.isOrderLegacy__c = true;
        insert order;        
       
        Test.StartTest();
                    
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();  
        for(Integer i=0;i<5;i++){   
            Order_Line_Item__c orderLineItemRecord = new Order_Line_Item__c
            (New_Contract_Period__c=30, 
            DTL_Date__c=date.today(),
            Earliest_Start_Date__c=date.today(), 
            Start_Date__c=date.today()+1,   
            End_Date__c=date.today()+100, 
            Main_Package_Period__c=100,      
            Qty__c=100, 
            Term_Length__c=100,          
            Delivered_By__c='Vendor', 
            Main_Package_Billing_Type__c='Full Prepaid',        
            Main_Package_Frequency__c='Default', 
            Main_Package_Sub_Type__c='Termed',        
            Main_Package_Type__c='Base',
            Generate_Invoice__c = true,
            Order__c = order.Id,
            Main_Package_ID__c = pack.Id);            
            orderLineItemList.add(orderLineItemRecord);
        }
        
        insert orderLineItemList;               
      
       
        Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
        zInv.Zuora__BillingAccount__c = billAcc.id;
        zInv.Zuora__AmountWithoutTax__c = 100;
        zInv.Zuora__TaxAmount__c = 100;
        zInv.Zuora__Zuora_Id__c = 'ABC123456';
        zinv.Zuora__TotalAmount__c = 110;
        zinv.Is_PDF_Generated__c = False;       
        insert zInv;
        
        Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
        invoiceLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
        invoiceLineItem.Charge_Amount__c = 10;
        invoiceLineItem.Tax_Amount__c = 100;
        invoiceLineItem.UOM__c = 'ADJUSTMENT';
        insert invoiceLineItem;
        
        
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec = TestDataFactory.createSubscription(1)[0];
        subRec.Zuora__Account__c = acc.Id;
        subRec.Order_Number__c = order.Id;
        subRec.Subscriber_Contact__c = con[0].Id;
        subRec.Recipient_Contact__c = con[0].Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Vendor__c = 'test123';
        subRec.Vendor_1__c = acc.Id;
        subRec.Order_Line_Item_Number_1__c = orderLineItemList[0].Id;
        subRec.Zuora__CustomerAccount__c = billAcc.Id ;            
        insert subRec;
        System.assertEquals(subRec.Vendor__c, 'test123');              
          
        Test.setMock(WebServiceMock.class, new zLoginMock());
       
        
        SP_InvoiceRequestBatch batch = new SP_InvoiceRequestBatch('A', 4, 'abbs', false);
        ID batchprocessid = Database.executeBatch(batch, 1000); 
      

        Test.StopTest(); 
        
    }
    
        
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product',
                                                    'Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate',
                                                    'Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue',
                                                    'CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine',
                                                    'SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI',
                                                    '123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ',
                                                    '00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx',
                                                    '012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type',
                                                        'Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderCNameArray = new String[]{'ARMS Latest Invoice ID','Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital',
                                                        'Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'0027105620','Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
    }
 }