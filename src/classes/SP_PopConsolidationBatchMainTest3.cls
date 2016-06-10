@isTest
private class SP_PopConsolidationBatchMainTest3{
    static testMethod void testSP_PopConsolidationBatchMain(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);       
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Id addressRT = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
 
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = addressRT;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        /*for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
            sub.Frequency_1__c = GlobalVariableClass.FREQ_MONSAT;
        }*/

        for(Integer i = 0; i < subs.size(); i++ ){
            subs[i].Zuora__CustomerAccount__c = billAcc.Id;
            subs[i].Subscription_Type__c = 'Publication';
            subs[i].Delivered_By__c = 'Vendor';
            subs[i].Vendor_1__c = acc.Id;
            subs[i].Product_Code__c = '01';
            subs[i].Frequency__c = GlobalVariableClass.FREQ_MONSAT;
            subs[i].Recipient_Contact__c = con.Id;
        }
        system.debug('***wendy FREQ_MONSAT: ' + GlobalVariableClass.FREQ_MONSAT);
        database.insert(subs);
        System.debug('***before insert : ' + subs);
        List<Zuora__Subscription__c> insertedSubs = [Select Frequency_1__c from Zuora__Subscription__c where Id in :subs];
        System.debug('***after insert : ' + insertedSubs[0].Frequency_1__c);
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        List<Publication__c> pubs = TestDataFactory.createPublication(1);
       /*APRIL
        for(Publication__c pub: pubs){
            pub.Publication_Next_Start_Date__c = date.today()+5;
            pub.Frequency_Code__c = 'D';
            //pub.Published_Days__c = 'NNNNNNN';
        } APRIL*/
        pubs[0].Publication_Next_Start_Date__c = date.today()+5;
        pubs[0].Frequency_Code__c = 'D';      
        pubs[0].Published_Days__c = 'YYYYYYY';
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        temp.Temp_Stop_Date__c = date.today();
        database.insert(temp);
        
           
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
     //added by aprilveloso Compile
     /* Error: Field is not writeable: Vendor_POP_Batch__c.CreatedDate at line 139 column 26    
        List<Vendor_POP_Batch__c> vendorPopList = Testdatafactory.createVendorPopBatch(1); 
        vendorPopList[0].createdDate =  [SELECT createdDate from Vendor_POP_batch__c WHERE createdDate = 2015-10-13T10:11:08.000+0000 LIMIT 1].createdDate;
        vendorPopList[0].Subscription_Name__c = null;
        // vendorPopList[0].createdDate = var;
        vendorPopList[0].Publication_Issue_Date__c = date.today()+5;
        database.insert(vendorPopList);
     */   
        
                
        Date inputDate = date.today();
        Id jobID =acc.id;
      
