/*
 * Class Name: InvoicePaymentTriggerHandlerTest
 * @author: Jensar Joey Z. Sayson
 * Date: 4/8/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for InvoicePaymentTriggerHandler
 */

@isTest(seeAllData = true)
public class InvoicePaymentTriggerHandlerTest {
		String sessionId = UserInfo.getSessionId();    
	//initializing queueable class
    static testMethod void test01(){

        
        Test.startTest();
        InvoicePaymentTriggerHandler ipth = new InvoicePaymentTriggerHandler();
//		SObject sObj = new SObject();
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
        List<Zuora__ZInvoice__c> inv = TestDataFactory.createInvoice(1);
        inv[0].Zuora__BIllingAccount__c = billAcc.Id;
        insert inv;
        Set<String> invIdSet = new Set<String>();
        invIdSet.add(inv[0].Zuora__Zuora_Id__c);
        
        List<Zuora__Payment__c> payment = TestDataFactory.createPayment(1);
        payment[0].Zuora__BillingAccount__c = billAcc.Id;
        insert payment;
        
        List<Zuora__PaymentInvoice__c> invPayment = TestDataFactory.createInvoicePayment(1);
        invPayment[0].Zuora__Payment__c = payment[0].Id;
        invPayment[0].Zuora__Invoice__c = inv[0].Id;
        insert invPayment;
        
        ipth.runBeforeInsertTrigger();
        ipth.runBeforeUpdateTrigger();
        ipth.runBeforeDeleteTrigger();
        ipth.runAfterInsertTrigger();
        ipth.runAfterUpdateTrigger();
        ipth.runAfterDeleteTrigger();
        
        ipth.beforeInsert(null);
        ipth.beforeUpdate(null, null);
        ipth.beforeDelete(null);
        ipth.afterInsert(null);
        ipth.afterUpdate(null, null);
        ipth.afterDelete(null);
        /*try{
			ipth.bulkBefore(); 
        }catch(Exception e){}
        try{
			ipth.bulkAfter();
        }catch(Exception e){} */      
        
/*            
		ipth.beforeInsert();
        ipth.beforeUpdate();
        ipth.beforeDelete();
        ipth.afterInsert();
        ipth.afterUpdate();
        ipth.afterDelete();
*/        
        //ipth.invIdSet = invIdSet;
        //ipth.andFinally();
        InvoicePaymentTriggerHandler.createTasks(invIdSet);
        Test.stopTest();
        
        
        
/*
        try{
            
        }catch(Exception e){}   
*/       
    }
    

}