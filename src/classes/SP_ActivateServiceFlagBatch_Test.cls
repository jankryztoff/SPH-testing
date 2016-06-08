/**
   @author AMiranda
   @name SP_ActivateServiceFlagBatch_Test
   @createDate 18 Feb 2015
   @description Test for class SP_ActivateServiceFlagBatch
   @version 1.0 
*/
@isTest
private class SP_ActivateServiceFlagBatch_Test {

    static Integration_Settings__c is;
    static BatchInterface_Settings__c bis;
    static List<Service_Access_Flag__c> safList;
    static List<Asia1__c> a1List;
    static List<Asia1_Subscription__c> a1sList;
    
    /**
        @name setUpData
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setUpData() {
        
        is = new Integration_Settings__c();
        is.Name = 'Endpoint Delegator';
        is.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';        
        insert is;
        
        bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';        
        insert bis;
        
        safList = new List<Service_Access_Flag__c>();
        
        for (Integer i=0; i<200; i++) {        
            Service_Access_Flag__c saf = new Service_Access_Flag__c(); 
            saf.Name = 'ASM0000_' + i;
            //saf.Flag_Code__c = 'ASM0000_' + i;
            saf.Flag_Description__c = 'ASM0000_' + i;       
            safList.add(saf);
        }        
        insert safList;    
        
        a1List = new List<Asia1__c>{};
        
        for (Integer i=0; i<200; i++) {        
            Asia1__c a1 = new Asia1__c(); 
            a1.Display_Name__c = 'ASM0000_' + i;
            a1.User_ID_LDAP_ID__c = 'ASM0000_' + i;
            a1.Password__c = 'ASM0000_' + i;
            a1.ASIAONE_Legacy_Id__c = 'ASM0000_' + i;            
            a1.Legacy_Created_By__c = 'ASM00000';
            a1.Legacy_Created_Date__c = String.valueOf(Date.today());
            a1.Legacy_Updated_By__c = 'ASM00000';
            a1.Legacy_Updated_Date__c = String.valueOf(Date.today());  
            a1.Status__c = 'Pending Creation';        
            a1List.add(a1);
        }        
        insert a1List;        
        
        a1sList = new List<Asia1_Subscription__c>();
        
        for (Integer i=0; i<200; i++) {        
            Asia1_Subscription__c  a1s = new Asia1_Subscription__c(); 
            a1s.Asia1__c = a1List.get(i).Id;           
            a1s.ASIAONE_Subscription_Legacy_Id__c = 'ASM0000_' + i;
            a1s.Service_Access_Flag__c = safList.get(i).Id;            
            a1s.Legacy_Create_By__c = 'ASM00000';
            a1s.Legacy_Create_Date__c = String.valueOf(Date.today());
            a1s.Legacy_Update_By__c = 'ASM00000';
            a1s.Legacy_Update_Date__c = String.valueOf(Date.today());          
            a1sList.add(a1s);
        }        
        insert a1sList;
    }


    /**
       Tests the execute method in the base class.
       @name executeTest
       @param none
       @return void
       @throws none
    */
    public static testMethod void executeTest() {       
            
        try {  
            setUpData();         
            Test.StartTest(); 
            
            SP_ActivateServiceFlagBatch sp1 = new SP_ActivateServiceFlagBatch();            
            ID batchprocessId1 = Database.executeBatch(sp1, 200); 
            System.debug('ASM batchprocessId1= ' + batchprocessId1);
            System.assert(batchprocessId1 != null);
            
            List<BATCH_JOB_SCHEDULER__c> bsList = new List<BATCH_JOB_SCHEDULER__c>();           
            
            for (Integer i=0; i<200; i++) {            
                BATCH_JOB_SCHEDULER__c bs = new BATCH_JOB_SCHEDULER__c();
                bs.Status__c = 'ACTIVE';
                bs.Batch_Code__c = 'ASM' + i;
                bs.Batch_Run_Date__c = Date.today();
                bs.SFDC_Job_id__c = batchprocessId1; 
                bsList.add(bs);
            }
            
            insert bsList;
            System.assert(bsList.size() > 0);           
                   
            Test.StopTest();
        
         } catch (Exception e) {
             System.debug('ERROR= ' + e);
         }    
    }
}