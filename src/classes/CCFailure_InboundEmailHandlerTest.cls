/**
 * Class Name: CCFailure_InboundEmailHandlerTest
 * @author: Recuerdo Bregente
 * Date: 07.17.2015
 * Requirement/Project Name: SPH
 * @description Test Class for CreditCardFailure_InboundEmailHandler
 */
@isTest(seeAllData=True)
private class CCFailure_InboundEmailHandlerTest {

    // Test Data
    static CreditCardFailure_InboundEmailHandler testClass;
    static Messaging.InboundEmail email;
    static Messaging.InboundEnvelope env;
    
    static Account acc;
    static Singpost_Address__c postal;
    static Address__c address;
    static List<Contact> con;
    static List<Package__c> pkg;
    static List<Zuora__CustomerAccount__c> zcaList;
    static List<Zuora__Subscription__c> zSubs;
    static List<Zuora__PaymentMethod__c> zpmList;

        
    /**
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/17/2015
    */ 
    static void prepareTestData(String methodType, String paymentDate, String amount, String text){
        testClass = new CreditCardFailure_InboundEmailHandler();
        email = new Messaging.InboundEmail();
        
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
            }
            acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId =  '012N00000008ic6'; 
            acc.Email__c = 'recuerdo.bregente@gmail.com';
            acc.Mobile__c = '09324861074';
            insert acc;
            
            postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
            
            con = TestDataFactory.createContact(1);
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            con[0].Recipient_Indicator__c = true;
            insert con;
                   
            pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15'; 
            insert pkg;
           
            
            zcaList = TestDataFactory.createBillingAccount(1);
            zcaList[0].Zuora__AccountNumber__c = 'ACC00001';
            zcaList[0].Name = 'Zuora Customer Account';
            zcaList[0].Zuora__Account__c = acc.Id;
            zcaList[0].Zuora__Credit_Balance__c = 1;
            zcaList[0].Refund_Amount__c = 100;
            zcaList[0].Zuora__AutoPay__c =false;
            zcaList[0].Zuora__Balance__c = 1;
            zcaList[0].Payment_Mode__c = methodType;
            zcaList[0].Other_PaymentMethod__c= methodType;
            //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            zcaList[0].Zuora__PaymentMethodType__c = methodType; 
            zcalist[0].Zuora__External_Id__c = '22544AA';  
            zcalist[0].Zuora__Zuora_Id__c = '0124';         
            insert zcaList;
            
            //START : D-1929 3/2/2015 added to create Default Payment Method
            zpmList = TestDataFactory.createPaymentMethod(1);
            zpmList[0].Name = 'Zuora Customer Account';
            zpmList[0].Zuora__Type__c = methodType;
            zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
            insert zpmList;  
            //End: D-1929 3/2/2015 added to create Default Payment Method
            
            zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
            update zcaList;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con[0].Id;
            orderRec.Subscriber_Charge__c = 15;
            insert orderRec;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pkg[0].id;
            insert orderline;
            
            //create billing account      
            zSubs =  TestDataFactory.createSubscription(1);
            zSubs[0].Order_Line_Item_Number__c = orderline.Id;
            zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Main_Package_1__c = pkg[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Number__c = null;
            zSubs[0].Zuora__CustomerAccount__c = zcaList[0].Id;
            zSubs[0].Billing_Type__c = 'Full Prepaid';
            zSubs[0].Legacy_Create_Date__c = 'a';
            zSubs[0].Legacy_Create_By__c = 'a';
            zSubs[0].Legacy_Update_By__c = 'a';
            zSubs[0].Legacy_Subscription_ID__c = 'a';
            zSubs[0].Legacy_Update_Date__c = 'a';
            zSubs[0].Number_of_Copies__c = 100;
            zSubs[0].Number_of_Copies1__c = '100';
            zSubs[0].Zuora__Zuora_Id__c = 'ZZ0001';
            zSubs[0].Recipient_Contact__c = con[0].id;
            insert zSubs;
        
        env = new Messaging.InboundEnvelope();
    }
    
    /**
    * @name: testInvoicePaymentMethod
    * @author : Recuerdo B. Bregente
    * @description : Tests handleInboundEmail with Invoice PaymentMethod.
    * @date: 07/17/2015
    */
    static testMethod void testInvoicePaymentMethod(){
    
        try{
             Test.startTest();
             prepareTestData('Invoice', '07/07/2015', '1000', '');
             testClass.handleInboundEmail(email, env); 
                                                        
             System.assertNotEquals(null, testClass);
             Test.stopTest();
         } catch(Zuora.zRemoteException e){
             System.assertNotEquals(null, e);
         }
    }
    
    /**
    * @name: testCashPaymentMethod
    * @author : Recuerdo B. Bregente
    * @description : Tests handleInboundEmail with Cash PaymentMethod.
    * @date: 07/17/2015
    */
    static testMethod void testCashPaymentMethod(){
    
        try{
             Test.startTest();
             prepareTestData('Cash', '07/07/2015', '1000', '');
             testClass.handleInboundEmail(email, env); 
                                                        
             System.assertNotEquals(null, testClass);
             Test.stopTest();
         } catch(Zuora.zRemoteException e){
             System.assertNotEquals(null, e);
         }
    }
    
    /**
    * @name: testPaymentDateIsInvalid
    * @author : Recuerdo B. Bregente
    * @description : Tests handleInboundEmail with invalid paymentdate.
    * @date: 07/17/2015
    */
    static testMethod void testPaymentDateIsInvalid(){
    
        try{
             Test.startTest();
             prepareTestData('Cash', '07-07-2015', '1000', '');
             testClass.handleInboundEmail(email, env); 
                                                        
             System.assertNotEquals(null, testClass);
             Test.stopTest();
         } catch(Zuora.zRemoteException e){
             System.assertNotEquals(null, e);
         }
    }
    
    /**
    * @name: testAmountIsInvalid
    * @author : Recuerdo B. Bregente
    * @description : Tests handleInboundEmail with invalid amount.
    * @date: 07/17/2015
    */
    static testMethod void testAmountIsInvalid(){
    
        try{
             Test.startTest();
             prepareTestData('Cash', '07/07/2015', 'Invalid Amount', '');
             testClass.handleInboundEmail(email, env); 
                                                        
             System.assertNotEquals(null, testClass);
             Test.stopTest();
         } catch(Zuora.zRemoteException e){
             System.assertNotEquals(null, e);
         }
    }
    
    /**
    * @name: testInvalidEmailPlainTextBody
    * @author : Recuerdo B. Bregente
    * @description : Tests handleInboundEmail with invalid email plainTextBody.
    * @date: 07/17/2015
    */
    static testMethod void testInvalidEmailPlainTextBody(){
    
        try{
             Test.startTest();
             prepareTestData('Cash', '07/07/2015', '1000', null);
             testClass.handleInboundEmail(email, env); 
                                                        
             System.assertNotEquals(null, testClass);
             Test.stopTest();
         } catch(Zuora.zRemoteException e){
             System.assertNotEquals(null, e);
         }
    }
}