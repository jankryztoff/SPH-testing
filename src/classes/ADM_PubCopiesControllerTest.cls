/**
   @author Christian Coquilla
   @name ADM_PubCopiesControllerTest
   @createDate 05 Apr 2016
   @description Test for class ADM_PubCopiesController
   @version 1.0 
*/
@isTest(seeAllData=true)
public class ADM_PubCopiesControllerTest {
    static testMethod void ADM_PubCopiesController_Test(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Vendor_Group__c = 'g';
        acc.Vendor_Code__c = 'code';
        insert acc;
        
        
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
     Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Package_Price__c = 100;
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
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
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
     Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Name = 'Sub';
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        //subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Main_Package__c = 'pack.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Product_Code__c = '12345';
        //subRecs.Vendor_1__c = acc.Id;
        //subRecs.Vendor__c = 'acc.id';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Recipient_Contact__c = con.Id;
        //subRecs.Recipient_Contact_1__c = 'con.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Ph_d__c = true;
        subRecs.Ph_e__c = true;
        subRecs.Product_Code__c = 'productCode';
        subRecs.Qty__c = 2;
        subRecs.Qty1__c = '2';
     database.insert(subRecs);
     
     Public_Holiday__c pubHoliday = new Public_Holiday__c();
     pubHoliday.Holiday_Date__c = date.Today().addDays(15);
     insert pubHoliday;
     
     zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
     zproduct.ProductCode__c = 'productCode';
     insert zproduct; 
     
     Publication__c pub = TestDataFactory.createPublication(1)[0];
     pub.Publication_Code__c='WK';
     pub.Published_Days__c = 'YYYYYYN';
     pub.Publication_Type__c = 'N';
     pub.Platform_Type__c = 'All in One (AIO)';
     pub.Frequency_Code__c = 'D';
     pub.Publication_Next_Start_Date__c = date.Today().addDays(15);
     insert pub;
     
     Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
     ppc.ZProduct__c = zproduct.Id;
     ppc.Publication_Code__c = pub.Id;
     
     insert ppc;
     
     
     Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
     spc.Zuora__UOM__c = 'UOM';
     spc.Zuora__Price__c = 100;
     spc.Zuora__Subscription__c = subRecs.Id;
     insert spc;
     
     Non_Publication_Day__c pubDay = TestDataFactory.createNonPublicationDay(1)[0];
     pubDay.Publication__c = pub.Id;
     pubDay.Non_Publication_Date__c = date.Today().addDays(15);
     insert pubDay;
    
    test.startTest();
    ADM_PubCopiesController cont = new ADM_PubCopiesController();
    cont.subName = subRecs.Name;
    cont.startDate = Date.newinstance(2015, 04, 1);
    cont.endDate = date.today().addMonths(1).addDays(1);
    cont.isCredit = true;
    cont.totalRefund = 100.00;
    cont.calculateCopies();
    cont.calculateUsage();
    test.stopTest();
    }
    