        test.startTest();
           // SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
           // Id batchID = database.executeBatch(batch, 200);
            SP_PopConsolidationBatchMain batch2 = new SP_PopConsolidationBatchMain(jobID, inputDate);
            Id batchID = database.executeBatch(batch2, 200);
          //  batch2.getTempStopQty(inputDate,  tempStop2);
            SP_PopConsolidationBatchMain batch3 = new SP_PopConsolidationBatchMain(jobID);
        test.stopTest();

    }
    
    static testMethod void testSP_PopConsolidationBatchMain2(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
        }
        database.insert(subs);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pubs = TestDataFactory.createPublication(2);
        for(Publication__c pub: pubs){
            pub.Publication_Next_Start_Date__c = date.today()+12;
            pub.Frequency_Code__c = 'W';
            pub.Published_Days__c = 'NNNYYNN';
        }
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        database.insert(temp);
        
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
        test.startTest();
            SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            Id batchID = database.executeBatch(batch, 200);
           
        test.stopTest();
    }
    /*APRIL*/
    static testMethod void testSP_PopConsolidationBatchMain3(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);       
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
        }
        database.insert(subs);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pubs = TestDataFactory.createPublication(1);
        pubs[0].Publication_Next_Start_Date__c = date.today()+16;
        pubs[0].Frequency_Code__c = 'F';      
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        database.insert(temp);
        
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
         
        test.startTest();
            SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();

    }
    
    static testMethod void testSP_PopConsolidationBatchMain4(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
        }
        database.insert(subs);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pubs = TestDataFactory.createPublication(2);
        for(Publication__c pub: pubs){
            pub.Publication_Next_Start_Date__c = date.today()+35;
            pub.Frequency_Code__c = 'M';
            pub.Published_Days__c = 'NNNYYNN';
        }
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        database.insert(temp);
        
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
        test.startTest();
            SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();
    }
    static testMethod void testSP_PopConsolidationBatchMain5(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);       
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
        }
        database.insert(subs);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pubs = TestDataFactory.createPublication(1);
        pubs[0].Publication_Next_Start_Date__c = date.today()+90;
        pubs[0].Frequency_Code__c = 'B';      
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        database.insert(temp);
        
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
         
        test.startTest();
            SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();

    }
    
    static testMethod void testSP_PopConsolidationBatchMain6(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
        }
        database.insert(subs);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pubs = TestDataFactory.createPublication(2);
        for(Publication__c pub: pubs){
            pub.Publication_Next_Start_Date__c = date.today()+180;
            pub.Frequency_Code__c = 'Q';
            pub.Published_Days__c = 'NNNYYNN';
        }
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        database.insert(temp);
        
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
        test.startTest();
            SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();
    }
    static testMethod void testSP_PopConsolidationBatchMain7(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);       
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
        }
        database.insert(subs);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pubs = TestDataFactory.createPublication(1);
        pubs[0].Publication_Next_Start_Date__c = date.today()+300;
        pubs[0].Frequency_Code__c = 'H';      
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        database.insert(temp);
        
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
         
        test.startTest();
            SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();

    }
    
    static testMethod void testSP_PopConsolidationBatchMain8(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
        }
        database.insert(subs);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pubs = TestDataFactory.createPublication(2);
        for(Publication__c pub: pubs){
            pub.Publication_Next_Start_Date__c = date.today()+380;
            pub.Frequency_Code__c = 'Y';
            pub.Published_Days__c = 'NNNYYNN';
        }
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        database.insert(temp);
        
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
        test.startTest();
            SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            Id batchID = database.executeBatch(batch, 200);
        test.stopTest();
    }
    
    static testMethod void NewTest01(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
        }
        database.insert(subs);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pubs = TestDataFactory.createPublication(2);
        for(Publication__c pub: pubs){
            pub.Publication_Code__c = '02';
            pub.Publication_Next_Start_Date__c = date.today()+380;
            pub.Frequency_Code__c = 'D';
            pub.Published_Days__c = 'NNNYYNN';
        }
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        temp.Temp_Stop_Date__c = date.Today()-1;
        temp.Qty__c = 0;
        database.insert(temp);
        
        List<Subscription_Temp_Stop__c> tempStopList = new List<Subscription_Temp_Stop__c>();
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        tempStopList.add(tempStop);

        
        system.assertnotEquals(tempStopList.size(), 0);
        
        test.startTest();
            SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            Id batchID = database.executeBatch(batch, 200);
            batch.getTempStopQty(date.Today(), tempStopList);
        test.stopTest();
    }
    
    
    static testMethod void testSP_PopConsolidationBatchMainOverseas(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);       
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Id addressRT = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Overseas').getRecordTypeId();
 
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = addressRT;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        /*for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
            sub.Frequency_1__c = GlobalVariableClass.FREQ_MONSAT;
        }*/

        for(Integer i = 0; i < subs.size(); i++ ){
            subs[i].Zuora__CustomerAccount__c = billAcc.Id;
            subs[i].Subscription_Type__c = 'Publication';
            subs[i].Delivered_By__c = 'Vendor';
            subs[i].Vendor_1__c = acc.Id;
            subs[i].Product_Code__c = '01';
            subs[i].Frequency__c = GlobalVariableClass.FREQ_MONSAT;
            subs[i].Recipient_Contact__c = con.Id;
            subs[i].Delivered_By_1__c = GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT;
            subs[i].Sponsor_1__c = true;
        }
        system.debug('***wendy FREQ_MONSAT: ' + GlobalVariableClass.FREQ_MONSAT);
        database.insert(subs);
        System.debug('***before insert : ' + subs);
        List<Zuora__Subscription__c> insertedSubs = [Select Frequency_1__c from Zuora__Subscription__c where Id in :subs];
        System.debug('***after insert : ' + insertedSubs[0].Frequency_1__c);
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        List<Publication__c> pubs = TestDataFactory.createPublication(1);
       /*APRIL
        for(Publication__c pub: pubs){
            pub.Publication_Next_Start_Date__c = date.today()+5;
            pub.Frequency_Code__c = 'D';
            //pub.Published_Days__c = 'NNNNNNN';
        } APRIL*/
        pubs[0].Publication_Next_Start_Date__c = date.today()+5;
        pubs[0].Frequency_Code__c = 'D';      
        pubs[0].Published_Days__c = 'YYYYYYY';
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        temp.Temp_Stop_Date__c = date.today();
        database.insert(temp);
        
           
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
     //added by aprilveloso Compile
     /* Error: Field is not writeable: Vendor_POP_Batch__c.CreatedDate at line 139 column 26    
        List<Vendor_POP_Batch__c> vendorPopList = Testdatafactory.createVendorPopBatch(1); 
        vendorPopList[0].createdDate =  [SELECT createdDate from Vendor_POP_batch__c WHERE createdDate = 2015-10-13T10:11:08.000+0000 LIMIT 1].createdDate;
        vendorPopList[0].Subscription_Name__c = null;
        // vendorPopList[0].createdDate = var;
        vendorPopList[0].Publication_Issue_Date__c = date.today()+5;
        database.insert(vendorPopList);
     */   
        
                
        Date inputDate = date.today();
        Id jobID =acc.id;
      
        test.startTest();
           // SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
           // Id batchID = database.executeBatch(batch, 200);
            SP_PopConsolidationBatchMain batch2 = new SP_PopConsolidationBatchMain(jobID, inputDate);
            Id batchID = database.executeBatch(batch2, 200);
          //  batch2.getTempStopQty(inputDate,  tempStop2);
            SP_PopConsolidationBatchMain batch3 = new SP_PopConsolidationBatchMain(jobID);
        test.stopTest();

    }
    
    static testMethod void testSP_PopConsolidationBatchMainInternal(){
        Integer counter = 0;
    
        Date NEXT_90_DAYS = date.today()+90;
    
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);       
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Case_Stop';
        key.Id__c = '012N00000008k09IAA';
        key.Type__c = 'RecordType';
        database.insert(key);
    
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = date.today()+5;
        database.insert(job);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        Id addressRT = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Airline').getRecordTypeId();
 
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = addressRT;
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        /*for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Delivered_By__c = 'Vendor';
            sub.Vendor_1__c = acc.Id;
            sub.Product_Code__c = '01';
            sub.Frequency_1__c = GlobalVariableClass.FREQ_MONSAT;
        }*/

        for(Integer i = 0; i < subs.size(); i++ ){
            subs[i].Zuora__CustomerAccount__c = billAcc.Id;
            subs[i].Subscription_Type__c = 'Publication';
            subs[i].Delivered_By__c = 'Vendor';
            subs[i].Vendor_1__c = acc.Id;
            subs[i].Product_Code__c = '01';
            subs[i].Frequency__c = GlobalVariableClass.FREQ_MONSAT;
            subs[i].Recipient_Contact__c = con.Id;
            subs[i].Delivered_By_1__c = GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT;
        }
        system.debug('***wendy FREQ_MONSAT: ' + GlobalVariableClass.FREQ_MONSAT);
        database.insert(subs);
        System.debug('***before insert : ' + subs);
        List<Zuora__Subscription__c> insertedSubs = [Select Frequency_1__c from Zuora__Subscription__c where Id in :subs];
        System.debug('***after insert : ' + insertedSubs[0].Frequency_1__c);
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        List<Publication__c> pubs = TestDataFactory.createPublication(1);
       /*APRIL
        for(Publication__c pub: pubs){
            pub.Publication_Next_Start_Date__c = date.today()+5;
            pub.Frequency_Code__c = 'D';
            //pub.Published_Days__c = 'NNNNNNN';
        } APRIL*/
        pubs[0].Publication_Next_Start_Date__c = date.today()+5;
        pubs[0].Frequency_Code__c = 'D';      
        pubs[0].Published_Days__c = 'YYYYYYY';
        database.insert(pubs);
        
        List<Non_Publication_Day__c> nonPubs = TestDataFactory.createNonPublicationDay(2);
        for(Non_Publication_Day__c nonPub: nonPubs){
            nonPub.Publication__c = pubs[0].Id;
            nonPub.Non_Publication_Date__c = NEXT_90_DAYS;
        }
        database.insert(nonPubs);
        
        Public_Holiday__c holiday = new Public_Holiday__c();
        holiday.Holiday_Date__c = NEXT_90_DAYS;
        database.insert(holiday);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pubs[0].Id;
        database.insert(pp); 
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Status = 'Closed';
        cas.Effective_Date__c = date.today()+2;
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        database.insert(cas);
        
        Case cas2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas2.Status = 'Closed';
        cas2.Effective_Date__c = date.today()+2;
        cas2.Change_of_Address_Type__c = 'Change of Vendor';
        cas2.Contact_To_Update__c = con.Id;
        cas2.Vendor__c = acc.ID;
        database.insert(cas2);
        
        case casQ = [SELECT Status, Effective_Date__c FROM Case WHERE Id=: cas.Id];
        system.assertEquals(casQ.Status, 'Closed'); 
        //system.assertEquals(casQ.Effective_Date__c, date.today()+1); 
        
        counter=0;
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(5);
        for(Case_Subscription__c caseSub: caseSubs){
            caseSub.Subscription__c = subs[0].Id;
            caseSub.Case__c = cas.Id;
            if(counter==4){
                caseSub.Case__c = cas2.Id;
            }
            counter++;
        }
        database.insert(caseSubs);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas.Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = NEXT_90_DAYS;
        database.insert(aa);
        
        Temp_Stop__c temp = new Temp_Stop__c();
        temp.Cancelled__c = false;
        temp.Restart_Date__c = NEXT_90_DAYS;
        temp.Temp_Stop_Date__c = date.today();
        database.insert(temp);
        
           
        Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
        tempStop.Subscription__c = subs[0].Id;
        tempStop.Temp_Stop__c = temp.Id;
        database.insert(tempStop);
        
     //added by aprilveloso Compile
     /* Error: Field is not writeable: Vendor_POP_Batch__c.CreatedDate at line 139 column 26    
        List<Vendor_POP_Batch__c> vendorPopList = Testdatafactory.createVendorPopBatch(1); 
        vendorPopList[0].createdDate =  [SELECT createdDate from Vendor_POP_batch__c WHERE createdDate = 2015-10-13T10:11:08.000+0000 LIMIT 1].createdDate;
        vendorPopList[0].Subscription_Name__c = null;
        // vendorPopList[0].createdDate = var;
        vendorPopList[0].Publication_Issue_Date__c = date.today()+5;
        database.insert(vendorPopList);
     */   
                
        Date inputDate = date.today();
        Id jobID =acc.id;
        
        List <Publication__c> pubList = TestDataFactory.createPublication(1);
        insert pubList;
        
        POP_History__c popHistory = new POP_History__c();
        popHistory.Publication_Issue_Date__c = date.Today()+1;
        popHistory.Publication_Issue_Date__c = date.Today()+1;
        popHistory.Publication__c = pubList[0].Id;
        insert popHistory;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(popHistory.Id, yesterday);
        
        test.startTest();
            // SP_PopConsolidationBatchMain batch = new SP_PopConsolidationBatchMain(job.Id, date.today()+1, date.today()+5, false);
            // Id batchID = database.executeBatch(batch, 200);
           
            SP_PopConsolidationBatchMain batch2 = new SP_PopConsolidationBatchMain(jobID, inputDate);
            Id batchID = database.executeBatch(batch2, 200);
            //  batch2.getTempStopQty(inputDate,  tempStop2);
           
            SP_PopConsolidationBatchMain batch3 = new SP_PopConsolidationBatchMain(jobID);
            
        test.stopTest();

    }

}