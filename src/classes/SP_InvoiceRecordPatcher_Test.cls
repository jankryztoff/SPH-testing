/**
* Class Name: PackingLabelsController_Test
* @author: Accenture April Veloso
* Date: 25/08/2015
* @Description: This class is used to code coverage of the SP_InvoiceRecordPatcher class.
*
*/
@isTest (Seealldata=true)
public class SP_InvoiceRecordPatcher_Test{

    static testMethod void testFalse() {
    
             test.startTest();
            
                    //create values                  
                    Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0]; 
                    zInv.Is_PDF_Generated__c = true;
                    Database.insert(zInv);
         
                    
                    List<Zuora__ZInvoice__c> scope = [SELECT Id, Is_PDF_Generated__c FROM Zuora__ZInvoice__c WHERE Is_PDF_Generated__c = false];
                    
                    SP_InvoiceRecordPatcher batch = new SP_InvoiceRecordPatcher();
                    ID batchprocessid = Database.executeBatch(batch,200);
                    Database.BatchableContext BC;  
                    batch.execute(BC, scope);
             Test.StopTest();
     }           
        
}