/**
 * Class Name: CreateInvoiceTriggerHandlerTest
 * @author: Recuerdo Bregente
 * Date: 07.13.2015
 * Requirement/Project Name: SPH
 * @description Test Class for CreateInvoiceTriggerHandler
 */
@isTest(seeAllData=True)
private class CreateInvoiceTriggerHandlerTest {

    static Integer uname = 0;
    static Account acc;
    static Singpost_Address__c postal;
    static Address__c address;
    static List<Contact> con;
    static List<Package__c> pkg;
    static List<Zuora__CustomerAccount__c> zcaList;
    static List<Zuora__Subscription__c> zSubs;
    static List<Zuora__PaymentMethod__c> zpmList;
    static CreateInvoiceTriggerHandler createInvTrigHandlerClass;

        
    /**
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/13/2015
    */ 
    static void prepareTestData(){
            createInvTrigHandlerClass = new CreateInvoiceTriggerHandler();
    
            acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber'); 
            acc.Attention_To_Care_Of_Indicator__c = 'A';
            insert acc;
            
            Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
            testCustomerAccount.AGD_Unit__c = '1';
            testCustomerAccount.Attention_To_Care_Of_Indicator__c = acc.Attention_To_Care_Of_Indicator__c;
            testCustomerAccount.Attention_To_Care_Of_Name__c = 'test';
            testCustomerAccount.Attention_To_Care_Of_Salutation__c = 'MR';
            testCustomerAccount.Zuora__Account__c = acc.Id;
            insert testCustomerAccount;
                
            Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
            testInvoice.Zuora__InvoiceDate__c = date.today();
            testInvoice.Zuora__BillingAccount__c = testCustomerAccount.id;
            testInvoice.Zuora__External_Id__c='1';
            insert testInvoice;
    }

    
    /**
    * @author : Mayank Singh Rana
    * @description : Tests isAfterInsertTriggerCalled is False.
    * @date: 07/13/2015
    */
    static testMethod void isInsertTriggerCalledIsFalse(){
    
            boolean errorExist = false;
            boolean beforeInsert = false;
            boolean beforeUpdate = false;
            boolean beforeDelete = false;
            boolean afterUpdate = false;
            boolean afterDelete = false;
            boolean afterInsert = false;
            
            Test.startTest(); 
                      
            prepareTestData();
                       
            beforeInsert = createInvTrigHandlerClass.runBeforeInsertTrigger();
            beforeUpdate = createInvTrigHandlerClass.runBeforeUpdateTrigger();
            beforeDelete = createInvTrigHandlerClass.runBeforeDeleteTrigger();
            afterUpdate = createInvTrigHandlerClass.runAfterUpdateTrigger();
            afterDelete = createInvTrigHandlerClass.runAfterDeleteTrigger();
            afterInsert = createInvTrigHandlerClass.runAfterInsertTrigger();
                
            SObject so = (SObject) acc;
                
            createInvTrigHandlerClass.bulkBefore();
            createInvTrigHandlerClass.beforeInsert(so);
            createInvTrigHandlerClass.beforeUpdate(so, so);
            createInvTrigHandlerClass.beforeDelete(so);
            createInvTrigHandlerClass.afterUpdate(so, so);
            createInvTrigHandlerClass.afterDelete(so);
            createInvTrigHandlerClass.andFinally();
                
            Test.stopTest();
                
            // Assert all
            System.assertEquals(true, beforeInsert);
            System.assertEquals(false, beforeUpdate);
            System.assertEquals(false, beforeDelete);
            System.assertEquals(false, afterUpdate);
            System.assertEquals(false, afterDelete);
            System.assertEquals(false, afterInsert);
   }
}