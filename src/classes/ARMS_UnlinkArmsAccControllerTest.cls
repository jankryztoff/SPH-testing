/**
* Class Name: ARMS_UnlinkArmsAccControllerTest
* @author: Jerome delos Santos
* Date: 1/13/2015
* Modified: Ana Fe Dumangas
* Modified Date: 7/8/15
* @Description: This class is used for acceptable code coverage of ARMS_UnlinkArmsAccController.
* History: 
*
*/
@isTest(Seealldata = True)
public class ARMS_UnlinkArmsAccControllerTest
{
   /* public static testMethod void testARMS_UnlinkArmsAccController()
    {   //Test.setMock(WebServiceMock.class, new wwwSphComArWsWsdlCamMock());
        String recType = ConstantsSLB.getOther('ARMS CSO Admin');
            User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [Select Id From Profile Where Name = :recType Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        System.runAs(testUser) {
        Account newAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        newAccount.NRIC__c = 'T1234567R';
        insert new List<sObject>{newAccount};
       
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //inserted by Limot
        //Order__c ord = TestDataFactory.createOrder(1)[0];
        //ord.Account__c = acc.Id;
        //insert ord; 
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'FULL PREPAID'; 
        insert billAcc;
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Billing_Type__c = 'FULL PREPAID'; 
        ord.Account__c = acc.id;
        database.insert(ord);
        
        //System.assertEquals(ord[0].AccountId,billAcc[0].Zuora__Account__c); //inserted by Limot

        Map<String, SObject> zCust = TestDataFactory.createSubscriptionPackage();
        Test.startTest();
        
        ARMS_UnlinkArmsAccController.updateBillAccount(zCust.get('Zuora__CustomerAccount__c').Id);
        Test.stopTest();
       }
    }*/
    
    public static testMethod void testARMS_UnlinkArmsAccController(){
        string error='';
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        Account dbacc = [SELECT accountNumber from Account where accountnumber != null LIMIT 1];
        acc.AccountNumber = dbacc.AccountNumber; //'account number 001'; //00001123456789';
        acc.Staff_ID__c = 'ID001';
        database.insert(acc);
        
       // RecordType recType = [SELECT Id FROM RecordType WHERE developerName='Overseas'][0];
        Address__c ad = TestDataFactory.createAddress(1)[0];
       // ad.RecordType = recType;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.NRIC__c = 'T2123451S';
        con.Address__c = ad.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Name = 'Billing Account';
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; //START/END D-4463 JohnD
        billAcc.ARMS_Account_Number__c = '001';
        billAcc.ARMS_Customer_Number__c = '002';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        insert billAcc;
        
        BT_CO_ARMS_UpdateCustomerBatchFile__c armsUp = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
        armsUp.Customer_Name1__c = 'Billing Account'; //billAcc.Name;
        armsUp.UniqueKey__c = acc.AccountNumber;
        armsUp.CCRID__c = billAcc.ARMS_Customer_Number__c;
        insert armsUp; 
        
        Test.startTest();
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        ARMS_UnlinkArmsAccController.updateBillAccount(billAcc.Id);
        Test.stopTest();
        }
        catch (Exception e){
        error = e.getMessage();
        }
        
        System.debug(error);
    }
    
    public static testMethod void testARMS_UnlinkArmsAccController2(){
        string error='';
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.AccountNumber = 'account number 001sadsad'; //00001123456789';
        acc.Staff_ID__c = 'ID001';
        database.insert(acc);
        
        City__c city = TestDataFactory.createCity(1)[0];
        city.Flight_Number_1__c = '23';
        city.City_Name__c = 'SINGAPORE';
        database.insert(city);
        
        RecordType recType = [SELECT Id FROM RecordType WHERE developerName='Airline'];
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = recType.Id;
        ad.City__c = city.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Passport__c = 'passport';
        con.Address__c = ad.Id;
        con.NRIC__c = 'T2123451S';
        con.HomePhone__c = '123456';
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Name = 'Billing Account';
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; //START/END D-4463 JohnD
        billAcc.ARMS_Account_Number__c = '001';
        billAcc.ARMS_Customer_Number__c = '002';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        insert billAcc;
      
        BT_CO_ARMS_UpdateCustomerBatchFile__c armsUp = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
        armsUp.Customer_Name1__c = billAcc.Name;
        armsUp.UniqueKey__c = acc.AccountNumber;
        armsUp.CCRID__c = billAcc.ARMS_Customer_Number__c;
        insert armsUp; 
        
        Test.startTest();
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        ARMS_UnlinkArmsAccController.updateBillAccount(billAcc.Id);
        Test.stopTest();
        }
        catch (Exception e){
        error = e.getMessage();
        }
        
        System.debug(error);
    }
    
    public static testMethod void testARMS_UnlinkArmsAccController3(){
        string error='';
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.AccountNumber = 'account number 001sadsad'; //00001123456789';
        acc.Staff_ID__c = 'ID001';
        acc.GST_Out_of_Scope__c = true;
        database.insert(acc);
        
        RecordType recType = [SELECT Id FROM RecordType WHERE developerName='Overseas'][0];
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = recType.Id;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Passport__c = 'passport';
        con.Address__c = ad.Id;
        con.HomePhone__c = '123456';
        con.Mobile_Number__c = '123456';
        con.Fax__c = '123456';
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Name = 'Billing Account';
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; //START/END D-4463 JohnD
        billAcc.ARMS_Account_Number__c = '001';
        billAcc.ARMS_Customer_Number__c = '002';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        insert billAcc;
        
        BT_CO_ARMS_UpdateCustomerBatchFile__c armsUp = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
        armsUp.Customer_Name1__c = billAcc.Name;
        armsUp.UniqueKey__c = acc.AccountNumber;
        armsUp.CCRID__c = billAcc.ARMS_Customer_Number__c;
        insert armsUp; 
        
        Test.startTest();
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        ARMS_UnlinkArmsAccController.updateBillAccount(billAcc.Id);
        Test.stopTest();
        }
        catch (Exception e){
        error = e.getMessage();
        }
        
        System.debug(error);
    } 
    
    public static testMethod void testARMS_UnlinkArmsAccController4(){
        string error='';
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.AccountNumber = 'account number 001sadsad01'; //00001123456789';
        acc.Staff_ID__c = 'ID001';
        //acc.GST_Out_of_Scope__c = true;
        database.insert(acc);
        
        RecordType recType = [SELECT Id, developerName FROM RecordType WHERE developerName='Internal'];
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = recType.Id;
        database.insert(ad);
        
        //System.assertEquals(ad.RecordType.developerName, 'Internal');
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Passport__c = 'passport';
        con.Address__c = ad.Id;
        con.HomePhone__c = '123456';
        con.Mobile_Number_2__c = '123456';
        con.Fax__c = '123456';
        con.NRIC__c = 'T2123451S';
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Name = 'Billing Account';
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; //START/END D-4463 JohnD
        billAcc.ARMS_Account_Number__c = '001';
        billAcc.ARMS_Customer_Number__c = '002';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        insert billAcc;
        
        BT_CO_ARMS_UpdateCustomerBatchFile__c armsUp = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
        armsUp.Customer_Name1__c = billAcc.Name;
        armsUp.UniqueKey__c = acc.AccountNumber;
        armsUp.CCRID__c = billAcc.ARMS_Customer_Number__c;
        insert armsUp; 
        
        Test.startTest();
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        ARMS_UnlinkArmsAccController.updateBillAccount(billAcc.Id);
        Test.stopTest();
        }
        catch (Exception e){
        error = e.getMessage();
        }
        
        System.debug(error);
    } 
}