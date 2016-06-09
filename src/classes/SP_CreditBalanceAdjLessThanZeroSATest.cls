@isTest (seealldata = false)
public class SP_CreditBalanceAdjLessThanZeroSATest {

      static testmethod void test() {
           
                   try{
                   Test.setMock(WebServiceMock.class, new zLoginMock());
                   
                   Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                   acc.AccountNumber = '31521179';
                   database.insert(acc);
                   
                   Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
                   invoice.Name = 'test invoice';
                   invoice.Zuora__Balance2__c = -5;
                   invoice.Zuora__Account__c = acc.Id;
                   insert invoice;
                   
                   Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
                    zInvoice.Name = 'Test Invoice';
                    zInvoice.Zuora__Account__c = acc.id;
                    //zInvoice.Zuora__BillingAccount__c = billingAcc.Id;
                    zInvoice.Zuora__Balance2__c = -500; 
                    insert zInvoice;    
                    
                    List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
                    
                    for(integer i=0; i<=50; i++){
                    Zuora__ZInvoice__c zInvoice1 = new Zuora__ZInvoice__c();
                    zInvoice1.Name = 'Test Invoice';
                    zInvoice1.Zuora__Account__c = acc.id;
                    //zInvoice1.Zuora__BillingAccount__c = billingAcc.Id;
                    zInvoice1.Zuora__Balance2__c = -500; 
                    invoiceList.add(zInvoice1);    
                    }
                    insert invoiceList;
                     
                   Set<String> accNum = new Set<String>();
                   accNum.add(acc.AccountNumber);
                   
                   String query = 'SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c';
                       
                   Zuora__ZInvoice__c accnumber = [SELECT Zuora__Account__r.AccountNumber FROM Zuora__ZInvoice__c WHERE Id =: invoice.Id];
                   //system.assertEquals('test',string.valueof(accnumber.Zuora__Account__r.AccountNumber));
                   Test.startTest();
                   SP_CreditBalanceAdjustmentLessThanZeroSA batch = new SP_CreditBalanceAdjustmentLessThanZeroSA(accNum);
                  
                   ID batchprocessid = Database.executeBatch(batch,200);
                   Database.BatchableContext BC;
                   batch.execute(BC, invoiceList);
                   System.assertNotEquals(null, batchprocessid);
                   
            
                } catch (Exception e) {
                   }
        }
    
  static testmethod void test2() {
           
                   try{
                   Test.setMock(WebServiceMock.class, new zLoginMock());
                       
                   Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                   database.insert(acc);
                   
                   Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
                   invoice.Name = 'test invoice';
                   invoice.Zuora__Balance2__c = -1;
                   invoice.Zuora__Account__c = acc.Id;
                   insert invoice;
                   
                   Set<String> accNum = new Set<String>();
                   accNum.add(acc.Id);
                   
                   String query = 'SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c';
                   Integer type = 2;
                   
                   Set<String> setString = new Set<String>();
                   setString.add(query);
                   
                   Test.startTest();
                   SP_CreditBalanceAdjustmentLessThanZero batch = new SP_CreditBalanceAdjustmentLessThanZero(setString, type);
                   ID batchprocessid = Database.executeBatch(batch,200);
                   
                   System.assertNotEquals(null, batchprocessid);
            
                } catch (Exception e) {
                   }
        }

}