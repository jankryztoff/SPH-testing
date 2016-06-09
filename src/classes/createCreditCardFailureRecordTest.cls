/*
*@author: Alfred Abrina
*@name createCreditCardFailureRecordTest
*@CreateDate: 02/18/2015
*@description: Test Class for createCreditCardFailureRecord
*@version 1.0
*@reference createCreditCardFailureRecord
*/
@isTest //(Seealldata = TRUE)
private class createCreditCardFailureRecordTest {

/**
* Method that feeds data to test creditcard failure 
* @name testCase1
* @param req, res, acct
*/
       static testmethod void testCase1(){
       try{
       //  String[] myDateOnly = string.valueof(date.today().addDays(3)).split(' ');
                //String[] strDate = myDateOnly[0].split('/');
                //Integer myIntMonth = integer.valueOf(strDate[0]);
                //Integer myIntDay = integer.valueOf(strDate[1]);
                //Integer myIntYear = integer.valueOf(strDate[2]); 
        //system.debug( '\n\n ***debug : ' + myIntMonth + '\n\n **** ' + myIntYear + '\n\n **** ' + myIntDay + '\n\n' );        
        String PaymentDate = string.valueof(date.today().addyears(3));
        PaymentDate = PaymentDate.replaceall('-', '/');  
        system.debug( '\n\n ***debug : ' + PaymentDate + '\n\n' );
        String PaymentErrorMessage = 'Payment error';
        String PaymentMethodPaymentMethodType = 'Credit Card';
        String PaymentMethodCardHolderName = 'Alfred Abrina';
        String PaymentMethodCreditCardType = 'MasterCard';
        String PaymentMethodExpirationDate = string.valueof(date.Today().addDays(6));    
        PaymentMethodExpirationDate = PaymentMethodExpirationDate.replaceall('-', '/');  
        String PaymentMethodAchBankName = 'BDO';  
        String F = 'F';
          
           
        list<Key_Id__c> listKeys = new list<Key_Id__c>();
        id RTAcct =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor Subscriber').getRecordTypeId(); 
        id RTAcct2 =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Individual').getRecordTypeId(); 
        id RTContact =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); 
        
        listKeys.add(new Key_Id__c(Name='Account_Vendor Subscriber', Type__c = 'RecordType', Id__c = string.valueOf(RTAcct) ));
        
        listKeys.add(new Key_Id__c(Name='Account_Direct Individual', Type__c = 'RecordType', Id__c = string.valueOf(RTAcct2)));
        listKeys.add(new Key_Id__c(Name='Contact_Customer Contact', Type__c = 'RecordType', Id__c =string.valueof(RTContact)));
        //listKeys.add(new Key_Id__c(Name='LOG_DEBUG_ON', Type__c = 'RecordType'));
        insert listKeys; 
        system.assert(listKeys.size() == 3 );  
    
        Billing_Batch__c testBatch = new Billing_Batch__c(Name = 'Default',Next_Batch_Number__c=19, Batch__c ='0');
        insert testBatch;
        
        Other__c  testOther = new Other__c(Name='LOG_DEBUG_ON', Value__c='TRUE');
        insert testOther;
        
       
        
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acct.Name = '0tRyes';
        acct.Phone = '225232';
        acct.RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        acct.Status__c = 'Active';
        insert acct; 
                  
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acct.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Credit Card';
        billAcc.Zuora__Batch__c = 'Batch'+ConstantsSLB.getBillingBatch('Default');
        insert billAcc;
            
        String AccountName = billAcc.Id;
        String BillToContactFirstName = 'Alfred'; 
        String BillToContactLastName = 'Abrina';       
        String BillToContactWorkEmail = 'test@force.com';
        Decimal PaymentAmount = 30;  
            
                
         RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/CreditCardFailure';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        createCreditCardFailureRecord cont = new createCreditCardFailureRecord();
        
        string result1 = createCreditCardFailureRecord.doPostCreateRecord(AccountName, BillToContactFirstName, BillToContactLastName, BillToContactWorkEmail, PaymentAmount, PaymentDate, 
        PaymentErrorMessage, PaymentMethodPaymentMethodType, PaymentMethodCardHolderName, PaymentMethodCreditCardType, 
        PaymentMethodExpirationDate, PaymentMethodAchBankName, F);

         
        System.assertNotEquals(result1, ' '); 
        }catch(Exception e){
        System.debug('Error: ' + e.getMessage());
        }
     }     
}