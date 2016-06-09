@isTest(SeeAllData = true)
private class UpdateCreditCardDetailsTest{
    static testMethod void testUpdateCreditCardDetails(){
        test.startTest();
            UpdateCreditCardDetails uccd = new UpdateCreditCardDetails();
            uccd.paymentMethodId = '123';
            uccd.getSource();
        test.stopTest();
    }
}