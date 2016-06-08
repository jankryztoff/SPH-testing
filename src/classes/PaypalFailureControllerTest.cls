/**
   @author Christian Coquilla
   @name PaypalFailureControllerTest
   @createDate 07 Apr 2016
   @description Test for class PaypalFailureController
   @version 1.0 
*/
@isTest(seeAllData=true)
public class PaypalFailureControllerTest {
    
       
    static testMethod void PaypalFailureController_Test(){
    
        
    
        List<Profile> csoprof = new List<Profile>();
        csoprof = [Select ID From Profile Where Name = 'cso' LIMIT 1];
        
        User testUser = new User(
        Alias = 'stndrd',
        Email='standarduser@test.com', 
        EmailEncodingKey='UTF-8',
        LastName='Test',
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US',
        ProfileId = csoprof[0].id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='standard@test.com'
        );
        
    System.runAs(testUser){
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    acc.NRIC__c = 'T1234567R';
    insert acc;
    
    Contact con = TestDataFactory.createContact(1)[0];
    //con.Address__c = addressRec.Id;
    con.AccountId = acc.Id;
    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    con.Recipient_Indicator__c = true;
    con.Billing_Indicator__c = true;
    //con.FirstName = FName;
    //con.LastName = LName;
    insert con;    
    
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    billAcc.Zuora__Account__c = acc.Id;
    billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
    billAcc.Billing_Contact__c = con.id;
    billAcc.Billing_Type__c = 'Full Prepaid';
    insert billAcc;
    
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
    order.Billing_Type__c = 'Full Prepaid';
    order.Case_Record_Type__c = 'Complaint - Magazine';
    order.Category__c = 'Subscription Request';
    order.Sub_Category__c ='Stop Subscription';
    order.Credit_Balance__c = 0;
    order.Delivery_Charge__c = 0;
    order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
    order.Order_Type__c = 'Change of Subscription Package';
    order.PO_Number__c = 'PO00000';
    //order.Postage_Charge__c = 200.00;
    insert order;
    
    External_Payment__c ep = TestDataFactory.createExternalPayment(1)[0];    
    ep.Sold_To_Contact_Name__c = con.Id;
    ep.Transaction_Type__c = 'F';
    ep.Billing_Account__c =  billAcc.Id;
    insert ep;
    
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    pack.Name = 'Pack name';
    pack.Billing_Type__c = 'Full Prepaid';
    pack.Package_Type__c = 'Base';
    pack.Subscription_Period__c = '18';
    pack.Package_Code__c = 'afds132';
    insert pack;
    
    Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
    subRecs.Zuora__CustomerAccount__c = billAcc.Id;
    subRecs.Zuora__Account__c = acc.Id;
    subRecs.Zuora__Zuora_Id__c = '1123';
    subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
    subRecs.Subscriber_Contact__c = con.Id;
    subRecs.Recipient_Contact__c = con.Id;
    subRecs.Contact__c = con.Id;
    subRecs.Main_Package_1__c = pack.id;
    subRecs.Zuora__Status__c = 'Active';
    subRecs.Order_Number__c = order.Id;
    subRecs.Suppress_Vendor_Start_Notice__c = 'false';
    subRecs.Supressed_Acknowledgement_Letter__c = 'false';
    subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    subRecs.Urgent__c = 'false';
    subRecs.Vendor_Conversion__c = 'false';
    subRecs.Charity__c = 'false';
    subRecs.Billing_Type__c = 'Full Prepaid';
    //subRecs.Order_Line_Item_Number__c = orderline.id;
    subRecs.Subscription_Type_1__c = 'Publication';
    subRecs.Subscription_Type__c = 'Publication';
    subRecs.Zuora__Status__c = 'Active';
    subRecs.Order_Number_1__c = order.id;
    subRecs.Generate_Invoice1__c = 'false';
    insert subRecs;
    
    Zuora__ZInvoice__c invList = TestDataFactory.createInvoice(1)[0];
    invList.Zuora__Zuora_Id__c = '01p90000006XHnT';
    invList.Zuora__BillingAccount__c = billAcc.Id;
    Database.insert(invList);
    
    List<Invoice_Line_Item__c> invLineItemList = new List<Invoice_Line_Item__c>();
           
   Invoice_Line_Item__c ili = new Invoice_Line_Item__c();   
   ili.Charge_Amount__c = 100;
   ili.Subscription__c = subRecs.Id;
   ili.Invoice_ID__c = '01p90000006XHnT';
   insert ili; 
    
    
    test.starttest(); 
     
      
          
        ApexPages.currentPage().getParameters().put('Id',ep.Id);
        PaypalFailureController pfcontroller = new PaypalFailureController();        
        pfcontroller.address1 = 'address1'; 
        pfcontroller.address2 = 'address2';
        pfcontroller.address3 = 'address3';
        pfcontroller.address4 = 'address4';  
        pfcontroller.address5 = 'address5';   
        
        
       
        }
          
    }
 }