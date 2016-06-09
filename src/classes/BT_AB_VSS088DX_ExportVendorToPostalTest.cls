//@isTest (Seealldata = TRUE)
@isTest
public class BT_AB_VSS088DX_ExportVendorToPostalTest {

/**
     * Class Name: BT_AB_VSS088DX_ExportVendorToPostalTest
     * @author : Accenture IDC : Rashmi.G.P
     * Date: 12 Feb 2015
     * Requirement/Project Name: SPH Project
     * @description Test Class for BT_AB_VSS088DX_ExportVendorToPostal
     * 
     */
/*     
    static testmethod void unitTest1()
    {
        try{
            Test.startTest(); 
            BT_AB_VSS088DX_ExportVendorToPostal batch = new BT_AB_VSS088DX_ExportVendorToPostal();

            List<Vendor_Allocation__c> sample = [SELECT Id, Vendor_Account__r.Vendor_Group__c, Vendor_Account__r.Vendor_Code__c, SingPost_Address__r.Name FROM Vendor_Allocation__c WHERE Status__c = 'Active' LIMIT 5];
            if(sample.size() > 0 ){
                //ID batchprocessid = Database.executeBatch(batch);
            }else{
                //ID batchprocessid = Database.executeBatch(batch);
            }
            Test.stopTest();
        }catch(Exception e){
            
        }
    }//end of unitTest1
**/

/**
     * Class Name: BT_AB_VSS088DX_ExportVendorToPostalTest
     * @author : Accenture PH : Aduan, Juan Carlos
     * Date Modified: 10 May 2016
     * Requirement/Project Name: SPH Project
     * @description Test Class for BT_AB_VSS088DX_ExportVendorToPostal
     * 
*/
   
    @testSetup static void setup(){

        String recTypeName = 'Vendor';
        // create dummy Account record/s
        List<Account> dummyAccList = TestDataFactory.createAccount(1, recTypeName);
        dummyAccList[0].Name = 'Test1';
        dummyAccList[0].Status__c = 'Active';
        dummyAccList[0].Vendor_Code__c = '0001D';
        dummyAccList[0].Vendor_Group__c = 'V';

        insert dummyAccList;

        //create dummy Singpost Address record/s
        List<Singpost_Address__c> dummySingpostAddList = TestDataFactory.createSingpostAddress(1);
        
        insert dummySingpostAddList;

    }
    static testMethod void testCreatingDataPoolRecordsByBatch(){

        //query those records that you create on your @testsetup method
        Account testAccount = [Select Id from Account LIMIT 1];
        Singpost_Address__c testSingpostAddress = [Select Id, Name from Singpost_Address__c LIMIT 1];      

        //create Vendor Allocation record/s 
        List<Vendor_Allocation__c> dummyVAlist = TestDataFactory.createVendorAlloc(1);
        dummyVAlist[0].Vendor_Account__c = testAccount.Id;
        dummyVAlist[0].Legacy_Created_By__c = 'Test 1';
        dummyVAlist[0].Legacy_Created_Date__c = String.valueOf(system.today().format());
        dummyVAlist[0].Legacy_Updated_By__c = 'Test 1';
        dummyVAlist[0].Legacy_Updated_Date__c = String.valueOf(system.today().format());
        dummyVAlist[0].Allocated__c = true;
        dummyVAlist[0].Operated__c = true;
        dummyVAlist[0].SingPost_Address__c = testSingpostAddress.Id;

        insert dummyVAlist;
        BatchInterface_Settings__c customConfig = new BatchInterface_Settings__c();
        customConfig.Name = 'Endpoint Delegator';
        customConfig.value__c = 'http://tstcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        
        insert customConfig;

        Test.startTest();
        //instantiate the batch class that you want to test then execute
            BT_AB_VSS088DX_ExportVendorToPostal batch = new BT_AB_VSS088DX_ExportVendorToPostal();
            Database.executeBatch(batch);
        Test.stopTest();

        //query the expected result
        List<BA_INT_DATA_POOL__c> dataPoolResults = [SELECT Id FROM BA_INT_DATA_POOL__c];
        //validate if the record/s on BA_INT_DATA_POOL__c custom object was created
        System.assertEquals(1,dataPoolResults.size()); 

    }
}