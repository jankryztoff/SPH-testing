@isTest
Public class BT_AB_INET054DX_SICOTest{
    
    Public Static testMethod void BT_AB_INET054DX_SICOTest() {

        List<Zuora__ZInvoice__c> invList = TestDataFactory.createInvoice(200);
               for(Zuora__ZInvoice__c inv: invList)
               {    
                  inv.Name = 'INV1001';    
               }                               
               insert invList; 
               
         try{      
         Test.StartTest();
         BT_AB_INET054DX_ShareInvestorChargeOut batch = new BT_AB_INET054DX_ShareInvestorChargeOut();
         ID batchprocessid = Database.executeBatch(batch, 200);
         Test.StopTest();
         }catch(exception e){}
       }          
}