    static testMethod void ADM_PubCopiesController_FCequalsW(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Vendor_Group__c = 'g';
        acc.Vendor_Code__c = 'code';
        insert acc;
        
        
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
     Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Package_Price__c = 100;
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
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
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
     Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Name = 'Sub';
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        //subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Main_Package__c = 'pack.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Product_Code__c = '12345';
        //subRecs.Vendor_1__c = acc.Id;
        //subRecs.Vendor__c = 'acc.id';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Recipient_Contact__c = con.Id;
        //subRecs.Recipient_Contact_1__c = 'con.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Ph_d__c = true;
        subRecs.Ph_e__c = true;
        subRecs.Product_Code__c = 'productCode';
        subRecs.Qty__c = 2;
        subRecs.Qty1__c = '2';
     database.insert(subRecs);
     
     Public_Holiday__c pubHoliday = new Public_Holiday__c();
     pubHoliday.Holiday_Date__c = date.Today().addDays(15);
     insert pubHoliday;
     
     zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
     zproduct.ProductCode__c = 'productCode';
     insert zproduct; 
     
     Publication__c pub = TestDataFactory.createPublication(1)[0];
     pub.Publication_Code__c='WK';
     pub.Published_Days__c = 'YYYYYYN';
     pub.Publication_Type__c = 'M';
     pub.Platform_Type__c = 'Online';
     pub.Frequency_Code__c = 'W';
     pub.Public_Holiday_Weekend_Pub_Indicator__c = True;
     pub.Public_Holiday_Weekday_Pub_Indicator__c = True;
     pub.Publication_Platform_AIO__c = 'Online';
     pub.Publication_Next_Start_Date__c = date.Today().addDays(15);
     insert pub;
     
     Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
     ppc.ZProduct__c = zproduct.Id;
     ppc.Publication_Code__c = pub.Id;
     insert ppc;
     
     
     Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
     spc.Zuora__UOM__c = 'UOM';
     spc.Zuora__Price__c = 100;
     spc.Zuora__Subscription__c = subRecs.Id;
     insert spc;
     
     Non_Publication_Day__c pubDay = TestDataFactory.createNonPublicationDay(1)[0];
     pubDay.Publication__c = pub.Id;
     pubDay.Non_Publication_Date__c = date.Today().addDays(15);
     insert pubDay;
    
    test.startTest();
    ADM_PubCopiesController cont = new ADM_PubCopiesController();
    cont.subName = subRecs.Name;
    cont.startDate = date.today();
    cont.endDate = date.today().addDays(30);
    cont.isCredit = true;
    cont.totalRefund = 100.00;
    cont.calculateCopies();
    cont.calculateUsage();
    test.stopTest();
    }
    static testMethod void ADM_PubCopiesController_FCequalsH(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Vendor_Group__c = 'g';
        acc.Vendor_Code__c = 'code';
        insert acc;
        
        
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
     Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Package_Price__c = 100;
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
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
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
     Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Name = 'Sub';
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        //subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Main_Package__c = 'pack.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Product_Code__c = '12345';
        //subRecs.Vendor_1__c = acc.Id;
        //subRecs.Vendor__c = 'acc.id';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Recipient_Contact__c = con.Id;
        //subRecs.Recipient_Contact_1__c = 'con.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Ph_d__c = true;
        subRecs.Ph_e__c = true;
        subRecs.Product_Code__c = 'productCode';
        subRecs.Qty__c = 2;
        subRecs.Qty1__c = '2';
     database.insert(subRecs);
     
     Public_Holiday__c pubHoliday = new Public_Holiday__c();
     pubHoliday.Holiday_Date__c = date.Today().addDays(15);
     insert pubHoliday;
     
     zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
     zproduct.ProductCode__c = 'productCode';
     insert zproduct; 
     
     Publication__c pub = TestDataFactory.createPublication(1)[0];
     pub.Publication_Code__c='WK';
     pub.Published_Days__c = 'YYYYYYN';
     pub.Publication_Type__c = 'N';
     pub.Platform_Type__c = 'All in One (AIO)';
     pub.Frequency_Code__c = 'H';
     pub.Publication_Next_Start_Date__c = date.Today().addDays(15);
     insert pub;
     
     Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
     ppc.ZProduct__c = zproduct.Id;
     ppc.Publication_Code__c = pub.Id;
     
     insert ppc;
     
     
     Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
     spc.Zuora__UOM__c = 'UOM';
     spc.Zuora__Price__c = 100;
     spc.Zuora__Subscription__c = subRecs.Id;
     insert spc;
     
     Non_Publication_Day__c pubDay = TestDataFactory.createNonPublicationDay(1)[0];
     pubDay.Publication__c = pub.Id;
     pubDay.Non_Publication_Date__c = date.Today().addDays(15);
     insert pubDay;
    
    test.startTest();
    ADM_PubCopiesController cont = new ADM_PubCopiesController();
    cont.subName = subRecs.Name;
    cont.startDate = Date.newinstance(2015, 04, 4);
    cont.endDate = date.today().addMonths(1).addDays(1);
    cont.isCredit = true;
    cont.totalRefund = 100.00;
    cont.calculateCopies();
    cont.calculateUsage();
    test.stopTest();
    }
    
