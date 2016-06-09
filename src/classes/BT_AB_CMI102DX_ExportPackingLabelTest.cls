/**
     * Class Name: BT_AB_CMI102DX_ExportPackingLabelTest
     * Created By: Christian C. Coquilla
     * Date: 12 Apr 2015
     * Requirement/Project Name: SPH Project
     * @description Test Class for BT_AB_CMI102DX_ExportPackingLabel
     * 
     */


@isTest(seealldata=true)
public class BT_AB_CMI102DX_ExportPackingLabelTest {


   static testmethod void unitTest1()
     {
     
     List<CMIS_POP_Packing_label_Batch__c> cmisList= new List<CMIS_POP_Packing_label_Batch__c>();
     
         CMIS_POP_Packing_label_Batch__c cmis = new CMIS_POP_Packing_label_Batch__c();
         cmis.Total_Direct_Subscriptions__c = 1;
         cmis.Batch_Run_Date__c = date.Today();
         cmis.Mailing_Agent__c = 'Agent';
         cmis.Publication_Code__c = 'pubCode';
         cmis.Publication_Issue_Date__c = date.today()-1;
         cmis.Total_Local_Freelist_Copies__c = 10;
         cmis.Total_Local_Subscription_Copies__c = 10;
         cmis.Total_Overseas_Freelist_Copies__c = 10;
         cmis.Total_Overseas_Subscription_Copies__c = 10;
         cmis.Total_Sponsored_Copies__c = 10;
         cmis.Vendor_Group__c = 'Vendor';
         
         
         cmisList.add(cmis);
         
         insert cmisList;  

            Test.StartTest();  
             BT_AB_CMI102DX_ExportPackingLabel batch = new BT_AB_CMI102DX_ExportPackingLabel();
              ID batchprocessid = Database.executeBatch(batch,200); 
           Test.StopTest();
      
          
        }
     }