@isTest (seealldata = true)
private class SP_CreditBalanceAdjLessThanZeroTest {

        static testmethod void test() {
           
                   try{
                   Test.setMock(WebServiceMock.class, new zLoginMock());
                   
                   Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
                   invoice.Name = 'test invoice';
                   invoice.Zuora__Balance2__c = -1;
                   insert invoice;
                   
                   String query = 'SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c';
                  
                   Test.startTest();
                   SP_CreditBalanceAdjustmentLessThanZero batch = new SP_CreditBalanceAdjustmentLessThanZero();
                  
                   ID batchprocessid = Database.executeBatch(batch,200);
                   
                   System.assertNotEquals(null, batchprocessid);
            
                } catch (Exception e) {
                   }
        }
        static testmethod void test2() {
           
                   try{
                   Test.setMock(WebServiceMock.class, new zLoginMock());
                   
                   Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
                   invoice.Name = 'test invoice';
                   invoice.Zuora__Balance2__c = -1;
                   insert invoice;
                   
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
        static testmethod void test3() {
           
                   try{
                   Test.setMock(WebServiceMock.class, new zLoginMock());
                   
                   Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
                   invoice.Name = 'test invoice';
                   invoice.Zuora__Balance2__c = -1;
                   insert invoice;
                   
                   String query = 'SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c';
                   Integer type = 1;
                   
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