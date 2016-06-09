@isTest (Seealldata = TRUE)
//BT_AB_HDS036DX_DailyTempStopFile_Dummy Test class
public class BT_AB_HDS036DX_DailyTempStopFile_DTest {
        
        
        static void unitTestDailyTempStopFile(){
        
        List <Case> cases = TestDataFactory.createCase(1, 'Temp Stop Subscription'); //needed
        List <Package__c> pack = TestDataFactory.createPackage(1); //needed
        List <Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1); //needed
        List <Case_Subscription__c> casSub = TestDataFactory.createCaseSubscription(1);  //needed
        List <Product_Publication__c> proPub =TestDataFactory.createProductPublication(1);  //needed
        List <Publication__c> publication = TestDataFactory.createPublication(1); //needed
        List <zqu__ZProduct__c> zPro = TestDataFactory.createZProduct(1); //needed
        List <Order__c> order = TestDataFactory.createOrder(1); //needed
        List <Account> acc = TestDataFactory.createAccount(1, 'Vendor Subscriber'); //needed
        List<Zuora__CustomerAccount__c> bAcc = TestDataFactory.createBillingAccount(1);
        List <Contact> contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');        
        
        BT_CO_Batch_Run_Request__c bRun = new BT_CO_Batch_Run_Request__c(Interface_ID__c = 'HDS036DX', Batch_Run_Date__c = System.Today()+1);
        insert bRUn;
        
