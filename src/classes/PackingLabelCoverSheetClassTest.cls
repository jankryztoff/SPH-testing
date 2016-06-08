/*
 * Class Name: PackingLabelCoverSheetClassTest
 * @author: Jensar Joey Z. Sayson/Rom Edison Reyes
 * Date: 4/8/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for PackingLabelCoverSheetClass
 * @history
 *      04/14/2016 RReyes - modified class
 */

@isTest(seeAllData = true)
public class PackingLabelCoverSheetClassTest {

static testMethod void testAll(){
    
    List<CMIS_POP_Packing_label_Batch__c> lstPackLbl = new  List<CMIS_POP_Packing_label_Batch__c>();
    
    for(integer x=0;x<9;x++){
        lstPackLbl.add(new CMIS_POP_Packing_label_Batch__c());
    }

    for(CMIS_POP_Packing_label_Batch__c obj: lstPackLbl){
        obj.Total_Overseas_Freelist_Copies__c = 1;
        obj.Total_Overseas_Subscription_Copies__c = 2;
        obj.Publication_Issue_Date__c = Date.today().addDays(-2);
        obj.Batch_Run_Date__c = Date.today();
        
        obj.Total_Direct_Subscriptions__c = 1;
        obj.Total_Local_Freelist_Copies__c = 1; 
        obj.Total_Local_Subscription_Copies__c = 1;
        obj.Total_Sponsored_Copies__c = 1;
        
        obj.Mailing_Agent__c =  'mailingagentid';
        obj.Vendor_Group__c = 'vendorgroupid';
    }
    lstPackLbl[0].Publication_Code__c = 'ST';
    lstPackLbl[1].Publication_Code__c = 'BT';
    lstPackLbl[2].Publication_Code__c = 'BH';
    lstPackLbl[3].Publication_Code__c = 'NP';
    lstPackLbl[4].Publication_Code__c = 'ZB';
    lstPackLbl[5].Publication_Code__c = 'TM';
    lstPackLbl[6].Publication_Code__c = 'WB';
    lstPackLbl[7].Publication_Code__c = 'SM';
    lstPackLbl[8].Publication_Code__c = 'MY';

    insert lstPackLbl;
    
    PageReference pageRef = Page.PackingLabelCoverSheetPage;
    Test.setCurrentPage(pageRef);
    String dateParam = String.valueOf(Date.today().addDays(-2));
    ApexPages.currentPage().getParameters().put('d',dateParam);    
    
    Test.StartTest();
    PackingLabelCoverSheetClass pck = new PackingLabelCoverSheetClass();
    Test.StopTest();
    
    }
}