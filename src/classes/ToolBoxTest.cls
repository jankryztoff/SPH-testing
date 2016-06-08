/*
 * Class Name: ToolBoxTest
 * @author: Reyes, Rom Edison C.
 * Date: 04/07/2016
 * Project/Requirement: SPH :'(
 * @description : Test Class for ToolBox class
 */
@isTest (seeAllData= True)
global class ToolBoxTest{

static testMethod void testToolBox(){
            
    //Account
    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    acc.NRIC__c = 'T1234567R';
    acc.Name = 'Test Account';
    acc.Phone = '123-456';
    acc.Email__c = 'test@test.com';
    acc.Date_of_Birth__c = date.today();
    acc.Gender__c = 'Male';
    acc.Race__c = 'Chinese';
    acc.Language__c = 'Others';
    acc.Contact_Person__c = 'Contact Person';
    acc.Sub_Group__c = 'Freelist(MY)';
    insert acc;
    
    //Country
    Country__c ctry = TestDataFactory.createCountry(1)[0];
    ctry.Country_Name__c = 'Singapore';
    insert ctry;
    
    //Singpost Address
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    postal.Name = '123';
    postal.House_Block_Number__c = 'TEST';
    postal.Address_Type__c = 'A';
    postal.Building_Name__c = 'Building';
    postal.Street_Name__c = 'Street';
    insert postal;
        
     //Address
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
    addressRec.Address_Type__c = 'A';
    addressRec.Postal_Code__c = postal.Id;
    addressRec.Block_House_Number__c ='TEST';
    addressRec.Level_Number__c ='xx';
    addressRec.Unit_Number__c = 'yy';
    addressRec.Country__c = ctry.id;
    insert addressRec; 
    
    //Contact
    Contact con = TestDataFactory.createContact(1)[0];
    con.Address__c = addressRec.Id;
    con.AccountId = acc.Id;
    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    con.Recipient_Indicator__c = true;
    con.Billing_Indicator__c = true;
    con.FirstName = 'Test';
    con.LastName = 'Contact';
    con.Passport__c = 'PassTest';
    con.HomePhone__c = '123 456';
    con.Mobile_Number__c = '123456';
    con.Email = 'test@test.com';
    insert con;

    //Billing Account
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    billAcc.Zuora__Account__c = acc.Id;
    billAcc.Billing_Contact__c = con.Id;
    billAcc.Billing_Type__c = 'Full Prepaid';
    insert billAcc;
    
    //Order 
    Order__c order = TestDataFactory.createOrder(1)[0];
    order.Account__c = acc.Id;
    order.Informed_Customer__c = TRUE;
    order.Recipient_Contact__c = con.Id;
    order.Order_Type__c = 'Renewal';
    order.Status__c = 'Draft';
    order.Eligible_for_Retention__c = TRUE;
    order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
    order.Payment_Mode__c = 'Paypal';
    order.Billing_Account__c = billAcc.id;
    order.Billing_Type__c = 'Full Prepaid';
    order.Billing_Contact__c = con.id;
    order.Case_Record_Type__c = 'Complaint - Magazine';
    order.Category__c = 'Subscription Request';
    order.Sub_Category__c ='Stop Subscription';
    order.Credit_Balance__c = 0;
    order.Delivery_Charge__c = 0;
    order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
    order.Order_Type__c = 'Change of Subscription Package';
    order.PO_Number__c = 'PO00000';
    order.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
    order.Delivery_Charge_Type__c = 'C';
    insert order;
        
    String exceptionMessage = '';
    
    Test.StartTest();
    try{
        ToolBox.submitQuotes(order.id);
    }catch(Exception e){
        exceptionMessage = e.getMessage();
    }
    System.assertEquals(exceptionMessage, '');
    Test.StopTest();
}

}