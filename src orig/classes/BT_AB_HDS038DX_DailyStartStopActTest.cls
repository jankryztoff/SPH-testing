/**
 * Class Name: <BT_AB_HDS038DX_DailyStartStopActTest>
 * @author: <patrick.c.villarica>
 * Date: <02/07/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for BT_AB_HDS038DX_DailyStartStopActionFile>
 */

@isTest (seeAllData = FALSE)
public class BT_AB_HDS038DX_DailyStartStopActTest {
    
    static testmethod void unitTestDailyStartStopActionFile(){
        
        defaultCustomSetting();
        
        //instantiate record creation -- Start
        Id startSubRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Start Subscription').getRecordTypeId();
        List <Case> cases = TestDataFactory.createCase(1, 'Start Subscription');
        List <Subscription_Vendor__c> subVendor = TestDataFactory.createSubscriptionVendor(1);
        List <Case_Vendor_Subscription__c> caseVendorSub = TestDataFactory.createCaseVendorSub(1);
        List <Publication__c> publication = TestDataFactory.createPublication(1);
        List <Subscription_Vendor_Publication__c> venPub = TestDataFactory.createVendorPublication(1);
        List <Order__c> order = TestDataFactory.createOrder(1);
        List <Account> acc = TestDataFactory.createAccount(1, 'Vendor Subscriber');                
        List <Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
        List <Zuora__CustomerAccount__c> billAccounts = TestDataFactory.createBillingAccount(1);
        List <Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
        List <Package__c> pack = TestDataFactory.createPackage(1);
        List <Package_Item__c> packItem = TestDataFactory.createPackageItem(1, 'Base Product');
        List <zqu__ZProduct__c> zProd = TestDataFactory.createZProduct(1);
        List <Product_Publication__c> prodPub = TestDataFactory.createProductPublication(1);
        List <Product_Family__c> prodF = TestDataFactory.createProductFamily(1);
        //Recipient Contact
        List <Contact> contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');        
        List <Address__c> testAddress = TestDataFactory.createAddress(1);
        List <Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(1);
        List <zqu__ProductRatePlan__c> prodRatePlan = TestDataFactory.createProductRatePlan(1);
        List <zqu__ProductRatePlanCharge__c> prodRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1);
        //instantiate record creation -- End
        
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('HDS038DX');   
        Date dtEffStart = Date.valueOf(brd);
        
        for(Product_Family__c pF: prodF) {
        pF.Product_Family__c = 'test';
        pF.Product_Family_Name__c = 'test';
        }
        insert prodF;
        
        
        for(zqu__ZProduct__c zp: zProd) {
        zp.ProductSubType__c = 'Magazine';
        zp.ProductCode__c = 'WSJA';
        zp.ProductFamily__c = 'BH';
        }
        
        insert zProd;
        
        
        //Set Publication fields -- Start
        for(Publication__c pub: publication) {
            pub.Published_Days__c = 'YYYYYYY';
            pub.Publication_Type__c = 'M';
            pub.Platform_Type__c = 'Print';
            pub.Publication_Type__c = 'N';
            pub.Publication_Code__c = 'test';
            pub.Product_Family_Lookup__c = prodF[0].Id;
            pub.Product_Family__c = 'WSJA'; 
            //pub.Product_Family__c = 'BH';
            pub.Name = 'test';
        } //Set Publication fields -- End
        
        insert acc;
        
        //jurna added
        //Set Address fields -- Start
        for(Address__c add: testAddress) {
        } //Set Address fields -- End
        
        insert testAddress;
        
