@isTest(SeeAllData=true)
public class BT_AB_HDS039DX_DR_SIFTest
{
    static testmethod void myUnitTest(){
     
     List<Vendor_Monthly_Data__c> VMD = new List<Vendor_Monthly_Data__c>();

     List<Address__c> addressList = TestDataFactory.createAddress(200);
     insert addressList;

     
     for(integer i=0 ; i<200 ; i++)
     {
     Vendor_Monthly_Data__c  vendorMonthlyDate = new Vendor_Monthly_Data__c(
          Vendor_Number__c = '1',
          Publication_Code__c = '12',
          Credit_Debit__c = '20',
          Credit_Period__c = date.today(),
          Copies__c = 2,
          Amount_Type__c = 'Test'        
         );
 
     VMD.add(vendorMonthlyDate);
     }
     insert VMD;
     
     List<Case> caseList = TestDataFactory.createCase(200, 'Adjustments');
   
         for(Case cas: caseList){                                                                    
             cas.Effective_Date__c = date.Today();
         }                                                                                              
         insert caseList;   
   
     
     Test.StartTest();
     BT_AB_HDS039DX_DR_SubscriptionIssuesFile batch = new BT_AB_HDS039DX_DR_SubscriptionIssuesFile();
     ID batchprocessid = Database.executeBatch(batch,200);
     Test.StopTest();
     
    }
    
   
}