@RestResource(urlMapping='/CreditCardFailure/*')
global with sharing class createCreditCardFailureRecord 
{   
    @HTTPPost 
    global static String doPostCreateRecord (String AccountName, String BillToContactFirstName, 
        String BillToContactLastName, String BillToContactWorkEmail, Decimal PaymentAmount, 
        String PaymentDate, String PaymentErrorMessage, String PaymentMethodPaymentMethodType,
        String PaymentMethodCardHolderName, String PaymentMethodCreditCardType, 
        String PaymentMethodExpirationDate, String PaymentMethodAchBankName, String F){  
        
        External_Payment__c ePayment = new External_Payment__c();
           
            ePayment.Billing_Account__c = AccountName;
            ePayment.Billing_Contact_First_Name__c = BillToContactFirstName;
            ePayment.Billing_Contact_Last_Name__c = BillToContactLastName;           
            ePayment.Billing_Contact_email__c = BillToContactWorkEmail;
            ePayment.Payment_amount__c = PaymentAmount;
            ePayment.Payment_Date__c = convertDate(PaymentDate);
            ePayment.Error_Message__c = PaymentErrorMessage;
            ePayment.Payment_Method__c = PaymentMethodPaymentMethodType;
            ePayment.Card_Holder_Name__c = PaymentMethodCardHolderName;
            ePayment.Card_Type__c = PaymentMethodCreditCardType;
            ePayment.Expiration_Date__c = convertDate(PaymentMethodExpirationDate);
            ePayment.Bank_Name__c = PaymentMethodAchBankName;
            ePayment.Transaction_Date__c = convertDate(PaymentDate);
            ePayment.Transaction_Amount__c = PaymentAmount;
            ePayment.Transaction_Type__c = 'F';
                      
        insert ePayment;
        
        return ePayment.Id;
    }
    
    private static Date convertDate(String myDate)
            {
                String[] myDateOnly = myDate.split(' ');
                String[] strDate = myDateOnly[0].split('/');
                Integer myIntMonth = integer.valueOf(strDate[0]);
                Integer myIntDay = integer.valueOf(strDate[1]);
                Integer myIntYear = integer.valueOf(strDate[2]);

                Date d = Date.newInstance(myIntYear, myIntMonth, myIntDay);
                return d;
             } 

}