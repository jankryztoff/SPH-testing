/**
   @Author 
   @name SP_VBSDeliveryFeeBatchTest
   @CreateDate 
   @Description 
   @Version <1.0>
   @reference 
*/

@isTest (seeAllData=true)

public class SP_VBSDeliveryFeeBatchTest{
    static testMethod void testSP_VBSDeliveryFeeBatch(){
        Integer count = 0;
        List<Account> accounts = TestDataFactory.createAccount(200, 'Corporate Subscriber');
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE Name='Vendor'LIMIT 1];
        for(Account acnt:accounts){
            acnt.Vendor_Code__c = 'VC';
            acnt.RecordType = recType;
            acnt.Active__c = true;
            count++;
        }
        database.insert(accounts);
        
        count = 0;
        List<BT_CO_VBS_CreditDebit__c> bt_co= TestDataFactory.createBT_CO_VBS_CreditDebit(200);
        for(BT_CO_VBS_CreditDebit__c CD: bt_co){
            CD.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
            CD.Posting_Date__c = date.today();
            CD.Reason_Code__c = GlobalVariableClass.REASON_CD_DEL;
            CD.Vendor_Group__c = 'A';
            CD.Vendor_Number__c = accounts[0].Vendor_Code__c;
            CD.Job_Id__c = 'ST001';
            CD.Publication_Code__c = 'pubC';
        }
        database.insert(bt_co);
        
        count = 0;
        List<BT_CO_VSS_CreditDebit__c> VSS = TestDataFactory.createBT_CO_VSS_CreditDebit(200);
        for(BT_CO_VSS_CreditDebit__c btVSS: VSS){
            btVSS.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
            btVSS.Vendor_Number__c = accounts[0].Vendor_Code__c;
            btVSS.Posting_Date__c = date.today();
            btVSS.Delivery__c = 100;
        }
        database.insert(VSS);
        
        BATCH_JOB_SCHEDULER__c job = [SELECT Id, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c LIMIT 1];
        String jobId = job.SFDC_Job_id__c; 
        
    test.startTest();
         SP_VBSDeliveryFeeBatch VBS = new SP_VBSDeliveryFeeBatch(jobId);
         Database.BatchableContext BC;
         VBS.start(BC);
         VBS.execute(BC, accounts);
         VBS.finish(BC);
         //Database.executebatch(BC, accounts);
     test.stopTest();
    } 
}