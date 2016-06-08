@isTest (seeAllData = false)
private Class TempStopDirectControllerTest{
    
    static testMethod void testTempStopDirectController() {
        Integer counter=0;
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'EshopDuration';
        key.Id__c = '3';
        key.Type__c = 'Number of Months';
        database.insert(key);
        
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'CRSMDuration';
        key2.Id__c = '6';
        key2.Type__c = 'Number of Months'; 
        database.insert(key2);
        

        Key_Id__c key3 = new Key_Id__c();
        key3.Name = 'Case_Temp Stop';
        key3.Id__c = '012N00000008k0EIAQ';
        key3.Type__c = 'RecordType';
        database.insert(key3);
        
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
        
        UOM__c uom = new UOM__c();
        uom.Name = 'Copy Sun';
        uom.Label__c = 'Copy Sun';
        database.insert(uom);
        
        UOM__c uom2 = new UOM__c();
        uom2.Name = 'Copy Weekday';
        uom2.Label__c = 'Copy Weekday';
        database.insert(uom2);
        
        UOM__c uom3 = new UOM__c();
        uom3.Name = 'Copy Sat';
        uom3.Label__c = 'Copy Sat';
        database.insert(uom3);
        
        UOM__c uom4 = new UOM__c();
        uom4.Name = 'Discount-Percentage';
        uom4.Label__c = 'Discount-Percentage';
        database.insert(uom4);
        
        Error_Messages__c error = new Error_Messages__c();
        error.Name = 'Incomplete Inputs';
        //error.Apex_Class_Trigger_Name__c = 
        //error.Description__c = 
        error.Message__c = 'Please complete the required fields';
        //error.Method_Name__c = 
        database.insert(error);
        
        Error_Messages__c error2 = new Error_Messages__c();
        error2.Name = 'Overlapping';
        //error.Apex_Class_Trigger_Name__c = 
        //error.Description__c = 
        error2.Message__c = 'The date inputs overlap with an existing Temp Stop Record.';
        //error.Method_Name__c = 
        database.insert(error2);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        database.insert(con);
        
       
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
        for(zqu__ZProduct__c z : zp){
            if(counter==0){
                z.ProductPlatform__c = 'Print';    
            }
            else{
                z.ProductPlatform__c = 'All-In-One';    
            }
            z.ProductSubType__c = 'Newspaper';
            counter++;  
        }
        database.insert(zp);
        
        counter=0;
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pr : prp){
            pr.zqu__ZProduct__c = zp[counter].Id;
            counter++;   
        }
        database.insert(prp);
        
        counter=0;
        List<Package_Item__c> packItem = TestDataFactory.createPackageItem(2,'Base Product');
        for(Package_Item__c pi : packItem){
            pi.Package__c = pack.Id;
            pi.Product_Rate_Plan__c = prp[counter].Id;
            counter++;
        }
        database.insert(packItem);
        
       
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        
        counter = 0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            if(counter==0){
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = 'Publication';
            }
            else if (counter==1){
                sub.Subscription_Type__c = 'Delivery';
                sub.Subscription_Type_1__c = 'Delivery';
            }
            else{
                sub.Subscription_Type__c = 'Postage';
                sub.Subscription_Type_1__c = 'Postage';
            }
            sub.Zuora__Account__c = acc.id;
            sub.Zuora__Status__c = 'Active';
            //sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number__c = ordLine.Id;
           // sub.Order_Line_Item_Number_1__c = ordLine.Id;
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Name = 'Name';
            sub.Main_Package__c = pack.Id; 
            sub.Qty__c = 3;
            sub.Number_of_Copies__c = 3;
            sub.Number_of_Copies1__c = '3';
            sub.Product_Code__c = 'Product Code0';
            sub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
            sub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
            sub.Term_Length__c = 1;
            sub.Term_Length1__c = '1';
            sub.Main_Package_1__c = pack.id;
            sub.Main_Package__c = pack.id;
            counter++;
        }
        database.insert(subs);
        
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Base_Subscription__c = subs[0].id;
        ord.Order_Type__c = 'Renewal';
        database.insert(ord);
        
        Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
        ordLine.Order__c = ord.Id;
        ordLine.Main_Package_ID__c = pack.Id;
        ordLine.Start_Date__c = subs[0].Zuora__SubscriptionEndDate__c.addDays(1);
        database.insert(ordLine);
        
        
        subs[0].Order_Line_Item_Number__c = ordLine.Id;
        subs[0].Order_Line_Item_Number_1__c = ordLine.Id;
        
        subs[1].Order_Line_Item_Number__c = ordLine.Id;
        subs[1].Order_Line_Item_Number_1__c = ordLine.Id;
        
        subs[2].Order_Line_Item_Number__c = ordLine.Id;
        subs[2].Order_Line_Item_Number_1__c = ordLine.Id;
        database.update(subs);
        
        
        List<Case> cas = TestDataFactory.createCase(2, 'Temp Stop Subscription');
        for(Case c : cas){
            c.Temp_Stop_Sub__c = subs[0].Id;
            c.Status = 'Pending';  
            //c.Sub_Status__c = 'Waiting for Urgent Temp Stop/Restart Approval'; 
            c.AccountId = acc.Id;
        }
        database.insert(cas);
      
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubProductCharge(4);
            spc[0].Zuora__UOM__c = 'Copy Sun';
            spc[0].Zuora__Subscription__c = subs[0].Id; 
            spc[0].Zuora__Price__c = 100;
            spc[0].Zuora__EffectiveStartDate__c = date.today();
            spc[0].Zuora__Model__c = 'Discount-Percentage';
            spc[0].Zuora__ProductName__c = 'discount';
            
            spc[1].Zuora__UOM__c = 'Copy Weekday';
            spc[1].Zuora__Subscription__c = subs[0].Id; 
            spc[1].Zuora__Price__c = 100;
            spc[1].Zuora__EffectiveStartDate__c = date.today();
            spc[1].Zuora__Model__c = 'Discount-Percentage';
            spc[1].Zuora__ProductName__c = 'discount';
            
            spc[2].Zuora__UOM__c =  'Copy Sat';
            spc[2].Zuora__Subscription__c = subs[0].Id; 
            spc[2].Zuora__Price__c = 100;
            spc[2].Zuora__EffectiveStartDate__c = date.today();
            spc[2].Zuora__Model__c = 'Discount-Percentage';
            spc[2].Zuora__ProductName__c = 'discount';
            
            spc[3].Zuora__UOM__c =  null;
            spc[3].Zuora__Subscription__c = subs[0].Id; 
            spc[3].Zuora__Price__c = 100;
            spc[3].Zuora__EffectiveStartDate__c = date.today();
            spc[3].Zuora__Model__c = 'Discount-Percentage';
            spc[3].Zuora__ProductName__c = 'discount';
           
            database.insert(spc);
        
        counter=0;
        List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
        for(zqu__ProductRatePlanCharge__c pr : prpc){
            pr.zqu__ProductRatePlan__c = prp[counter].Id;
            pr.PublicationCode__c = '01';
            counter++;
        }
        database.insert(prpc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        pub.Platform_Type__c = 'Print';
        database.insert(pub);
        
        counter=0;
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        for(Temp_Stop__c t : temp){
            if(counter==0){
                t.Temp_Stop_Date__c = date.today();
            }
            else{
                t.Temp_Stop_Date__c = date.today()+1;
            }
            t.Restart_Date__c = date.today()+2;
            t.Case__c = cas[0].Id;
            t.Qty__c = 3;
            t.Cancelled__C = false;
            counter++;   
        }
        database.insert(temp);
        
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Subscription__c = subs[0].Id;
        subTemp.Temp_Stop__c = temp[0].Id;
        
        Subscription_Temp_Stop__c subTemp1 = new Subscription_Temp_Stop__c();
        subTemp1.Subscription__c = subs[0].Id;
        subTemp1.Temp_Stop__c = temp[1].Id;
        
        List<Subscription_Temp_Stop__c> subTempList = new List<Subscription_Temp_Stop__c>();
        subTempList.add(subTemp);
        subTempList.add(subTemp1);
        database.insert(subTempList);
    
        test.startTest();
            PageReference pageRef = page.TempStopDirect;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('accountId', acc.id);
        
            TempStopDirectController cont = new TempStopDirectController();
            cont.myId = subs[0].Id;
            cont.followUpTask = true;
            cont.subTempStop = subTempList[0];
            TempStopDirectController.SubscriptionWrapper wrapper =  new TempStopDirectController.SubscriptionWrapper();
            wrapper.tp = temp[0];
            wrapper.tp.Restart_Date__c = date.today()+2;
            wrapper.tp.Temp_Stop_Date__c = date.today()+1;
            wrapper.tp.Qty__c = 3;
            wrapper.Id = subs[0].Id;
            wrapper.yearToDate = 12.50;
            wrapper.earliestStartDate = date.today();
            wrapper.subId = subs[0].Id;
            wrapper.OldYearToDateCurrentYear = 5;
            wrapper.OldYearToDateNextYear = 5;
            wrapper.tempStopQty = 2.2;
            wrapper.yearToDateNextYearfromSub = 3;
            List<TempStopDirectController.SubscriptionWrapper> wrapperList =  new List<TempStopDirectController.SubscriptionWrapper>();
            wrapperList.add(wrapper);
            cont.subscriptionResultList = wrapperList; 
            
            TempStopDirectController.SelectedWrapper wrapper2 = new TempStopDirectController.SelectedWrapper();
            wrapper2.tempStopId = temp[0].Id;
            wrapper2.subEndDate = date.today()+5;
            wrapper2.subStartDate = date.today();
            wrapper2.tempStopStatus = '';
            wrapper2.subid = subs[0].Id;
            wrapper2.packageId = pack.Id;
            wrapper2.orderTempStopDays = 10;
            wrapper2.totalIssues = 3;
            wrapper2.yearToDate = 2.5;
            wrapper2.recipientid = con.Id;
            wrapper2.billingid = billAcc.Id;
            wrapper2.id = subs[0].Id;
            wrapper2.subscriptionName = 'Name';
            wrapper2.earliestStartDate = date.today();
            wrapper2.tempStopDate = date.today()+5;
            wrapper2.restartDate = date.today()+10;
            wrapper2.remarks = '';
            wrapper2.tempStopQty = 2.2;
            wrapper2.status = '';
            wrapper2.frequency = '';
            wrapper2.billingAccount = '';
            wrapper2.recipient = '';
            wrapper2.deliverySub = '';
            wrapper2.tempstopDays = 10;
            wrapper2.qty = 3;
            wrapper2.refundEligible = 3;
            wrapper2.totalCredit = 3.3;
            wrapper2.yearToDateCurrentYear = 20;
            wrapper2.yearToDateNextYear = 5;
            wrapper2.oldYearToDateCurrentYear = 5;
            wrapper2.oldYearToDateNextYear = 2;
            wrapper2.tempStopToUpdate = '';
            wrapper2.yearToDateTemp = 3;
            wrapper2.yearToDateNextYearfromSub = 3;
            wrapper2.caseStatusUpdate = '';
            List<TempStopDirectController.SelectedWrapper> wrapperList2 =  new List<TempStopDirectController.SelectedWrapper>();
            wrapperList2.add(wrapper2);
            //cont.tempStopRequestList = wrapperList2;
            
            cont.setSelectedRecords();
            
            cont.myIdUpdate = subs[0].Id;
            cont.updateRequestList = wrapperList2;
            cont.checkDuplicateSubscriptionUpdate();
            cont.subTempStopRecList = subTempList;
            cont.myIdCancel = subs[0].Id;
            cont.cancelRequestList = wrapperList2;
            cont.validateLimitMsg = 'test';
            cont.tempStop = 'test';
            cont.restartDate = string.valueOf(wrapper2.restartDate);
            cont.checkDuplicateSubscriptionCancel();
            cont.thisOrder = new Order__c();
            cont.subfreq = 'Default';
            cont.isPubDay = true;
            cont.wrapperToUpdate = new TempStopDirectController.SubscriptionWrapper();
            cont.wrapperToCancel = new TempStopDirectController.SubscriptionWrapper();
            cont.updateListWrapper = new list<TempStopDirectController.SubscriptionWrapper>();
            cont.cancelListWrapper = new list<TempStopDirectController.SubscriptionWrapper>();
            cont.testCoveragePatch();
          
            
            try{
                cont.removeSubscriptionRecordUpdate();
            }catch(Exception e){}
            
            cont.cancelRequestList = wrapperList2;
        
            try{
                cont.removeSubscriptionRecordCancel();
            }catch(Exception e){}
            
            
            cont.cancel();
            cont.validateLimit();
            cont.getErrorOnLimit();
            cont.getselectedTempStopType();
            cont.setTempStopType(GlobalVariableClass.TS_RADIO_CREATE_TEMP_STOP);
            cont.pendingCaseChecker(subs[0].Id);
            cont.deliverySub(subs[0].Id);
            cont.validateLimit(20.2, 20);
            
            cont.tempStopRequestList = wrapperList2;
            cont.removeSubscriptionRecord();
            
            TempStopDirectController.SubscriptionWrapper wrapper3 =  new TempStopDirectController.SubscriptionWrapper();
            wrapper3.tp = temp[0];
            wrapper3.tp.Restart_Date__c = date.today()+10;
            wrapper3.tp.Temp_Stop_Date__c = date.today()+15;
            wrapper3.tp.Qty__c = 3;
            wrapper3.Id = subs[0].Id;
            wrapper3.yearToDate = 12.50;
            wrapper3.earliestStartDate = date.today();
            wrapper3.subId = subs[0].Id;
            wrapper3.OldYearToDateCurrentYear = 5;
            wrapper3.OldYearToDateNextYear = 5;
            wrapper3.tempStopQty = 2.2;
            wrapper3.yearToDateNextYearfromSub = 3;
            List<TempStopDirectController.SubscriptionWrapper> wrapperList3 =  new List<TempStopDirectController.SubscriptionWrapper>();
            wrapperList3.add(wrapper3);
            cont.myIdUpdate = subs[0].id;
            cont.updateResultList = wrapperList3;
            cont.setUpdateRecords();
        test.stopTest();    
    }    
    
    static testMethod void testTempStopDirectController2() {
        Integer counter=0;
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'EshopDuration';
        key.Id__c = '3';
        key.Type__c = 'Number of Months';
        database.insert(key);
        
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'CRSMDuration';
        key2.Id__c = '6';
        key2.Type__c = 'Number of Months';
        database.insert(key2);
        
        //String tempStop = GlobalVariableClass.TS_SUBJECT;
        //List<RecordType> rt = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name=:tempStop LIMIT 1];
        
        Key_Id__c key3 = new Key_Id__c();
        key3.Name = 'Case_Temp Stop';
        key3.Id__c = '012N00000008k0EIAQ';
        key3.Type__c = 'RecordType';
        database.insert(key3);
        
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
        
        UOM__c uom = new UOM__c();
        uom.Name = 'Copy Sun';
        uom.Label__c = 'Copy Sun';
        database.insert(uom);
        
        UOM__c uom2 = new UOM__c();
        uom2.Name = 'Copy Weekday';
        uom2.Label__c = 'Copy Weekday';
        database.insert(uom2);
        
        UOM__c uom3 = new UOM__c();
        uom3.Name = 'Copy Sat';
        uom3.Label__c = 'Copy Sat';
        database.insert(uom3);
        
        UOM__c uom4 = new UOM__c();
        uom4.Name = 'Discount-Percentage';
        uom4.Label__c = 'Discount-Percentage';
        database.insert(uom4);
        
        Error_Messages__c error = new Error_Messages__c();
        error.Name = 'Incomplete Inputs';
        //error.Apex_Class_Trigger_Name__c = 
        //error.Description__c = 
        error.Message__c = 'Please complete the required fields';
        //error.Method_Name__c = 
        database.insert(error);
        
        Error_Messages__c error2 = new Error_Messages__c();
        error2.Name = 'Overlapping';
        //error.Apex_Class_Trigger_Name__c = 
        //error.Description__c = 
        error2.Message__c = 'The date inputs overlap with an existing Temp Stop Record.';
        //error.Method_Name__c = 
        database.insert(error2);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        database.insert(con);
        
       
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
        for(zqu__ZProduct__c z : zp){
            if(counter==0){
                z.ProductPlatform__c = 'Print';    
            }
            else{
                z.ProductPlatform__c = 'All-In-One';    
            }
            z.ProductSubType__c = 'Newspaper';
            counter++;  
        }
        database.insert(zp);
        
        counter=0;      
        
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pr : prp){
            pr.zqu__ZProduct__c = zp[counter].Id;
            counter++;   
        }
        database.insert(prp);
        
        counter=0;
        List<Package_Item__c> packItem = TestDataFactory.createPackageItem(2,'Base Product');
        for(Package_Item__c pi : packItem){
            pi.Package__c = pack.Id;
            pi.Product_Rate_Plan__c = prp[counter].Id;
            counter++;
        }
        database.insert(packItem);
        
       
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        
        counter = 0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            if(counter==0){
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = 'Publication';
            }
            else if (counter==1){
                sub.Subscription_Type__c = 'Delivery';
                sub.Subscription_Type_1__c = 'Delivery';
            }
            else{
                sub.Subscription_Type__c = 'Postage';
                sub.Subscription_Type_1__c = 'Postage';
            }
            sub.Zuora__Account__c = acc.id;
            sub.Zuora__Status__c = 'Active';
            //sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number__c = ordLine.Id;
           // sub.Order_Line_Item_Number_1__c = ordLine.Id;
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Name = 'Name';
            sub.Main_Package__c = pack.Id; 
            sub.Qty__c = 3;
            sub.Number_of_Copies__c = 3;
            sub.Number_of_Copies1__c = '3';
            sub.Product_Code__c = 'Product Code0';
            sub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
            sub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
            sub.Term_Length__c = 1;
            sub.Term_Length1__c = '1';
            sub.Main_Package_1__c = pack.id;
            sub.Main_Package__c = pack.id;
            counter++;
        }
        database.insert(subs);
        
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Base_Subscription__c = subs[0].id;
        ord.Order_Type__c = 'Renewal';
        database.insert(ord);
        
        Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
        ordLine.Order__c = ord.Id;
        ordLine.Main_Package_ID__c = pack.Id;
        ordLine.Start_Date__c = subs[0].Zuora__SubscriptionEndDate__c.addDays(1);
        database.insert(ordLine);
        
        
        subs[0].Order_Line_Item_Number__c = ordLine.Id;
        subs[0].Order_Line_Item_Number_1__c = ordLine.Id;
        
        subs[1].Order_Line_Item_Number__c = ordLine.Id;
        subs[1].Order_Line_Item_Number_1__c = ordLine.Id;
        
        subs[2].Order_Line_Item_Number__c = ordLine.Id;
        subs[2].Order_Line_Item_Number_1__c = ordLine.Id;
        database.update(subs);
        
        
        List<Case> cas = TestDataFactory.createCase(2, 'Temp Stop Subscription');
        for(Case c : cas){
            c.Temp_Stop_Sub__c = subs[0].Id;
            c.Status = 'Pending';  
            //c.Sub_Status__c = 'Waiting for Urgent Temp Stop/Restart Approval'; 
            c.AccountId = acc.Id;
        }
        database.insert(cas);
      
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubProductCharge(4);
            spc[0].Zuora__UOM__c = 'Copy Sun';
            spc[0].Zuora__Subscription__c = subs[0].Id; 
            spc[0].Zuora__Price__c = 100;
            spc[0].Zuora__EffectiveStartDate__c = date.today();
            spc[0].Zuora__Model__c = 'Discount-Percentage';
            spc[0].Zuora__ProductName__c = 'discount';
            
            spc[1].Zuora__UOM__c = 'Copy Weekday';
            spc[1].Zuora__Subscription__c = subs[0].Id; 
            spc[1].Zuora__Price__c = 100;
            spc[1].Zuora__EffectiveStartDate__c = date.today();
            spc[1].Zuora__Model__c = 'Discount-Percentage';
            spc[1].Zuora__ProductName__c = 'discount';
            
            spc[2].Zuora__UOM__c =  'Copy Sat';
            spc[2].Zuora__Subscription__c = subs[0].Id; 
            spc[2].Zuora__Price__c = 100;
            spc[2].Zuora__EffectiveStartDate__c = date.today();
            spc[2].Zuora__Model__c = 'Discount-Percentage';
            spc[2].Zuora__ProductName__c = 'discount';
            
            spc[3].Zuora__UOM__c =  null;
            spc[3].Zuora__Subscription__c = subs[0].Id; 
            spc[3].Zuora__Price__c = 100;
            spc[3].Zuora__EffectiveStartDate__c = date.today();
            spc[3].Zuora__Model__c = 'Discount-Percentage';
            spc[3].Zuora__ProductName__c = 'discount';
           
            database.insert(spc);
        
        counter=0;
        List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
        for(zqu__ProductRatePlanCharge__c pr : prpc){
            pr.zqu__ProductRatePlan__c = prp[counter].Id;
            pr.PublicationCode__c = '01';
            counter++;
        }
        database.insert(prpc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Platform_Type__c = 'Print';
        database.insert(pub);
        
        counter=0;
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        for(Temp_Stop__c t : temp){
            if(counter==0){
                t.Temp_Stop_Date__c = date.today();
            }
            else{
                t.Temp_Stop_Date__c = date.today()+1;
            }
            t.Restart_Date__c = date.today()+2;
            t.Case__c = cas[0].Id;
            t.Qty__c = 3;
            t.Cancelled__C = false;
            counter++;   
        }
        database.insert(temp);
        
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Subscription__c = subs[0].Id;
        subTemp.Temp_Stop__c = temp[0].Id;
        
        Subscription_Temp_Stop__c subTemp1 = new Subscription_Temp_Stop__c();
        subTemp1.Subscription__c = subs[0].Id;
        subTemp1.Temp_Stop__c = temp[1].Id;
        
        List<Subscription_Temp_Stop__c> subTempList = new List<Subscription_Temp_Stop__c>();
        subTempList.add(subTemp);
        subTempList.add(subTemp1);
        database.insert(subTempList);

        //Start D-4452 02-Apr-2016 Added By S.Puli        
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = cas[0].Id;
        database.insert(tempS);
        
        test.startTest();
            PageReference pageRef = page.TempStopDirect;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('accountId', acc.id);
        
            TempStopDirectController cont = new TempStopDirectController();
            cont.myId = subs[0].Id;
            cont.followUpTask = true;
            cont.subTempStop = subTempList[0];
            TempStopDirectController.SubscriptionWrapper wrapper =  new TempStopDirectController.SubscriptionWrapper();
            wrapper.tp = temp[0];
            wrapper.tp.Restart_Date__c = date.today()+2;
            wrapper.tp.Temp_Stop_Date__c = date.today()+1;
            wrapper.tp.Qty__c = 3;
            wrapper.Id = subs[0].Id;
            wrapper.yearToDate = 12.50;
            wrapper.earliestStartDate = date.today();
            wrapper.subId = subs[0].Id;
            wrapper.OldYearToDateCurrentYear = 5;
            wrapper.OldYearToDateNextYear = 5;
            wrapper.tempStopQty = 2.2;
            wrapper.yearToDateNextYearfromSub = 3;
            List<TempStopDirectController.SubscriptionWrapper> wrapperList =  new List<TempStopDirectController.SubscriptionWrapper>();
            wrapperList.add(wrapper);
            cont.subscriptionResultList = wrapperList; 
            
            TempStopDirectController.SelectedWrapper wrapper2 = new TempStopDirectController.SelectedWrapper();
            wrapper2.tempStopId = temp[0].Id;
            wrapper2.subEndDate = date.today()+100;
            wrapper2.subStartDate = date.today();
            wrapper2.tempStopStatus = '';
            wrapper2.subid = subs[0].Id;
            wrapper2.packageId = pack.Id;
            wrapper2.orderTempStopDays = 10;
            wrapper2.totalIssues = 3;
            wrapper2.yearToDate = 2.5;
            wrapper2.recipientid = con.Id;
            wrapper2.billingid = billAcc.Id;
            wrapper2.id = subs[0].Id;
            wrapper2.subscriptionName = 'Name';
            wrapper2.earliestStartDate = date.today();
            wrapper2.tempStopDate = date.today()+15;
            wrapper2.restartDate = date.today()+20;
            wrapper2.remarks = '';
            wrapper2.tempStopQty = 2.2;
            wrapper2.status = '';
            wrapper2.frequency = '';
            wrapper2.billingAccount = '';
            wrapper2.recipient = '';
            wrapper2.deliverySub = '';
            wrapper2.tempstopDays = 10;
            wrapper2.qty = 3;
            wrapper2.refundEligible = 3;
            wrapper2.totalCredit = 3.3;
            wrapper2.yearToDateCurrentYear = 20;
            wrapper2.yearToDateNextYear = 5;
            wrapper2.oldYearToDateCurrentYear = 5;
            wrapper2.oldYearToDateNextYear = 2;
            wrapper2.tempStopToUpdate = tempS.Id;
            wrapper2.yearToDateTemp = 3;
            wrapper2.yearToDateNextYearfromSub = 3;
            wrapper2.caseStatusUpdate = '';
            List<TempStopDirectController.SelectedWrapper> wrapperList2 =  new List<TempStopDirectController.SelectedWrapper>();
            wrapperList2.add(wrapper2);
            //cont.tempStopRequestList = wrapperList2;
            
            cont.setSelectedRecords();
            
            cont.myIdUpdate = subs[0].Id;
            cont.updateRequestList = wrapperList2;
            cont.checkDuplicateSubscriptionUpdate();
            cont.subTempStopRecList = subTempList;
            cont.myIdCancel = subs[0].Id;
            cont.cancelRequestList = wrapperList2;
            cont.checkDuplicateSubscriptionCancel();
            
          
            
            try{
                cont.removeSubscriptionRecordUpdate();
            }catch(Exception e){}
            
            cont.cancelRequestList = wrapperList2;
        
            try{
                cont.removeSubscriptionRecordCancel();
            }catch(Exception e){}
            
            
            //cont.cancel();
            //cont.validateLimit();
            //cont.getErrorOnLimit();
            //cont.getselectedTempStopType();
            cont.setTempStopType(GlobalVariableClass.TS_RADIO_UPDATE_TEMP_STOP);
            cont.pendingCaseChecker(subs[0].Id);
            cont.deliverySub(subs[0].Id);
            cont.validateLimit(20.2, 20);
            //List<Case> casList = cont.createRecordsOnSave();
            cont.tempStopRequestList = wrapperList2;
            cont.removeSubscriptionRecord();
            cont.submit();
            
            List<TempStopDirectController.SubscriptionWrapper> wrapperList3 =  new List<TempStopDirectController.SubscriptionWrapper>();
            wrapperList3.add(wrapper);
            cont.myIdUpdate = subs[0].id;
            cont.updateResultList = wrapperList3;
            cont.setUpdateRecords();
        test.stopTest();    
    }
    
    static testMethod void testTempStopDirectController3() {
        Integer counter=0;
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'EshopDuration';
        key.Id__c = '3';
        key.Type__c = 'Number of Months';
        database.insert(key);
        
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'CRSMDuration';
        key2.Id__c = '6';
        key2.Type__c = 'Number of Months';
        database.insert(key2);
        
        //String tempStop = GlobalVariableClass.TS_SUBJECT;
        //List<RecordType> rt = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name=:tempStop LIMIT 1];
        
        Key_Id__c key3 = new Key_Id__c();
        key3.Name = 'Case_Temp Stop';
        key3.Id__c = '012N00000008k0EIAQ';
        key3.Type__c = 'RecordType';
        database.insert(key3);
        
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
        
        UOM__c uom = new UOM__c();
        uom.Name = 'Copy Sun';
        uom.Label__c = 'Copy Sun';
        database.insert(uom);
        
        UOM__c uom2 = new UOM__c();
        uom2.Name = 'Copy Weekday';
        uom2.Label__c = 'Copy Weekday';
        database.insert(uom2);
        
        UOM__c uom3 = new UOM__c();
        uom3.Name = 'Copy Sat';
        uom3.Label__c = 'Copy Sat';
        database.insert(uom3);
        
        UOM__c uom4 = new UOM__c();
        uom4.Name = 'Discount-Percentage';
        uom4.Label__c = 'Discount-Percentage';
        database.insert(uom4);
        
        Error_Messages__c error = new Error_Messages__c();
        error.Name = 'Incomplete Inputs';
        error.Message__c = 'Please complete the required fields';

        Error_Messages__c error3 = new Error_Messages__c();
        error3.Name = 'Validate Restart Date 5';
        error3.Message__c = 'Please complete the required fields';
        
        Error_Messages__c error2 = new Error_Messages__c();
        error2.Name = 'Overlapping';
        error2.Message__c = 'The date inputs overlap with an existing Temp Stop Record.';
        database.insert(new list<Error_Messages__c>{error, error2, error3});
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        database.insert(con);
        
       
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        counter=0;
        List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
        for(zqu__ZProduct__c z : zp){
            if(counter==0){
                z.ProductPlatform__c = 'Print';    
            }
            else{
                z.ProductPlatform__c = 'All-In-One';    
            }
            z.ProductSubType__c = 'Newspaper';
            counter++;  
        }
        database.insert(zp);
        
        counter=0;      
        
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c pr : prp){
            pr.zqu__ZProduct__c = zp[counter].Id;
            counter++;   
        }
        database.insert(prp);
        
        counter=0;
        List<Package_Item__c> packItem = TestDataFactory.createPackageItem(2,'Base Product');
        for(Package_Item__c pi : packItem){
            pi.Package__c = pack.Id;
            pi.Product_Rate_Plan__c = prp[counter].Id;
            counter++;
        }
        database.insert(packItem);
        
       
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.id;
        database.insert(billAcc);
        
        counter = 0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(3);
        for(Zuora__Subscription__c sub : subs){
            if(counter==0){
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = 'Publication';
            }
            else if (counter==1){
                sub.Subscription_Type__c = 'Delivery';
                sub.Subscription_Type_1__c = 'Delivery';
            }
            else{
                sub.Subscription_Type__c = 'Postage';
                sub.Subscription_Type_1__c = 'Postage';
            }
            sub.Zuora__Account__c = acc.id;
            sub.Zuora__Status__c = 'Active';
            //sub.Zuora__SubscriptionEndDate__c = date.today()+10;
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Order_Line_Item_Number__c = ordLine.Id;
           // sub.Order_Line_Item_Number_1__c = ordLine.Id;
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Name = 'Name';
            sub.Main_Package__c = pack.Id; 
            sub.Qty__c = 3;
            sub.Number_of_Copies__c = 3;
            sub.Number_of_Copies1__c = '3';
            sub.Product_Code__c = 'Product Code0';
            sub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
            sub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
            sub.Term_Length__c = 1;
            sub.Term_Length1__c = '1';
            sub.Main_Package_1__c = pack.id;
            sub.Main_Package__c = pack.id;
            counter++;
        }
        database.insert(subs);
        
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Base_Subscription__c = subs[0].id;
        ord.Order_Type__c = 'Renewal';
        database.insert(ord);
        
        Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
        ordLine.Order__c = ord.Id;
        ordLine.Main_Package_ID__c = pack.Id;
        ordLine.Start_Date__c = subs[0].Zuora__SubscriptionEndDate__c.addDays(1);
        database.insert(ordLine);
        
        
        subs[0].Order_Line_Item_Number__c = ordLine.Id;
        subs[0].Order_Line_Item_Number_1__c = ordLine.Id;
        
        subs[1].Order_Line_Item_Number__c = ordLine.Id;
        subs[1].Order_Line_Item_Number_1__c = ordLine.Id;
        
        subs[2].Order_Line_Item_Number__c = ordLine.Id;
        subs[2].Order_Line_Item_Number_1__c = ordLine.Id;
        database.update(subs);
        
        
        List<Case> cas = TestDataFactory.createCase(2, 'Temp Stop Subscription');
        for(Case c : cas){
            c.Temp_Stop_Sub__c = subs[0].Id;
            c.Status = 'Pending';  
            //c.Sub_Status__c = 'Waiting for Urgent Temp Stop/Restart Approval'; 
            c.AccountId = acc.Id;
        }
        database.insert(cas);
      
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubProductCharge(4);
            spc[0].Zuora__UOM__c = 'Copy Sun';
            spc[0].Zuora__Subscription__c = subs[0].Id; 
            spc[0].Zuora__Price__c = 100;
            spc[0].Zuora__EffectiveStartDate__c = date.today();
            spc[0].Zuora__Model__c = 'Discount-Percentage';
            spc[0].Zuora__ProductName__c = 'discount';
            
            spc[1].Zuora__UOM__c = 'Copy Weekday';
            spc[1].Zuora__Subscription__c = subs[0].Id; 
            spc[1].Zuora__Price__c = 100;
            spc[1].Zuora__EffectiveStartDate__c = date.today();
            spc[1].Zuora__Model__c = 'Discount-Percentage';
            spc[1].Zuora__ProductName__c = 'discount';
            
            spc[2].Zuora__UOM__c =  'Copy Sat';
            spc[2].Zuora__Subscription__c = subs[0].Id; 
            spc[2].Zuora__Price__c = 100;
            spc[2].Zuora__EffectiveStartDate__c = date.today();
            spc[2].Zuora__Model__c = 'Discount-Percentage';
            spc[2].Zuora__ProductName__c = 'discount';
            
            spc[3].Zuora__UOM__c =  null;
            spc[3].Zuora__Subscription__c = subs[0].Id; 
            spc[3].Zuora__Price__c = 100;
            spc[3].Zuora__EffectiveStartDate__c = date.today();
            spc[3].Zuora__Model__c = 'Discount-Percentage';
            spc[3].Zuora__ProductName__c = 'discount';
           
            database.insert(spc);
        
        counter=0;
        List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
        for(zqu__ProductRatePlanCharge__c pr : prpc){
            pr.zqu__ProductRatePlan__c = prp[counter].Id;
            pr.PublicationCode__c = '01';
            counter++;
        }
        database.insert(prpc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Platform_Type__c = 'Print';
        database.insert(pub);
        
        counter=0;
        List<Temp_Stop__c> temp = TestDataFactory.createTempStop(2);
        for(Temp_Stop__c t : temp){
            if(counter==0){
                t.Temp_Stop_Date__c = date.today();
            }
            else{
                t.Temp_Stop_Date__c = date.today()+1;
            }
            t.Restart_Date__c = date.today()+2;
            t.Case__c = cas[0].Id;
            t.Qty__c = 3;
            t.Cancelled__C = false;
            counter++;   
        }
        database.insert(temp);
        
        Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
        subTemp.Subscription__c = subs[0].Id;
        subTemp.Temp_Stop__c = temp[0].Id;
        
        Subscription_Temp_Stop__c subTemp1 = new Subscription_Temp_Stop__c();
        subTemp1.Subscription__c = subs[0].Id;
        subTemp1.Temp_Stop__c = temp[1].Id;
        
        List<Subscription_Temp_Stop__c> subTempList = new List<Subscription_Temp_Stop__c>();
        subTempList.add(subTemp);
        subTempList.add(subTemp1);
        database.insert(subTempList);

        //Start D-4452 02-Apr-2016 Added By S.Puli        
        
        Temp_Stop__c tempS = TestDataFactory.createTempStop(1)[0];
        tempS.Order__c = ord.Id;
        tempS.Case__c = cas[0].Id;
        database.insert(tempS);
        
        test.startTest();
            PageReference pageRef = page.TempStopDirect;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('accountId', acc.id);
        
            TempStopDirectController cont = new TempStopDirectController();
            cont.myId = subs[0].Id;
            cont.followUpTask = true;
            cont.subTempStop = subTempList[0];
            TempStopDirectController.SubscriptionWrapper wrapper =  new TempStopDirectController.SubscriptionWrapper();
            wrapper.tp = temp[0];
            wrapper.tp.Restart_Date__c = date.today()+15;
            wrapper.tp.Temp_Stop_Date__c = date.today()+10;
            wrapper.tp.Qty__c = 3;
            wrapper.Id = subs[0].Id;
            wrapper.yearToDate = 12.50;
            wrapper.earliestStartDate = date.today();
            wrapper.subId = subs[0].Id;
            wrapper.OldYearToDateCurrentYear = 5;
            wrapper.OldYearToDateNextYear = 5;
            wrapper.tempStopQty = 2.2;
            wrapper.yearToDateNextYearfromSub = 3;
            List<TempStopDirectController.SubscriptionWrapper> wrapperList =  new List<TempStopDirectController.SubscriptionWrapper>();
            wrapperList.add(wrapper);
            cont.subscriptionResultList = wrapperList; 
            
            TempStopDirectController.SelectedWrapper wrapper2 = new TempStopDirectController.SelectedWrapper();
            wrapper2.tempStopId = temp[0].Id;
            wrapper2.subEndDate = date.today()+100;
            wrapper2.subStartDate = date.today();
            wrapper2.tempStopStatus = '';
            wrapper2.subid = subs[0].Id;
            wrapper2.packageId = pack.Id;
            wrapper2.orderTempStopDays = 10;
            wrapper2.totalIssues = 3;
            wrapper2.yearToDate = 2.5;
            wrapper2.recipientid = con.Id;
            wrapper2.billingid = billAcc.Id;
            wrapper2.id = subs[0].Id;
            wrapper2.subscriptionName = 'Name';
            wrapper2.earliestStartDate = date.today();
            wrapper2.tempStopDate = date.today()+15;
            wrapper2.restartDate = date.today()+20;
            wrapper2.remarks = '';
            wrapper2.tempStopQty = 2.2;
            wrapper2.status = '';
            wrapper2.frequency = '';
            wrapper2.billingAccount = '';
            wrapper2.recipient = '';
            wrapper2.deliverySub = '';
            wrapper2.tempstopDays = 10;
            wrapper2.qty = 3;
            wrapper2.refundEligible = 3;
            wrapper2.totalCredit = 3.3;
            wrapper2.yearToDateCurrentYear = 20;
            wrapper2.yearToDateNextYear = 5;
            wrapper2.oldYearToDateCurrentYear = 5;
            wrapper2.oldYearToDateNextYear = 2;
            wrapper2.tempStopToUpdate = tempS.Id;
            wrapper2.yearToDateTemp = 3;
            wrapper2.yearToDateNextYearfromSub = 3;
            wrapper2.caseStatusUpdate = '';
            List<TempStopDirectController.SelectedWrapper> wrapperList2 =  new List<TempStopDirectController.SelectedWrapper>();
            wrapperList2.add(wrapper2);
            //cont.tempStopRequestList = wrapperList2;
            
            cont.setSelectedRecords();
            
            cont.myIdUpdate = subs[0].Id;
            cont.updateRequestList = wrapperList2;
            cont.checkDuplicateSubscriptionUpdate();
            cont.subTempStopRecList = subTempList;
            cont.myIdCancel = subs[0].Id;
            cont.cancelRequestList = wrapperList2;
            cont.checkDuplicateSubscriptionCancel();
            
            try{
                cont.removeSubscriptionRecordUpdate();
            }catch(Exception e){}
            
            cont.cancelRequestList = wrapperList2;
        
            try{
                cont.removeSubscriptionRecordCancel();
            }catch(Exception e){}
            
            
            //cont.cancel();
            //cont.validateLimit();
            //cont.getErrorOnLimit();
            //cont.getselectedTempStopType();
            cont.setTempStopType(GlobalVariableClass.TS_RADIO_CANCEL_TEMP_STOP);
            cont.pendingCaseChecker(subs[0].Id);
            cont.deliverySub(subs[0].Id);
            cont.validateLimit(20.2, 20);
            //List<Case> casList = cont.createRecordsOnSave();
            cont.tempStopRequestList = wrapperList2;
            cont.removeSubscriptionRecord();
            cont.submit();
            
            List<TempStopDirectController.SubscriptionWrapper> wrapperList3 =  new List<TempStopDirectController.SubscriptionWrapper>();
            wrapperList3.add(wrapper);
            cont.myIdUpdate = subs[0].id;
            cont.updateResultList = wrapperList3;
            cont.setUpdateRecords();
            cont.setCancelRecords();
        test.stopTest();    
    }
}