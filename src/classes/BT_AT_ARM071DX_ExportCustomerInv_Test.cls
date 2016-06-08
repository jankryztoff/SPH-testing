/*
 * Class Name: BT_AT_ARM071DX_ExportCustomerInv_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - ARM071DX Interface
 * @description A test class for BT_AT_ARM071DX_ExportCustomerInvoice 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_ARM071DX_ExportCustomerInv_Test
{   
    private static List<Account> accList = new List<Account>();
    private static BT_CO_ARMS_ExportCustomerInvoice__c btCoArms;
    private static Zuora__ZInvoice__c zInvoice;
    private static Zuora__CustomerAccount__c billAcc;
    
    /** This method creates the sample data to be used throughout the class **/
    public static void testData()
    {
       btCoArms = new BT_CO_ARMS_ExportCustomerInvoice__c();
            btCoArms.Name = 'btCoArms001';
            btCoArms.accountNumber__c = 'AcntNo1234';
            btCoArms.synonym__c ='11CustmrNo';
            btCoArms.invoiceNumber__c ='anyId0000';
        insert btCoArms;
        
        BT_CO_ARMS_ExportCustomerInvoice__c btCoArms1 = new BT_CO_ARMS_ExportCustomerInvoice__c();
            btCoArms1.Name = 'btCoArms002';      
            btCoArms1.accountNumber__c = 'AcntNo1234';
            btCoArms1.synonym__c ='11CustmrNo';   
            btCoArms1.invoiceNumber__c ='anyId0000';
        insert btCoArms1;
        
       
        for (integer i=0 ;i<3; i++)
        {
            Account acc = new account();
                acc.Name='Test Account'+i;
                acc.AccountNumber = '11CustmrNo';
            accList.add(acc);
        }
        insert accList;
        
        /*Test Billing Account Data*/
        billAcc = new Zuora__CustomerAccount__c();
            billAcc.Zuora__Account__c = accList[0].id;
            billAcc.Zuora__AccountNumber__c = '123456789';
            billAcc.Name = 'test Billing Account';
            billAcc.ARMS_Customer_Number__c = '11CustmrNo';
            billAcc.ARMS_Account_Number__c = 'AcntNo1234';
        insert billAcc; 

         
        zInvoice = new Zuora__ZInvoice__c();
            zInvoice.Name = 'anyId0000';
            zInvoice.Zuora__Zuora_Id__c = 'any_text_of_length_32_or_less';
            zInvoice.Zuora__BillingAccount__c = billAcc.id;
            zInvoice.ARMS_Invoice_ID__c = 'anyId0000';
        insert zInvoice;
        system.debug('zInvoice-->'+zInvoice);
        
        

        
    }
    
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        testData();
        Zuora__CustomerAccount__c bAccount = TestDataFactory.createBillingAccount(1)[0];
        bAccount.Zuora__Account__c = accList[1].id;
        insert bAccount;
        String UniqueIDKey;
        for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, Zuora__AccountNumber__c FROM Zuora__CustomerAccount__c WHERE Id =: bAccount.Id Limit 1]){
            UniqueIDKey = zBillingAccount.Zuora__AccountNumber__c;    
        }
    
        List<BT_CO_ARMS_ExportCustomerInvoice__c> interfaceRecordList = new List<BT_CO_ARMS_ExportCustomerInvoice__c>();
        
        BT_CO_ARMS_ExportCustomerInvoice__c interfaceRecord = new BT_CO_ARMS_ExportCustomerInvoice__c();
        interfaceRecord.Name = 'ARM071DX';
        interfaceRecord.feUniqueKey__c = UniqueIDKey;
        interfaceRecord.accountNumber__c = '1';
        interfaceRecord.accountType__c = '2';
        interfaceRecord.invoiceAmount__c = '100';
        interfaceRecord.invoiceDate__c = '11212014';
        interfaceRecord.invoiceDueDate__c = '11282014';
        interfaceRecord.invoiceNumber__c = '6';
        interfaceRecord.invoiceOutstandingAmount__c = '702';
        interfaceRecord.synonym__c = '8';
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    /* Author Name: Mayank Singh Rana
       @description test method to validate the condition where Billing Account object has Account Number*/
    static testMethod void toTestAcntno()
    {
        testData();
        Zuora__CustomerAccount__c bAccount = TestDataFactory.createBillingAccount(1)[0];
        system.debug('accList[1].id--->'+accList[1].id);
        bAccount.Zuora__Account__c = accList[1].id;
        bAccount.ARMS_Account_Number__c = '9876543210';
        insert bAccount;
        
         String UniqueIDKey;
        for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, Zuora__AccountNumber__c FROM Zuora__CustomerAccount__c WHERE Id =: bAccount.Id Limit 1]){
            UniqueIDKey = zBillingAccount.Zuora__AccountNumber__c;   

        List<BT_CO_ARMS_ExportCustomerInvoice__c> interfaceRecordList = new List<BT_CO_ARMS_ExportCustomerInvoice__c>();
        Boolean isValid = true;
        
        BT_CO_ARMS_ExportCustomerInvoice__c interfaceRecord = new BT_CO_ARMS_ExportCustomerInvoice__c();
        interfaceRecord.Name = 'ARM071DX';
        interfaceRecord.feUniqueKey__c = UniqueIDKey;
        interfaceRecord.accountNumber__c = '1';
        interfaceRecord.accountType__c = '2';
        interfaceRecord.invoiceAmount__c = '100';
        interfaceRecord.invoiceDate__c = '11212014';
        interfaceRecord.invoiceDueDate__c = '11282014';
        interfaceRecord.invoiceNumber__c = '6';
        interfaceRecord.invoiceOutstandingAmount__c = '702';
        interfaceRecord.synonym__c = '8';
        
        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
        }
    }
    
    
}