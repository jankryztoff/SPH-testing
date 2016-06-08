/* Class name: CreditCardFailure_InboundEmailHanderT
 * Created by: Jensar Joey Sayson
 * Base class: CreditCardFailure_InboundEmailHander
 * For additional coverage : Joyrem Zarmaine D. Ayuman
 */

@isTest (seeAllData=True)
public class CreditCardFailure_InboundEmailHandTest {
    
    static Map<String, SObject> sObjectData;
    static string amount;
    static string paymentDate;
    static string text;
    static string amountName;
    
    //testmethod No. 1
    static testmethod void test01(){
      
        setDataMethod();
        
        CreditCardFailure_InboundEmailHandler ccf_ieh = new CreditCardFailure_InboundEmailHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        
         email.plainTextBody = '<CreditCardDetails>' +
                              '<AccountName>Billy and Jones</AccountName>' +
                              '<AccountNumber>ACC00001</AccountNumber>' +
                              '<BillToContactWorkEmail>recuerdo.bregente@gmail.com</BillToContactWorkEmail>' +
                              '<BillToContactFirstName>Recuerdo</BillToContactFirstName>' +
                              '<BillToContactLastName>Bregente</BillToContactLastName>' +
                              '<PaymentMethodCardHolderName>Recuerdo Bregente</PaymentMethodCardHolderName>' +
                              '<PaymentMethodCreditCardType>Invoice</PaymentMethodCreditCardType>' +
                              '<PaymentErrorMessage>You have no more credit available.</PaymentErrorMessage>' +
                              '<PaymentMethodExpirationDate>02-02-2016</PaymentMethodExpirationDate>' +
                              '<PaymentAmount>'+amount+'</PaymentAmount>' +
                              '<PaymentDate>'+paymentDate+'</PaymentDate>' +
                              '<PaymentMethodPaymentMethodType>Credid Card</PaymentMethodPaymentMethodType>' +
                              '<PaymentMethodPaypalEmail>recuerdo.bregente@gmail.com</PaymentMethodPaypalEmail>' +
                              '<PaymentMethodPaypalBaid>test</PaymentMethodPaypalBaid>' +
                              '</CreditCardDetails>';
            
            if(text == null){
                email.plainTextBody = '<CreditCardDetails></CreditCardDetails></CreditCardDetails>';
            } //joy
        
        Test.startTest();
        
        //TODO jowie
        try{
            
            ccf_ieh.handleInboundEmail(email, null);
        }catch(Exception e){}
        
        Test.stopTest();
        
    }
    
    static testmethod void test02(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123456';
        billAcc.Other_PaymentMethod__c = 'Invoice';
        insert billAcc;
        
        Zuora__PaymentMethod__c dpm = TestDataFactory.createPaymentMethod(1)[0];
        dpm.Zuora__Type__c = 'PayPal';
        dpm.Zuora__BillingAccount__c = billAcc.Id;
        insert dpm;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = '<CreditCardDetails>'+
            '<AccountName><FirstName>Ana</FirstName></AccountName>'+
            '<AccountNumber>123456</AccountNumber>'+
            '<BillToContactWorkEmail>sample@email.com</BillToContactWorkEmail>'+
            '<BillToContactFirstName>fname</BillToContactFirstName>'+
            '<BillToContactLastName>lname</BillToContactLastName>'+
            '<PaymentMethodCardHolderName>holderName</PaymentMethodCardHolderName>'+
            '<PaymentMethodCreditCardType>cType</PaymentMethodCreditCardType>'+
            '<PaymentErrorMessage>Message</PaymentErrorMessage>'+
            '<PaymentMethodExpirationDate>10/2016</PaymentMethodExpirationDate>'+
            '<PaymentAmount>100</PaymentAmount>'+
            '<PaymentDate>10/15/2015</PaymentDate>'+
            '<PaymentMethodPaymentMethodType>creditcard</PaymentMethodPaymentMethodType>'+
            '<PaymentMethodPaypalEmail>paypal@email.com</PaymentMethodPaypalEmail>'+
            '<PaymentMethodPaypalBaid>baid</PaymentMethodPaypalBaid>'+
            '</CreditCardDetails>';
        
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //end test data
    
        test.startTest();
            CreditCardFailure_InboundEmailHandler handler = new CreditCardFailure_InboundEmailHandler();
            handler.handleInboundEmail(email, env);
            
            billAcc.Zuora__Default_Payment_Method__c = dpm.Id;
            CreditCardFailure_InboundEmailHandler handler2 = new CreditCardFailure_InboundEmailHandler();
            handler2.handleInboundEmail(email, env);
        test.stopTest();
    }
    
