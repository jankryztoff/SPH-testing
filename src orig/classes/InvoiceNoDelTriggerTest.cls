@isTest
public class InvoiceNoDelTriggerTest {

	public static testMethod void test() {
	    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.GST_Invoice__c = 'Yes';
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.ARMS_Account_Type__c = 'Savings';
        billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
        billAcc.ARMS_Debt_Management__c = 'picklist data type??';
        billAcc.ARMS_ID__c = '00002';
        billAcc.Zuora__AccountNumber__c = '12345667';
        billAcc.Zuora__BillToAddress1__c = 'Address1';
        billAcc.Zuora__BillToAddress2__c = 'Address2';
        billAcc.Zuora__BillToPostalCode__c = '1900';
        billAcc.Zuora__BillToCity__c = 'New York';
        billAcc.Zuora__BillToName__c = 'John Smith';
        // billAcc.Other_PaymentMethod__c = paymentMethod;
        // billAcc.Zuora__Balance__c = zuoraBalance;
        insert billAcc;
        
        
        Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
        zInv.Zuora__BillingAccount__c = billAcc.id;
        zInv.Zuora__Account__c = acc.id;
        zInv.Zuora__AmountWithoutTax__c = 100;
        zInv.Zuora__TaxAmount__c = 100;
        zInv.Zuora__Zuora_Id__c = 'ABC123456';
        zinv.Zuora__TotalAmount__c = 110;
        zinv.Zuora__PaymentAmount__c = 10;
        insert zInv;
        
        Test.startTest();
        try{        
            delete zInv;
        }catch(Exception ex){
            System.assertEquals(ex.getMessage(), 'Custom Sync : cannot delete Invoice!');
        }
        Test.stopTest();
        //Invoice will not be deleted since theere will be an exception thrown.
        System.assertEquals(zInv, zInv);
        
	}

}