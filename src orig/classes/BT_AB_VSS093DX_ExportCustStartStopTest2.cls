@isTest(SeeAllData = False)
private class BT_AB_VSS093DX_ExportCustStartStopTest2 {

    static void defaultCustomSetting() {
    
        List<Key_Id__c> keyIds = new List<Key_Id__c>();
        List<Other__c>  others = new List<Other__c>();
        
        String[] keyIdNameArray = new String[]
        {
            'Account_Direct Individual',
            'Account_Vendor Subscriber',
            'Address_Local',
            'Contact_Customer Contact',
            'Package Item_Base Product',
            'Package Item_Bundle Product',
            'Package Item_Discount',
            'Package Item_Extension Discount',
            'UpdateARMSInfoResultId',
            'NEXT_RECIPIENT_NUMBER',
            'Account_Direct Corporate',
            'Account_Direct SPH Inter-Division',
            'Case_Change of Subscription',
            'Case_Start Sub',
            'Case_Stop',
            'Case_Temp Stop',
            'CSO Asst. Manager/ Manager Queue',
            'CSO TL Queue',
            'Head of Customer Service Queue',
            'Case Renewal of Subscription',
            'Case_Change in Address',
            'Complaint_Newspaper',
            'Case_Complaint Magazine',
            'SubTypeDel',
            'SubTypePostage',
            'SubTypePub'
        };

        String[] keyIdIdcArray = new String[]
        {
            '012N00000008ic1IAA',
            '012N00000008ibwIAA',
            '012N00000008idiIAA',
            '012N00000008r43IAA',
            '012N00000008jCOIAY',
            '012N00000008jCdIAI',
            '012N00000008jCTIAY',
            '012N00000008jCsIAI',
            '123vd',
            '123457177',
            '012N00000008ic6IAA',
            '012N00000008icBIAQ',
            '012N00000008lpwIAA',
            '012N00000008jvYIAQ',
            '012N00000008k09IAA',
            '012N00000008k0EIAQ',
            '00GN0000000mMcJ',
            '00GN0000000lUNp',
            '00GN0000000mUXw',
            '012N00000008lqG',
            '012N00000008lAoIAI',
            '012N00000008kI8IAI',
            '012N00000008kIDIAY',
            'Delivery',
            'Postage',
            'Publication'
        };
        
        String[] keyIdTypeArray = new String[]
        {
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Id',
            'Number',
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Id',
            'Id',
            'Id',
            'Record Type',
            'Record Type',
            'Record Type',
            'Record Type',
            'Name',
            'Name',
            'Name'
        };

        
//        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
//        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
//        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        /*
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
                Key_Id__c keyId = new Key_Id__c();
                keyId.Name    = keyIdNameArray[i];
                keyId.Id__c   = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
                keyIds.add(keyId);
        }
        insert keyIds;
        */
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print'};
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
                Other__c otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
                others.add(otherC);
        }
        insert others;
        
        //Cir_Planner_Schedule__c
        List<Cir_Planner_Schedule__c> cpsList = new List<Cir_Planner_Schedule__c>{
            new Cir_Planner_Schedule__c(Name='CIR Plan Schedule', Mon_Fri_End_Time__c=Date.today(),
                Mon_Fri_Start_Time__c=Date.today(),Sat_PH_End_Time__c=Date.today(),Sat_PH_Start_Time__c=Date.today(),
                Sun_End_Time__c=Date.today(),Sun_Start_Time__c=Date.today())
        };
        Database.insert(cpsList);        
        
        //Other__c
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'),
            
            new Other__c(Name='Zero Charge Amount',     Value__c='Zero'),
            new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB'),
            new Other__c(Name='APT DELIVERY CHARGE',    Value__c='APT'),
            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='LANDED')
        };        
        Database.insert(otherList);
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
            batchInterfaceSetting.Name = 'Endpoint Delegator';
            batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
    }
    /*
    static testMethod void testBT_AB_VSS093DX_ExportCustomerStartStop01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            
            //Test Data
            defaultCustomSetting();
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'PubC';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub.Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub.Publication_Type__c = 'N';
            pub.Platform_Type__c = 'Print';
            insert pub;
            
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
           
           
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            Test.startTest();
            
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            Recordtype recType = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Change_of_Address'];                     
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            cas.Publication__c = pub.id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            cas.RecordTypeId = recType.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Change of Address'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            //cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
            
            tempStop.Case__c = cas.id;
            update tempStop;
            
            Case caseType = [SELECT Id, LastModifiedDate FROM Case LIMIT 1]; 
            Datetime caseTypeDate = caseType.LastModifiedDate;
            
            String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('VSS093DX');            
            DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate);
            DateTime cutOffStart = cutOffEnd.addDays(-1);  
            DateTime dtLastBatchRunDate = DateUtility.getOverrideDate('VSS093DX');         
            DateTime newCutOffStart = cutOffStart;
            
            System.Debug('111cas.LastModifiedDate' + cas.LastModifiedDate);
            System.Debug('111newCutOffStart' + newCutOffStart);
            System.Debug('111cutOffStart' + cutOffStart);
            System.Debug('111cutOffEnd' + cutOffEnd);
            //System.Debuf('111LastModifiedDate' + LastModifiedDate);
            System.Debug('111cas.Status' + cas.Status);
            System.Debug('111RecordType.DeveloperName' + recType.DeveloperName);
            System.Debug('111tempStop.Cancelled__c' + tempStop.Cancelled__c);
            System.Debug('111cas.Sub_Status__c' + cas.Sub_Status__c);
            System.Debug('111cas.Temp_Stop_Type__c' + cas.Temp_Stop_Type__c);
            System.Debug('LastmodifiedDate' + caseTypeDate );
        
       
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'CODE1';
            subRecs.Qty__c = 5;
            subRecs.Frequency__c = 'Mon - Fri';
            subRecs.Frequency_1__c = 'Mon - Fri';
            subRecs.Vendor_1__c = acc.id;
            
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;
          
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
            
            Address_Assignment__c addAssign = new Address_Assignment__c();
            addAssign.Case__c = cas.id;
            addAssign.Address__c = addressRec.id;
            addAssign.Contact__c = con.id;
            addAssign.Effective_Date__c = date.Today();
            addAssign.Active__c = TRUE;
            insert addAssign;
            
             List<Subscription_Vendor__c> subVen  = TestDataFactory.createSubscriptionVendor(1);
            subVen[0].Account__c = acc.id;
            subVen[0].Vendor__c = acc.id;
            subVen[0].Recipient__c = con.id;
            subVen[0].Subscription_Start_Date__c = date.Today();
            subVen[0].Subscription_Stop_Date__c = date.Today() +60;
            subVen[0].Status__c = 'Active';
            insert subVen;
            
            List<Case_Vendor_Subscription__c> CaseVenList= TestDataFactory.createCaseVendorSub(2);
            For(Case_Vendor_Subscription__c CaseVen : CaseVenList ){
                CaseVen.Address__c = addressRec.id;
                CaseVen.Account__c = acc.id;
                CaseVen.Case__c = cas.id;
                CaseVen.Subscription_Vendor__c = subVen[0].id; 
                CaseVen.Complaint_From__c = date.Today() -30;
                CaseVen.Complaint_To__c = date.Today() -10;      
                CaseVen.Complaint_Copies__c  = 5;  
            }
            insert CaseVenList;
            
            
           
            List<Subscription_Vendor_Publication__c> CasePubList = TestDataFactory.createVendorPublication(2);
            for(Subscription_Vendor_Publication__c CasePub : CasePubList){
                CasePub.Account__c = acc.id;
                CasePub.Subscription_Vendor__c =  subVen[0].id;
                CasePub.Publication__c = pub.id;
            }
           
            insert CasePubList ;
            
                     
            Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Case__c = cas.id;
            caseSub.Account__C = acc.id;
            caseSub.Address__c = addressRec.id;
            caseSub.isComplaint__c = TRUE;
            caseSub.Subscription__c = subRecs.id;
            caseSub.Complaint_From__c = date.Today () -30;
            caseSub.Complaint_To__c = date.Today () -10;
            caseSub.Complaint_Copies__c = 5;
            insert caseSub;
            
            
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch,200);
            
            System.assertNotEquals(null, batchprocessid);
            
            Test.stopTest();
        
        }
      }
      */
        static testMethod void testtempStop() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
           
            //Test Data
            defaultCustomSetting();
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            /*zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;

            zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
            zprpc.PublicationCode__c = 'PubC';
            insert zprpc;
             
            //Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            */
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Publication_Code__c = 'PubC';
            pub[0].Published_Days__c = 'YYYYYYY';
            pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub[0].Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub[0].Publication_Type__c = 'N';
            pub[0].Platform_Type__c = 'Print';
            insert pub;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
          /*  
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'PubC';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub.Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub.Publication_Type__c = 'N';
            pub.Platform_Type__c = 'Print';
            insert pub;
          */  
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            
            
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            Recordtype recType2 = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Temp_Stop_Subscription'];                     
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            cas.Publication__c = pub[0].id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            cas.RecordTypeId = recType2.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Temp Stop'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            //cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
            
            
            /*
            Case caseType = [SELECT Id, LastModifiedDate FROM Case LIMIT 1]; 
            Datetime caseTypeDate = caseType.LastModifiedDate;
            
            String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('VSS093DX');            
            DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate);
            DateTime cutOffStart = cutOffEnd.addDays(-1);  
            DateTime dtLastBatchRunDate = DateUtility.getOverrideDate('VSS093DX');         
            DateTime newCutOffStart = cutOffStart;
            
            System.Debug('111cas.LastModifiedDate' + cas.LastModifiedDate);
            System.Debug('111newCutOffStart' + newCutOffStart);
            System.Debug('111cutOffStart' + cutOffStart);
            System.Debug('111cutOffEnd' + cutOffEnd);
            //System.Debuf('111LastModifiedDate' + LastModifiedDate);
            System.Debug('111cas.Status' + cas.Status);
            System.Debug('111RecordType.DeveloperName' + recType.DeveloperName);
            System.Debug('111tempStop.Cancelled__c' + tempStop.Cancelled__c);
            System.Debug('111cas.Sub_Status__c' + cas.Sub_Status__c);
            System.Debug('111cas.Temp_Stop_Type__c' + cas.Temp_Stop_Type__c);
            System.Debug('LastmodifiedDate' + caseTypeDate );
            */
           
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'CODE1';
            subRecs.Qty__c = 5;
            subRecs.Frequency__c = 'Mon - Fri';
            subRecs.Frequency_1__c = 'Mon - Fri';
            subRecs.Vendor_1__c = acc.id;
            Test.startTest();
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;
               
          /*
           List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
            //caseSub[0].Case__c = cas.id;
            caseSub[0].Account__C = acc.id;
            caseSub[0].Address__c = addressRec.id;
            caseSub[0].isComplaint__c = FALSE;
            caseSub[0].Subscription__c = subRecs.id;
            caseSub[0].Complaint_From__c = date.Today () -30;
            caseSub[0].Complaint_To__c = date.Today () -10;
            caseSub[0].Complaint_Copies__c = 5;
            insert caseSub;
            */
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
           
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();
            
           
            List<Subscription_Vendor__c> subVen  = TestDataFactory.createSubscriptionVendor(1);
            subVen[0].Account__c = acc.id;
            subVen[0].Vendor__c = acc.id;
            subVen[0].Recipient__c = con.id;
            subVen[0].Subscription_Start_Date__c = date.Today();
            subVen[0].Subscription_Stop_Date__c = date.Today() +60;
            subVen[0].Status__c = 'Active';
            insert subVen;
            
            List<Case_Vendor_Subscription__c> CaseVenList= TestDataFactory.createCaseVendorSub(2);
            For(Case_Vendor_Subscription__c CaseVen : CaseVenList ){
                CaseVen.Address__c = addressRec.id;
                CaseVen.Account__c = acc.id;
                CaseVen.Case__c = cas.id;
                CaseVen.Subscription_Vendor__c = subVen[0].id; 
                CaseVen.Complaint_From__c = date.Today() -30;
                CaseVen.Complaint_To__c = date.Today() -10;      
                CaseVen.Complaint_Copies__c  = 5;  
            }
            insert CaseVenList;
            
           
             List<Subscription_Vendor_Publication__c> CasePubList = TestDataFactory.createVendorPublication(2);
            for(Subscription_Vendor_Publication__c CasePub : CasePubList){
                CasePub.Account__c = acc.id;
                CasePub.Subscription_Vendor__c =  subVen[0].id;
                CasePub.Publication__c = pub[0].id;
            }
           
            insert CasePubList ;
            
            
            Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Case__c = cas.id;
            caseSub.Account__C = acc.id;
            caseSub.Address__c = addressRec.id;
            caseSub.isComplaint__c = TRUE;
            caseSub.Subscription__c = subRecs.id;
            caseSub.Complaint_From__c = date.Today () -30;
            caseSub.Complaint_To__c = date.Today () -10;
            caseSub.Complaint_Copies__c = 5;
            
            insert caseSub;
            
            BT_AB_VSS093DX_ExportCustomerStartStop batch2 = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch2,200);
            
            System.assertNotEquals(null, batchprocessid);
            
            Test.stopTest();
        
        }
       }
       
       static testMethod void testtempStop2() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            
            //Test Data
            defaultCustomSetting();
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            /*zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;

            zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
            zprpc.PublicationCode__c = 'PubC';
            insert zprpc;
             
            //Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            */
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Publication_Code__c = 'PubC';
            pub[0].Published_Days__c = 'YYYYYYY';
            pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub[0].Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub[0].Publication_Type__c = 'N';
            pub[0].Platform_Type__c = 'Print';
            insert pub;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
          /*  
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'PubC';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub.Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub.Publication_Type__c = 'N';
            pub.Platform_Type__c = 'Print';
            insert pub;
          */  
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            
            
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            Recordtype recType2 = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Temp_Stop_Subscription'];                     
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            cas.Publication__c = pub[0].id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            cas.RecordTypeId = recType2.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Temp Stop'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            //cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
            
            
            /*
            Case caseType = [SELECT Id, LastModifiedDate FROM Case LIMIT 1]; 
            Datetime caseTypeDate = caseType.LastModifiedDate;
            
            String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('VSS093DX');            
            DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate);
            DateTime cutOffStart = cutOffEnd.addDays(-1);  
            DateTime dtLastBatchRunDate = DateUtility.getOverrideDate('VSS093DX');         
            DateTime newCutOffStart = cutOffStart;
            
            System.Debug('111cas.LastModifiedDate' + cas.LastModifiedDate);
            System.Debug('111newCutOffStart' + newCutOffStart);
            System.Debug('111cutOffStart' + cutOffStart);
            System.Debug('111cutOffEnd' + cutOffEnd);
            //System.Debuf('111LastModifiedDate' + LastModifiedDate);
            System.Debug('111cas.Status' + cas.Status);
            System.Debug('111RecordType.DeveloperName' + recType.DeveloperName);
            System.Debug('111tempStop.Cancelled__c' + tempStop.Cancelled__c);
            System.Debug('111cas.Sub_Status__c' + cas.Sub_Status__c);
            System.Debug('111cas.Temp_Stop_Type__c' + cas.Temp_Stop_Type__c);
            System.Debug('LastmodifiedDate' + caseTypeDate );
            */
           
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'CODE1';
            subRecs.Qty__c = 5;
            subRecs.Frequency__c = 'Mon - Fri';
            subRecs.Frequency_1__c = 'Mon - Fri';
            subRecs.Vendor_1__c = acc.id;
            Test.startTest();
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;
               
          /*
           List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
            //caseSub[0].Case__c = cas.id;
            caseSub[0].Account__C = acc.id;
            caseSub[0].Address__c = addressRec.id;
            caseSub[0].isComplaint__c = FALSE;
            caseSub[0].Subscription__c = subRecs.id;
            caseSub[0].Complaint_From__c = date.Today () -30;
            caseSub[0].Complaint_To__c = date.Today () -10;
            caseSub[0].Complaint_Copies__c = 5;
            insert caseSub;
            */
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
           
            tempStop.Case__c = cas.id;
            update tempStop;
            cas.Temp_Stop__c = tempStop.id;
            update cas;
            
           
            List<Subscription_Vendor__c> subVen  = TestDataFactory.createSubscriptionVendor(1);
            subVen[0].Account__c = acc.id;
            subVen[0].Vendor__c = acc.id;
            subVen[0].Recipient__c = con.id;
            subVen[0].Subscription_Start_Date__c = date.Today();
            subVen[0].Subscription_Stop_Date__c = date.Today() +60;
            subVen[0].Status__c = 'Active';
            insert subVen;
            
            List<Case_Vendor_Subscription__c> CaseVenList= TestDataFactory.createCaseVendorSub(2);
            For(Case_Vendor_Subscription__c CaseVen : CaseVenList ){
                CaseVen.Address__c = addressRec.id;
                CaseVen.Account__c = acc.id;
                CaseVen.Case__c = cas.id;
                CaseVen.Subscription_Vendor__c = subVen[0].id; 
                CaseVen.Complaint_From__c = date.Today() -30;
                CaseVen.Complaint_To__c = date.Today() -10;      
                CaseVen.Complaint_Copies__c  = 5;  
            }
            insert CaseVenList;
            
           
             List<Subscription_Vendor_Publication__c> CasePubList = TestDataFactory.createVendorPublication(2);
            for(Subscription_Vendor_Publication__c CasePub : CasePubList){
                CasePub.Account__c = acc.id;
                CasePub.Subscription_Vendor__c =  subVen[0].id;
                CasePub.Publication__c = pub[0].id;
            }
           
            insert CasePubList ;
            
            
            Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Case__c = cas.id;
            caseSub.Account__C = acc.id;
            caseSub.Address__c = addressRec.id;
            caseSub.isComplaint__c = TRUE;
            caseSub.Subscription__c = subRecs.id;
            caseSub.Complaint_From__c = date.Today () -30;
            caseSub.Complaint_To__c = date.Today () -10;
            caseSub.Complaint_Copies__c = 5;
            caseSub.Subscription__c = subRecs.id;
            insert caseSub;
            
            BT_AB_VSS093DX_ExportCustomerStartStop batch2 = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch2,200);
            
            System.assertNotEquals(null, batchprocessid);
            
            Test.stopTest();
        
        }
       }
       
       static testMethod void testtempStop2b() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
             Database.BatchableContext BC;
            //Test Data
            defaultCustomSetting();
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            /*zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;

            zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
            zprpc.PublicationCode__c = 'PubC';
            insert zprpc;
             
            //Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            */
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Publication_Code__c = 'PubC';
            pub[0].Published_Days__c = 'YYYYYYY';
            pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub[0].Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub[0].Publication_Type__c = 'N';
            pub[0].Platform_Type__c = 'Print';
            insert pub;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
          /*  
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'PubC';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub.Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub.Publication_Type__c = 'N';
            pub.Platform_Type__c = 'Print';
            insert pub;
          */  
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            
            
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            //Recordtype recType2 = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Temp_Stop_Subscription']; 
                   
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            //cas.Status = 'Closed';
            cas.Publication__c = pub[0].id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            //cas.RecordTypeId = recType2.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Change of Address'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            //cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
            
            
            /*
            Case caseType = [SELECT Id, LastModifiedDate FROM Case LIMIT 1]; 
            Datetime caseTypeDate = caseType.LastModifiedDate;
            
            String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('VSS093DX');            
            DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate);
            DateTime cutOffStart = cutOffEnd.addDays(-1);  
            DateTime dtLastBatchRunDate = DateUtility.getOverrideDate('VSS093DX');         
            DateTime newCutOffStart = cutOffStart;
            
            System.Debug('111cas.LastModifiedDate' + cas.LastModifiedDate);
            System.Debug('111newCutOffStart' + newCutOffStart);
            System.Debug('111cutOffStart' + cutOffStart);
            System.Debug('111cutOffEnd' + cutOffEnd);
            //System.Debuf('111LastModifiedDate' + LastModifiedDate);
            System.Debug('111cas.Status' + cas.Status);
            System.Debug('111RecordType.DeveloperName' + recType.DeveloperName);
            System.Debug('111tempStop.Cancelled__c' + tempStop.Cancelled__c);
            System.Debug('111cas.Sub_Status__c' + cas.Sub_Status__c);
            System.Debug('111cas.Temp_Stop_Type__c' + cas.Temp_Stop_Type__c);
            System.Debug('LastmodifiedDate' + caseTypeDate );
            */
           
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'CODE1';
            subRecs.Qty__c = 5;
            subRecs.Frequency__c = 'Mon - Fri';
            subRecs.Frequency_1__c = 'Mon - Fri';
            subRecs.Vendor_1__c = acc.id;
            Test.startTest();
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;

        Address_Assignment__c addAssign = new Address_Assignment__c();
            addAssign.Case__c = cas.id;
            addAssign.Address__c = addressRec.id;
            addAssign.Contact__c = con.id;
            addAssign.Effective_Date__c = date.Today();
            addAssign.Active__c = TRUE;
            insert addAssign;
               
          /*
           List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
            //caseSub[0].Case__c = cas.id;
            caseSub[0].Account__C = acc.id;
            caseSub[0].Address__c = addressRec.id;
            caseSub[0].isComplaint__c = FALSE;
            caseSub[0].Subscription__c = subRecs.id;
            caseSub[0].Complaint_From__c = date.Today () -30;
            caseSub[0].Complaint_To__c = date.Today () -10;
            caseSub[0].Complaint_Copies__c = 5;
            insert caseSub;
            */
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
           
            tempStop.Case__c = cas.id;
            update tempStop;
            cas.Temp_Stop__c = tempStop.id;
            update cas;
            
           
            List<Subscription_Vendor__c> subVen  = TestDataFactory.createSubscriptionVendor(1);
            subVen[0].Account__c = acc.id;
            subVen[0].Vendor__c = acc.id;
            subVen[0].Recipient__c = con.id;
            subVen[0].Subscription_Start_Date__c = date.Today();
            subVen[0].Subscription_Stop_Date__c = date.Today() +60;
            subVen[0].Status__c = 'Active';
            insert subVen;
            
            List<Case_Vendor_Subscription__c> CaseVenList= TestDataFactory.createCaseVendorSub(2);
            For(Case_Vendor_Subscription__c CaseVen : CaseVenList ){
                CaseVen.Address__c = addressRec.id;
                CaseVen.Account__c = acc.id;
                CaseVen.Case__c = cas.id;
                CaseVen.Subscription_Vendor__c = subVen[0].id; 
                CaseVen.Complaint_From__c = date.Today() -30;
                CaseVen.Complaint_To__c = date.Today() -10;      
                CaseVen.Complaint_Copies__c  = 5;  
            }
            insert CaseVenList;
            
           
             List<Subscription_Vendor_Publication__c> CasePubList = TestDataFactory.createVendorPublication(2);
            for(Subscription_Vendor_Publication__c CasePub : CasePubList){
                CasePub.Account__c = acc.id;
                CasePub.Subscription_Vendor__c =  subVen[0].id;
                CasePub.Publication__c = pub[0].id;
            }
           
            insert CasePubList ;
            
            
            Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Case__c = cas.id;
            caseSub.Account__C = acc.id;
            caseSub.Address__c = addressRec.id;
            caseSub.isComplaint__c = false;
    
            caseSub.Subscription__c = subRecs.id;
            caseSub.Complaint_From__c = date.Today () -30;
            caseSub.Complaint_To__c = date.Today () -10;
            caseSub.Complaint_Copies__c = 5;
            caseSub.Subscription__c = subRecs.id;
            insert caseSub;
            
            
            
            BT_AB_VSS093DX_ExportCustomerStartStop batch2 = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch2,200);
            
            System.assertNotEquals(null, batchprocessid);
            
            Test.stopTest();
        
        }
       }
       
     static testmethod void testexecuteCaseSubscription(){
          System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            Database.BatchableContext BC;
            //Test Data
            defaultCustomSetting();
            
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Name = 'TestName';
            pub[0].Publication_Code__c = 'PubC';
            pub[0].Published_Days__c = 'YYYYYYY';
            pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub[0].Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub[0].Publication_Type__c = 'N';
            pub[0].Platform_Type__c = 'Print';
            insert pub;
            
           // system.assertEquals(null, pub[0].Name);
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductCode__c = 'CODE1';
            zProduct.ProductFamily__c = '6789';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
            
            
            List <Product_Publication__c> pp = TestDataFactory.createProductPublication(1);
            
            pp[0].Publication_Code__c = pub[0].Id;
            pp[0].ZProduct__c = zProduct.Id;

            insert pp; 
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem); 
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            
            
           
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            
            Test.startTest();
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            //Recordtype recType = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Complaint_Newspaper'];                     
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            //cas.Publication__c = pub[0].id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            //cas.RecordTypeId = recType.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Change of Address'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            //cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
       
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'CODE1';
            subRecs.Qty__c = 5;
            subRecs.Frequency__c = 'Mon - Fri';
            subRecs.Frequency_1__c = 'Mon - Fri';
            
            subRecs.Vendor_1__c = acc.id;
            
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;
            
            Address_Assignment__c addAssign = new Address_Assignment__c();
            addAssign.Case__c = cas.id;
            addAssign.Address__c = addressRec.id;
            addAssign.Contact__c = con.id;
            addAssign.Effective_Date__c = date.Today();
            addAssign.Active__c = TRUE;
            insert addAssign;
            
            List<Case_Subscription__c> caseSubList = TestDataFactory.createCaseSubscription(2);
            for (Case_Subscription__c caseSub : caseSubList){
                //caseSub.Case__c             = cas.id;
                caseSub.Account__C          = acc.id;
                caseSub.Address__c          = addressRec.id;
                caseSub.isComplaint__c      = FALSE;
                caseSub.Subscription__c     = subRecs.id;
                caseSub.Complaint_From__c   = date.Today () -30;
                caseSub.Complaint_To__c     = date.Today () -10;
                caseSub.Complaint_Copies__c = 5;
                caseSub.Case__c = cas.Id;
            }
            insert caseSubList;
            
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
            
            List<sObject> scope = [ SELECT  Account.Vendor_Code__c, Account.Vendor_Group__c, Publication__r.Publication_Code__c,
            RecordType.DeveloperName, 
            RecordType.Description, 
            Date_Replaced__c, 
            Date_Closed__c, 
            Description, 
            Effective_Date__c, 
            Earliest_Stop_Date__c,
            POP_Start_Date__c, 
            Remarks__c,     
            Restart_Date__c, 
            Sub_Category__c, 
            Stop_Request_Date__c, 
            Stop_Date__c, 
            Temp_Stop_Date__c, 
            Temp_Stop__c, 
            Temp_Stop__r.Cancelled__c,
            Temp_Stop_Type__c, 
            LastModifiedDate, 
            Change_of_Address_Type__c, 
            ID 
            FROM Case]; 
            
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch,200);
            batch.execute(BC, scope);
            System.assertNotEquals(null, batchprocessid);          
            
            Test.stopTest();
      }
    }
    
    static testmethod void testexecuteCaseSubscription2(){
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            Database.BatchableContext BC;
            //Test Data
            defaultCustomSetting();
            
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Publication_Code__c = 'PubC';
            pub[0].Published_Days__c = 'YYYYYYY';
            pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub[0].Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub[0].Publication_Type__c = 'N';
            pub[0].Platform_Type__c = 'Print';
            pub[0].Product_Family__c = 'PubC';
            pub[0].Name = 'PubC';
            insert pub;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
             zProduct.ProductCode__c = 'PubC';
        //zp.ProductFamily__c = 'BH';
        zProduct.ProductFamily__c = 'PubC';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
            
            List <Product_Publication__c> prodPub = TestDataFactory.createProductPublication(1);
            for(Product_Publication__c pp: prodPub) {
            pp.Publication_Code__c = pub[0].Id;
            pp.ZProduct__c = zProduct.Id;
            }
            
            insert prodPub;
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            
            
           
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            
            Test.startTest();
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            //Recordtype recType = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Complaint_Newspaper'];                     
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            cas.Publication__c = pub[0].id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            //cas.RecordTypeId = recType.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Change of Address'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            //cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
       
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'PubC';
            subRecs.Qty__c = 5;
            subRecs.Frequency__c = 'Mon - Fri';
            subRecs.Frequency_1__c = 'Mon - Fri';
            
            subRecs.Vendor_1__c = acc.id;
            
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;
            
            Address_Assignment__c addAssign = new Address_Assignment__c();
            addAssign.Case__c = cas.id;
            addAssign.Address__c = addressRec.id;
            addAssign.Contact__c = con.id;
            addAssign.Effective_Date__c = date.Today();
            addAssign.Active__c = TRUE;
            insert addAssign;
            
            List<Case_Subscription__c> caseSubList = TestDataFactory.createCaseSubscription(2);
            for (Case_Subscription__c caseSub : caseSubList){
                //caseSub.Case__c             = cas.id;
                caseSub.Account__C          = acc.id;
                caseSub.Address__c          = addressRec.id;
                caseSub.isComplaint__c      = FALSE;
                caseSub.Subscription__c     = subRecs.id;
                caseSub.Complaint_From__c   = date.Today () -30;
                caseSub.Complaint_To__c     = date.Today () -10;
                caseSub.Complaint_Copies__c = 5;
                caseSub.Case__c = cas.Id;
            }
            insert caseSubList;
            
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
            
      
            List<sObject> scope = [ SELECT  Account.Vendor_Code__c, Account.Vendor_Group__c, Publication__r.Publication_Code__c,
            RecordType.DeveloperName, 
            RecordType.Description, 
            Date_Replaced__c, 
            Date_Closed__c, 
            Description, 
            Effective_Date__c, 
            Earliest_Stop_Date__c,
            POP_Start_Date__c, 
            Remarks__c,     
            Restart_Date__c, 
            Sub_Category__c, 
            Stop_Request_Date__c, 
            Stop_Date__c, 
            Temp_Stop_Date__c, 
            Temp_Stop__c, 
            Temp_Stop__r.Cancelled__c,
            Temp_Stop_Type__c, 
            LastModifiedDate, 
            Change_of_Address_Type__c, 
            ID 
            FROM Case]; 
            
          
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch,200);
            batch.execute(BC, scope);
            System.assertNotEquals(null, batchprocessid);
            
            Test.stopTest();
      }
      
    }
    
    static testmethod void testNullFrequency(){
          System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            Database.BatchableContext BC;
            //Test Data
            defaultCustomSetting();
            
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Publication_Code__c = 'PubC';
            pub[0].Published_Days__c = 'YYYYYYY';
            pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub[0].Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub[0].Publication_Type__c = 'N';
            pub[0].Platform_Type__c = 'Print';
            insert pub;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            
            
            List <Product_Publication__c> pp = TestDataFactory.createProductPublication(1);
            
            pp[0].Publication_Code__c = pub[0].Id;
            pp[0].ZProduct__c = zProduct.Id;

            insert pp; 
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            
            
           
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            
            Test.startTest();
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            //Recordtype recType = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Complaint_Newspaper'];                     
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            cas.Publication__c = pub[0].id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            //cas.RecordTypeId = recType.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Change of Address'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            //cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
       
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'CODE1';
            subRecs.Qty__c = 5;
            //subRecs.Frequency__c = 'Mon - Fri';
            //subRecs.Frequency_1__c = 'Mon - Fri';
            subRecs.Frequency__c = null;
            subRecs.Frequency_1__c = null;
            subRecs.Vendor_1__c = acc.id;
            
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;
            
            Address_Assignment__c addAssign = new Address_Assignment__c();
            addAssign.Case__c = cas.id;
            addAssign.Address__c = addressRec.id;
            addAssign.Contact__c = con.id;
            addAssign.Effective_Date__c = date.Today();
            addAssign.Active__c = TRUE;
            insert addAssign;
            
            List<Case_Subscription__c> caseSubList = TestDataFactory.createCaseSubscription(2);
            for (Case_Subscription__c caseSub : caseSubList){
                caseSub.Case__c             = cas.id;
                caseSub.Account__C          = acc.id;
                caseSub.Address__c          = addressRec.id;
                caseSub.isComplaint__c      = FALSE;
                caseSub.Subscription__c     = subRecs.id;
                caseSub.Complaint_From__c   = date.Today () -30;
                caseSub.Complaint_To__c     = date.Today () -10;
                caseSub.Complaint_Copies__c = 5;
            }
            insert caseSubList;
            
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
            
      
            List<sObject> scope = [ SELECT  Account.Vendor_Code__c, Account.Vendor_Group__c, Publication__r.Publication_Code__c,
            RecordType.DeveloperName, 
            RecordType.Description, 
            Date_Replaced__c, 
            Date_Closed__c, 
            Description, 
            Effective_Date__c, 
            Earliest_Stop_Date__c,
            POP_Start_Date__c, 
            Remarks__c,     
            Restart_Date__c, 
            Sub_Category__c, 
            Stop_Request_Date__c, 
            Stop_Date__c, 
            Temp_Stop_Date__c, 
            Temp_Stop__c, 
            Temp_Stop__r.Cancelled__c,
            Temp_Stop_Type__c, 
            LastModifiedDate, 
            Change_of_Address_Type__c, 
            ID 
            FROM Case]; 
            
          
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch,200);
            batch.execute(BC, scope);
            System.assertNotEquals(null, batchprocessid);
            
            Test.stopTest();
      }
    }
    
    static testmethod void testNullFrequency2(){
          System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            Database.BatchableContext BC;
            //Test Data
            defaultCustomSetting();
            
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            List<Publication__c> pub = TestDataFactory.createPublication(2);
            pub[0].Publication_Code__c = 'PubC';
            pub[0].Published_Days__c = 'YYYYYYY';
            pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub[0].Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub[0].Publication_Type__c = 'N';
            pub[0].Platform_Type__c = 'Print';
            pub[0].Name = 'test';
            
            pub[1].Publication_Code__c = 'PubC';
            pub[1].Published_Days__c = 'YYYYYYY';
            pub[1].Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub[1].Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub[1].Publication_Type__c = 'N';
            pub[1].Platform_Type__c = 'Print';
            pub[1].Name = 'test';
            insert pub;
           
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.productcode__c = 'PubC';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            
            
            List <Product_Publication__c> ppn = TestDataFactory.createProductPublication(2);
            /*for(Product_Publication__c pp: ppn){
            pp.Publication_Code__c = pub[0].Id;
            pp.ZProduct__c = zProduct.Id;
            
            }*/
            ppn[0].Publication_Code__c = pub[0].id;
            ppn[0].ZProduct__c = zProduct.Id;
            ppn[1].Publication_Code__c = pub[1].id;
            ppn[1].ZProduct__c = zProduct.Id;
            insert ppn; 
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            
            
           
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            
            Test.startTest();
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            //Recordtype recType = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Complaint_Newspaper'];                     
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            cas.Publication__c = pub[0].id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            //cas.RecordTypeId = recType.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Change of Address'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            //cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
       
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'PubC';
            subRecs.Qty__c = 5;
            //subRecs.Frequency__c = 'Mon - Fri';
            //subRecs.Frequency_1__c = 'Mon - Fri';
            subRecs.Frequency__c = null;
            subRecs.Frequency_1__c = null;
            subRecs.Vendor_1__c = acc.id;
            
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;
            
            Address_Assignment__c addAssign = new Address_Assignment__c();
            addAssign.Case__c = cas.id;
            addAssign.Address__c = addressRec.id;
            addAssign.Contact__c = con.id;
            addAssign.Effective_Date__c = date.Today();
            addAssign.Active__c = TRUE;
            insert addAssign;
            
            List<Case_Subscription__c> caseSubList = TestDataFactory.createCaseSubscription(1);
            List<Case_Subscription__c> caslist = new List<Case_Subscription__c>();
            for (Case_Subscription__c caseSub : caseSubList){
                caseSub.Case__c             = cas.id;
                caseSub.Account__C          = acc.id;
                caseSub.Address__c          = addressRec.id;
                caseSub.isComplaint__c      = FALSE;
                caseSub.Subscription__c     = subRecs.id;
                caseSub.Complaint_From__c   = date.Today () -30;
                caseSub.Complaint_To__c     = date.Today () -10;
                caseSub.Complaint_Copies__c = 5;
                caslist.add(caseSub);
            }
            
            insert caslist;
            
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
            
      
            List<sObject> scope = [ SELECT  Account.Vendor_Code__c, Account.Vendor_Group__c, Publication__r.Publication_Code__c,
            RecordType.DeveloperName, 
            RecordType.Description, 
            Date_Replaced__c, 
            Date_Closed__c, 
            Description, 
            Effective_Date__c, 
            Earliest_Stop_Date__c,
            POP_Start_Date__c, 
            Remarks__c,     
            Restart_Date__c, 
            Sub_Category__c, 
            Stop_Request_Date__c, 
            Stop_Date__c, 
            Temp_Stop_Date__c, 
            Temp_Stop__c, 
            Temp_Stop__r.Cancelled__c,
            Temp_Stop_Type__c, 
            LastModifiedDate, 
            Change_of_Address_Type__c, 
            ID 
            FROM Case]; 
            
          
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch,200);
            batch.execute(BC, scope);
            System.assertNotEquals(null, batchprocessid);
            
            Test.stopTest();
      }
    }
    
    
    /*
    static testMethod void testSample() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            
            //Test Data
            defaultCustomSetting();
            
                    
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '150';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'Lahug';
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
 
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Vendor_Group__c = 'A';
            acc.Vendor_Code__c = 'CODE1';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'PubC';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Public_Holiday_Weekday_Pub_Indicator__c = true;
            pub.Public_Holiday_Weekend_Pub_Indicator__c = true;
            pub.Publication_Type__c = 'N';
            pub.Platform_Type__c = 'Print';
            insert pub;
            
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.productcode__c = 'CODE1';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
//List<zqu__ProductRatePlanCharge__c> listPRPC = [SELECT ID,PublicationCode__c,zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.ID IN :listPRP];

            List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(1);
            zprpc[0].Name = 'Product Rate Plan Charge';
            zprpc[0].zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc[0].zqu__ZuoraId__c = '3689922200';
            zprpc[0].PublicationCode__c = 'PubC';
            insert zprpc;
             
//List<Package_Item__c> listPackageItem = [SELECT ID,Product_Rate_Plan__r.ID,Package__r.ID, package__r.package_code__c FROM Package_Item__c where Package__r.ID IN :listPackages AND recordType.developerName IN ('Base_Product', 'Bundle_Product')];         
      
           // Recordtype rectypePack = [SELECT Id, DeveloperName FROM Recordtype WHERE sObjectType = 'Package_Item__c' AND DeveloperName = 'Base_Product'];

            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(1,'Base Product');
            pItem[0].Package__c = pack.id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem.RecordtypeID = rectypePack.id;
            Database.insert(pItem);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
            Database.insert(billAcc);  
            
           
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
           
           
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.Billing_Indicator__c = true;
            Database.insert(con1);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
            //order.Postage_Charge__c = 200.00;
            Database.insert(order);   
            
            Test.startTest();
            
            BT_CO_Batch_Run_Request__c batchCo = new  BT_CO_Batch_Run_Request__c();
            batchCo.Interface_ID__c = 'VSS093DX';
            batchCo.Batch_Run_Date__c = date.Today()+2;
            batchCo.End_Time__c = null; //  dateTime.newInstance(2015, 08, 15, 18, 30, 05);
            insert batchCo;
            
            BT_CS_Interface_Parameters__c intParam = new BT_CS_Interface_Parameters__c();
            intParam.Name = 'Default Timestamp';
            intParam.Value__c = '-18-30-05';
            intParam.Description__c = 'Description';
            insert intParam;
            
            Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
            
            tempStop.Cancelled__c = False; //Checkbox
            tempStop.Restart_Date__c = date.Today ()+90;
            tempStop.Temp_Stop_Date__c = date.Today ()+30;
            insert tempStop;
                      
            Recordtype recType = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Temp_Stop_Subscription'];                     
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.Order__c = order.Id;  
            cas.Account__c = acc.id;
            cas.Publication__c = pub.id;
            //cas.RecordTypeId = getRecordType('Start Subscription','Case').id;
            cas.RecordTypeId = recType.id;
            cas.Date_Replaced__c = date.Today()+3;
            cas.Description = 'Description';
            cas.Effective_Date__c = date.Today() +1;
            cas.Earliest_Stop_Date__c = date.Today() +60;
            cas.POP_Start_Date__c = date.Today()+1;
            cas.Remarks__c = 'Remarks';
            cas.Restart_Date__c = date.Today() +90;
            cas.Sub_Category__c = 'Change of Address'; //Picklist
            cas.Stop_Request_Date__c =  date.Today()+60;
            cas.Stop_Date__c = date.Today()+15;
            cas.Temp_Stop_Date__c = date.Today() +30;
            cas.Temp_Stop__c = tempStop.id;
            cas.Temp_Stop_Type__c = 'New'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            cas.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            //cas.Status = 'Closed'; //Picklist
            cas.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            //cas.LastModifiedDate = dateTime.newInstance(2015, 08, 09, 18, 30, 05);
            Database.insert(cas); 
            
            
            tempStop.Case__c = cas.id;
            update tempStop;
            
            Case caseType = [SELECT Id, LastModifiedDate FROM Case LIMIT 1]; 
            Datetime caseTypeDate = caseType.LastModifiedDate;
            
            String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('VSS093DX');            
            DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate);
            DateTime cutOffStart = cutOffEnd.addDays(-1);  
            DateTime dtLastBatchRunDate = DateUtility.getOverrideDate('VSS093DX');         
            DateTime newCutOffStart = cutOffStart;
            
            System.Debug('111cas.LastModifiedDate' + cas.LastModifiedDate);
            System.Debug('111newCutOffStart' + newCutOffStart);
            System.Debug('111cutOffStart' + cutOffStart);
            System.Debug('111cutOffEnd' + cutOffEnd);
            //System.Debuf('111LastModifiedDate' + LastModifiedDate);
            System.Debug('111cas.Status' + cas.Status);
            System.Debug('111RecordType.DeveloperName' + recType.DeveloperName);
            System.Debug('111tempStop.Cancelled__c' + tempStop.Cancelled__c);
            System.Debug('111cas.Sub_Status__c' + cas.Sub_Status__c);
            System.Debug('111cas.Temp_Stop_Type__c' + cas.Temp_Stop_Type__c);
            System.Debug('LastmodifiedDate' + caseTypeDate );
        
       
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = Date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE; //changed by JJZS
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            Database.insert(orderline);
    
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.id;
            subRecs.Zuora__Account__c = acc.Id;
            subRecs.Zuora__Zuora_Id__c = '1123';
            subRecs.Zuora__SubscriptionStartDate__c = date.Today() +1;
            subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs.Subscriber_Contact__c = con.Id;
            subRecs.Recipient_Contact__c = con.Id;
            subRecs.Main_Package_1__c = pack.id;
            subRecs.Main_Package__c = pack.id;
            subRecs.Order_Number__c = order.Id;
            subRecs.Suppress_Vendor_Start_Notice__c = 'false';
            subRecs.Supressed_Acknowledgement_Letter__c = 'false';
            subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs.Urgent__c = 'false';
            subRecs.Vendor_Conversion__c = 'false';
            subRecs.Charity__c = 'false';
            subRecs.Billing_Type__c = 'Full Prepaid';
            subRecs.Order_Line_Item_Number__c = orderline.id;
            subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            subRecs.Zuora__Status__c = 'Active';
            subRecs.Order_Number_1__c = order.id;
            subRecs.Order_Line_Item_Number_1__c = orderline.Id;
            subRecs.Generate_Invoice1__c = 'false';
            subRecs.Sponsor_1__c = false;
            
            subRecs.Product_Code__c = 'CODE1';
            subRecs.Qty__c = 5;
            subRecs.Frequency__c = 'Mon - Fri';
            subRecs.Frequency_1__c = 'Mon - Fri';
            subRecs.Vendor_1__c = acc.id;
            
            Database.insert(subRecs);
        
            
            order.Subscription__c = subRecs.id;
            update order;
          
            //FROM Case
            //FROM Temp_Stop__c 
            //Case_Subscription__c
            //Case_Vendor_Subscription__c
            //Subscription_Vendor_Publication__c
            
            Address_Assignment__c addAssign = new Address_Assignment__c();
            addAssign.Case__c = cas.id;
            addAssign.Address__c = addressRec.id;
            addAssign.Contact__c = con.id;
            addAssign.Effective_Date__c = date.Today();
            addAssign.Active__c = TRUE;
            insert addAssign;
            
             List<Subscription_Vendor__c> subVen  = TestDataFactory.createSubscriptionVendor(1);
            subVen[0].Account__c = acc.id;
            subVen[0].Vendor__c = acc.id;
            subVen[0].Recipient__c = con.id;
            subVen[0].Subscription_Start_Date__c = date.Today();
            subVen[0].Subscription_Stop_Date__c = date.Today() +60;
            subVen[0].Status__c = 'Active';
            insert subVen;
            
            List<Case_Vendor_Subscription__c> CaseVenList= TestDataFactory.createCaseVendorSub(2);
            For(Case_Vendor_Subscription__c CaseVen : CaseVenList ){
                CaseVen.Address__c = addressRec.id;
                CaseVen.Account__c = acc.id;
                CaseVen.Case__c = cas.id;
                CaseVen.Subscription_Vendor__c = subVen[0].id; 
                CaseVen.Complaint_From__c = date.Today() -30;
                CaseVen.Complaint_To__c = date.Today() -10;      
                CaseVen.Complaint_Copies__c  = 5;  
            }
            insert CaseVenList;
            
            
           
            List<Subscription_Vendor_Publication__c> CasePubList = TestDataFactory.createVendorPublication(2);
            for(Subscription_Vendor_Publication__c CasePub : CasePubList){
                CasePub.Account__c = acc.id;
                CasePub.Subscription_Vendor__c =  subVen[0].id;
                CasePub.Publication__c = pub.id;
            }
           
            insert CasePubList ;
            
                     
            Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Case__c = cas.id;
            caseSub.Account__C = acc.id;
            caseSub.Address__c = addressRec.id;
            caseSub.isComplaint__c = TRUE;
            caseSub.Subscription__c = subRecs.id;
            caseSub.Complaint_From__c = date.Today () -30;
            caseSub.Complaint_To__c = date.Today () -10;
            caseSub.Complaint_Copies__c = 5;
            insert caseSub;
            
            
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();
            ID batchprocessid = Database.executeBatch(batch,200);
            
            System.assertNotEquals(null, batchprocessid);
            
            Test.stopTest();
        
        }
      }
      */
    
    
}