    static void setDataMethod(){
        
        sObjectData = null;
        sObjectData = new Map<String, SObject>();
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Billing_Type__c = 'Full Prepaid';
        acc.Name = 'testname';
        acc.Email__c = 'test@gmail.com';
        acc.Mobile__c = '09321234567';
        Database.insert(acc);
        sObjectData.put('Account', acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        Database.insert(con);
        sObjectData.put('Contact',con);
        
                        
        
        Zuora__CustomerAccount__c billingAcct = TestDataFactory.createBillingAccount(1)[0];
        billingAcct.Billing_Contact__c = con.Id;
        billingAcct.Zuora__Credit_Balance__c = 1;
        billingAcct.Name = 'Zuora Customer Account';
        billingAcct.Refund_Amount__c = 100;
        billingAcct.Zuora__AutoPay__c =false;
        billingAcct.Zuora__Balance__c = 1;
        billingAcct.Zuora__External_Id__c = '22544AA'; 
        billingAcct.Zuora__Zuora_Id__c = '0124';  
        billingAcct.Zuora__AccountNumber__c = 'test01';
        billingAcct.Payment_Mode__c = 'Other';
        billingAcct.Billing_Type__c = 'Full Prepaid';
        billingAcct.Zuora__Account__c = acc.Id;
        
        Database.insert(billingAcct);
        sObjectData.put('Zuora__CustomerAccount__c',billingAcct);
        
        Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
        pm.Zuora__Type__c = 'Paypal';
        pm.Zuora__BillingAccount__c = billingAcct.id;   //joy
        
        insert pm;
        
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'Test Document Name';
         doc.body = Blob.valueOf('Test Document Body') ;
         insert doc;
         
        
        
    }
    
    //---4/10/16 JMG-----------------
    static testmethod void test03(){
      
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '123456';
        billAcc.Other_PaymentMethod__c = 'Invoice';
        billAcc.Billing_Type__c = 'Recurring Postpaid';
        insert billAcc;
        
        Zuora__PaymentMethod__c dpm = TestDataFactory.createPaymentMethod(1)[0];
        dpm.Zuora__Type__c = 'Paypal';
        dpm.Zuora__BillingAccount__c = billAcc.Id;
        insert dpm;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = '<CreditCardDetails>'+
            '<AccountName><FirstName>Ana</FirstName></AccountName>'+
            '<AccountNumber>123456</AccountNumber>'+
            '<BillToContactWorkEmail>sample@email.com</BillToContactWorkEmail>'+
            '<BillToContactFirstName>fname</BillToContactFirstName>'+
            '<BillToContactLastName>lname</BillToContactLastName>'+
            '<PaymentMethodCardHolderName>holderName</PaymentMethodCardHolderName>'+
            '<PaymentMethodCreditCardType>cType</PaymentMethodCreditCardType>'+
            '<PaymentErrorMessage>Message</PaymentErrorMessage>'+
            '<PaymentMethodExpirationDate>10/2016</PaymentMethodExpirationDate>'+
            '<PaymentAmount>100</PaymentAmount>'+
            '<PaymentDate>10/15/2015</PaymentDate>'+
            '<PaymentMethodPaymentMethodType>creditcard</PaymentMethodPaymentMethodType>'+
            '<PaymentMethodPaypalEmail>paypal@email.com</PaymentMethodPaypalEmail>'+
            '<PaymentMethodPaypalBaid>baid</PaymentMethodPaypalBaid>'+
            '</CreditCardDetails>';
        
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //end test data
    
        test.startTest();
            CreditCardFailure_InboundEmailHandler handler = new CreditCardFailure_InboundEmailHandler();
            handler.handleInboundEmail(email, env);
            
            billAcc.Zuora__Default_Payment_Method__c = dpm.Id;
            CreditCardFailure_InboundEmailHandler handler2 = new CreditCardFailure_InboundEmailHandler();
            handler2.handleInboundEmail(email, env);
        test.stopTest();
        
    }
    //-----------------------------------
}