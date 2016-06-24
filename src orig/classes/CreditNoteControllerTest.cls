/**
* Class Name: <CreditNoteControllerTest>
* @author: <Kristine Balaoing>
* Date: <04/10/2016>
* Requirement/Project Name: <SPH>
* @description<Test Class for CreditNoteController>
*/

@isTest
private class CreditNoteControllerTest {
    
    static List<Account> accList;
    static Contact con;
    static Zuora__CustomerAccount__c  billAcc;
    static List<Credit_Note_Item__c> credNoteItemList;
    static List<Zuora__ZInvoice__c> zINvoiceList;
    static Zuora__ZInvoice__c zInv;
    static Credit_Note__c credRec;
    public String creditNoteNumber;
    static Date issueDate;
    static String address1;
    static String address2;
    static String address3;
    static String address4;
    static String address5;
    static String finalAddress;

        
    static testMethod void CreditNoteControllerTest() {  
       
        
        //Account
        setAccount();

        //Create Contact
        setContact();
        //BA
        setBillingAccount();
        
        //setPackage();

        credRec = new Credit_Note__c();
        credRec.Billing_Account__c = billAcc.id;
        credRec.Document_Date__c = date.today();
        insert credRec;
        
        zInv = new Zuora__ZInvoice__c();
        insert zInv;
        
        //System.assertEquals(null, zInv);
        
        credNoteItemList = new List<Credit_Note_Item__c>();
        Credit_Note_Item__c credItem = new Credit_Note_Item__c();
        Credit_Note_Item__c credItem2 = new Credit_Note_Item__c();
        credItem.Invoice__c = zInv.Id;
        credItem.Credit_Note__c = credRec.id;
        credNoteItemList.add(credItem);
        
        //credItem2.Invoice__c = zINvoiceList[0].Id;
        //credItem2.Credit_Note__c = credRec.id;
        //credNoteItemList.add(credItem2);
        insert credNoteItemList;

        PageReference pageRef = Page.LP_CreditNote;
        system.test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', credRec.Id);
        CreditNoteController controller = new CreditNoteController();
        controller.generateCreditNoteController();
        
        
    }
    //Create Billing Account
    private static void setBillingAccount() {
        billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Name = 'TEST';     
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.Billing_Contact__c = con.Id;
        billAcc.ARMS_Account_Number__c = '2456747588';
  
        insert billAcc;
    }

    //Create Account 
    private static void setAccount(){
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        insert accList;
    }
    
    //Create Contact
    private static void setContact(){
        //Create Contact
        con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = accList[0].Id;
        con.Recipient_Indicator__c = true;
        insert con;
    }

}