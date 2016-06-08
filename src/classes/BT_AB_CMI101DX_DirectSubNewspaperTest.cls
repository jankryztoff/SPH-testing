@isTest
public class BT_AB_CMI101DX_DirectSubNewspaperTest {

/**
     * Class Name: BT_AB_CMI101DX_DirectSubNewspaperTest
     * Accenture IDC : Rashmi.G.P
     * Date: 12 Feb 2015
     * Requirement/Project Name: SPH Project
     * @description Test Class for BT_AB_CMI101DX_DirectSubNewspaper
     * 
     */

   static testmethod void unitTest1()
     {
     try{
     List<Vendor_POP_Batch__c> VendorPOPList = new List<Vendor_POP_Batch__c>();
     
         Vendor_POP_Batch__c v1 = new Vendor_POP_Batch__c();
         v1.Publication_Code__c = 'code';
         v1.Publication_Issue_Date__c = date.today().adddays(2);
         v1.Vendor_Group__c = 'abcd';
         v1.Vendor_Number__c = '110081';
         v1.Total_Direct_Subscriptions__c = 100;
         v1.Total_Local_Freelist_Copies__c = 200;
         v1.Total_Local_Subscription_Copies__c = 50;
         v1.Total_Overseas_Freelist_Copies__c = 200;
         v1.Total_Overseas_Subscription_Copies__c = 100;
         v1.Total_Sponsored_Copies__c = 300;
         
         VendorPOPList.add(v1);
         
         insert VendorPOPList;  

            Test.StartTest();  
             BT_AB_CMI101DX_DirectSubNewspaper batch = new BT_AB_CMI101DX_DirectSubNewspaper();
              ID batchprocessid = Database.executeBatch(batch,200); 
           Test.StopTest();
      
        }catch(Exception e)
         {
         }    
        }//end of unitTest1
      
       static testmethod void unitTest2()
     {
  
     List<Vendor_POP_Batch__c> VendorPOPList = new List<Vendor_POP_Batch__c>();
     
         Vendor_POP_Batch__c v1 = new Vendor_POP_Batch__c();
         v1.Publication_Code__c = 'code';
         v1.Publication_Issue_Date__c = date.today().adddays(2);
         v1.Vendor_Group__c = 'abcd';
         v1.Vendor_Number__c = '110081';
         v1.Total_Direct_Subscriptions__c = 100;
         v1.Total_Local_Freelist_Copies__c = 200;
         v1.Total_Local_Subscription_Copies__c = 50;
         v1.Total_Overseas_Freelist_Copies__c = 200;
         v1.Total_Overseas_Subscription_Copies__c = 100;
         v1.Total_Sponsored_Copies__c = 300;
         
         VendorPOPList.add(v1);
         
         insert VendorPOPList;  

            Test.StartTest();  
             BT_AB_CMI101DX_DirectSubNewspaper dsn = new BT_AB_CMI101DX_DirectSubNewspaper();
              Database.BatchableContext objBatchC; 
            dsn.execute(objBatchC,VendorPOPList); 
           Test.StopTest();
         
        
        }//end of unitTest2     
}