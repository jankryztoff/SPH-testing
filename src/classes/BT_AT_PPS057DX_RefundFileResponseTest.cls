/**
  * Class Name: BT_AT_PPS057DX_RefundFileResponseTest
  * @author: Accenture IDC - Nilesh
  * Date: 12 Feb 2015
  * Requirement/Project Name: SPH Project
  * @description Test Class for BT_AT_PPS057DX_RefundFileResponse
  * 
  */
@isTest 
public class BT_AT_PPS057DX_RefundFileResponseTest {  

    static testMethod void executeTriggerException() { 
    
        DmlException expectedException;
                
        Test.startTest();        
        
        try
        {
            List<BT_CO_PPS_RefundFileResponse__c> refundFileResponseList = createRefundFileResponse(1);
            insert refundFileResponseList; 
        }
        catch (DmlException dmx) 
        {
            expectedException = dmx;
        }
            
        Test.stopTest();
        
       //System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, expectedException.getDmlType(0));
    }
    
    static testMethod void executeTrigger() { 
    
        Test.startTest();
        BT_CO_PPS_RefundFileResponse__c testRefundFileResponse2 = createRefundFileResponse(1)[0];
            testRefundFileResponse2.customerACNumber__c = 'XXX';
            testRefundFileResponse2.paymentAmount__c='10';
            testRefundFileResponse2.customerAccount__c ='1234567890';
        insert testRefundFileResponse2; 
        
        Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            testAccount.NRIC__c = 'T1234567R';
            testAccount.AccountNumber = '1234567890';
        insert testAccount;
        List<Account> AccountList = new List<Account>();
        AccountList.add(testAccount);
        
        Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
            testCustomerAccount.Zuora__Account__c = testAccount.Id;
        insert testCustomerAccount;
        
        Zuora__Refund__c testRefund = TestDataFactory.createRefund(1)[0];
            testRefund.Zuora__AccountingCode__c = 'XXX';
            testRefund.Zuora__Account__c = testAccount.Id;
            testRefund.Status__c = 'processed'; 
            testRefund.Zuora__BillingAccount__c = testCustomerAccount.id;
        insert testRefund;
        
        BT_CO_PPS_RefundFile__c testRefundFile = createRefundFile(1)[0];
            testRefundFile.Status__c = 'sent';
        insert testRefundFile;      
        
        BT_CO_PPS_RefundFileResponse__c testRefundFileResponse = createRefundFileResponse(1)[0];
            testRefundFileResponse.customerACNumber__c = 'XXX';
            testRefundFileResponse.paymentAmount__c='10';
        insert testRefundFileResponse; 

        Test.stopTest();
    }    
    
    public static List<BT_CO_PPS_RefundFile__c> createRefundFile(Integer count) {

        List<BT_CO_PPS_RefundFile__c> refundFileList = new List<BT_CO_PPS_RefundFile__c>();
    
        for(Integer i=0; i<count; i++){
             BT_CO_PPS_RefundFile__c testRefundFile = new BT_CO_PPS_RefundFile__c();
            testRefundFile.Name = 'RefundFile ' + i; 
            refundFileList.add(testRefundFile); 
        }
        
        return refundFileList;
    }
    
    public static List<BT_CO_PPS_RefundFileResponse__c> createRefundFileResponse(Integer count) {

        List<BT_CO_PPS_RefundFileResponse__c> refundFileResponseList = new List<BT_CO_PPS_RefundFileResponse__c>();
    
        for(Integer i=0; i<count; i++){
            BT_CO_PPS_RefundFileResponse__c testRefundFileResponse = new BT_CO_PPS_RefundFileResponse__c();
            testRefundFileResponse.Name = 'RefundFileResponse ' + i; 
            refundFileResponseList.add(testRefundFileResponse); 
        }
        
        return refundFileResponseList;
    }     
}