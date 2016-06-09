/**
   @Author Joyrem Zarmaine Ayuman
   @name UpdateAddressHouseBlockNumberBatch
   @CreateDate 02/04/2015
   @Description Test class for UpdateAddressHouseBlockNumberBatch
   @Version <1.0>
   @reference 
*/

@isTest(seeAllData=False)

private class UpdateAddressHouseBlockNumberBatchTest{

    static testmethod void unitTest1() {  // <-- This is the Original Test Method Signature
    
        /*BT_CO_MIRO_SubscriptionIssueFile__c sif1 = new BT_CO_MIRO_SubscriptionIssueFile__c();
        sif1.Publication_Code__c = 'code';
        sif1.Publication_Issue_Date__c = System.Today();
        sif1.postal_sector__c = 'MN';
        sif1.vendor_number__c = '0001C';
        sif1.office_house_mail_indicator__c = 'Y';
        sif1.house_type__c = 'A';
        sif1.sub_channel_code__c = 'ABC';
        sif1.subscription_copies__c = 200;
        sif1.subscriber_count__c = 100;
        
        insert sif1;*/
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TESTest';
        postal.Address_Type__c = 'A';
        insert postal;
        
                
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        UpdateAddressHouseBlockNumberBatch batch = new UpdateAddressHouseBlockNumberBatch();
        ID batchprocessid = Database.executeBatch(batch,200);
        System.assertNotEquals(null, batchprocessid);
        
        /*Database.batchableContext bc;
        batch.start();
        batch.execute(bc, */
        
        }
   }