    static testMethod void ADM_PubCopiesController_FCequalsF(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Vendor_Group__c = 'g';
        acc.Vendor_Code__c = 'code';
        insert acc;
        
        
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
     Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Package_Price__c = 100;
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
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
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
     Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Name = 'Sub';
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        //subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Main_Package__c = 'pack.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Product_Code__c = '12345';
        //subRecs.Vendor_1__c = acc.Id;
        //subRecs.Vendor__c = 'acc.id';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Recipient_Contact__c = con.Id;
        //subRecs.Recipient_Contact_1__c = 'con.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Ph_d__c = true;
        subRecs.Ph_e__c = true;
        subRecs.Product_Code__c = 'productCode';
        subRecs.Qty__c = 2;
        subRecs.Qty1__c = '2';
     database.insert(subRecs);
     
     Public_Holiday__c pubHoliday = new Public_Holiday__c();
     pubHoliday.Holiday_Date__c = date.Today().addDays(15);
     insert pubHoliday;
     
     zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
     zproduct.ProductCode__c = 'productCode';
     insert zproduct; 
     
     Publication__c pub = TestDataFactory.createPublication(1)[0];
     pub.Publication_Code__c='WK';
     pub.Published_Days__c = 'YYYYYYN';
     pub.Publication_Type__c = 'N';
     pub.Platform_Type__c = 'Tablet';
     pub.Frequency_Code__c = 'F';
     pub.Publication_Next_Start_Date__c = date.Today().addDays(15);
     insert pub;
     
     Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
     ppc.ZProduct__c = zproduct.Id;
     ppc.Publication_Code__c = pub.Id;
     
     insert ppc;
     
     
     Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
     spc.Zuora__UOM__c = 'UOM';
     spc.Zuora__Price__c = 100;
     spc.Zuora__Subscription__c = subRecs.Id;
     insert spc;
     
     Non_Publication_Day__c pubDay = TestDataFactory.createNonPublicationDay(1)[0];
     pubDay.Publication__c = pub.Id;
     pubDay.Non_Publication_Date__c = date.Today().addDays(15);
     insert pubDay;
    
    test.startTest();
    ADM_PubCopiesController cont = new ADM_PubCopiesController();
    cont.subName = subRecs.Name;
    cont.startDate = Date.newinstance(2015, 04, 4);
    cont.endDate = date.today().addMonths(1).addDays(1);
    cont.isCredit = true;
    cont.totalRefund = 100.00;
    cont.calculateCopies();
    cont.calculateUsage();
    test.stopTest();
    }    
    static testMethod void ADM_PubCopiesController_FCequalsM(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Vendor_Group__c = 'g';
        acc.Vendor_Code__c = 'code';
        insert acc;
        
        
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
     Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Package_Price__c = 100;
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
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
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
     Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Name = 'Sub';
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        //subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Main_Package__c = 'pack.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Product_Code__c = '12345';
        //subRecs.Vendor_1__c = acc.Id;
        //subRecs.Vendor__c = 'acc.id';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Recipient_Contact__c = con.Id;
        //subRecs.Recipient_Contact_1__c = 'con.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Ph_d__c = true;
        subRecs.Ph_e__c = true;
        subRecs.Product_Code__c = 'productCode';
        subRecs.Qty__c = 2;
        subRecs.Qty1__c = '2';
     database.insert(subRecs);
     
     Public_Holiday__c pubHoliday = new Public_Holiday__c();
     pubHoliday.Holiday_Date__c = date.Today().addDays(15);
     insert pubHoliday;
     
     zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
     zproduct.ProductCode__c = 'productCode';
     insert zproduct; 
     
     Publication__c pub = TestDataFactory.createPublication(1)[0];
     pub.Publication_Code__c='WK';
     pub.Published_Days__c = 'YYYYYYN';
     pub.Publication_Type__c = 'N';
     pub.Platform_Type__c = 'Tablet';
     pub.Frequency_Code__c = 'M';
     pub.Publication_Next_Start_Date__c = date.Today().addDays(15);
     insert pub;
     
     Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
     ppc.ZProduct__c = zproduct.Id;
     ppc.Publication_Code__c = pub.Id;
     
     insert ppc;
     
     
     Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
     spc.Zuora__UOM__c = 'UOM';
     spc.Zuora__Price__c = 100;
     spc.Zuora__Subscription__c = subRecs.Id;
     insert spc;
     
     Non_Publication_Day__c pubDay = TestDataFactory.createNonPublicationDay(1)[0];
     pubDay.Publication__c = pub.Id;
     pubDay.Non_Publication_Date__c = date.Today().addDays(15);
     insert pubDay;
    
    test.startTest();
    ADM_PubCopiesController cont = new ADM_PubCopiesController();
    cont.subName = subRecs.Name;
    cont.startDate = Date.newinstance(2015, 04, 4);
    cont.endDate = date.today().addMonths(1).addDays(1);
    cont.isCredit = true;
    cont.totalRefund = 100.00;
    cont.calculateCopies();
    cont.calculateUsage();
    test.stopTest();
    }    
    static testMethod void ADM_PubCopiesController_FCequalsB(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Vendor_Group__c = 'g';
        acc.Vendor_Code__c = 'code';
        insert acc;
        
        
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
     Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Package_Price__c = 100;
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
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
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
     Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Name = 'Sub';
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        //subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Main_Package__c = 'pack.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Product_Code__c = '12345';
        //subRecs.Vendor_1__c = acc.Id;
        //subRecs.Vendor__c = 'acc.id';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Recipient_Contact__c = con.Id;
        //subRecs.Recipient_Contact_1__c = 'con.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Ph_d__c = true;
        subRecs.Ph_e__c = true;
        subRecs.Product_Code__c = 'productCode';
        subRecs.Qty__c = 2;
        subRecs.Qty1__c = '2';
     database.insert(subRecs);
     
     Public_Holiday__c pubHoliday = new Public_Holiday__c();
     pubHoliday.Holiday_Date__c = date.Today().addDays(15);
     insert pubHoliday;
     
     zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
     zproduct.ProductCode__c = 'productCode';
     insert zproduct; 
     
     Publication__c pub = TestDataFactory.createPublication(1)[0];
     pub.Publication_Code__c='WK';
     pub.Published_Days__c = 'YYYYYYN';
     pub.Publication_Type__c = 'N';
     pub.Platform_Type__c = 'Tablet';
     pub.Frequency_Code__c = 'B';
     pub.Publication_Next_Start_Date__c = date.Today().addDays(15);
     insert pub;
     
     Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
     ppc.ZProduct__c = zproduct.Id;
     ppc.Publication_Code__c = pub.Id;
     
     insert ppc;
     
     
     Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
     spc.Zuora__UOM__c = 'UOM';
     spc.Zuora__Price__c = 100;
     spc.Zuora__Subscription__c = subRecs.Id;
     insert spc;
     
     Non_Publication_Day__c pubDay = TestDataFactory.createNonPublicationDay(1)[0];
     pubDay.Publication__c = pub.Id;
     pubDay.Non_Publication_Date__c = date.Today().addDays(15);
     insert pubDay;
    
    test.startTest();
    ADM_PubCopiesController cont = new ADM_PubCopiesController();
    cont.subName = subRecs.Name;
    cont.startDate = Date.newinstance(2015, 04, 4);
    cont.endDate = date.today().addMonths(1).addDays(1);
    cont.isCredit = true;
    cont.totalRefund = 100.00;
    cont.calculateCopies();
    cont.calculateUsage();
    test.stopTest();
    }   
    static testMethod void ADM_PubCopiesController_FCequalsQ(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Vendor_Group__c = 'g';
        acc.Vendor_Code__c = 'code';
        insert acc;
        
        
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
     Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Package_Price__c = 100;
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
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
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
     Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Name = 'Sub';
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        //subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Main_Package__c = 'pack.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Product_Code__c = '12345';
        //subRecs.Vendor_1__c = acc.Id;
        //subRecs.Vendor__c = 'acc.id';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Recipient_Contact__c = con.Id;
        //subRecs.Recipient_Contact_1__c = 'con.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Ph_d__c = true;
        subRecs.Ph_e__c = true;
        subRecs.Product_Code__c = 'productCode';
        subRecs.Qty__c = 2;
        subRecs.Qty1__c = '2';
     database.insert(subRecs);
     
     Public_Holiday__c pubHoliday = new Public_Holiday__c();
     pubHoliday.Holiday_Date__c = date.Today().addDays(15);
     insert pubHoliday;
     
     zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
     zproduct.ProductCode__c = 'productCode';
     insert zproduct; 
     
     Publication__c pub = TestDataFactory.createPublication(1)[0];
     pub.Publication_Code__c='WK';
     pub.Published_Days__c = 'YYYYYYN';
     pub.Publication_Type__c = 'N';
     pub.Platform_Type__c = 'Tablet';
     pub.Frequency_Code__c = 'Q';
     pub.Publication_Next_Start_Date__c = date.Today().addDays(15);
     insert pub;
     
     Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
     ppc.ZProduct__c = zproduct.Id;
     ppc.Publication_Code__c = pub.Id;
     
     insert ppc;
     
     
     Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
     spc.Zuora__UOM__c = 'UOM';
     spc.Zuora__Price__c = 100;
     spc.Zuora__Subscription__c = subRecs.Id;
     insert spc;
     
     Non_Publication_Day__c pubDay = TestDataFactory.createNonPublicationDay(1)[0];
     pubDay.Publication__c = pub.Id;
     pubDay.Non_Publication_Date__c = date.Today().addDays(15);
     insert pubDay;
    
    test.startTest();
    ADM_PubCopiesController cont = new ADM_PubCopiesController();
    cont.subName = subRecs.Name;
    cont.startDate = Date.newinstance(2015, 04, 4);
    cont.endDate = date.today().addMonths(1).addDays(1);
    cont.isCredit = true;
    cont.totalRefund = 100.00;
    cont.calculateCopies();
    cont.calculateUsage();
    test.stopTest();
    }     
    static testMethod void ADM_PubCopiesController_FCequalsY(){
    
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Vendor_Group__c = 'g';
        acc.Vendor_Code__c = 'code';
        insert acc;
        
        
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
    
    Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
     Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Package_Price__c = 100;
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
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
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
     Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Name = 'Sub';
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        //subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Main_Package__c = 'pack.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Product_Code__c = '12345';
        //subRecs.Vendor_1__c = acc.Id;
        //subRecs.Vendor__c = 'acc.id';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Recipient_Contact__c = con.Id;
        //subRecs.Recipient_Contact_1__c = 'con.Id';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Ph_d__c = true;
        subRecs.Ph_e__c = true;
        subRecs.Product_Code__c = 'productCode';
        subRecs.Qty__c = 2;
        subRecs.Qty1__c = '2';
     database.insert(subRecs);
     
     Public_Holiday__c pubHoliday = new Public_Holiday__c();
     pubHoliday.Holiday_Date__c = date.Today().addDays(15);
     insert pubHoliday;
     
     zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
     zproduct.ProductCode__c = 'productCode';
     insert zproduct; 
     
     Publication__c pub = TestDataFactory.createPublication(1)[0];
     pub.Publication_Code__c='WK';
     pub.Published_Days__c = 'YYYYYYN';
     pub.Publication_Type__c = 'N';
     pub.Platform_Type__c = 'Tablet';
     pub.Frequency_Code__c = 'Y';
     pub.Publication_Next_Start_Date__c = date.Today().addDays(15);
     insert pub;
     
     Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
     ppc.ZProduct__c = zproduct.Id;
     ppc.Publication_Code__c = pub.Id;
     
     insert ppc;
     
     
     Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
     spc.Zuora__UOM__c = 'UOM';
     spc.Zuora__Price__c = 100;
     spc.Zuora__Subscription__c = subRecs.Id;
     insert spc;
     
     Non_Publication_Day__c pubDay = TestDataFactory.createNonPublicationDay(1)[0];
     pubDay.Publication__c = pub.Id;
     pubDay.Non_Publication_Date__c = date.Today().addDays(15);
     insert pubDay;
    
    test.startTest();
    ADM_PubCopiesController cont = new ADM_PubCopiesController();
    cont.subName = subRecs.Name;
    cont.startDate = Date.newinstance(2015, 04, 4);
    cont.endDate = date.today().addMonths(1).addDays(1);
    cont.isCredit = true;
    cont.totalRefund = 100.00;
    cont.calculateCopies();
    cont.calculateUsage();
    test.stopTest();
    }     
}