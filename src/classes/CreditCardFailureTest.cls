@isTest
private class CreditCardFailureTest{
    static testMethod void testCreditCardFailure(){
        //start test data
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'subject';
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //end test data
        
        test.startTest();
            CreditCardFailure ccf = new CreditCardFailure();
            ccf.handleInboundEmail(email, envelope);
        test.stopTest();
    }
}