        for(Account ac: acc){
            ac.Name = 'Test';
            ac.Account_Legacy_Id__c = 'Test';
        }  
        insert acc;       
                
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
        }
        
        for(Package__c p: pack){
            p.Package_Type__c = 'Add ON';
            p.Name = 'Add ON';
            p.Subscription_Type__c = 'Termed';
            p.Package_Code__c = '1234567890';
            p.Subscription_Period__c = '2';
            p.Effective_Start_Date__c = System.today();
            p.Effective_End_Date__c = System.today();
        }
        
        insert pack;

        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
            con.Contact_Legacy_Id__c = 'TEST';
        }
        insert contact;   
        
        bacc[0].Zuora__Account__c = acc[0].id;
        insert bAcc;
        
        for(Zuora__Subscription__c s: sub) {
            s.Zuora__CustomerAccount__c = bAcc[0].id;
            s.Name = 'TEST-S00001026';
            s.Number_of_Copies__c = 1.00;
            s.Next_Earliest_Start_Date__c = System.today();
            s.Zuora__Version__c = 1;
            s.Zuora__Status__c = 'Cancelled';
            s.Zuora__InitialTerm__c = '9';
            s.Parent_Transaction_ID__c = '9';
            s.Product_Code__c = 'STSU';
            s.Zuora__Account__c = acc[0].Id;
            s.Zuora__SubscriptionStartDate__c = System.today();
            s.Zuora__SubscriptionEndDate__c = System.today();
            s.Notification_Letter__c = 'Test';
            s.Year_to_Date_Temp_Stop_Days__c = 9;
            s.Previous_Year_Temp_Stop_Days__c = 9;
            s.Legacy_Create_Date__c = '9';
            s.Legacy_Create_By__c = '9';
            s.Legacy_Update_Date__c = '9';
            s.Legacy_Update_By__c = '9';
            s.Legacy_Subscription_ID__c = '9';
            s.Cheque_details__c = '9';
            s.DTL__c = '9';
            s.Paypal_Payment_Profile_Id__c = '9';
            s.Pub_Tag__c = '9';
            s.Sponsored_Indicator__c = '9';
            s.Subscribe_As__c = '9';
            s.Subscription_End_Date__c = '9';
            s.Subscription_Grace_Period_End_Date__c = '9';
            s.Gift_ID__c = '9';
            s.Redeem_Date__c = '9';
            s.Gift_ID_2__c = '9';
            s.Redeem_Date_2__c = '9';
            s.Unique_Address_Id__c = 'Test';
            s.Subscriber_Contact__c = contact[0].Id;
            s.Recipient_Contact__c = contact[0].Id;
            s.Subscription_Charge__c = 9;
            s.Term_Length__c = 9;
            s.Main_Package_1__c = pack[0].Id;
            s.Zuora__Zuora_Id__c = 'Test';
            s.Qty__c = 9;
            s.Frequency__c = ' ';
            s.Number_of_Copies1__c =  '100';
            s.Number_of_Copies__c = 100;
            s.Qty__c = 20;
        }    
 
        for(zqu__ZProduct__c z: zPro) {
            z.Name = 'Test';
            z.zqu__SKU__c = 'Test';
            z.ProductCode__c = 'Test';
        }

        insert zPro;
        for(Product_Publication__c pp: proPub) {
            pp.ZProduct__c = zPro[0].Id; //zproduct     
        }
        
        insert proPub;

        insert sub;           

        for(Order__c o: order){
            o.Informed_Customer__c = TRUE;
            o.Order_type__c = 'Temp_Stop_Subscription';
            o.Account__c = acc[0].Id;
            o.Delivery_Charge__c = 9;
            o.Monthly_Delivery_Charge_for_Full_Payment__c = 9;
            o.Recipient_Contact__c = contact[0].Id;
            o.Credit_Balance__c = 9;
            o.Order_Legacy_Id__c = 'TEST';
            o.Legacy_Create_Date__c = 'TEST';
            o.Legacy_Create_By__c = 'TEST';
            o.Legacy_Update_Date__c = 'TEST';
            o.Legacy_Update_By__c = 'TEST';
        }
        insert order;
        
        for(Case c: cases) {
            c.Order__c = order[0].Id;            
            c.Status = 'New';
            //c.RecordTypeId = '012N00000008k0E';
            c.Effective_Date__c = System.Today()+1;
        }

        insert cases;        

        for(Case_Subscription__c cSub: casSub) {
            cSub.Account__c = acc[0].Id;
            cSub.Case__c = cases[0].Id;
            cSub.Subscription__c = sub[0].Id;
            cSub.Legacy_Create_Date__c = 'Test';
            cSub.Legacy_Create_By__c = 'Test';
            cSub.Legacy_Update_Date__c = 'Test';
            cSub.Legacy_Update_By__c = 'Test';
        }       
        insert casSub;
        
        Test.StartTest();        
       
        Set<Id> lastmodifiedIds = New Set<Id>();
        lastmodifiedIds.add(userInfo.getUserId());
        Date Start_Date = Date.NewInstance(2016,04,08);
        Date End_date = Date.NewInstance(2016,04,09);
        
        BT_AB_HDS036DX_DailyTempStopFile_Dummy batch = new BT_AB_HDS036DX_DailyTempStopFile_Dummy(lastmodifiedIds,Start_Date ,End_date );
        ID batchprocessid = Database.executeBatch(batch, 200);

        Test.StopTest();
    }
        
        /**
        
        */
        static void unitTestDailyTempStopFileMONFRI(){    
          
        List <Case> cases = TestDataFactory.createCase(1, 'Temp Stop Subscription'); //needed
        List <Package__c> pack = TestDataFactory.createPackage(1); //needed
        List <Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1); //needed
        List <Case_Subscription__c> casSub = TestDataFactory.createCaseSubscription(1);  //needed
        List <Product_Publication__c> proPub =TestDataFactory.createProductPublication(1);  //needed
        List <Publication__c> publication = TestDataFactory.createPublication(1); //needed
        List <zqu__ZProduct__c> zPro = TestDataFactory.createZProduct(1); //needed
        List <Order__c> order = TestDataFactory.createOrder(1); //needed
        List <Account> acc = TestDataFactory.createAccount(1, 'Vendor Subscriber'); //needed
        List<Zuora__CustomerAccount__c> bAcc = TestDataFactory.createBillingAccount(1);
        List<Contact> contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');
        List<Address__c> address = TestDataFactory.createAddress(1);    
        List<Singpost_Address__c> postSing = TestDataFactory.createSingpostAddress(1);
        
        BT_CO_Batch_Run_Request__c bRun = new BT_CO_Batch_Run_Request__c(Interface_ID__c = 'HDS036DX', Batch_Run_Date__c = System.Today()+1);
        insert bRUn;
        
        for(Account ac: acc){
            ac.Name = 'Test';
            ac.Account_Legacy_Id__c = 'Test';
        }  
        insert acc;       
                
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
        }
        
        for(Package__c p: pack){
            p.Package_Type__c = 'Add ON';
            p.Name = 'Add ON';
            p.Subscription_Type__c = 'Termed';
            p.Package_Code__c = '1234567890';
            p.Subscription_Period__c = '2';
            p.Effective_Start_Date__c = System.today();
            p.Effective_End_Date__c = System.today();
        }
        
        insert pack;
        
        postSing[0].Building_Name__c = 'R';
        insert postSing;
        
        address[0].Postal_Code__c = postSing[0].id;
        insert address;
        
        
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
            con.Address__c = address[0].id;
            con.Contact_Legacy_Id__c = 'TEST';
        }
        insert contact;  
        
        bacc[0].Zuora__Account__c = acc[0].id;
        insert bAcc; 
        
        for(Zuora__Subscription__c s: sub) {
            s.Zuora__CustomerAccount__c = bAcc[0].id;
            s.Name = 'TEST-S00001026';
            s.Number_of_Copies__c = 1.00;
            s.Next_Earliest_Start_Date__c = System.today();
            s.Zuora__Version__c = 1;
            s.Zuora__Status__c = 'Cancelled';
            s.Zuora__InitialTerm__c = '9';
            s.Parent_Transaction_ID__c = '9';
            s.Product_Code__c = 'STSU';
            s.Zuora__Account__c = acc[0].Id;
            s.Zuora__SubscriptionStartDate__c = System.today();
            s.Zuora__SubscriptionEndDate__c = System.today();
            s.Notification_Letter__c = 'Test';
            s.Year_to_Date_Temp_Stop_Days__c = 9;
            s.Previous_Year_Temp_Stop_Days__c = 9;
            s.Legacy_Create_Date__c = '9';
            s.Legacy_Create_By__c = '9';
            s.Legacy_Update_Date__c = '9';
            s.Legacy_Update_By__c = '9';
            s.Legacy_Subscription_ID__c = '9';
            s.Cheque_details__c = '9';
            s.DTL__c = '9';
            s.Paypal_Payment_Profile_Id__c = '9';
            s.Pub_Tag__c = '9';
            s.Sponsored_Indicator__c = '9';
            s.Subscribe_As__c = '9';
            s.Subscription_End_Date__c = '9';
            s.Subscription_Grace_Period_End_Date__c = '9';
            s.Gift_ID__c = '9';
            s.Redeem_Date__c = '9';
            s.Gift_ID_2__c = '9';
            s.Redeem_Date_2__c = '9';
            s.Unique_Address_Id__c = 'Test';
            s.Subscriber_Contact__c = contact[0].Id;
            s.Recipient_Contact__c = contact[0].Id;
            s.Subscription_Charge__c = 9;
            s.Term_Length__c = 9;
            s.Main_Package_1__c = pack[0].Id;
            s.Zuora__Zuora_Id__c = 'Test';
            s.Qty__c = 9;
            s.Frequency__c = 'Mon - Fri';
            s.Number_of_Copies1__c =  '100';
            s.Number_of_Copies__c = 100;
            s.Qty__c = 20;
        }    
 
        for(zqu__ZProduct__c z: zPro) {
            z.Name = 'Test';
            z.zqu__SKU__c = 'Test';
            z.ProductCode__c = 'Test';
        }

        insert zPro;
        for(Product_Publication__c pp: proPub) {
            pp.ZProduct__c = zPro[0].Id; //zproduct     
        }
        
        insert proPub;

        insert sub;           

        for(Order__c o: order){
            o.Informed_Customer__c = TRUE;
            o.Order_type__c = 'Temp_Stop_Subscription';
            o.Account__c = acc[0].Id;
            o.Delivery_Charge__c = 9;
            o.Monthly_Delivery_Charge_for_Full_Payment__c = 9;
            o.Recipient_Contact__c = contact[0].Id;
            o.Credit_Balance__c = 9;
            o.Order_Legacy_Id__c = 'TEST';
            o.Legacy_Create_Date__c = 'TEST';
            o.Legacy_Create_By__c = 'TEST';
            o.Legacy_Update_Date__c = 'TEST';
            o.Legacy_Update_By__c = 'TEST';
        }
        insert order;
        
        for(Case c: cases) {
            c.Order__c = order[0].Id;            
            c.Status = 'Closed';
            //c.RecordTypeId = '012N00000008k0E';
            c.Effective_Date__c = System.Today()+1;
        }

        insert cases;        

        for(Case_Subscription__c cSub: casSub) {
            cSub.Account__c = acc[0].Id;
            cSub.Case__c = cases[0].Id;
            cSub.Subscription__c = sub[0].Id;
            cSub.Legacy_Create_Date__c = 'Test';
            cSub.Legacy_Create_By__c = 'Test';
            cSub.Legacy_Update_Date__c = 'Test';
            cSub.Legacy_Update_By__c = 'Test';
        }       
        insert casSub;
        /**
        String customRecordTypes = StringUtility.getCustomSetting('HDS036DX Case Record Types');
        Set<String> caseRecordTypesSet = new Set<String>();
        
        //Temp_Stop_Subscription|Case_Temp Stop|Temp Stop
        caseRecordTypesSet = StringUtility.getValues(customRecordTypes);
        
        List<String> caseStatusList = new List<String>();
        caseStatusList.add('Closed');
        
        String batchRunDate;       
        List<BT_CO_Batch_Run_Request__c> brrList = [SELECT Id, Batch_Run_Date__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = 'HDS036DX' AND End_Time__c = null ORDER BY CreatedDate DESC];
        DateTime batchRun;
        
        for (BT_CO_Batch_Run_Request__c brrRecord: brrList)
        {
            batchRun = brrRecord.Batch_Run_Date__c;
            break;
        }
        
        batchRunDate = batchRun.format('yyyy-MM-dd');
        //System.assertEquals('', batchRunDate);
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate,'Default Timestamp'); 
        //System.assertEquals('', cutOffEnd);
        DateTime cutOffStart = cutOffEnd.addDays(-1);   
        DateTime dtLastBatchRunDate = DateUtility.getOverrideDate('HDS036DX'); 
        DateTime newCutOffStart = null;
        if (dtLastBatchRunDate>cutOffStart) {
            newCutOffStart = cutOffStart;
            newCutOffStart = DateTime.parse(newCutOffStart.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        } else {
            Integer minutesDiff = Integer.valueOf((dtLastBatchRunDate.getTime() - cutOffStart.getTime())/1000/60);
            newCutOffStart = cutOffStart.addMinutes(minutesDiff);           
        }
        
        List<Case_Subscription__c> caseSubList = [SELECT Id, Subscription__r.Frequency__c, Case__r.LastModifiedDate,
        Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c FROM Case_Subscription__c 
        WHERE Case__r.RecordType.DeveloperName IN :caseRecordTypesSet AND Case__r.Status IN :caseStatusList 
        AND (
                (Case__r.LastModifiedDate > :newCutOffStart.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
                    AND Case__r.LastModifiedDate <= :cutOffEnd.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
                )
            ) 
            ];
        boolean found = false;
        for(Case_Subscription__c caseSubs : caseSubList){
            if(casSub[0].id == caseSubs.id) {
                System.assertEquals('s', caseSubs.Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c);
                found = true;
            }
        } */
        //System.assertEquals(true, found);
        
        Test.StartTest();
        Set<Id> lastmodifiedIds = New Set<Id>();
        lastmodifiedIds.add(userInfo.getUserId());
        Date Start_Date = Date.NewInstance(2016,03,02);
        Date End_date = Date.NewInstance(2016,03,04);
        //BT_AB_HDS036DX_DailyTempStopFile_Dummy batch = new BT_AB_HDS036DX_DailyTempStopFile_Dummy();
        BT_AB_HDS036DX_DailyTempStopFile_Dummy batch = new BT_AB_HDS036DX_DailyTempStopFile_Dummy(lastmodifiedIds,Start_Date ,End_date );
        ID batchprocessid = Database.executeBatch(batch, 200);

        Test.StopTest();        

    }
    
        /**
        
        */
        static testmethod void unitTestDailyTempStopFileDateIsNull(){    
          
        List <Case> cases = TestDataFactory.createCase(1, 'Temp Stop Subscription'); //needed
        List <Package__c> pack = TestDataFactory.createPackage(1); //needed
        List <Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1); //needed
        List <Case_Subscription__c> casSub = TestDataFactory.createCaseSubscription(1);  //needed
        List <Product_Publication__c> proPub =TestDataFactory.createProductPublication(1);  //needed
        List <Publication__c> publication = TestDataFactory.createPublication(1); //needed
        List <zqu__ZProduct__c> zPro = TestDataFactory.createZProduct(1); //needed
        List <Order__c> order = TestDataFactory.createOrder(1); //needed
        List <Account> acc = TestDataFactory.createAccount(1, 'Vendor Subscriber'); //needed
        List<Zuora__CustomerAccount__c> bAcc = TestDataFactory.createBillingAccount(1);
        List<Contact> contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');
        List<Address__c> address = TestDataFactory.createAddress(1);    
        List<Singpost_Address__c> postSing = TestDataFactory.createSingpostAddress(1);
        
        BT_CO_Batch_Run_Request__c bRun = new BT_CO_Batch_Run_Request__c(Interface_ID__c = 'HDS036DX', Batch_Run_Date__c = System.Today()+1);
        //insert bRUn;
        
        for(Account ac: acc){
            ac.Name = 'Test';
            ac.Account_Legacy_Id__c = 'Test';
        }  
        insert acc;       
                
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
        }
        
        for(Package__c p: pack){
            p.Package_Type__c = 'Add ON';
            p.Name = 'Add ON';
            p.Subscription_Type__c = 'Termed';
            p.Package_Code__c = '1234567890';
            p.Subscription_Period__c = '2';
            p.Effective_Start_Date__c = System.today();
            p.Effective_End_Date__c = System.today();
        }
        
        insert pack;
        
        postSing[0].Building_Name__c = 'R';
        insert postSing;
        
        address[0].Postal_Code__c = postSing[0].id;
        insert address;
        
        
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
            con.Address__c = address[0].id;
            con.Contact_Legacy_Id__c = 'TEST';
        }
        insert contact;  
        
        bacc[0].Zuora__Account__c = acc[0].id;
        insert bAcc; 
        
        for(Zuora__Subscription__c s: sub) {
            s.Zuora__CustomerAccount__c = bAcc[0].id;
            s.Name = 'TEST-S00001026';
            s.Number_of_Copies__c = 1.00;
            s.Next_Earliest_Start_Date__c = System.today();
            s.Zuora__Version__c = 1;
            s.Zuora__Status__c = 'Cancelled';
            s.Zuora__InitialTerm__c = '9';
            s.Parent_Transaction_ID__c = '9';
            s.Product_Code__c = 'STSU';
            s.Zuora__Account__c = acc[0].Id;
            s.Zuora__SubscriptionStartDate__c = System.today();
            s.Zuora__SubscriptionEndDate__c = System.today();
            s.Notification_Letter__c = 'Test';
            s.Year_to_Date_Temp_Stop_Days__c = 9;
            s.Previous_Year_Temp_Stop_Days__c = 9;
            s.Legacy_Create_Date__c = '9';
            s.Legacy_Create_By__c = '9';
            s.Legacy_Update_Date__c = '9';
            s.Legacy_Update_By__c = '9';
            s.Legacy_Subscription_ID__c = '9';
            s.Cheque_details__c = '9';
            s.DTL__c = '9';
            s.Paypal_Payment_Profile_Id__c = '9';
            s.Pub_Tag__c = '9';
            s.Sponsored_Indicator__c = '9';
            s.Subscribe_As__c = '9';
            s.Subscription_End_Date__c = '9';
            s.Subscription_Grace_Period_End_Date__c = '9';
            s.Gift_ID__c = '9';
            s.Redeem_Date__c = '9';
            s.Gift_ID_2__c = '9';
            s.Redeem_Date_2__c = '9';
            s.Unique_Address_Id__c = 'Test';
            s.Subscriber_Contact__c = contact[0].Id;
            s.Recipient_Contact__c = contact[0].Id;
            s.Subscription_Charge__c = 9;
            s.Term_Length__c = 9;
            //s.Main_Package_1__c = null;
            s.Zuora__Zuora_Id__c = 'Test';
            s.Qty__c = 9;
            s.Frequency__c = 'Mon - Fri';
            s.Number_of_Copies1__c =  '100';
            s.Number_of_Copies__c = 100;
            s.Qty__c = 20;
        }    
 
        for(zqu__ZProduct__c z: zPro) {
            z.Name = 'Test';
            z.zqu__SKU__c = 'Test';
            z.ProductCode__c = 'Test';
        }

        insert zPro;
        for(Product_Publication__c pp: proPub) {
            pp.ZProduct__c = zPro[0].Id; //zproduct     
        }
        
        insert proPub;

        insert sub;           

        for(Order__c o: order){
            o.Informed_Customer__c = TRUE;
            o.Order_type__c = 'Temp_Stop_Subscription';
            o.Account__c = acc[0].Id;
            o.Delivery_Charge__c = 9;
            o.Monthly_Delivery_Charge_for_Full_Payment__c = 9;
            o.Recipient_Contact__c = contact[0].Id;
            o.Credit_Balance__c = 9;
            o.Order_Legacy_Id__c = 'TEST';
            o.Legacy_Create_Date__c = 'TEST';
            o.Legacy_Create_By__c = 'TEST';
            o.Legacy_Update_Date__c = 'TEST';
            o.Legacy_Update_By__c = 'TEST';
        }
        insert order;
        
        for(Case c: cases) {
            c.Order__c = order[0].Id;            
            c.Status = 'Closed';
            //c.RecordTypeId = '012N00000008k0E';
            c.Effective_Date__c = System.Today()+1;
            c.Temp_Stop__c = null;
            c.Temp_Stop_Date__c = null;
        }

        insert cases;        

        for(Case_Subscription__c cSub: casSub) {
            cSub.Account__c = acc[0].Id;
            cSub.Case__c = cases[0].Id;
            cSub.Subscription__c = sub[0].Id;
            cSub.Legacy_Create_Date__c = 'Test';
            cSub.Legacy_Create_By__c = 'Test';
            cSub.Legacy_Update_Date__c = 'Test';
            cSub.Legacy_Update_By__c = 'Test';
        }       
        insert casSub;
        /**
        String customRecordTypes = StringUtility.getCustomSetting('HDS036DX Case Record Types');
        Set<String> caseRecordTypesSet = new Set<String>();
        
        //Temp_Stop_Subscription|Case_Temp Stop|Temp Stop
        caseRecordTypesSet = StringUtility.getValues(customRecordTypes);
        
        List<String> caseStatusList = new List<String>();
        caseStatusList.add('Closed');
        
        String batchRunDate;       
        List<BT_CO_Batch_Run_Request__c> brrList = [SELECT Id, Batch_Run_Date__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = 'HDS036DX' AND End_Time__c = null ORDER BY CreatedDate DESC];
        DateTime batchRun;
        
        for (BT_CO_Batch_Run_Request__c brrRecord: brrList)
        {
            batchRun = brrRecord.Batch_Run_Date__c;
            break;
        }
        
        batchRunDate = batchRun.format('yyyy-MM-dd');
        //System.assertEquals('', batchRunDate);
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate,'Default Timestamp'); 
        //System.assertEquals('', cutOffEnd);
        DateTime cutOffStart = cutOffEnd.addDays(-1);   
        DateTime dtLastBatchRunDate = DateUtility.getOverrideDate('HDS036DX'); 
        DateTime newCutOffStart = null;
        if (dtLastBatchRunDate>cutOffStart) {
            newCutOffStart = cutOffStart;
            newCutOffStart = DateTime.parse(newCutOffStart.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        } else {
            Integer minutesDiff = Integer.valueOf((dtLastBatchRunDate.getTime() - cutOffStart.getTime())/1000/60);
            newCutOffStart = cutOffStart.addMinutes(minutesDiff);           
        }
        
        List<Case_Subscription__c> caseSubList = [SELECT Id, Subscription__r.Frequency__c, Case__r.LastModifiedDate,
        Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c, Case__r.Temp_Stop_Date__c, Case__r.Temp_Stop__c,
        Subscription__r.Main_Package_1__c FROM Case_Subscription__c 
        WHERE Case__r.RecordType.DeveloperName IN :caseRecordTypesSet AND Case__r.Status IN :caseStatusList 
         AND (
                (Case__r.LastModifiedDate > :newCutOffStart.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
                    AND Case__r.LastModifiedDate <= :cutOffEnd.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
                )
            )
            ];
        boolean found = false;
        for(Case_Subscription__c caseSubs : caseSubList){
            if(casSub[0].id == caseSubs.id) {
                //System.assertEquals(null, caseSubs.Case__r.Temp_Stop_Date__c);
                found = true;
            }
        } 
        System.assertEquals(true, found);
        */
        Test.StartTest();
        
        Set<Id> lastmodifiedIds = New Set<Id>();
        lastmodifiedIds.add(userInfo.getUserId());
        Date Start_Date = Date.NewInstance(2016,04,18);
        Date End_date = Date.NewInstance(2016,04,19);
        
        //BT_AB_HDS036DX_DailyTempStopFile_Dummy batch = new BT_AB_HDS036DX_DailyTempStopFile_Dummy();
        BT_AB_HDS036DX_DailyTempStopFile_Dummy batch = new BT_AB_HDS036DX_DailyTempStopFile_Dummy(lastmodifiedIds,Start_Date ,End_date );
        ID batchprocessid = Database.executeBatch(batch, 200);

        Test.StopTest();        

    }

}