        //Set Contact fields -- Start
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
            con.Address__c = testAddress[0].Id; // jurna added
        } //Set Contact fields -- End
        
        insert contact;  
        
        //Set Order__c fields -- Start
        for(Order__c o: order) {
            o.Account__c = acc[0].id;
            o.Informed_Customer__c = TRUE;
            o.Recipient_Contact__c = contact[0].Id;
        } //Set Order__c fields -- End
        
        insert order;
        
        //Set Case fields -- Start
        for(Case c: cases) {
        
            c.Status = 'Closed';
            c.RecordTypeId = startSubRecordTypeId;
            c.Effective_Date__c = System.Today()+1;
            c.Restart_Date__c = System.Today()+1;
            c.Sub_Status__c = 'Closed';
            c.Order__c = order[0].Id;
        } //Set Case fields -- End      
        
        insert cases;
        
        for(Zuora__CustomerAccount__c billAcc: billAccounts){
            billAcc.Name = 'Zuora Customer Account';
            billAcc.Zuora__Account__c = acc[0].Id;
            billAcc.Zuora__Credit_Balance__c = 1;
            billAcc.Refund_Amount__c = 100;
            billAcc.Zuora__AutoPay__c =false;
            billAcc.Zuora__Balance__c = 1;
            billAcc.Payment_Mode__c = 'Invoice';
            billAcc.Other_PaymentMethod__c= 'Invoice';
                //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            billAcc.Zuora__PaymentMethodType__c = 'Invoice';
            billAcc.ARMS_Customer_Number__c = 'ARMSCUS001';
            billAcc.ARMS_Account_Number__c = 'ARMSACC001';
            billAcc.Zuora__External_Id__c = '22544AA';  
            billAcc.Zuora__Zuora_Id__c = '0124';
            billAcc.Billing_Type__c= 'Recurring Prepaid';    
            billAcc.Zuora__Status__c = 'Active';
            billAcc.Billing_Contact__c = contact[0].Id;
        }
        insert billAccounts;
        
        //Set Subscription_Vendor__c fields -- Start
        for(Subscription_Vendor__c sVendor: subVendor) {
            sVendor.Account__c = acc[0].Id;
            sVendor.Status__c = 'Active';
            sVendor.Recipient__c = contact[0].Id;
        } //Set Subscription_Vendor__c fields -- End
        
        //DML insert for related records for Case_Vendor_Subscription__c - Start
        insert subVendor;
        insert publication;
        //DML insert for related records for Case_Vendor_Subscription__c - End
        
        for(Package__c p: pack){
        p.Name = 'Pack name';
        p.Billing_Type__c = 'Recurring Prepaid';
        p.Package_Type__c = 'Base';
        p.Subscription_Period__c = '18';
        p.Package_Code__c = 'afds132';
        }
        
        insert pack;
        
        for(zqu__ProductRatePlan__c prdRatePlan: prodRatePlan) { 
        prdRatePlan.Name = 'HDB DELIVERY CHARGE';
        prdRatePlan.zqu__ZProduct__c = zProd[0].Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        }
        
        insert prodRatePlan; 
        
        for(Package_Item__c pItem: packItem) {
        pItem.Package__c = pack[0].id;
        pItem.Product_Rate_Plan__c = prodRatePlan[0].id;
        pItem.Name = 'Test Pack Item';
        }

        insert packItem;
        
        for(zqu__ProductRatePlanCharge__c zprpc: prodRatePlanCharge) { 
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prodRatePlan[0].id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        //zprpc.zqu__UOM__c = 'landed';
        zprpc.zqu__Deleted__c = false;
        zprpc.zqu__Type__c = 'Usage';
        zprpc.PublicationCode__c = 'test';
        }
        
        insert prodRatePlanCharge;   
        
        for(Product_Publication__c pp: prodPub) {
        pp.Publication_Code__c = publication[0].Id;
        pp.ZProduct__c = zProd[0].Id;
        }
        
        insert prodPub;
        
        for(Zuora__Subscription__c sub: subscription) {
            sub.Main_Package_1__c = pack[0].id;
            sub.Zuora__Account__c = acc[0].id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            //subRec.Order_Number__c = order.Id;
            sub.Zuora__CustomerAccount__c = billAccounts[0].Id;
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Legacy_Create_Date__c = 'a';
            sub.Legacy_Create_By__c = 'a';
            sub.Legacy_Update_By__c = 'a';
            sub.Legacy_Subscription_ID__c = 'a';
            sub.Legacy_Update_Date__c = 'a';
            sub.Number_of_Copies__c = 100;
            sub.Number_of_Copies1__c = '100';
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Term_Length__c = 1;
            //sub.Zuora__SubscriptionStartDate__c = Date.today();
            sub.Zuora__SubscriptionEndDate__c = dtEffStart.addDays(2);
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            sub.Zuora__SubscriptionStartDate__c = dtEffStart.addDays(1);
            //sub.Zuora__Zuora_Id__c = 'ZZID000'+count;
            sub.Main_package__c = pack[0].id;
            sub.Product_Code__c = 'WSJA';
        }
        
        insert subscription;
        
        for(Case_Subscription__c cs: caseSub) {
        cs.Account__c = acc[0].Id;
        cs.Case__c = cases[0].Id;
        cs.Subscription__c = subscription[0].Id;
        }
        
        insert caseSub;
        
        for(Case_Vendor_Subscription__c cvSub: caseVendorSub) {
            
            cvSub.Case__c = cases[0].Id;
            cvSub.Subscription_Vendor__c = subVendor[0].Id;
            cvSub.Account__c = acc[0].Id;            
        }
        
        insert caseVendorSub;
        
        for(Subscription_Vendor_Publication__c vpub: venPub) {
        
            vpub.Subscription_Vendor__c = subVendor[0].Id;
            vpub.Publication__c = publication[0].Id;
            vpub.Order__c = order[0].Id;
            vpub.Account__c = acc[0].Id;
        }
          
        insert venPub;
        
        for(Order_Line_Item__c orderline: orderLineItem) { 
        orderline.Order__c = order[0].Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        // orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Stop_Request_Date__c =  dtEffStart.addDays(1);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        orderline.Subscription__c = subscription[0].Id;
        }
        
        insert orderLineItem;
        
        Test.StartTest();
        
        BT_AB_HDS038DX_DailyStartStopActionFile batch = new BT_AB_HDS038DX_DailyStartStopActionFile();
        ID batchprocessid = Database.executeBatch(batch, 200);
         
        Test.StopTest();
    }//end of unitTestDailyStartStopActionFile    
    
    //jurna
    static testmethod void unitTestDailyStartStopActionFile2(){
        
        defaultCustomSetting();
        
        //instantiate record creation -- Start
        Id startSubRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Start Subscription').getRecordTypeId();
        List <Case> cases = TestDataFactory.createCase(1, 'Start Subscription');
        List <Subscription_Vendor__c> subVendor = TestDataFactory.createSubscriptionVendor(1);
        List <Case_Vendor_Subscription__c> caseVendorSub = TestDataFactory.createCaseVendorSub(1);
        List <Publication__c> publication = TestDataFactory.createPublication(1);
        List <Subscription_Vendor_Publication__c> venPub = TestDataFactory.createVendorPublication(1);
        List <Order__c> order = TestDataFactory.createOrder(1);
        List <Account> acc = TestDataFactory.createAccount(1, 'Vendor Subscriber');                
        List <Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
        List <Zuora__CustomerAccount__c> billAccounts = TestDataFactory.createBillingAccount(1);
        List <Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
        List <Package__c> pack = TestDataFactory.createPackage(1);
        List <Package_Item__c> packItem = TestDataFactory.createPackageItem(1, 'Base Product');
        List <zqu__ZProduct__c> zProd = TestDataFactory.createZProduct(1);
        List <Product_Publication__c> prodPub = TestDataFactory.createProductPublication(1);
        List <Product_Family__c> prodF = TestDataFactory.createProductFamily(1);
        //Recipient Contact
        List <Contact> contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');        
        List <Address__c> testAddress = TestDataFactory.createAddress(1);
        List <Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(1);
        List <zqu__ProductRatePlan__c> prodRatePlan = TestDataFactory.createProductRatePlan(1);
        List <zqu__ProductRatePlanCharge__c> prodRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1);
        //instantiate record creation -- End
        
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('HDS038DX');   
        Date dtEffStart = Date.valueOf(brd);
        
        for(Product_Family__c pF: prodF) {
        //pF.Product_Family__c = 'test';
        pF.Product_Family__c = 'WSJA';
        //pF.Product_Family_Name__c = 'test';
        pF.Product_Family_Name__c = 'WSJA';
        }
        insert prodF;
        
        
        for(zqu__ZProduct__c zp: zProd) {
        zp.ProductSubType__c = 'Magazine';
        zp.ProductCode__c = 'WSJA';
        //zp.ProductFamily__c = 'BH';
        zp.ProductFamily__c = 'WSJA';
        
        }
        
        insert zProd;
        
        
        //Set Publication fields -- Start
        for(Publication__c pub: publication) {
            pub.Published_Days__c = 'YYYYYYY';
           // pub.Publication_Type__c = 'M';
            pub.Platform_Type__c = 'Print';
            pub.Publication_Type__c = 'N';
            pub.Publication_Code__c = 'WSJA';
            pub.Product_Family_Lookup__c = prodF[0].Id;
            pub.Product_Family__c = 'WSJA'; 
            //pub.Product_Family__c = 'BH';
            pub.Name = 'test';
        } //Set Publication fields -- End
        
        insert acc;
        
        //jurna added
        //Set Address fields -- Start
        for(Address__c add: testAddress) {
        } //Set Address fields -- End
        
        insert testAddress;
        
        //Set Contact fields -- Start
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
            con.Address__c = testAddress[0].Id; // jurna added
        } //Set Contact fields -- End
        
        insert contact;  
        
        //Set Order__c fields -- Start
        for(Order__c o: order) {
            o.Account__c = acc[0].id;
            o.Informed_Customer__c = TRUE;
            o.Recipient_Contact__c = contact[0].Id;
        } //Set Order__c fields -- End
        
        insert order;
        
        //Set Case fields -- Start
        for(Case c: cases) {
        
            c.Status = 'Closed';
            c.RecordTypeId = startSubRecordTypeId;
            c.Effective_Date__c = System.Today()+1;
            c.Restart_Date__c = System.Today()+1;
            c.Sub_Status__c = 'Closed';
            c.Order__c = order[0].Id;
        } //Set Case fields -- End      
        
        insert cases;
        
        for(Zuora__CustomerAccount__c billAcc: billAccounts){
            billAcc.Name = 'Zuora Customer Account';
            billAcc.Zuora__Account__c = acc[0].Id;
            billAcc.Zuora__Credit_Balance__c = 1;
            billAcc.Refund_Amount__c = 100;
            billAcc.Zuora__AutoPay__c =false;
            billAcc.Zuora__Balance__c = 1;
            billAcc.Payment_Mode__c = 'Invoice';
            billAcc.Other_PaymentMethod__c= 'Invoice';
                //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            billAcc.Zuora__PaymentMethodType__c = 'Invoice';
            billAcc.ARMS_Customer_Number__c = 'ARMSCUS001';
            billAcc.ARMS_Account_Number__c = 'ARMSACC001';
            billAcc.Zuora__External_Id__c = '22544AA';  
            billAcc.Zuora__Zuora_Id__c = '0124';
            billAcc.Billing_Type__c= 'Recurring Prepaid';    
            billAcc.Zuora__Status__c = 'Active';
            billAcc.Billing_Contact__c = contact[0].Id;
        }
        insert billAccounts;
        
        //Set Subscription_Vendor__c fields -- Start
        for(Subscription_Vendor__c sVendor: subVendor) {
            sVendor.Account__c = acc[0].Id;
            sVendor.Status__c = 'Active';
            sVendor.Recipient__c = contact[0].Id;
        } //Set Subscription_Vendor__c fields -- End
        
        //DML insert for related records for Case_Vendor_Subscription__c - Start
        insert subVendor;
        insert publication;
        //DML insert for related records for Case_Vendor_Subscription__c - End
        
        for(Package__c p: pack){
        p.Name = 'Pack name';
        p.Billing_Type__c = 'Recurring Prepaid';
        p.Package_Type__c = 'Base';
        p.Subscription_Period__c = '18';
        p.Package_Code__c = 'afds132';
        }
        
        insert pack;
        
        for(zqu__ProductRatePlan__c prdRatePlan: prodRatePlan) { 
        prdRatePlan.Name = 'HDB DELIVERY CHARGE';
        prdRatePlan.zqu__ZProduct__c = zProd[0].Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        }
        
        insert prodRatePlan; 
        
        for(Package_Item__c pItem: packItem) {
        pItem.Package__c = pack[0].id;
        pItem.Product_Rate_Plan__c = prodRatePlan[0].id;
        pItem.Name = 'Test Pack Item';
        }

        insert packItem;
        
        for(zqu__ProductRatePlanCharge__c zprpc: prodRatePlanCharge) { 
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prodRatePlan[0].id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        //zprpc.zqu__UOM__c = 'landed';
        zprpc.zqu__Deleted__c = false;
        zprpc.zqu__Type__c = 'Usage';
        //zprpc.PublicationCode__c = 'test';
        zprpc.PublicationCode__c = publication[0].Publication_Code__c;
        }
        
        insert prodRatePlanCharge;   
        
        for(Product_Publication__c pp: prodPub) {
        pp.Publication_Code__c = publication[0].Id;
        pp.ZProduct__c = zProd[0].Id;
        }
        
        insert prodPub;
        
        for(Zuora__Subscription__c sub: subscription) {
            sub.Main_Package_1__c = pack[0].id;
            sub.Zuora__Account__c = acc[0].id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            //subRec.Order_Number__c = order.Id;
            sub.Zuora__CustomerAccount__c = billAccounts[0].Id;
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Legacy_Create_Date__c = 'a';
            sub.Legacy_Create_By__c = 'a';
            sub.Legacy_Update_By__c = 'a';
            sub.Legacy_Subscription_ID__c = 'a';
            sub.Legacy_Update_Date__c = 'a';
            sub.Number_of_Copies__c = 100;
            sub.Number_of_Copies1__c = '100';
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Term_Length__c = 1;
            //sub.Zuora__SubscriptionStartDate__c = Date.today();
            sub.Zuora__SubscriptionEndDate__c = dtEffStart.addDays(2);
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            sub.Zuora__SubscriptionStartDate__c = dtEffStart.addDays(1);
            //sub.Zuora__Zuora_Id__c = 'ZZID000'+count;
            sub.Main_package__c = pack[0].id;
            sub.Product_Code__c = 'WSJA';
        }
        
        insert subscription;
        
        for(Case_Subscription__c cs: caseSub) {
        cs.Account__c = acc[0].Id;
        cs.Case__c = cases[0].Id;
        cs.Subscription__c = subscription[0].Id;
        }
        
        insert caseSub;
        
        for(Case_Vendor_Subscription__c cvSub: caseVendorSub) {
            
            cvSub.Case__c = cases[0].Id;
            cvSub.Subscription_Vendor__c = subVendor[0].Id;
            cvSub.Account__c = acc[0].Id;            
        }
        
        insert caseVendorSub;
        
        for(Subscription_Vendor_Publication__c vpub: venPub) {
        
            vpub.Subscription_Vendor__c = subVendor[0].Id;
            vpub.Publication__c = publication[0].Id;
            vpub.Order__c = order[0].Id;
            vpub.Account__c = acc[0].Id;
        }
          
        insert venPub;
        
        for(Order_Line_Item__c orderline: orderLineItem) { 
        orderline.Order__c = order[0].Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        // orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Stop_Request_Date__c =  dtEffStart.addDays(1);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        orderline.Subscription__c = subscription[0].Id;
        }
        
        insert orderLineItem;
        
        Test.StartTest();
        
        BT_AB_HDS038DX_DailyStartStopActionFile batch = new BT_AB_HDS038DX_DailyStartStopActionFile();
        ID batchprocessid = Database.executeBatch(batch, 200);
         
        Test.StopTest();
    }//end of unitTestDailyStartStopActionFile    
    
    
    //jurna
    static testmethod void unitTestDailyStartStopActionFile3(){
        
        defaultCustomSetting();
        
        //instantiate record creation -- Start
        Id startSubRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Stop Subscription').getRecordTypeId();
        List <Case> cases = TestDataFactory.createCase(1, 'Stop Subscription');
        List <Subscription_Vendor__c> subVendor = TestDataFactory.createSubscriptionVendor(1);
        List <Case_Vendor_Subscription__c> caseVendorSub = TestDataFactory.createCaseVendorSub(1);
        List <Publication__c> publication = TestDataFactory.createPublication(1);
        List <Subscription_Vendor_Publication__c> venPub = TestDataFactory.createVendorPublication(1);
        List <Order__c> order = TestDataFactory.createOrder(1);
        List <Account> acc = TestDataFactory.createAccount(1, 'Vendor Subscriber');                
        List <Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
        List <Zuora__CustomerAccount__c> billAccounts = TestDataFactory.createBillingAccount(1);
        List <Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
        List <Package__c> pack = TestDataFactory.createPackage(1);
        List <Package_Item__c> packItem = TestDataFactory.createPackageItem(1, 'Base Product');
        List <zqu__ZProduct__c> zProd = TestDataFactory.createZProduct(1);
        List <Product_Publication__c> prodPub = TestDataFactory.createProductPublication(1);
        List <Product_Family__c> prodF = TestDataFactory.createProductFamily(1);
        //Recipient Contact
        List <Contact> contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');        
        List <Address__c> testAddress = TestDataFactory.createAddress(1);
        List <Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(1);
        List <zqu__ProductRatePlan__c> prodRatePlan = TestDataFactory.createProductRatePlan(1);
        List <zqu__ProductRatePlanCharge__c> prodRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1);
        //instantiate record creation -- End
        
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('HDS038DX');   
        Date dtEffStart = Date.valueOf(brd);
        
        for(Product_Family__c pF: prodF) {
        //pF.Product_Family__c = 'test';
        pF.Product_Family__c = 'WSJA';
        //pF.Product_Family_Name__c = 'test';
        pF.Product_Family_Name__c = 'WSJA';
        }
        insert prodF;
        
        
        for(zqu__ZProduct__c zp: zProd) {
        zp.ProductSubType__c = 'Magazine';
        zp.ProductCode__c = 'WSJA';
        //zp.ProductFamily__c = 'BH';
        zp.ProductFamily__c = 'WSJA';
        
        }
        
        insert zProd;
        
        
        //Set Publication fields -- Start
        for(Publication__c pub: publication) {
            pub.Published_Days__c = 'YYYYYYY';
           // pub.Publication_Type__c = 'M';
            pub.Platform_Type__c = 'Print';
            pub.Publication_Type__c = 'N';
            pub.Publication_Code__c = 'WSJA';
            pub.Product_Family_Lookup__c = prodF[0].Id;
            pub.Product_Family__c = 'WSJA'; 
            //pub.Product_Family__c = 'BH';
            pub.Name = 'test';
        } //Set Publication fields -- End
        
        insert acc;
        
        //jurna added
        //Set Address fields -- Start
        for(Address__c add: testAddress) {
        } //Set Address fields -- End
        
        insert testAddress;
        
        //Set Contact fields -- Start
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
            con.Address__c = testAddress[0].Id; // jurna added
        } //Set Contact fields -- End
        
        insert contact;  
        
        //Set Order__c fields -- Start
        for(Order__c o: order) {
            o.Account__c = acc[0].id;
            o.Informed_Customer__c = TRUE;
            o.Recipient_Contact__c = contact[0].Id;
        } //Set Order__c fields -- End
        
        insert order;
        
        //Set Case fields -- Start
        for(Case c: cases) {
        
            c.Status = 'Closed';
            c.RecordTypeId = startSubRecordTypeId;
            c.Effective_Date__c = System.Today()+1;
            c.Restart_Date__c = System.Today()+1;
            c.Sub_Status__c = 'Closed';
            c.Order__c = order[0].Id;
        } //Set Case fields -- End      
        
        insert cases;
        
        for(Zuora__CustomerAccount__c billAcc: billAccounts){
            billAcc.Name = 'Zuora Customer Account';
            billAcc.Zuora__Account__c = acc[0].Id;
            billAcc.Zuora__Credit_Balance__c = 1;
            billAcc.Refund_Amount__c = 100;
            billAcc.Zuora__AutoPay__c =false;
            billAcc.Zuora__Balance__c = 1;
            billAcc.Payment_Mode__c = 'Invoice';
            billAcc.Other_PaymentMethod__c= 'Invoice';
                //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            billAcc.Zuora__PaymentMethodType__c = 'Invoice';
            billAcc.ARMS_Customer_Number__c = 'ARMSCUS001';
            billAcc.ARMS_Account_Number__c = 'ARMSACC001';
            billAcc.Zuora__External_Id__c = '22544AA';  
            billAcc.Zuora__Zuora_Id__c = '0124';
            billAcc.Billing_Type__c= 'Recurring Prepaid';    
            billAcc.Zuora__Status__c = 'Active';
            billAcc.Billing_Contact__c = contact[0].Id;
        }
        insert billAccounts;
        
        //Set Subscription_Vendor__c fields -- Start
        for(Subscription_Vendor__c sVendor: subVendor) {
            sVendor.Account__c = acc[0].Id;
            sVendor.Status__c = 'Active';
            sVendor.Recipient__c = contact[0].Id;
        } //Set Subscription_Vendor__c fields -- End
        
        //DML insert for related records for Case_Vendor_Subscription__c - Start
        insert subVendor;
        insert publication;
        //DML insert for related records for Case_Vendor_Subscription__c - End
        
        for(Package__c p: pack){
        p.Name = 'Pack name';
        p.Billing_Type__c = 'Recurring Prepaid';
        p.Package_Type__c = 'Base';
        p.Subscription_Period__c = '18';
        p.Package_Code__c = 'afds132';
        }
        
        insert pack;
        
        for(zqu__ProductRatePlan__c prdRatePlan: prodRatePlan) { 
        prdRatePlan.Name = 'HDB DELIVERY CHARGE';
        prdRatePlan.zqu__ZProduct__c = zProd[0].Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        }
        
        insert prodRatePlan; 
        
        for(Package_Item__c pItem: packItem) {
        pItem.Package__c = pack[0].id;
        pItem.Product_Rate_Plan__c = prodRatePlan[0].id;
        pItem.Name = 'Test Pack Item';
        }

        insert packItem;
        
        for(zqu__ProductRatePlanCharge__c zprpc: prodRatePlanCharge) { 
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prodRatePlan[0].id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        //zprpc.zqu__UOM__c = 'landed';
        zprpc.zqu__Deleted__c = false;
        zprpc.zqu__Type__c = 'Usage';
        //zprpc.PublicationCode__c = 'test';
        zprpc.PublicationCode__c = publication[0].Publication_Code__c;
        }
        
        insert prodRatePlanCharge;   
        
        for(Product_Publication__c pp: prodPub) {
        pp.Publication_Code__c = publication[0].Id;
        pp.ZProduct__c = zProd[0].Id;
        }
        
        insert prodPub;
        
        for(Zuora__Subscription__c sub: subscription) {
            sub.Main_Package_1__c = pack[0].id;
            sub.Zuora__Account__c = acc[0].id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            //subRec.Order_Number__c = order.Id;
            sub.Zuora__CustomerAccount__c = billAccounts[0].Id;
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Legacy_Create_Date__c = 'a';
            sub.Legacy_Create_By__c = 'a';
            sub.Legacy_Update_By__c = 'a';
            sub.Legacy_Subscription_ID__c = 'a';
            sub.Legacy_Update_Date__c = 'a';
            sub.Number_of_Copies__c = 100;
            sub.Number_of_Copies1__c = '100';
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Term_Length__c = 1;
            //sub.Zuora__SubscriptionStartDate__c = Date.today();
            sub.Zuora__SubscriptionEndDate__c = dtEffStart.addDays(2);
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            sub.Zuora__SubscriptionStartDate__c = dtEffStart.addDays(1);
            //sub.Zuora__Zuora_Id__c = 'ZZID000'+count;
            sub.Main_package__c = pack[0].id;
            sub.Product_Code__c = 'WSJA';
        }
        
        insert subscription;
        
        for(Case_Subscription__c cs: caseSub) {
        cs.Account__c = acc[0].Id;
        cs.Case__c = cases[0].Id;
        cs.Subscription__c = subscription[0].Id;
        }
        
        insert caseSub;
        
        for(Case_Vendor_Subscription__c cvSub: caseVendorSub) {
            
            cvSub.Case__c = cases[0].Id;
            cvSub.Subscription_Vendor__c = subVendor[0].Id;
            cvSub.Account__c = acc[0].Id;            
        }
        
        insert caseVendorSub;
        
        for(Subscription_Vendor_Publication__c vpub: venPub) {
        
            vpub.Subscription_Vendor__c = subVendor[0].Id;
            vpub.Publication__c = publication[0].Id;
            vpub.Order__c = order[0].Id;
            vpub.Account__c = acc[0].Id;
        }
          
        insert venPub;
        
        for(Order_Line_Item__c orderline: orderLineItem) { 
        orderline.Order__c = order[0].Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        // orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Stop_Request_Date__c =  dtEffStart.addDays(1);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        orderline.Subscription__c = subscription[0].Id;
        }
        
        insert orderLineItem;
        
        Test.StartTest();
        
        BT_AB_HDS038DX_DailyStartStopActionFile batch = new BT_AB_HDS038DX_DailyStartStopActionFile();
        ID batchprocessid = Database.executeBatch(batch, 200);
         
        Test.StopTest();
    }//end of unitTestDailyStartStopActionFile    
    
    //jurna
    static testmethod void unitTestDailyStartStopActionFile4(){
        
        defaultCustomSetting();
        
        //instantiate record creation -- Start
        Id startSubRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Stop Subscription').getRecordTypeId();
        List <Case> cases = TestDataFactory.createCase(1, 'Stop Subscription');
        List <Subscription_Vendor__c> subVendor = TestDataFactory.createSubscriptionVendor(1);
        List <Case_Vendor_Subscription__c> caseVendorSub = TestDataFactory.createCaseVendorSub(1);
        List <Publication__c> publication = TestDataFactory.createPublication(1);
        List <Subscription_Vendor_Publication__c> venPub = TestDataFactory.createVendorPublication(1);
        List <Order__c> order = TestDataFactory.createOrder(1);
        List <Account> acc = TestDataFactory.createAccount(1, 'Vendor Subscriber');                
        List <Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
        List <Zuora__CustomerAccount__c> billAccounts = TestDataFactory.createBillingAccount(1);
        List <Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
        List <Package__c> pack = TestDataFactory.createPackage(1);
        List <Package_Item__c> packItem = TestDataFactory.createPackageItem(1, 'Base Product');
        List <zqu__ZProduct__c> zProd = TestDataFactory.createZProduct(1);
        List <Product_Publication__c> prodPub = TestDataFactory.createProductPublication(1);
        List <Product_Family__c> prodF = TestDataFactory.createProductFamily(1);
        //Recipient Contact
        List <Contact> contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');        
        List <Address__c> testAddress = TestDataFactory.createAddress(1);
        List <Order_Line_Item__c> orderLineItem = TestDataFactory.createOrderLineItem(1);
        List <zqu__ProductRatePlan__c> prodRatePlan = TestDataFactory.createProductRatePlan(1);
        List <zqu__ProductRatePlanCharge__c> prodRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1);
        //instantiate record creation -- End
        
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('HDS038DX');   
        Date dtEffStart = Date.valueOf(brd);
        
        for(Product_Family__c pF: prodF) {
        //pF.Product_Family__c = 'test';
        pF.Product_Family__c = 'WSJA';
        //pF.Product_Family_Name__c = 'test';
        pF.Product_Family_Name__c = 'WSJA';
        }
        insert prodF;
        
        
        for(zqu__ZProduct__c zp: zProd) {
        zp.ProductSubType__c = 'Magazine';
        zp.ProductCode__c = 'WSJA';
        //zp.ProductFamily__c = 'BH';
        zp.ProductFamily__c = 'WSJA';
        
        }
        
        insert zProd;
        
        
        //Set Publication fields -- Start
        for(Publication__c pub: publication) {
            pub.Published_Days__c = 'YYYYYYY';
           // pub.Publication_Type__c = 'M';
            pub.Platform_Type__c = 'Print';
            pub.Publication_Type__c = 'N';
            pub.Publication_Code__c = 'WSJA';
            pub.Product_Family_Lookup__c = prodF[0].Id;
            pub.Product_Family__c = 'WSJA'; 
            //pub.Product_Family__c = 'BH';
            pub.Name = 'test';
        } //Set Publication fields -- End
        
        insert acc;
        
        //jurna added
        //Set Address fields -- Start
        for(Address__c add: testAddress) {
        } //Set Address fields -- End
        
        insert testAddress;
        
        //Set Contact fields -- Start
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
            con.Address__c = testAddress[0].Id; // jurna added
        } //Set Contact fields -- End
        
        insert contact;  
        
        //Set Order__c fields -- Start
        for(Order__c o: order) {
            o.Account__c = acc[0].id;
            o.Informed_Customer__c = TRUE;
            o.Recipient_Contact__c = contact[0].Id;
        } //Set Order__c fields -- End
        
        insert order;
        
        //Set Case fields -- Start
        for(Case c: cases) {
        
            c.Status = 'Closed';
            c.RecordTypeId = startSubRecordTypeId;
            c.Effective_Date__c = System.Today()+1;
            c.Restart_Date__c = System.Today()+1;
            c.Sub_Status__c = 'Closed';
            //c.Order__c = order[0].Id;
        } //Set Case fields -- End      
        
        insert cases;
        
        for(Zuora__CustomerAccount__c billAcc: billAccounts){
            billAcc.Name = 'Zuora Customer Account';
            billAcc.Zuora__Account__c = acc[0].Id;
            billAcc.Zuora__Credit_Balance__c = 1;
            billAcc.Refund_Amount__c = 100;
            billAcc.Zuora__AutoPay__c =false;
            billAcc.Zuora__Balance__c = 1;
            billAcc.Payment_Mode__c = 'Invoice';
            billAcc.Other_PaymentMethod__c= 'Invoice';
                //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            billAcc.Zuora__PaymentMethodType__c = 'Invoice';
            billAcc.ARMS_Customer_Number__c = 'ARMSCUS001';
            billAcc.ARMS_Account_Number__c = 'ARMSACC001';
            billAcc.Zuora__External_Id__c = '22544AA';  
            billAcc.Zuora__Zuora_Id__c = '0124';
            billAcc.Billing_Type__c= 'Recurring Prepaid';    
            billAcc.Zuora__Status__c = 'Active';
            billAcc.Billing_Contact__c = contact[0].Id;
        }
        insert billAccounts;
        
        //Set Subscription_Vendor__c fields -- Start
        for(Subscription_Vendor__c sVendor: subVendor) {
            sVendor.Account__c = acc[0].Id;
            sVendor.Status__c = 'Active';
            sVendor.Recipient__c = contact[0].Id;
        } //Set Subscription_Vendor__c fields -- End
        
        //DML insert for related records for Case_Vendor_Subscription__c - Start
        insert subVendor;
        insert publication;
        //DML insert for related records for Case_Vendor_Subscription__c - End
        
        for(Package__c p: pack){
        p.Name = 'Pack name';
        p.Billing_Type__c = 'Recurring Prepaid';
        p.Package_Type__c = 'Base';
        p.Subscription_Period__c = '18';
        p.Package_Code__c = 'afds132';
        }
        
        insert pack;
        
        for(zqu__ProductRatePlan__c prdRatePlan: prodRatePlan) { 
        prdRatePlan.Name = 'HDB DELIVERY CHARGE';
        prdRatePlan.zqu__ZProduct__c = zProd[0].Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        }
        
        insert prodRatePlan; 
        
        for(Package_Item__c pItem: packItem) {
        pItem.Package__c = pack[0].id;
        pItem.Product_Rate_Plan__c = prodRatePlan[0].id;
        pItem.Name = 'Test Pack Item';
        }

        insert packItem;
        
        for(zqu__ProductRatePlanCharge__c zprpc: prodRatePlanCharge) { 
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prodRatePlan[0].id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        //zprpc.zqu__UOM__c = 'landed';
        zprpc.zqu__Deleted__c = false;
        zprpc.zqu__Type__c = 'Usage';
        //zprpc.PublicationCode__c = 'test';
        zprpc.PublicationCode__c = publication[0].Publication_Code__c;
        }
        
        insert prodRatePlanCharge;   
        
        for(Product_Publication__c pp: prodPub) {
        pp.Publication_Code__c = publication[0].Id;
        pp.ZProduct__c = zProd[0].Id;
        }
        
        insert prodPub;
        
        for(Zuora__Subscription__c sub: subscription) {
            sub.Main_Package_1__c = pack[0].id;
            sub.Zuora__Account__c = acc[0].id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            //subRec.Order_Number__c = order.Id;
            sub.Zuora__CustomerAccount__c = billAccounts[0].Id;
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Legacy_Create_Date__c = 'a';
            sub.Legacy_Create_By__c = 'a';
            sub.Legacy_Update_By__c = 'a';
            sub.Legacy_Subscription_ID__c = 'a';
            sub.Legacy_Update_Date__c = 'a';
            sub.Number_of_Copies__c = 100;
            sub.Number_of_Copies1__c = '100';
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Term_Length__c = 1;
            //sub.Zuora__SubscriptionStartDate__c = Date.today();
            sub.Zuora__SubscriptionEndDate__c = dtEffStart.addDays(2);
            //sub.Zuora__SubscriptionEndDate__c = null;
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            sub.Zuora__SubscriptionStartDate__c = dtEffStart.addDays(1);
            //sub.Zuora__Zuora_Id__c = 'ZZID000'+count;
            sub.Main_package__c = pack[0].id;
            sub.Product_Code__c = 'WSJA';
        }
        
        insert subscription;
        
        for(Case_Subscription__c cs: caseSub) {
        cs.Account__c = acc[0].Id;
        cs.Case__c = cases[0].Id;
        cs.Subscription__c = subscription[0].Id;
        }
        
        insert caseSub;
        
        for(Case_Vendor_Subscription__c cvSub: caseVendorSub) {
            
            cvSub.Case__c = cases[0].Id;
            cvSub.Subscription_Vendor__c = subVendor[0].Id;
            cvSub.Account__c = acc[0].Id;            
        }
        
        insert caseVendorSub;
        
        for(Subscription_Vendor_Publication__c vpub: venPub) {
        
            vpub.Subscription_Vendor__c = subVendor[0].Id;
            vpub.Publication__c = publication[0].Id;
            vpub.Order__c = order[0].Id;
            vpub.Account__c = acc[0].Id;
        }
          
        insert venPub;
        
        for(Order_Line_Item__c orderline: orderLineItem) { 
        orderline.Order__c = order[0].Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(30);
        orderline.Main_Package_ID__c = pack[0].Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        // orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Stop_Request_Date__c =  dtEffStart.addDays(1);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        orderline.Subscription__c = subscription[0].Id;
        }
        
        insert orderLineItem;
        
        Test.StartTest();
        
        BT_AB_HDS038DX_DailyStartStopActionFile batch = new BT_AB_HDS038DX_DailyStartStopActionFile();
        ID batchprocessid = Database.executeBatch(batch, 200);
         
        Test.StopTest();
    }//end of unitTestDailyStartStopActionFile    
    
    static testmethod void unitTestDailyStartStopActionFileNULL(){
    
        defaultCustomSetting();
        
        //instantiate record creation -- start
        Id startSubRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Start Subscription').getRecordTypeId();
        List <Case> cases = TestDataFactory.createCase(1, 'Start Subscription');
        List <Subscription_Vendor__c> subVendor = TestDataFactory.createSubscriptionVendor(1);
        List <Case_Vendor_Subscription__c> caseVendorSub = TestDataFactory.createCaseVendorSub(1);
        List <Publication__c> publication = TestDataFactory.createPublication(1);
        List <Subscription_Vendor_Publication__c> venPub = TestDataFactory.createVendorPublication(1);
        List <Order__c> order = TestDataFactory.createOrder(1);
        List <Account> acc = TestDataFactory.createAccount(1, 'Vendor Subscriber');
        List <Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
        List <Zuora__CustomerAccount__c> billAccounts = TestDataFactory.createBillingAccount(1);
        List <Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
        //Recipient Contact
        List <Contact> contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');
        List <Address__c> testAddress = TestDataFactory.createAddress(1);        
        //instantiate record creation -- end
        
        //Set Case fields -- Start
        for(Case c: cases) {
        
            c.Status = 'Closed';
            c.RecordTypeId = startSubRecordTypeId;
            c.Sub_Status__c = 'Closed';
        } //Set Case fields -- End
        
        //Set Publication fields -- Start
        for(Publication__c pub: publication) {
            pub.Published_Days__c = 'YYYYYYY';
            pub.Publication_Type__c = 'M';
            pub.Free_Publication__c = TRUE;
        } //Set Publication fields -- End
        
        insert acc;
       
        //jurna added
        //Set Address fields -- Start
        for(Address__c add: testAddress) {
        } //Set Address fields -- End
        
        insert testAddress;
        
        //Set Contact fields -- Start
        for(Contact con: contact) {
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = acc[0].Id;
            con.Address__c = testAddress[0].Id; // jurna added
        } //Set Contact fields -- End
        
        insert contact;
        
         for(Zuora__CustomerAccount__c billAcc: billAccounts){
            billAcc.Name = 'Zuora Customer Account';
            billAcc.Zuora__Account__c = acc[0].Id;
            billAcc.Zuora__Credit_Balance__c = 1;
            billAcc.Refund_Amount__c = 100;
            billAcc.Zuora__AutoPay__c =false;
            billAcc.Zuora__Balance__c = 1;
            billAcc.Payment_Mode__c = 'Invoice';
            billAcc.Other_PaymentMethod__c= 'Invoice';
                //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            billAcc.Zuora__PaymentMethodType__c = 'Invoice';
            billAcc.ARMS_Customer_Number__c = 'ARMSCUS001';
            billAcc.ARMS_Account_Number__c = 'ARMSACC001';
            billAcc.Zuora__External_Id__c = '22544AA';  
            billAcc.Zuora__Zuora_Id__c = '0124';
            billAcc.Billing_Type__c= 'Recurring Prepaid';    
            billAcc.Zuora__Status__c = 'Active';
            billAcc.Billing_Contact__c = contact[0].Id;
        }
        insert billAccounts;              
        
        //Set Order__c fields -- Start
        for(Order__c o: order) {
            o.Account__c = acc[0].id;
            o.Informed_Customer__c = TRUE;
            o.Recipient_Contact__c = contact[0].Id;
        } //Set Order__c fields -- End
        
        //Set Subscription_Vendor__c fields -- Start
        for(Subscription_Vendor__c sVendor: subVendor) {
            sVendor.Account__c = acc[0].Id;
            sVendor.Status__c = 'Active';            
        } //Set Subscription_Vendor__c fields -- End
        
        //DML insert for related records for Case_Vendor_Subscription__c - Start
        insert cases;
        insert subVendor;
        insert publication;
        insert order;
        //DML insert for related records for Case_Vendor_Subscription__c - Start
        
         for(Zuora__Subscription__c sub: subscription) {
            //sub.Main_Package_1__c = pack.id;
            sub.Zuora__Account__c = acc[0].id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            //subRec.Order_Number__c = order.Id;
            sub.Zuora__CustomerAccount__c = billAccounts[0].Id;
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Legacy_Create_Date__c = 'a';
            sub.Legacy_Create_By__c = 'a';
            sub.Legacy_Update_By__c = 'a';
            sub.Legacy_Subscription_ID__c = 'a';
            sub.Legacy_Update_Date__c = 'a';
            sub.Number_of_Copies__c = 100;
            sub.Number_of_Copies1__c = '100';
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Term_Length__c = 1;
            sub.Zuora__SubscriptionStartDate__c = Date.today();
            sub.Zuora__SubscriptionEndDate__c = Date.today();
            sub.Zuora__TermSettingType__c = 'EVERGREEN';
            //sub.Zuora__Zuora_Id__c = 'ZZID000'+count;
            //sub.Main_Package__c = pack.id;
        }
        
        insert subscription;
        
        for(Case_Subscription__c cs: caseSub) {
        cs.Account__c = acc[0].Id;
        cs.Case__c = cases[0].Id;
        cs.Subscription__c = subscription[0].Id;
        }
        
        insert caseSub;
        
        
        for(Case_Vendor_Subscription__c cvSub: caseVendorSub) {
            
            cvSub.Case__c = cases[0].Id;
            cvSub.Subscription_Vendor__c = subVendor[0].Id;
            cvSub.Account__c = acc[0].Id;         
        }
        
        insert caseVendorSub;
        
        for(Subscription_Vendor_Publication__c vpub: venPub) {
        
            vpub.Subscription_Vendor__c = subVendor[0].Id;
            vpub.Publication__c = publication[0].Id;
            vpub.Order__c = order[0].Id;
            vpub.Account__c = acc[0].Id;
            vpub.PHe__c = 12;   
        }
        
        insert venPub;
        
        Test.StartTest();
        
        BT_AB_HDS038DX_DailyStartStopActionFile batch = new BT_AB_HDS038DX_DailyStartStopActionFile();
        ID batchprocessid = Database.executeBatch(batch, 200);
         
        Test.StopTest(); 
    } //end of unitTestDailyStartStopActionFileNULL
    
    
   

    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        /*
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        */
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
        
        /*Key_Id__c keyIDtest = new Key_Id__c();
        keyIDtest.Name = 'NEXT_RECIPIENT_NUMBER';
        keyIDtest.Id__c = '30012531';
        insert keyIDtest;*/
    }
}