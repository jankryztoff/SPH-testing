@isTest(seeAllData = False)
public class PackingLabelTest{

 static testMethod void testpacklabelcoversheet() {
     //Test data creation
      List<string> myList = new List<String> { 'ST', 'BT', 'BH','NP', 'ZB', 'TM','WB', 'SM', 'MY','ST', 'BT' };

      

     
     
      List<CMIS_POP_Packing_label_Batch__c > pcs= new List<CMIS_POP_Packing_label_Batch__c >();
        for(Integer i=0;i<10;i++) {
            CMIS_POP_Packing_label_Batch__c p = new CMIS_POP_Packing_label_Batch__c (Name='test' + i, Total_Overseas_Subscription_Copies__c = 1, 
            Total_Overseas_Freelist_Copies__c = 1, Publication_Code__c= myList[i], Publication_Issue_Date__c = Date.today(),
            Mailing_Agent__c = 'bb', Total_Direct_Subscriptions__c = 2, Total_Local_Freelist_Copies__c = 1, Total_Local_Subscription_Copies__c = 1, Total_Sponsored_Copies__c = 2, Vendor_Group__c = 'aa'
            
            );
            pcs.add(p);
        }
        try{
        insert pcs;
        }catch(exception e){}
       packinglabebatch__c mc = new packinglabebatch__c();
       mc.toname__c =  'test';
       mc.ToEmailID__c=  'test@test.com';
       mc.DaysfromCurrentdate__c = 10;
       mc.name = 'Packing1';
       insert mc;
     
 
 
     try{
     PackingLabelCoverSheetClass pckvar = new PackingLabelCoverSheetClass();
     }catch(exception e){}
    
    try{
    Test.StartTest();

    PackingLabelBatchSch sh1 = new PackingLabelBatchSch();
    //String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
    Test.stopTest();
    }catch(exception e){} 
 }


}