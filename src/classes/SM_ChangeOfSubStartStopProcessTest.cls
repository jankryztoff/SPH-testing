/*
 * Class Name: SM_ChangeOfSubStartStopProcessTest
 * @author: Christian Coquilla
 * Date: 4/11/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for SM_ChangeOfSubStartStopProcess
 */

@isTest(seeAllData = true)
public class SM_ChangeOfSubStartStopProcessTest{
    static testMethod void test01(){
    
    
       Account acc = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
       insert acc;
       
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       billAcc.Zuora__Account__c = acc.id;
       billAcc.Zuora__Zuora_Id__c = '123456789';
       billAcc.Billing_Type__c = 'Recurring Prepaid';
       insert billAcc;
       
       Package__c pack = new Package__c();
       pack = TestDataFactory.createPackage(1)[0];
       pack.Package_Type__c = 'Base';
       pack.Name = 'Test Package';
       insert pack;
       
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
       
       Country__c cntry = TestDataFactory.createCountry(1)[0];
       cntry.Account__c = acc.id;
       cntry.Zonal_Code__c = 'D';
       insert cntry;
       
       Address__c addressRec = TestDataFactory.createAddress(1)[0];
       addressRec.Address_Type__c = 'A';
       addressRec.Postal_Code__c = postal.Id;
       addressRec.Block_House_Number__c ='TEST';
       addressRec.Level_Number__c ='xx';
       addressRec.Unit_Number__c = 'yy';
       addressRec.Country__c = cntry.id;
       insert addressRec;
       
       
       Contact con = TestDataFactory.createContact(1)[0];
       con.Address__c = addressRec.Id;
       con.AccountID = acc.Id;
       con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
       con.Recipient_Indicator__c = true;
       con.Mobile_Number__c = '9096996126';
       insert con;
       
       Order__c order = TestDataFactory.createOrder(1)[0]; 
       order.Account__c = acc.id;
       order.Informed_Customer__c = TRUE;
       order.Recipient_Contact__c = con.Id; 
       order.Credit_Balance__c = 800;
       order.Order_Type__c = 'Renewal';
       order.Status__c = 'Draft';
       order.Eligible_for_Retention__c = TRUE;
       order.Delivery_Charge__c = 20;
       order.Category__c = 'Subscription Request';
       order.Sub_Category__c ='Stop Subscription';
       order.Credit_Balance__c = 0;
       order.Delivery_Charge__c = 0;
       order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
       order.Order_Type__c = 'Change of Subscription Package';
       order.PO_Number__c = 'PO00000';
       order.Billing_Type__c = 'Recurring Prepaid';
       order.Billing_Account__c = billAcc.Id;
       insert order;
       
       Zuora__Subscription__c subs = testDataFactory.createSubscription(1)[0];
       subs.Name='Zuora';  
       subs.Main_Package_isNull__c = 'false';
       subs.Main_Package_1__c = pack.id;
       subs.Subscription_Type_1__c = 'Publication';
       subs.Zuora__SubscriptionEndDate__c = date.today().addDays(30); 
       subs.Zuora__Zuora_Id__c ='1123';
       subs.Recipient_Contact__c= con.id;
       subs.Order_Number_1__c = order.id;
       //subs.Order_Line_Item_Number_1__c = orderline.id;
       subs.Year_to_Date_Temp_Stop_Days__c = 10;
       subs.Previous_Year_Temp_Stop_Days__c= 8;
       subs.Zuora__Account__c = acc.id;
       subs.Zuora__AutoRenew__c = true;
       subs.Zuora__CustomerAccount__c = billAcc.id;
       subs.Number_of_Copies__c = 1;
       subs.Number_of_Copies1__c = '1';
       insert subs;
       
       
       set<Id> orderset = new set<Id>();
       orderset.add(order.Id);
    
    Test.startTest();

         System.enqueueJob(new SM_ChangeOfSubStartStopProcess(orderset));
         System.assertNotEquals(null, orderset);
        
    Test.stopTest();
    }

}