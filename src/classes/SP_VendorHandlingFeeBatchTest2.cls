@isTest(seeAllData=False)
private class SP_VendorHandlingFeeBatchTest2{
    static testMethod void testSP_VendorHandlingFeeBatch(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='VDC_BILL_MTH', Value__c=null)
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND DeveloperName='Vendor'];
        acc.RecordType.DeveloperName = 'Vendor';
        database.insert(acc);
        
        system.assertEquals(acc.RecordType.DeveloperName, 'Vendor');
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';
        pub.Publication_Next_Start_Date__c = date.today().addDays(2);
        database.insert(pub);
        
        Publication_Daily_Issue_Data__c pdid = new Publication_Daily_Issue_Data__c();
        pdid.Publication_Issue_Date__c = date.today()+2;
        pdid.Order_Closed_Indicator__c = 'N';
        pdid.Publication__c = pub.Id;
        pdid.Publication_Code__c = 'N';
        pdid.Consolidation_Date__c = date.today()+1;
        database.insert(pdid);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Subscription_Type__c = 'Publication';
        sub.Delivered_By__c = 'Vendor';
        sub.Delivered_By_1__c = 'Vendor';
        sub.Vendor__c = acc.Id;
        sub.Vendor_1__c = acc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = null;
        database.insert(sub);
        
        Zuora__Subscription__c subs = [SELECT Id,Subscription_Type__c, Delivered_By_1__c, Vendor_1__c, Vendor_1__r.RecordType.DeveloperName, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c
                                      FROM Zuora__Subscription__c WHERE Id=:sub.Id];
        system.assertEquals(subs.Vendor_1__r.RecordType.DeveloperName, 'Vendor');
        system.debug(subs);
        
        test.startTest();
            SP_VendorHandlingFeeBatch vhf = new SP_VendorHandlingFeeBatch();
            SP_VendorHandlingFeeBatch vhf2 = new SP_VendorHandlingFeeBatch(date.today());
            Database.executeBatch(vhf,300);
        test.stopTest();
    }
    
    static testMethod void testSP_VendorHandlingFeeBatch2(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='VDC_BILL_MTH', Value__c=null)
        };
        database.insert(otherList);
    
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        //acc.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND DeveloperName='Vendor'];
        //acc.RecordType.DeveloperName = 'Vendor';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='Vendor'].Id;
        database.insert(acc);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';
        pub.Publication_Next_Start_Date__c = date.today().addDays(2);
        database.insert(pub);
        
        Publication_Daily_Issue_Data__c pdid = new Publication_Daily_Issue_Data__c();
        pdid.Publication_Issue_Date__c = date.today()+2;
        pdid.Order_Closed_Indicator__c = 'N';
        pdid.Publication__c = pub.Id;
        pdid.Publication_Code__c = 'N';
        pdid.Consolidation_Date__c = date.today()+1;
        database.insert(pdid);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Subscription_Type__c = 'Publication';
        sub.Delivered_By__c = 'Vendor';
        sub.Delivered_By_1__c = 'Vendor';
        sub.Vendor__c = acc.Id;
        sub.Vendor_1__c = acc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = null;
        sub.Product_Code__c = '01';
        database.insert(sub);
        
        Zuora__Subscription__c subs = [SELECT Id,Subscription_Type__c, Delivered_By_1__c, Vendor_1__c, Vendor_1__r.RecordType.DeveloperName, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c
                                      FROM Zuora__Subscription__c WHERE Id=:sub.Id];
        system.assertEquals(subs.Vendor_1__r.RecordType.DeveloperName, 'Vendor');
        system.debug(subs);
        
        test.startTest();
            SP_VendorHandlingFeeBatch vhf = new SP_VendorHandlingFeeBatch();
            SP_VendorHandlingFeeBatch vhf2 = new SP_VendorHandlingFeeBatch(date.today());
            Database.executeBatch(vhf2,300);
        test.stopTest();
    }
    
    static testMethod void testSP_VendorHandlingFeeBatch3(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='VDC_BILL_MTH', Value__c='8')
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
    
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        //acc.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account'AND DeveloperName='Vendor'];
        //acc.RecordType.DeveloperName = 'Vendor';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='Vendor'].Id;
        database.insert(acc);
        
        //system.assertEquals(acc.RecordType.DeveloperName, 'Vendor');
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Integer counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(8);
        for(Publication__c p : pub){
            if(counter==0){
                p.Frequency_Code__c = 'D';   
            }
            else if(counter==1){
                p.Frequency_Code__c = 'W';   
            }
            else if(counter==2){
                p.Frequency_Code__c = 'F';   
            }
            else if(counter==3){
                p.Frequency_Code__c = 'M';   
            }
            else if(counter==4){
                p.Frequency_Code__c = 'B';   
            }
            else if(counter==5){
                p.Frequency_Code__c = 'Q';   
            }
            else if(counter==6){
                p.Frequency_Code__c = 'H';   
            }
            else{
                p.Frequency_Code__c = 'Y';   
            }
            p.Publication_Type__c = 'N';
            p.Platform_Type__c = 'Print';
            p.Publication_Next_Start_Date__c = date.today().addDays(2);
            counter++;
        }
        database.insert(pub);
        
        Date todayDt = Date.today();
        Date monthStart = Date.newInstance(todayDt.year(),todayDt.month(), 1);
        
        Publication_Daily_Issue_Data__c pdid = new Publication_Daily_Issue_Data__c();
        pdid.Publication_Issue_Date__c = monthStart;
        pdid.Order_Closed_Indicator__c = 'N';
        pdid.Publication__c = pub[0].Id;
        pdid.Publication_Code__c = 'N';
        pdid.Consolidation_Date__c = date.today()+1;
        //database.insert(pdid);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Subscription_Type__c = 'Publication';
        sub.Delivered_By__c = 'Vendor';
        sub.Delivered_By_1__c = 'Vendor';
        sub.Vendor__c = acc.Id;
        sub.Vendor_1__c = acc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = null;
        sub.Product_Code__c = '01';
        database.insert(sub);
        
        Public_Holiday__c ph = new Public_Holiday__c();
        ph.Holiday_Date__c = date.today();
        database.insert(ph);
        
        Vendor_Inserts__c vi = new Vendor_Inserts__c();
        vi.Publication__c = pub[0].Id;
        vi.Vendor_Number__c = '01';
        vi.Publication_Issue_Date__c = date.today();
        vi.Publication_Code__c = '01';
        vi.Vendor_Group__c = '1';
        vi.Number_of_Inserts__c = 1;
        database.insert(vi);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        counter=0;
        List<Product_Publication__c> pp = TestDataFactory.createProductPublication(8);
        for(Product_Publication__c p : pp){
            if(counter==0){
                p.Publication_Code__c = pub[0].Id;
            }   
            else if(counter==1){
                p.Publication_Code__c = pub[1].Id;
            }  
            else if(counter==2){
                p.Publication_Code__c = pub[2].Id;
            } 
            else if(counter==3){
                p.Publication_Code__c = pub[3].Id;
            } 
            else if(counter==4){
                p.Publication_Code__c = pub[4].Id;
            } 
            else if(counter==5){
                p.Publication_Code__c = pub[5].Id;
            } 
            else if(counter==6){
                p.Publication_Code__c = pub[6].Id;
            } 
            else{
                p.Publication_Code__c = pub[7].Id;
            }
            p.ZProduct__c = zp.Id;
            counter++; 
        }
        database.insert(pp);
        
        Non_Publication_Day__c nonPub = TestDataFactory.createNonPublicationDay(1)[0];
        nonPub.Publication__c = pub[0].Id;
        nonPub.Non_Publication_Date__c = date.today();
        database.insert(nonPub);
        
        Publication_Commission_Rates__c pcr = new Publication_Commission_Rates__c();
        pcr.Effective_Start_Date__c = date.today()-30;
        pcr.Publication__c = pub[0].Id;
        pcr.Commission_Rate_Tue__c = 0;
        pcr.Commission_Rate_Mon__c =0;
        pcr.Commission_Rate_Wed__c = 0;
        pcr.Commission_Rate_Thur__c = 0;
        pcr.Commission_Rate_Fri__c = 0;
        pcr.Commission_Rate_Sat__c = 0;
        pcr.Commission_Rate_Sun__c = 0;
        pcr.Commission_Rate_PHE__c = 0;
        pcr.Commission_Rate_PHD__c = 0;
        pcr.Insertion_Rate__c = 0;
        pcr.Commission_Rate_Special_Mon__c = 0;
        pcr.Commission_Rate_Special_Tue__c = 0;
        pcr.Commission_Rate_Special_Wed__c = 0;
        pcr.Commission_Rate_Special_Thur__c = 0;
        pcr.Commission_Rate_Special_Fri__c = 0;
        pcr.Commission_Rate_Special_Sat__c = 0; 
        pcr.Commission_Rate_Special_Sun__c = 0;
        pcr.Commission_Rate_Special_PHE__c = 0;
        pcr.Commission_Rate_Special_PHD__c = 0;
        database.insert(pcr);
        
        Pagination_Rate__c pr = new Pagination_Rate__c();
        pr.Effective_Start_Date__c = date.today()-30;
        pr.Publication__c = pub[0].Id;
        pr.Paginaton_Rate__c = 0;
        pr.Pagination_Range_UL__c = 1;
        pr.Pagination_Range_LL__c = 0;
        database.insert(pr);
        
        Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
        temp.Cancelled__c = false;
        temp.Temp_Stop_Date__c = date.today();
        temp.Restart_Date__c = date.today()+1;
        database.insert(temp);
      
        Subscription_Temp_Stop__c st = new Subscription_Temp_Stop__c();
        st.Subscription__c = sub.Id;
        st.Temp_Stop__c = temp.Id;    
        database.insert(st);
        
        List<Subscription_Temp_Stop__c> sts = new List<Subscription_Temp_Stop__c>();
        sts.add(st);
        
        Contact con = TestDataFactory.createContactRecType(1,'Vendor Staff')[0];
        database.insert(con);
        
        counter=0;
        List<Case> cas = TestDataFactory.createCase(2, 'Complaint - Magazine');
        for(Case c : cas){
            if(counter==0){
                c.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
            }
            else{
                c.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                c.Contact_To_Update__c = con.Id;
                c.Vendor__c = acc.Id;
            }
            c.Vendor_Subscription_Created__c = false;
            c.Status = 'Closed';
            c.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND Name='Stop Subscription'].Id;
            c.Effective_Date__c = date.today();
            counter++;
        }
        database.insert(cas);
        
        counter=0;
        List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
        for(Case_Subscription__c cs : caseSub){
            if(counter==0){
                cs.Case__c = cas[0].Id;
            }
            else{
                cs.Case__c = cas[1].Id;
            }
            cs.Subscription__c = sub.Id;
            counter++;
        }
        database.insert(caseSub);
        
        List<Case_Subscription__c> lstCaseSubs = [SELECT ID, Name, Case__c, Subscription__c, Case__r.Effective_Date__c, Vendor_Code__c
                       FROM Case_Subscription__c WHERE Subscription__c =:sub.Id AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       AND Case__r.Effective_Date__c!=null
                       AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD 
                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC)];
                            
        system.debug(lstCaseSubs);          
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND Name = 'Overseas'].Id;
        database.insert(ad);
        
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas[0].Id;
        aa.Vendor__c = acc.Id;
        aa.Address__c = ad.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = date.today();
        database.insert(aa);
        
        BT_CO_VSS_CreditDebit__c bt = TestDataFactory.createBT_CO_VSS_CreditDebit(1)[0];
        database.insert(bt);
        
        Map<String, BT_CO_VSS_CreditDebit__c> mapVSS = new Map<String, BT_CO_VSS_CreditDebit__c>();
        mapVSS.put(String.ValueOf(bt.Id), bt);
        
        test.startTest();
            SP_VendorHandlingFeeBatch vhf = new SP_VendorHandlingFeeBatch();
            SP_VendorHandlingFeeBatch vhf2 = new SP_VendorHandlingFeeBatch(date.today());
            Database.executeBatch(vhf,300);
            
            SP_VendorHandlingFeeBatch.COAWrapper wrapperCOA = new SP_VendorHandlingFeeBatch.COAWrapper();
            List<SP_VendorHandlingFeeBatch.COAWrapper> wrapperCOAList = new List<SP_VendorHandlingFeeBatch.COAWrapper>();
            wrapperCOAList.add(wrapperCOA);
            vhf2.getVendorInfo(sub, date.today(), wrapperCOAList);
            
            SP_VendorHandlingFeeBatch.HandlingFeeWrapper wrapperHan = new SP_VendorHandlingFeeBatch.HandlingFeeWrapper();
            wrapperHan.commissionRate = 0;
            wrapperHan.paginationRate = 0;
            wrapperHan.insertRate = 0;
            //List<SP_VendorHandlingFeeBatch.HandlingFeeWrapper> wrapperHanList = new List<SP_VendorHandlingFeeBatch.HandlingFeeWrapper>();
            //wrapperHanList.add(wrapperHan);
            
            //vhf2.calculateFee(mapVSS, sub, wrapperHan, pub[0], date.today(), 1, 1, );
            vhf2.getTempStopQty(date.today(), sts);
            
            SP_VendorHandlingFeeBatch.VendorInfoWrapper wrapperInfo = new SP_VendorHandlingFeeBatch.VendorInfoWrapper();
            wrapperInfo.vendorGroup = 'vendorgroup'; 
            wrapperInfo.vendorCode =  lstCaseSubs[0].Vendor_Code__c;
            wrapperInfo.addressId = String.ValueOf(ad.Id);
            
            vhf2.calculateFee(mapVSS, sub, wrapperHan, pub[0], date.today(), 1, 1, wrapperInfo);
            Set<Date> setHolidays = new Set<Date>();
            setHolidays.add(date.today());
            vhf2.getCommRateOfTheDate(date.today(), pcr, setHolidays);
        test.stopTest();
    }
}