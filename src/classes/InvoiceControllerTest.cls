/**
 * Class Name: SM_SubscriptionCancellationHelperTest 
 * @author: George Santos
 * Date: 2/11/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Test Class for SM_SubscriptionCancellationHelper
 */

@isTest(seeAllData = True)
public with sharing class InvoiceControllerTest {

    static testmethod void test(){
           try {
               // Test.setMock(WebServiceMock.class, new zLoginMock());   
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
                    acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
                    insert acc;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
                    Country__c country = TestDataFactory.createCountry(1)[0]; 
                    country.Country_Name__c = 'SINGAPORE'; 
                    insert country;
                    
                    Address__c address = TestDataFactory.createAddress(1)[0];
                    address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                    address.Block_House_Number__c =  'TEST';
                    address.Postal_Code__c = postal.id;
                    address.Level_Number__c = '17';
                    address.Unit_Number__c = 'Unit 5';
                    address.Country__c = country.id;
                    
                    //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
                    
                    insert address;
                    
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.AccountId = acc.Id;
                    con.Address__c = address.id;
                    con.Recipient_Indicator__c = true;
                    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    insert con;
                    
                     
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    //billAccountList [0].id = zInv.id;
                    billAccountList[0].Zuora__Account__c = acc.id; 
                    billAccountList[0].Billing_Contact__c = con.id;
                    billAccountList[0].ARMS_Account_Number__c = '027101021';
                    billAccountList[0].Other_PaymentMethod__c ='Invoice';
                    billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                    billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                    billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                    billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                    insert billAccountList;
                
                    
                    Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
                    zInv.Zuora__BillingAccount__c = billAccountList[0].id;
                    zInv.Zuora__Zuora_Id__c = 'ID456';
                    zInv.Zuora__AmountWithoutTax__c = 100;
                    zInv.Zuora__TaxAmount__c = 100;
                    zInv.Zuora__TotalAmount__c = 10;
                    zInv.Zuora__InvoiceDate__c = date.today();
                    zInv.ARMS_Invoice_ID__c = 'AB12';
                    insert zInv;
                              
                  
                    zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
                    insert zProd;
                    
                    zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
                    zProdRate.zqu__ZProduct__c = zProd.id;
                    insert zProdRate;
                    
                    Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
                    prodPub.ZProduct__c = zProd.id;
                    insert prodPub;
                    
                    Package__c pack = TestDataFactory.createPackage(1)[0];
                    insert pack;
                    
                    Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                    packItem.Package__c = pack.id;
                    packItem.Product_Rate_Plan__c = zProdRate.id;
                    insert packItem;
                            
                    
                    Order__c order = TestDataFactory.createOrder(1)[0];
                    order.Account__c = acc.Id;
                    order.Informed_Customer__c = TRUE;
                    order.Recipient_Contact__c = con.Id;
                    order.Subscriber_Charge__c = 100.00;
                    insert order;
                    
                    Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
                    orderLineItem.Order__c = order.id;
                    orderLineItem.Main_Package_ID__c = pack.id;
                    insert orderLineItem;
                    
                   /* Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
                    testInvoice.Zuora__TotalAmount__c = 10;
                    String tryString =  String.valueOf(testInvoice .Zuora__TotalAmount__c * 100);
                    System.debug('tryString' + tryString);
                    testInvoice.Zuora__BillingAccount__c = zBillAcc.id;
                    insert testInvoice;*/
                               
                    Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                    zSub.Name = 'NUM124';
                    zSub.Billing_Type__c = 'Full Prepaid';
                    zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                    zSub.Subscription_Type_1__c = 'Publication';
                    zSub.Subscription_Type__c = 'Publication';
                    zSub.Zuora__Account__c = acc.id;
                    zSub.Zuora__Status__c = 'Active';
                    zSub.Order_Line_Item_Number__c = orderLineItem.id;
                    zSub.Recipient_Contact__c = con.id;
                    zSub.Name = 'S0000000';
                    zSub.Order_Number__c = order.id;
                    zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
                    zSub.Zuora__AutoRenew__c = False;
                    zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                    zSub.Number_of_Copies__c=100;
                    zSub.Number_of_Copies1__c =  '100';
                    zSub.Qty__c = 20;
                    zSub.Subscription_Type_1__c = 'Publication';
                    zSub.Subscription_Type__c = 'Publication';
                    insert zSub; 
                    
                    Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
                    invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
                    invLineItem.Name = 'SPH';
                    invLineItem.Charge_Amount__c = 100.00;
                    //invLineItem.Tax_Amount__c = 10.00;
                    invLineItem.Subscription_ID__c = zSub.Zuora__Zuora_Id__c;
                    invLineItem.Subscription_Number__c = 'NUM124';
                    invLineItem.Service_Start_Date__c = date.Today() +1;
                    invLineItem.Service_End_Date__c = date.Today() +60;
                    insert invLineItem;
                    
                    
                   /*Invoice_Line_Item__c  invoiceLineItemList = [SELECT id, name, Invoice_ID__c, Subscription_ID__c, Subscription_Number__c, Charge_Amount__c, Tax_Exempt_Amount__c, Tax_Amount__c, Subscription__c,
                                                    Service_Start_Date__c, Service_End_Date__c
                                                    FROM Invoice_Line_Item__c 
                                                    WHERE Invoice_ID__c =: zInv.Zuora__Zuora_Id__c];
                    
                    system.assertEquals(null, invoiceLineItemList.Charge_Amount__c);*/
                    
                    
                    test.startTest();
                        PageReference pRef = Page.InvoiceTaxTemplate;
                        pRef.getParameters().put('id', zInv.id);
                        test.setCurrentPage(pRef);
                        InvoiceController invCont = new InvoiceController();
                        invCont.IsRecurring('Recurring Prepaid');
                    test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}  
    }
     /*  static testmethod void testAddressOverseas(){
       
            try {
                    Test.setMock(WebServiceMock.class, new zLoginMock()); 
                    User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com');
            
                    System.runAs(u){
                    
                    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
                    insert acc;
                    
                    RecordType addOverseas = [SELECT Name FROM RecordType WHERE Name =: 'Address_Overseas'];
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
                    List<Address__c> address = TestDataFactory.createAddress(1);
                    address[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
                    address[0].RecordTypeId = addOverseas.id;
                    address[0].Address_1__c = '175B Albert Street';
                    address[0].Address_2__c = '137 Alexandra Road';
                    address[0].Address_3__c = '11 Aliwal Street';
                    address[0].Address_4__c = '10 Allenby Road';
                    address[0].Postal_Code__c = postal.id;
                    insert address;
                    
                                      
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.AccountId = acc.Id;
                    con.Address__c = address[0].id;
                    con.Recipient_Indicator__c = true;
                    //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    insert con;
                                
                    Zuora__CustomerAccount__c zBillAcc = TestDataFactory.createBillingAccount(1)[0];
                    zBillAcc.Zuora__Account__c = acc.id;
                    zBillAcc.Billing_Contact__c = con.id;
                    zBillAcc.ARMS_Account_Number__c = 'AB12345678';
                    zBillAcc.name = 'April Summer';
                    insert zBillAcc;
                     
                    Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
                    zInv.Zuora__BillingAccount__c = zBillAcc.id;
                    zInv.Zuora__AmountWithoutTax__c = 100;
                    zInv.Zuora__TaxAmount__c = 100;
                    zInv.Zuora__TotalAmount__c = 10;
                    zInv.Zuora__InvoiceDate__c = date.today();
                    insert zInv;
                    
                    zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
                    insert zProd;
                    
                    zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
                    zProdRate.zqu__ZProduct__c = zProd.id;
                    insert zProdRate;
                    
                    Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
                    prodPub.ZProduct__c = zProd.id;
                    insert prodPub;
                    
                    Package__c pack = TestDataFactory.createPackage(1)[0];
                    insert pack;
                    
                    Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                    packItem.Package__c = pack.id;
                    packItem.Product_Rate_Plan__c = zProdRate.id;
                    insert packItem;
                    
                    Order__c order = TestDataFactory.createOrder(1)[0];
                    order.Account__c = acc.Id;
                    order.Informed_Customer__c = TRUE;
                    order.Recipient_Contact__c = con.Id;
                    order.Subscriber_Charge__c = 100.00;
                    insert order;
                    
                    Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
                    orderLineItem.Order__c = order.id;
                    orderLineItem.Main_Package_ID__c = pack.id;
                    insert orderLineItem;
                    
                    Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                    zSub.Zuora__CustomerAccount__c = zBillAcc.id;
                    zSub.Subscription_Type_1__c = 'Delivery';
                    zSub.Subscription_Type__c = 'Delivery';
                    zSub.Zuora__Account__c = acc.id;
                    zSub.Zuora__Status__c = 'Active';
                    zSub.Order_Line_Item_Number__c = orderLineItem.id;
                    zSub.Recipient_Contact__c = con.id;
                    zSub.Name = 'S0000000';
                    zSub.Order_Number__c = order.id;
                    zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
                    zSub.Zuora__AutoRenew__c = False;
                    zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                    zSub.Number_of_Copies__c=100;
                    zSub.Number_of_Copies1__c =  '100';
                    zSub.Qty__c = 20;
                    insert zSub;
                        
                    Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
                    invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
                    invLineItem.Charge_Amount__c = 1000;
                    invLineItem.Subscription_Id__c = zSub.Zuora__Zuora_Id__c;
                    invLineItem.Subscription_Number__c = 'XYZ1212';
                    insert invLineItem;
                    
                    test.startTest();
                        PageReference pRef = Page.InvoiceTaxTemplate;
                        pRef.getParameters().put('id', zInv.id);
                        test.setCurrentPage(pRef);
                        InvoiceController invCont = new InvoiceController();
                    test.stopTest();
                  }
              }
          catch(Exception e){}  
        }*/
    /*
     static testmethod void testAddressInternal(){
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
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
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                insert postal;
                
                Country__c country = TestDataFactory.createCountry(1)[0]; 
                country.Name = 'SINGAPORE'; 
                insert country;
                
                 SPH_Section__c sphSection = new SPH_Section__c();
                sphSection .Section_Name__c = 'Section Alpha';
                insert sphSection;
                
                SPH_Department__c sphDepartment = new SPH_Department__c();
                sphDepartment.Department_Name__c = 'Billing Department';
                insert sphDepartment;
                
                SPH_Division__c sphDivision = new SPH_Division__c();
                sphDivision.Department_Name__c = 'Billing Department';
                insert sphDivision;
                
                SPH_Company__c sphCompany = new SPH_Company__c();
                sphCompany.Company_Name__c = 'Accenture';
                insert sphCompany;
                
                SPH_Location__c sphLocation = new SPH_Location__c();
                sphLocation.Location_Name__c = 'Singapore';
                insert sphLocation;
                
                Address__c address = TestDataFactory.createAddress(1)[0];
                address.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
                address.Block_House_Number__c =  'Block 10';
                address.Postal_Code__c = postal.id;
                address.Level_Number__c = '17';
                address.Unit_Number__c = 'Unit 5';
                address.Country__c = country.id;
                address.Section_Code__c = sphSection.id;
                address.Department__c = sphDepartment.id;
                address.Division_Code__c = sphDivision.id;
                address.Company_Code__c = sphCompany.id;
                address.Location_Code__c = sphLocation.id;
             //   address.RecordType.Id = getRecordType('Address_Internal', Address__c).id;
                
                insert address;
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.AccountId = acc.Id;
                con.Address__c = address.id;
                con.Recipient_Indicator__c = true;
                //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                insert con;
                
                List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                billAccountList[0].name = 'April Summer';
                //billAccountList [0].id = zInv.id;
                billAccountList[0].Zuora__Account__c = acc.id; 
                billAccountList[0].Billing_Contact__c = con.id;
                //billAccountList[0].ARMS_Account_Number__c = 'AB12345678';
                //billAccountList[0].Other_PaymentMethod__c ='Other';
                insert billAccountList;
            
                
                Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
                zInv.Zuora__BillingAccount__c = billAccountList[0].id;
                zInv.Zuora__AmountWithoutTax__c = 100;
                zInv.Zuora__TaxAmount__c = 100;
                zInv.Zuora__TotalAmount__c = 10;
                zInv.Zuora__InvoiceDate__c = date.today();
                //zInv.ARMS_Invoice_ID__c = 'AB12345678';
                insert zInv;
                          
              
                zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
                insert zProd;
                
                zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
                zProdRate.zqu__ZProduct__c = zProd.id;
                insert zProdRate;
                
                Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
                prodPub.ZProduct__c = zProd.id;
                insert prodPub;
                
                Package__c pack = TestDataFactory.createPackage(1)[0];
                insert pack;
                
                Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                packItem.Package__c = pack.id;
                packItem.Product_Rate_Plan__c = zProdRate.id;
                insert packItem;
                           
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Subscriber_Charge__c = 100.00;
                insert order;
                
                Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
                orderLineItem.Order__c = order.id;
                orderLineItem.Main_Package_ID__c = pack.id;
                insert orderLineItem;
                
               /* Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
                testInvoice.Zuora__TotalAmount__c = 10;
                String tryString =  String.valueOf(testInvoice .Zuora__TotalAmount__c * 100);
                System.debug('tryString' + tryString);
                testInvoice.Zuora__BillingAccount__c = zBillAcc.id;
                insert testInvoice;
               
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Account__c = acc.id;
                zSub.Zuora__Status__c = 'Active';
                zSub.Order_Line_Item_Number__c = orderLineItem.id;
                zSub.Recipient_Contact__c = con.id;
                zSub.Name = 'S0000000';
                zSub.Order_Number__c = order.id;
                zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
                zSub.Zuora__AutoRenew__c = False;
                zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                zSub.Number_of_Copies__c=100;
                zSub.Number_of_Copies1__c =  '100';
                zSub.Qty__c = 20;
                insert zSub;
                              
                Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
                invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
                invLineItem.Charge_Amount__c = 1000;
                invLineItem.Subscription_Id__c = zSub.Zuora__Zuora_Id__c;
                invLineItem.Subscription_Number__c = 'XYZ1212';
                insert invLineItem;
                
                
                test.startTest();
                    PageReference pRef = Page.InvoiceTaxTemplate;
                    pRef.getParameters().put('id', zInv.id);
                    test.setCurrentPage(pRef);
                    InvoiceController invCont = new InvoiceController();
                test.stopTest();
             }
         }
          catch(Exception e) {}  
        }
    */
 
  /*static testmethod void testAddressAirline(){
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
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
            
            RecordType addAirline = [SELECT Id, Name FROM RecordType  WHERE Name = 'Address_Airline'];*/
            
            /*List<Key_Id__c> newKeyid = TestDataFactory.createKeyIds();
            newKeyid[0].name = 'Address_Airline'; 
            insert newKeyid;*/
          
            /*Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            //postal.Building_Name__c = 'Ebloc2';
            insert postal;
  
            City__c cityNew = new City__c();
            cityNew.City_Name__c = 'SINGAPORE';
            cityNew.Flight_Number_1__c = '133';
            cityNEw.Flight_Number_2__c = '122';
            insert cityNew ;
           
            Packing_Grp__c packingGroup = new Packing_Grp__c();
            packingGroup.Airline__c = '1234';
            packingGroup.Packing_Code__c = 'MFA';
            insert packingGroup ;
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');*/
            //address.RecordTypeId = addAirline.id; 
            //address.Block_House_Number__c =  'Block 10';
         /* address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';*/
            /*address.City__c = cityNew.id;
            address.Packing_Code__c = packingGroup.id;   
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            insert con;
            
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            insert billAccountList;
                    
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = billAccountList[0].id;
            zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__TotalAmount__c = 10;
            zInv.Zuora__InvoiceDate__c = date.today();
            //zInv.ARMS_Invoice_ID__c = 'AB12345678';
            insert zInv;
                      
          
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
                       
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
                      
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = con.id;
            zSub.Name = 'S0000000';
            zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            zSub.Zuora__AutoRenew__c = False;
            zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub.Number_of_Copies__c=100;
            zSub.Number_of_Copies1__c =  '100';
            zSub.Qty__c = 20;
            insert zSub;
                          
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Charge_Amount__c = 1000;
            invLineItem.Subscription_Id__c = zSub.Zuora__Zuora_Id__c;
            invLineItem.Subscription_Number__c = 'XYZ1212';
            insert invLineItem;
            
            
            test.startTest();
                PageReference pRef = Page.InvoiceTaxTemplate;
                pRef.getParameters().put('id', zInv.id);
                test.setCurrentPage(pRef);
                InvoiceController invCont = new InvoiceController();
            test.stopTest();
         }
         }
          catch(Exception e) {} 
        }*/
    
   
   /* static testmethod void testRMS_InvoicenotNull(){
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock()); 
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
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            
            Zuora__CustomerAccount__c zBillAcc = TestDataFactory.createBillingAccount(1)[0];
            //zBillAcc.id = zInv.id;
            zBillAcc.Zuora__Account__c = acc.id;
            zBillAcc.Billing_Contact__c = con.id;
            zBillAcc.ARMS_Account_Number__c = 'AB12345678';
            //zBillAcc.Other_PaymentMethod__c ='Other';
            zBillAcc.name = 'April Summer';
            insert zBillAcc;
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = zBillAcc.id;
            zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__TotalAmount__c = 10;
            zInv.Zuora__InvoiceDate__c = date.today();
            //zInv.ARMS_Invoice_ID__c = 'AB12345678';
            //zInv.Other_PaymentMethod__c ='Other';
            insert zInv;
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
    */        
            /*Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
            testInvoice.Zuora__BillingAccount__c = zBillAcc.id;
            testInvoice.Zuora__TotalAmount__c = 10;
            
            insert testInvoice;*/
     /*       
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            
            zSub.Zuora__CustomerAccount__c = zBillAcc.id;
            zSub.Subscription_Type_1__c = 'Delivery';
            zSub.Subscription_Type__c = 'Delivery';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = con.id;
            zSub.Name = 'S0000000';
            zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            zSub.Zuora__AutoRenew__c = False;
            zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub.Number_of_Copies__c=100;
            zSub.Number_of_Copies1__c =  '100';
            zSub.Qty__c = 20;
            zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            insert zSub;
                
           
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Charge_Amount__c = 1000;
            invLineItem.Subscription_Id__c = zSub.Zuora__Zuora_Id__c;
            invLineItem.Subscription_Number__c = 'XYZ1212';
            insert invLineItem;
            
            
            test.startTest();
                PageReference pRef = Page.InvoiceTaxTemplate;
                pRef.getParameters().put('id', zInv.id);
                test.setCurrentPage(pRef);
                InvoiceController invCont = new InvoiceController();
            test.stopTest();
            }
            }
          catch(Exception e) {
          }  
       }*/
    
   static testmethod void testChargeAmountLessThanZero(){
       try {
        Test.setMock(WebServiceMock.class, new zLoginMock());   
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
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            postal.House_Block_Number__c = '12';
            insert postal;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Country_Name__c = 'SINGAPORE'; 
            insert country;
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = country.id;
            
            //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
            
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[0].Billing_Type__c = GlobalVariableClass.BILLING_TYPE_RECURRING;
            //billAccountList[0].ARMS_Account_Number__c = 'AB12345678';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            insert billAccountList;
        
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = billAccountList[0].id;
            zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__TotalAmount__c = 10;
            zInv.Zuora__InvoiceDate__c = date.today();
            zInv.ARMS_Invoice_ID__c = 'AB12';
            insert zInv;
                      
          
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
            
           
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
            Integer counter=0;
            List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c sub : zSub){
            sub.Zuora__CustomerAccount__c = billAccountList[0].id;
            sub.Name = 'Test';
            //sub.Subscription_Type_1__c = 'Publication';
            //Sub.Subscription_Type__c = 'Publication';
            if(counter==0){
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;    
            }
            else if(counter==1){
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
            }
            else if(counter==2){
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            }
            else{
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_GIFT;
            }
            Sub.Zuora__Account__c = acc.id;
            Sub.Zuora__Status__c = 'Active';
            Sub.Order_Line_Item_Number__c = orderLineItem.id;
            Sub.Recipient_Contact__c = con.id;
            Sub.Name = 'S0000000';
            Sub.Order_Number__c = order.id;
            Sub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            Sub.Zuora__AutoRenew__c = False;
            Sub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            Sub.Number_of_Copies__c=100;
            Sub.Number_of_Copies1__c =  '100';
            Sub.Qty__c = 20;
            counter++;
            }
            insert zSub; 
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Name = 'Test';
            invLineItem.Subscription__c = zSub[0].Id;
            invLineItem.Charge_Amount__c = -1.00;
            invLineItem.Subscription_Id__c = zSub[0].Zuora__Zuora_Id__c;
            //invLineItem.Subscription_Number__c = 'XYZ1212';
            invLineItem.Subscription_Number__c = zSub[0].Name;
            invLineItem.Tax_Amount__c = 10.00;
            insert invLineItem;
            
            
            test.startTest();
                PageReference pRef = Page.InvoiceTaxTemplate;
                pRef.getParameters().put('id', zInv.id);
                test.setCurrentPage(pRef);
                InvoiceController invCont = new InvoiceController();
            test.stopTest();
        }
        }
          catch(Exception e) {}  
    }
    
    static testmethod void testChargeAmountLessThanZero2(){
       try {
        Test.setMock(WebServiceMock.class, new zLoginMock());   
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
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Country_Name__c = 'SINGAPORE'; 
            insert country;
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = country.id;
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
            
            //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
            
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            //billAccountList[0].ARMS_Account_Number__c = 'AB12345678';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            insert billAccountList;
        
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = billAccountList[0].id;
            zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__TotalAmount__c = 10;
            zInv.Zuora__InvoiceDate__c = date.today();
            zInv.ARMS_Invoice_ID__c = 'AB12';
            insert zInv;
                      
          
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
            
           
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
            
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = con.id;
            zSub.Name = 'S0000000';
            zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            zSub.Zuora__AutoRenew__c = False;
            zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub.Number_of_Copies__c=100;
            zSub.Number_of_Copies1__c =  '100';
            zSub.Qty__c = 20;
            insert zSub; 
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Charge_Amount__c = -1.00;
            invLineItem.Subscription_Id__c = zSub.Zuora__Zuora_Id__c;
            invLineItem.Subscription_Number__c = 'XYZ1212';
            invLineItem.Tax_Amount__c = 10.00;
            insert invLineItem;
            
            
            test.startTest();
                PageReference pRef = Page.InvoiceTaxTemplate;
                pRef.getParameters().put('id', zInv.id);
                test.setCurrentPage(pRef);
                InvoiceController invCont = new InvoiceController();
            test.stopTest();
        }
        }
          catch(Exception e) {}  
    }
    
    static testmethod void testChargeAmountLessThanZero3(){
       try {
        Test.setMock(WebServiceMock.class, new zLoginMock());   
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
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Country_Name__c = 'SINGAPORE'; 
            insert country;
            
            SPH_Department__c dept = new SPH_Department__c();
            dept.Department_Name__c = 'Test';
            insert dept;
            
            SPH_Division__c div = new SPH_Division__c();
            div.Department_Name__c = 'Test';
            insert div;
            
            SPH_Section__c sec = new SPH_Section__c();
            sec.Section_Name__c = 'Test';
            insert sec;
            
            SPH_Location__c loc = new SPH_Location__c();
            loc.Location_Name__c = 'Test';
            insert loc;
            
            SPH_Company__c comp = new SPH_Company__c();
            comp.Company_Name__c = 'test';
            insert comp;
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = country.id;
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
            address.Company_Code__c = comp.Id;
            address.Department__c = dept.Id;
            address.Division_Code__c = div.Id;
            address.Section_Code__c = sec.Id;
            address.Location_Code__c = loc.Id;
            
            //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
            
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            //billAccountList[0].ARMS_Account_Number__c = 'AB12345678';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            insert billAccountList;
        
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = billAccountList[0].id;
            zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__TotalAmount__c = 10;
            zInv.Zuora__InvoiceDate__c = date.today();
            zInv.ARMS_Invoice_ID__c = 'AB12';
            insert zInv;
                      
          
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
            
           
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
            
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = con.id;
            zSub.Name = 'S0000000';
            zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            zSub.Zuora__AutoRenew__c = False;
            zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub.Number_of_Copies__c=100;
            zSub.Number_of_Copies1__c =  '100';
            zSub.Qty__c = 20;
            insert zSub; 
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Charge_Amount__c = -1.00;
            invLineItem.Subscription_Id__c = zSub.Zuora__Zuora_Id__c;
            invLineItem.Subscription_Number__c = 'XYZ1212';
            invLineItem.Tax_Amount__c = 10.00;
            insert invLineItem;
            
            
            test.startTest();
                PageReference pRef = Page.InvoiceTaxTemplate;
                pRef.getParameters().put('id', zInv.id);
                test.setCurrentPage(pRef);
                InvoiceController invCont = new InvoiceController();
            test.stopTest();
        }
        }
          catch(Exception e) {}  
    }
    
    static testmethod void testChargeAmountLessThanZero4(){
       try {
        Test.setMock(WebServiceMock.class, new zLoginMock());   
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
            acc.Airline_Indicator__c = TRUE;
            //acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Country_Name__c = 'SINGAPORE'; 
            insert country;
            
            City__c cit = new City__c();
            cit.City_Name__c = 'Test';
            cit.Flight_Number_1__c = 'flight1';
            cit.Flight_Number_2__c = 'flight2';
            insert cit;
            
            Packing_Grp__c packingGroup = new Packing_Grp__c();
            packingGroup.Airline__c = '1234';
            packingGroup.Packing_Code__c = 'MFA';
            insert packingGroup ;
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = country.id;
            address.City__c = cit.Id;
            address.Packing_Code__c = packingGroup.Id;
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            //billAccountList[0].ARMS_Account_Number__c = 'AB12345678';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            insert billAccountList;
        
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = billAccountList[0].id;
            zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__TotalAmount__c = 10;
            zInv.Zuora__InvoiceDate__c = date.today();
            zInv.ARMS_Invoice_ID__c = 'AB12';
            insert zInv;
                      
          
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
            
           
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
            
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = con.id;
            zSub.Name = 'S0000000';
            zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            zSub.Zuora__AutoRenew__c = False;
            zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub.Number_of_Copies__c=100;
            zSub.Number_of_Copies1__c =  '100';
            zSub.Qty__c = 20;
            insert zSub; 
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Charge_Amount__c = -1.00;
            invLineItem.Subscription_Id__c = zSub.Zuora__Zuora_Id__c;
            invLineItem.Subscription_Number__c = 'XYZ1212';
            invLineItem.Tax_Amount__c = 10.00;
            insert invLineItem;
            
            
            test.startTest();
                PageReference pRef = Page.InvoiceTaxTemplate;
                pRef.getParameters().put('id', zInv.id);
                test.setCurrentPage(pRef);
                InvoiceController invCont = new InvoiceController();
            test.stopTest();
        }
        }
          catch(Exception e) {}  
    }
    
    static testmethod void testChargeAmountLessThanZero5(){
       try {
        Test.setMock(WebServiceMock.class, new zLoginMock());   
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
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            postal.House_Block_Number__c = '12';
            insert postal;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Country_Name__c = 'SINGAPORE'; 
            insert country;
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = country.id;
            
            //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
            
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[0].Billing_Type__c = GlobalVariableClass.BILLING_TYPE_RECURRING;
            billAccountList[0].ARMS_Account_Number__c = 'AB12345678';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            insert billAccountList;
        
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = billAccountList[0].id;
            zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__TotalAmount__c = 10;
            zInv.Zuora__InvoiceDate__c = date.today();
            zInv.ARMS_Invoice_ID__c = 'AB12';
            insert zInv;
                      
          
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
            
           
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
            
            List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(1);
            for (Zuora__Subscription__c sub : zSub){
            sub.Zuora__CustomerAccount__c = billAccountList[0].id;
            sub.Name = 'Test';
            sub.Subscription_Type_1__c = 'Publication';
            Sub.Subscription_Type__c = 'Publication';
            Sub.Zuora__Account__c = acc.id;
            Sub.Zuora__Status__c = 'Active';
            Sub.Order_Line_Item_Number__c = orderLineItem.id;
            Sub.Recipient_Contact__c = con.id;
            Sub.Name = 'S0000000';
            Sub.Order_Number__c = order.id;
            Sub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            Sub.Zuora__AutoRenew__c = False;
            Sub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            Sub.Number_of_Copies__c=100;
            Sub.Number_of_Copies1__c =  '100';
            Sub.Qty__c = 20;
            }
            insert zSub; 
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Name = 'Test';
            invLineItem.Subscription__c = zSub[0].Id;
            invLineItem.Charge_Amount__c = 1.00;
            invLineItem.Subscription_Id__c = zSub[0].Zuora__Zuora_Id__c;
            //invLineItem.Subscription_Number__c = 'XYZ1212';
            invLineItem.Subscription_Number__c = zSub[0].Name;
            invLineItem.Tax_Amount__c = 10.00;
            insert invLineItem;
            
            
            test.startTest();
                PageReference pRef = Page.InvoiceTaxTemplate;
                pRef.getParameters().put('id', zInv.id);
                test.setCurrentPage(pRef);
                InvoiceController invCont = new InvoiceController();
            test.stopTest();
        }
        }
          catch(Exception e) {}  
    }
 /* static testmethod void testTaxAmountEqualsZero(){
       try {
        Test.setMock(WebServiceMock.class, new zLoginMock());   
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
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Name = 'SINGAPORE'; 
            insert country;
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = country.id;
            
            //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
            
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
                    
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
           // billAccountList[0].ARMS_Account_Number__c = 'AB12345678';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            billAccountList[0].Billing_Type__c = 'Recurring Prepaid';

            insert billAccountList;
        
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = billAccountList[0].id;
            zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__TotalAmount__c = 10;
            zInv.Zuora__InvoiceDate__c = date.today();
            zInv.ARMS_Invoice_ID__c = 'AB12';
            insert zInv;
                      
          
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
            
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
          
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = con.id;
            zSub.Name = 'S0000000';
            zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            zSub.Zuora__AutoRenew__c = False;
            zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub.Number_of_Copies__c=100;
            zSub.Number_of_Copies1__c =  '100';
            zSub.Qty__c = 20;
            insert zSub; 
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Charge_Amount__c = -1.00;
            invLineItem.Subscription_Id__c = zSub.Zuora__Zuora_Id__c;
            invLineItem.Subscription_Number__c = 'XYZ1212';
            invLineItem.Tax_Amount__c = 0.00;
            insert invLineItem;
            
            
            test.startTest();
                PageReference pRef = Page.InvoiceTaxTemplate;
                pRef.getParameters().put('id', zInv.id);
                test.setCurrentPage(pRef);
                InvoiceController invCont = new InvoiceController();
            test.stopTest();
        }
        }
          catch(Exception e) {}  
    }*/
 }