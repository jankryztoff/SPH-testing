/*
 * Class Name: SP_CreditNoteRequestBatch
 * @author: April Grace Judilla
 * Date: 09/01/2015
 * Project/Requirement
 * 
 */ 
@isTest
public with sharing class SP_CreditNoteRequestBatchTest {
        
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface();                    
    }  
        
	static testmethod void test(){
			
		//asign values
		
		Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
		acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
		acc.GST_Invoice__c = 'Yes';
		database.insert(acc);
	 
		//assign values                    
		Contact con = TestDataFactory.createContact(1)[0];
		con.AccountId = acc.Id;
		con.Recipient_Indicator__c = true;
		con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
		database.insert(con);
							
		List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
		billAccountList[0].name = 'April Summer';
		//billAccountList [0].id = zInv.id;
		billAccountList[0].Zuora__Account__c = acc.id; 
		billAccountList[0].Billing_Contact__c = con.id;
		billAccountList[0].ARMS_Account_Number__c = '027101021';
		billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
		database.insert(billAccountList);
		
		Letter_Print_Request__c letterPrint = new Letter_Print_Request__c();
		letterPrint.Letter_Type__c = 'Credit_Notes';
		letterPrint.Status__c = 'New';
		
		database.insert(letterPrint);

		Credit_Note__c cNote = new Credit_Note__c();
		cNote.Is_PDF_Generated__c = false;
		cNote.Billing_Account__c = billAccountList[0].id;
		database.insert(cNote);
		
		Test.startTest();
		SP_CreditNoteRequestBatch batch= new SP_CreditNoteRequestBatch();
		ID batchprocessid = Database.executeBatch(batch ,200);
		System.assertNotEquals(null, batchprocessid);
		Test.stopTest();
	  
	}
	
	static testmethod void testAdHoc(){
			
		//asign values
		
		Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
		acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
		acc.GST_Invoice__c = GlobalVariableClass.TS_YES;
		database.insert(acc);
	 
		//assign values                    
		Contact con = TestDataFactory.createContact(1)[0];
		con.AccountId = acc.Id;
		con.Recipient_Indicator__c = true;
		con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
		database.insert(con);
									
		Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
		billAcc.name = 'April Summer';
		billAcc.Zuora__Account__c = acc.id; 
		billAcc.Billing_Contact__c = con.id;
		billAcc.ARMS_Account_Number__c = '027101021';
		billAcc.Billing_Type__c = 'Recurring Prepaid';
		database.insert(billAcc);
		
		Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
		zInv.Zuora__BillingAccount__c = billAcc.id;
		zInv.Zuora__Account__c = acc.id;
		zInv.Zuora__AmountWithoutTax__c = 100;
		zInv.Zuora__TaxAmount__c = 100;
		zInv.Zuora__Zuora_Id__c = 'ABC123456';
		zinv.Zuora__TotalAmount__c = 110;
		zinv.Zuora__PaymentAmount__c = 1000;
		zinv.Immediate_CB__c = 'Y';
		insert zInv;

		Credit_Note__c cNote = new Credit_Note__c();
		cNote.Is_PDF_Generated__c = false;
		cNote.Billing_Account__c = billAcc.id;
		cNote.Source_Invoice__c = zInv.Id;
		database.insert(cNote);

		Letter_Print_Request__c letterPrint = new Letter_Print_Request__c();
		letterPrint.Letter_Type__c = 'Credit_Notes';
		letterPrint.Status__c = GlobalVariableClass.STATUS_PENDING;
				
		database.insert(letterPrint);
		
		Set<Id> cNoteSet = new Set<Id>();
		cNoteSet.add(cNote.Id);
				
		Test.startTest();
		SP_CreditNoteRequestBatch batch= new SP_CreditNoteRequestBatch(cNoteSet);
		ID batchprocessid = Database.executeBatch(batch ,200);
		System.assertNotEquals('123', batchprocessid);
		Test.stopTest();
	  
	}
}