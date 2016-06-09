/**
@Author <Rom Edison Reyes>
@name <SP_BatchJobSchedulerTriggerTest>
@CreateDate <02/25/2015>
@Description <Test Class for SP_BatchJobSchedulerTrigger>
@Version <1.0>
@reference <>
*/
@isTest
private class SP_BatchJobSchedulerTriggerTest {
    
    @testSetup 
    static void setupData() {        
        insert CustomSettingsDataFactory.createKey_Id();        
    } 
 
    /**
    * test method for batch codes SP001-SP006
    * @name <testBatchJobScheduler1to5>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testBatchJobScheduler1()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'GracePeriodDaysBeforeEndDate';
        key.Id__c = '4';
        key.Type__c = 'Integer';
        database.insert(key);*/
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP001';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler2()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'GracePeriodDaysBeforeEndDate';
        key.Id__c = '4';
        key.Type__c = 'Integer';
        database.insert(key);*/
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP002';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler3()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'GracePeriodDaysBeforeEndDate';
        key.Id__c = '4';
        key.Type__c = 'Integer';
        database.insert(key);*/
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP003';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler4()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'GracePeriodDaysBeforeEndDate';
        key.Id__c = '4';
        key.Type__c = 'Integer';
        database.insert(key);*/
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP004';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler5()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'GracePeriodDaysBeforeEndDate';
        key.Id__c = '4';
        key.Type__c = 'Integer';
        database.insert(key); */ 
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP005';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    /**
    * test method for batch codes SP006-SP010
    * @name <testBatchJobScheduler6to10>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testBatchJobScheduler6()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP006';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
        static testmethod void testBatchJobScheduler7()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP007';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
       
    
        static testmethod void testBatchJobScheduler9()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP009';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler10()
    {       
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP0010';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    /**
    * test method for batch codes SP011-SP015
    * @name <testBatchJobScheduler11to15>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    /*
    static testmethod void testBatchJobScheduler11to15()
    {  
        try
        {
            Key_Id__c key = new Key_Id__c();
            key.Name = 'DaysBeforeSubEndDate_RenewalOfSub';
            key.Id__c = '14';
            key.Type__c = 'Integer';
            database.insert(key);
        
            List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
            for(Integer x=11; x<=15; x++) //fritz
            {
                BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

                batchRec.Batch_Code__c = 'SP0' + x;
                batchRec.Batch_Run_Date__c = date.today();
                batch.add(batchRec);
            }
            test.startTest();
            insert batch;    
            test.stopTest();
            LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
            System.assert(batchList.size()>0);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
    }
    */
    /**
    * test method for batch codes SP016-SP020
    * @name <testBatchJobScheduler16to20>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testBatchJobScheduler16()
    {       
        
        /*Key_Id__c key = new Key_Id__c();
        key.Name = 'Vendor Rep Role';
        key.Id__c = '0B7N00000008OoLKAU';
        key.Type__c = 'Case Team Role';
        database.insert(key);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
        
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);

        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
   
        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP016';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);

        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler17()
    {       
        /*Key_Id__c key = new Key_Id__c();
        key.Name = 'Vendor Rep Role';
        key.Id__c = '0B7N00000008OoLKAU';
        key.Type__c = 'Case Team Role';
        database.insert(key);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
        
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);

        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
   
        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP017';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);

        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler18()
    {       
        /*Key_Id__c key = new Key_Id__c();
        key.Name = 'Vendor Rep Role';
        key.Id__c = '0B7N00000008OoLKAU';
        key.Type__c = 'Case Team Role';
        database.insert(key);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
        
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);

        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
   
        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP018';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);

        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    

    
    
    /**
    * test method for batch codes SP021-SP025
    * @name <testBatchJobScheduler21to25>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    
    
    
    
    
    
    
    
    
    
    
    /**
    * test method for batch codes SP026-SP030
    * @name <testBatchJobScheduler26to30>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testBatchJobScheduler26()
    {       
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

            BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

            batchRec.Batch_Code__c = 'SP026';
            batchRec.Batch_Run_Date__c = date.today();
            batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler27()
    {       
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
 
            BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

            batchRec.Batch_Code__c = 'SP027';
            batchRec.Batch_Run_Date__c = date.today();
            batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler28()
    {       
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
   
            BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

            batchRec.Batch_Code__c = 'SP028';
            batchRec.Batch_Run_Date__c = date.today();
            batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler29()
    {       
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
 
            BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

            batchRec.Batch_Code__c = 'SP029';
            batchRec.Batch_Run_Date__c = date.today();
            batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler30()
    {       
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

            BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

            batchRec.Batch_Code__c = 'SP030';
            batchRec.Batch_Run_Date__c = date.today();
            batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    /**
    * test method for batch codes SP031-SP035
    * @name <testBatchJobScheduler31to35>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testBatchJobScheduler31()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP031';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler32()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP032';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
        static testmethod void testBatchJobScheduler33()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP033';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
        static testmethod void testBatchJobScheduler34()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP034';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
        static testmethod void testBatchJobScheduler35()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP035';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    /**
    * test method for batch codes SP036-SP040
    * @name <testBatchJobScheduler36to40>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testBatchJobScheduler36()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
    
        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP036';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler37()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
    
        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP037';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler38()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
    
        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP038';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler39()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
    
        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP039';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler40()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
    
        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP040';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    /**
    * test method for batch codes SP041-SP058
    * @name <testBatchJobScheduler41to43>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testBatchJobScheduler41()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        /*Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
       /* Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP041';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler42()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
       /* 
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP042';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
   
    
    static testmethod void testBatchJobScheduler44()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
      /*  Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
      /*  Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP044';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    

    
    static testmethod void testBatchJobScheduler46()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
      /*  Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key); */
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
       /* Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP046';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler47()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
    /*    Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
     /*   Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP047';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler48()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
       /* Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
      /*  Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP048';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler49()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
     /*   Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
     /*   Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP049';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler50()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
    /*    Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
    /*    Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP050';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler51()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
    /*    Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        
    /*    Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP051';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler52()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
       /* 
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        /*
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP052';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler53()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        /*
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP053';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler54()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        /*
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP054';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler55()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        /*
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP055';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler56()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
       /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
       /* 
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP056';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler57()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
        /*
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP057';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobScheduler58()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
      /*  
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'Vendor Rep Role';
        key2.Id__c = '0B7N00000008OoLKAU';
        key2.Type__c = 'Case Team Role';
        database.insert(key2);*/
        
        Batch_Configuration_Settings__c bcs = new Batch_Configuration_Settings__c();
        bcs.Name = 'SP_VendorNotificationsBatch';
        bcs.Batch_Size__c = 200;
        bcs.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
        bcs.Number_Of_Days_To_Retrieve__c = 30;
        database.insert(bcs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();

        batchRec.Batch_Code__c = 'SP058';
        batchRec.Batch_Run_Date__c = date.today();
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    /**
    * test method where brrlist has values
    * @name <testBatchJobSchedulerWithBRR>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testBatchJobSchedulerWithBRR1()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP041';
        batchRec.Batch_Run_Date__c = date.today();
        batchRec.Status__c = 'STARTED';
        batchRec.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR2()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
        batchRec.Batch_Code__c = 'SP042';
        batchRec.Batch_Run_Date__c = date.today();
        batchRec.Status__c = 'STARTED';
        batchRec.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    
    static testmethod void testBatchJobSchedulerWithBRR4()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK000';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR5()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK001';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR6()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK002';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR7()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK003';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR8()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK004';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR9()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK005';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR10()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK006';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR11()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK007';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR12()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK008';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR13()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec2 = new BATCH_JOB_SCHEDULER__c();
        batchRec2.Batch_Code__c = 'HK009';
        batchRec2.Batch_Run_Date__c = date.today();
        batchRec2.Status__c = 'STARTED';
        batchRec2.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec2);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR14()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec3 = new BATCH_JOB_SCHEDULER__c();
        batchRec3.Batch_Code__c = 'HK010';
        batchRec3.Batch_Run_Date__c = date.today();
        batchRec3.Status__c = 'STARTED';
        batchRec3.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec3);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR15()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec3 = new BATCH_JOB_SCHEDULER__c();
        batchRec3.Batch_Code__c = 'HK011';
        batchRec3.Batch_Run_Date__c = date.today();
        batchRec3.Status__c = 'STARTED';
        batchRec3.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec3);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR16()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec3 = new BATCH_JOB_SCHEDULER__c();
        batchRec3.Batch_Code__c = 'HK012';
        batchRec3.Batch_Run_Date__c = date.today();
        batchRec3.Status__c = 'STARTED';
        batchRec3.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec3);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR17()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec3 = new BATCH_JOB_SCHEDULER__c();
        batchRec3.Batch_Code__c = 'HK013';
        batchRec3.Batch_Run_Date__c = date.today();
        batchRec3.Status__c = 'STARTED';
        batchRec3.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec3);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR18()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);
        */
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec3 = new BATCH_JOB_SCHEDULER__c();
        batchRec3.Batch_Code__c = 'HK014';
        batchRec3.Batch_Run_Date__c = date.today();
        batchRec3.Status__c = 'STARTED';
        batchRec3.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec3);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR19()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec3 = new BATCH_JOB_SCHEDULER__c();
        batchRec3.Batch_Code__c = 'HK015';
        batchRec3.Batch_Run_Date__c = date.today();
        batchRec3.Status__c = 'STARTED';
        batchRec3.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec3);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
    static testmethod void testBatchJobSchedulerWithBRR20()
    {   
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'RetentionOutboundSixWeeks';
        key.Id__c = '42';
        key.Type__c = 'Integer';
        database.insert(key);*/
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        bs.Name = 'Endpoint Delegator';
        database.insert(bs);
    
        List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();

        BATCH_JOB_SCHEDULER__c batchRec3 = new BATCH_JOB_SCHEDULER__c();
        batchRec3.Batch_Code__c = 'HK016';
        batchRec3.Batch_Run_Date__c = date.today();
        batchRec3.Status__c = 'STARTED';
        batchRec3.Allow_Parallel_Jobs__c = false;
        batch.add(batchRec3);
        
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[0].id];
        System.assert(batchList.size()>0);
    }
    
}