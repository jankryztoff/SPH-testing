@isTest

private class CustomCallbackControllerTest{

    static testmethod void testCustomCallbackController(){
    
    Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
    insert acct;
    
    Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(1)[0];
    zca.Zuora__Account__c = acct.Id;
    insert zca;

    Zuora__PaymentMethod__c zpm = TestDataFactory.createPaymentMethod(1)[0];
    zpm.Zuora__BillingAccount__c = zca.Id;
    insert zpm;
    
    PageReference pageRef = Page.CustomCallbackPage;
    pageRef.getParameters().put('Id', zpm.Id);
    Test.setCurrentPage(pageRef);
    
    CustomCallbackController createCustomCallbackController = new CustomCallbackController();
    createCustomCallbackController.processCallbackParameters();
    
    System.assertEquals(zpm.id,ApexPages.currentPage().getParameters().get('Id'));
}//END testmethod testCustomCallbackController
}//END CustomCallbackControllerTest