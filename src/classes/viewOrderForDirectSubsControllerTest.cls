/**
   @author Christian Coquilla
   @name viewOrderForDirectSubscriptionControllerTest
   @createDate 09 Apr 2016
   @description Test for class viewOrderForDirectSubscriptionController
   @version 1.0 
*/

@isTest(seeAllData=true)
public class viewOrderForDirectSubsControllerTest{
      
    static testMethod void test01(){
    
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
    
    Package__c pack = new Package__c();
    pack = TestDataFactory.createPackage(1)[0];
    pack.Name = 'Pack name';
    pack.Billing_Type__c = 'Full Prepaid';
    pack.Package_Type__c = 'Base';
    pack.Subscription_Period__c = '18';
    pack.Package_Code__c = 'afds132';
    insert pack; 
    
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
    
    Promotion_Gift__c promogift = TestDataFactory.createPromotionGift(1)[0];
    insert promogift;
    
    Order_Line_Item_Gift__c gift = TestDataFactory.createItemGift(1)[0];
    gift.Order_Line_Item__c = orderline.Id;
    gift.Promotion_Gift__c = promogift.Id;
    insert gift;
    

    test.starttest();         
        ApexPages.currentPage().getParameters().put('Id',order.Id);
        viewOrderForDirectSubscriptionController controller = new viewOrderForDirectSubscriptionController();
        
    test.StopTest();    
    
    }
    
   } 
}