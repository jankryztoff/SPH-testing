/**
 * Class Name: SP_VendorNotifChainBatch_Test
 * @author: Sherwin Puli
 * Date: 08-June-2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test class for SP_VendorNotifChainBatch
 */
@isTest
public class SP_VendorNotifChainBatch_Test2{

    static Account acc;
    static Singpost_Address__c postal;
    static Address__c ad;
    static Package__c pack;
    static User uRunner;
    
    static List<Contact> con;
    static List<Order__c> orderRec;

    static Zuora__CustomerAccount__c billAcc;
    static List<Zuora__PaymentMethod__c> zpmList;
    static List<Zuora__Subscription__c> testSubscription;

    static List<Order_Line_Item__c> orderline;
    static List<Package_Item__c> pItems;
    static List<Zuora__Subscription__c> sub;

    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createBatchConfig(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createCharge();
        insert CustomSettingsDataFactory.createChargeType();
        insert CustomSettingsDataFactory.createZuora_HPM_Settings();
        insert CustomSettingsDataFactory.createError_Messages();
        insert CustomSettingsDataFactory.createARMSInterface();
        insert CustomSettingsDataFactory.createUom();
        insert CustomSettingsDataFactory.createUnit_of_Measure();
    }
    
    
    static void prepareTestData(){
        user  u = TestDataFactory.prepareTestusers();
        u.Validation_Exempted__c = true;
        System.runAs(u){
            Project__c pro = TestDataFactory.createProject(1)[0];
            pro.Project_Description__c = 'This is a new confidential project.';
            database.insert(pro);
            
            acc = TestDataFactory.createAccount(1, 'Vendor')[0];
            acc.Active__c = true;
            database.insert(acc);

            postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            postal.Name = '10000';
            database.insert(postal);

            ad = TestDataFactory.createAddress(1)[0];
            ad.Postal_Code__c = postal.id;
            database.insert(ad);
            
            Account parentAcc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            parentAcc.Email__c = 'testemailonly@noemail.com';
            parentAcc.Active__c = true;
            insert parentAcc;
            
            Recordtype rectypeConCustomer = [SELECT Id, Name from Recordtype where sObjecttype = 'Contact' and Name = 'Customer Contact' LIMIT 1];
            Contact conRec = TestDataFactory.createContact(1)[0];
            conRec.Recordtypeid = rectypeConCustomer.id;
            conRec.Account = parentAcc;
            conRec.AccountId = parentAcc.id;
            conRec.Recipient_Indicator__c = true; 
            conRec.Billing_Indicator__c = true; 
            conRec.Address__c = ad.id;
            conRec.Active__c = true;
            insert conRec;

            Recordtype rectypeCon = [SELECT Id, Name from Recordtype where sObjecttype = 'Contact' and Name = 'Vendor Staff' LIMIT 1];
            con = TestDataFactory.createContact(3);
            con[0].Recordtypeid = rectypeCon.id;
            con[0].Account = acc;
            con[0].AccountId = acc.id;
            con[0].Recipient_Indicator__c = true; 
            con[0].Address__c = ad.id;
            con[0].Active__c = true;
            con[0].Vendor_Communication_Preference__c  = 'SMS';

            con[1].Recordtypeid = rectypeCon.id;
            con[1].Account = acc;
            con[1].AccountId = acc.id;
            con[1].Recipient_Indicator__c = true; 
            con[1].Address__c = ad.id;
            con[1].Active__c = true;
            con[1].Vendor_Communication_Preference__c  = 'Email';

            con[2].Recordtypeid = rectypeCon.id;
            con[2].Account = acc;
            con[2].AccountId = acc.id;
            con[2].Recipient_Indicator__c = true; 
            con[2].Address__c = ad.id;
            con[2].Active__c = true;
            con[2].Vendor_Communication_Preference__c  = 'Email';
            database.insert(con);  

            Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
            temp.Restart_Date__c = date.today()+1;
            database.insert(temp);

            pack = TestDataFactory.createPackage(1)[0];
            pack.Subscription_Period__c = '15'; 
            pack.Package_Type__c = 'Base'; //packageType;
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Subscription_Period__c = '12'; //subPeriod;
            database.insert(pack);   
            
            Product_Family__c pf = new Product_Family__c();
            pf.Product_Family__c = GlobalVariableClass.PLATFORM_PRINT;
            pf.Product_Family_Name__c = GlobalVariableClass.PLATFORM_PRINT;
            insert pf;
            
            // Raus Ablaza
            // create zProduct and Rate Plan
            List<zqu__ZProduct__c> zProds = TestDataFactory.createZProduct(1);
            zqu__ZProduct__c zProd = zProds[0];
            zProd.ProductPlatform__c = GlobalVariableClass.PLATFORM_PRINT;
            insert zProd;
            
            List<zqu__ProductRatePlan__c> zProdRateList = TestDataFactory.createProductRatePlan(1);
            zqu__ProductRatePlan__c zProdRate = zProdRateList[0];
            zProdRate.zqu__ZProduct__c = zProd.Id;
            insert zProdRate;
            
            pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.id;
                pItem.RecordTypeId = ConstantsSLB.getKeyId('Package Item_Base Product');
                pItem.Product_Family__c = pf.id;
                pItem.Product_Rate_Plan__c = zProdRate.Id;
                //pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                //pItem.RecordTypeId = constantsSLB.getKeyID('Package Item_Discount');
            } //RecordType.Name = 'Discount' && Product_Rate_Plan__r.RatePlanType__c != 'Discount'
            insert pItems;
                
            billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            ARMS_TriggerHandler.isSkipUpdate = true;
            database.insert(billAcc);

            orderRec = TestDataFactory.createOrder(3);
            orderRec[0].Account__c = acc.Id;
            orderRec[0].Informed_Customer__c = TRUE;
            orderRec[0].Recipient_Contact__c = con[0].Id;
            orderRec[0].Subscriber_Charge__c = 100.00;
            

            orderRec[1].Account__c = acc.Id;
            orderRec[1].Informed_Customer__c = TRUE;
            orderRec[1].Recipient_Contact__c = con[1].Id;
            orderRec[1].Subscriber_Charge__c = 100.00;

            orderRec[2].Account__c = acc.Id;
            orderRec[2].Informed_Customer__c = TRUE;
            orderRec[2].Recipient_Contact__c = con[2].Id;
            orderRec[2].Subscriber_Charge__c = 100.00;

            insert orderRec;

            orderline = TestDataFactory.createOrderLineItem(3);
            orderline[0].Order__c = orderRec[0].Id;
            //orderline[0].Subscription__c = sub[0].id;
            orderline[0].Main_Package_ID__c = pack.Id;
            orderline[0].Start_Date__c = date.today()+1;
            orderline[0].End_Date__c = date.today().addMonths(12);

            orderline[1].Order__c = orderRec[1].Id;
            //orderline[1].Subscription__c = sub[1].id;
            orderline[1].Main_Package_ID__c = pack.Id;
            orderline[1].Start_Date__c = date.today()+1;
            orderline[1].End_Date__c = date.today().addMonths(12);
            orderline[1].Qty__c = 51;

            orderline[2].Order__c = orderRec[2].Id;
            //orderline[2].Subscription__c = sub[2].id;
            orderline[2].Main_Package_ID__c = pack.Id;
            orderline[2].Start_Date__c = date.today().addMonths(-12).addDays(1);
            orderline[2].End_Date__c = date.today();
            orderline[2].Qty__c = 5;
            insert orderline;
                       
            sub = TestDataFactory.createSubscription(3);
            sub[0].Zuora__Account__c = parentAcc.id;
            sub[0].Zuora__CustomerAccount__c = billAcc.Id;
            sub[0].Order_Number__c  = orderRec[0].Id;
            sub[0].Order_Number_1__c = orderRec[0].Id;
            sub[0].Zuora__SubscriptionStartDate__c = date.today()+1;
            sub[0].Zuora__SubscriptionEndDate__c = date.today().addMonths(12);
            sub[0].Term_Length1__c = '12';
            sub[0].Term_Length__c = 12;
            sub[0].Order_Line_Item_Number_1__c = orderline[0].Id;
            sub[0].Order_Line_Item_Number__c = orderline[0].Id;
            sub[0].Delivered_By_1__c = 'Vendor';
            sub[0].Delivered_By__c = 'Vendor';
            sub[0].Vendor_1__c = acc.Id;
            sub[0].Vendor__c = acc.Id;
            sub[0].Subscription_Type__c = 'Publication';
            sub[0].Subscription_Type_1__c = 'Publication';
            sub[0].Frequency__c = GlobalVariableClass.FREQUENCY_DEFAULT;
            sub[0].Frequency_1__c = GlobalVariableClass.FREQUENCY_DEFAULT; 
            sub[0].Contact__c = conRec.Id;
            sub[0].Recipient_Contact__c = conRec.Id;
            sub[0].Recipient_Contact_1__c = conRec.Id;
            
            sub[1].Zuora__Account__c = parentAcc.id;
            sub[1].Zuora__CustomerAccount__c = billAcc.Id;
            sub[1].Order_Number__c = orderRec[1].Id;
            sub[1].Order_Number_1__c = orderRec[1].Id;
            sub[1].Delivered_By_1__c = 'Vendor';
            sub[1].Zuora__Status__c = 'Active';
            sub[1].Subscription_Type_1__c = 'Publication';
            sub[1].Zuora__SubscriptionStartDate__c = date.today()+1;
            sub[1].Zuora__SubscriptionEndDate__c = date.today().addMonths(12);
            sub[1].Term_Length1__c = '12';
            sub[1].Term_Length__c = 12;
            sub[1].Order_Line_Item_Number_1__c = orderline[1].Id;
            sub[1].Order_Line_Item_Number__c = orderline[1].Id;
            sub[1].Delivered_By_1__c = 'Vendor';
            sub[1].Delivered_By__c = 'Vendor';
            sub[1].Vendor_1__c = acc.Id;
            sub[1].Vendor__c = acc.Id;
            sub[1].Subscription_Type__c = 'Publication';
            sub[1].Subscription_Type_1__c = 'Publication';
            sub[1].Frequency__c = GlobalVariableClass.SUB_FREQUENCY_FRISUN; 
            sub[1].Frequency_1__c = GlobalVariableClass.SUB_FREQUENCY_FRISUN; 
            sub[1].Contact__c = conRec.Id;
            sub[1].Recipient_Contact__c = conRec.Id;
            sub[1].Recipient_Contact_1__c = conRec.Id;
            sub[1].Ph_d__c = true;
            sub[1].Ph_e__c = true;
            sub[1].Number_of_Copies__c = 51.00;
            sub[1].Number_of_Copies1__c = '51.00';
            sub[1].Qty__c = 51.00;
            sub[1].Qty1__c = '51.00';
            sub[1].Main_Package__c = pack.id;
            sub[1].Main_Package_1__c = pack.id;

            sub[2].Zuora__Account__c = parentAcc.id;
            sub[2].Zuora__CustomerAccount__c = billAcc.Id;
            sub[2].Order_Number__c = orderRec[2].Id;
            sub[2].Order_Number_1__c = orderRec[2].Id;
            sub[2].Delivered_By_1__c = 'Vendor';
            sub[2].Zuora__Status__c = 'Active';
            sub[2].Subscription_Type_1__c = 'Publication';
            sub[2].Zuora__SubscriptionStartDate__c = date.today().addMonths(-12).addDays(1);
            sub[2].Zuora__SubscriptionEndDate__c = date.today();
            sub[2].Term_Length1__c = '12';
            sub[2].Term_Length__c = 12;
            sub[2].Order_Line_Item_Number_1__c = orderline[2].Id;
            sub[2].Order_Line_Item_Number__c = orderline[2].Id;
            sub[2].Delivered_By_1__c = 'Vendor';
            sub[2].Delivered_By__c = 'Vendor';
            sub[2].Vendor_1__c = acc.Id;
            sub[2].Vendor__c = acc.Id;
            sub[2].Subscription_Type__c = 'Publication';
            sub[2].Subscription_Type_1__c = 'Publication';
            sub[2].Frequency__c = GlobalVariableClass.SUB_FREQUENCY_MONFRI;
            sub[2].Frequency_1__c = GlobalVariableClass.SUB_FREQUENCY_MONFRI;
            sub[2].Contact__c = conRec.Id;
            sub[2].Recipient_Contact__c = conRec.Id;
            sub[2].Recipient_Contact_1__c = conRec.Id;
            sub[2].Ph_d__c = true;
            sub[2].Ph_e__c = true;
            sub[2].Number_of_Copies__c = 5.00;
            sub[2].Number_of_Copies1__c = '5.00';
            sub[2].Qty__c = 5.00;
            sub[2].Qty1__c = '5.00';
            sub[2].Main_Package__c = pack.id;
            sub[2].Main_Package_1__c = pack.id;
            database.insert(sub);
            
            
            List<Zuora__SubscriptionProductCharge__c> spcList = TestDataFactory.createSubscriptionProductCharge(5);
            spcList[0].PublicationCode__c = 'DT';
            spcList[0].Zuora__UOM__c = 'Copy Weekday';
            spcList[0].Zuora__Subscription__c = sub[0].Id;
            
            spcList[1].PublicationCode__c = 'DT';
            spcList[1].Zuora__UOM__c = 'Copy Weekday';
            spcList[1].Zuora__Subscription__c = sub[1].Id;
            
            spcList[2].PublicationCode__c = 'DUT';
            spcList[2].Zuora__UOM__c = 'Copy Sunday';
            spcList[2].Zuora__Subscription__c = sub[1].Id;
            
            spcList[3].PublicationCode__c = 'DT';
            spcList[3].Zuora__UOM__c = 'Copy Weekday';
            spcList[3].Zuora__Subscription__c = sub[2].Id;
            
            spcList[4].PublicationCode__c = 'DUT';
            spcList[4].Zuora__UOM__c = 'Copy Sunday';
            spcList[4].Zuora__Subscription__c = sub[2].Id;
            
            insert spcList;

            List<Case> cas = TestDataFactory.createCase(1, 'Start Subscription');
            //cas[0].Temp_Stop__c = temp.Id;
            //cas[0].Temp_Stop__r = temp;
            //cas[0].Effective_Date__c = date.today()+1;
            //cas[0].Change_of_Address_Type__c = 'Change of Vendor';
            //cas[0].Vendor__c  = acc.Id;
            //cas[0].Contact_To_Update__c = con[0].Id;
            cas[0].RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND Name = 'Start Subscription'].Id;
            //cas[0].COA__c = true;
            cas[0].Account = parentAcc;
            cas[0].Accountid = parentAcc.id;
            //cas[0].Temp_Stop_Sub__c = sub[0].id;
            //cas[0].Temp_Stop_Date__c = date.today();
            //cas[0].Restart_Date__c = date.today()+1;
            cas[0].Status = 'Closed';


            database.insert(cas);
                
            List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
            caseSub[0].Case__c = cas[0].Id;
            caseSub[0].Subscription__c = sub[0].Id;
            caseSub[0].Account__c = parentAcc.Id;
            caseSub[0].isComplaint__c = false;

            //caseSub[1].Case__c = cas[1].Id;
            //caseSub[1].Subscription__c = sub[0].Id;    

            //caseSub[2].Case__c = cas[2].Id;
            //caseSub[2].Subscription__c = sub[0].Id;    
            database.insert(caseSub);
                         
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'DUT';
            database.insert(pub);
                
            List<Publication__c> pubSun = TestDataFactory.createPublication(9);
            pubSun[0].Sunday_Publication__c = pub.Id;
            pubSun[0].Publication_Code__c = 'DT';
            //pubSun.Has_Sunday_Pub__c = TRUE;
            pubSun[0].Platform_Type__c = 'Print';
            pubSun[0].Published_Days__c = 'YYYYYYY';
            pubSun[0].Publish_Pattern__c = null;
            
            List<String> pubDates = new List<String>{'YYYYYYN', 'NNNNYYN', 'NNNNNYN', 'YYYYYYY', 'YYYYYNN', 'NNNNYYY', 'NNNNNYY', 'YYYYYYN'};
            Integer pubCtr = 1;
            for(String pd : pubDates){
                pubSun[pubCtr].Publication_Code__c = 'DT';
                pubSun[pubCtr].Platform_Type__c = 'Print';
                pubSun[pubCtr].Published_Days__c = pd;
            }
            
            pubSun[1].Sunday_Publication__c = pub.Id;
            pubSun[2].Sunday_Publication__c = pub.Id;
            
            database.insert(pubSun);

            Parcel__c par = TestDataFactory.createParcel(1)[0];
            par.Project_Name__c = pro.Id;
            par.Allocation_Type__c = 'SDA';
            par.Description__c = 'Description';
            insert par;

            List<Vendor_Allocation__c> venAlloc = TestDataFactory.createVendorAlloc(4);
            venAlloc[0].SingPost_Address__c = postal.Id;
            venAlloc[0].Vendor_Account__c = acc.Id;
            venAlloc[0].Parcel_Name__c = par.Id;
            venAlloc[0].Allocated__c = TRUE;

            venAlloc[1].SingPost_Address__c = postal.Id;
            venAlloc[1].Vendor_Account__c = acc.Id;
            venAlloc[1].Parcel_Name__c = par.Id;
            venAlloc[1].Allocated__c = TRUE;

            venAlloc[2].SingPost_Address__c = postal.Id;
            venAlloc[2].Vendor_Account__c = acc.Id;
            venAlloc[2].Parcel_Name__c = par.Id;
            venAlloc[2].Allocated__c = TRUE;

            venAlloc[3].SingPost_Address__c = postal.Id;
            venAlloc[3].Vendor_Account__c = acc.Id;
            venAlloc[3].Parcel_Name__c = par.Id;
            venAlloc[3].Allocated__c = TRUE;
            venAlloc[3].SingPost_Address__c = postal.Id;
            venAlloc[3].Vendor_Account__c = acc.Id;
            venAlloc[3].Parcel_Name__c = par.Id;
            venAlloc[3].Allocated__c = TRUE;
            insert venAlloc;
            Database.BatchableContext BC;

            Postal_Zone__c postalSector = new Postal_Zone__c();
            postalSector.Name = '10';
            database.insert(postalSector);

            Post_Sector_Ops_Rep_Mapping__c postSectorOps = TestdataFactory.createPostSector(1)[0];
            postSectorOps.Zone__c = postalSector.id;
            postSectorOps.Vendor_Ops__c = u.id; 
            database.insert(postSectorOps);
        }
        
    }
    
    static testmethod void testCreateUser(){
        // User usr = New User(Name = 'Kath', Profile.UserLicense.Name = GlobalVariableClass.USER_LICENSE, Alias='kpunz', ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE 
        //                         AND ContactId IN :vendorStaffContactIdMAP.keyset() AND IsActive = true)
        
        Account parentAcc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            parentAcc.Email__c = 'testemailonly@noemail.com';
            parentAcc.Active__c = true;
            insert parentAcc;
        
        List<Case> cas = TestDataFactory.createCase(1, 'Start Subscription');
            //cas[0].Temp_Stop__c = temp.Id;
            //cas[0].Temp_Stop__r = temp;
            //cas[0].Effective_Date__c = date.today()+1;
            //cas[0].Change_of_Address_Type__c = 'Change of Vendor';
            //cas[0].Vendor__c  = acc.Id;
            //cas[0].Contact_To_Update__c = con[0].Id;
            cas[0].RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND Name = 'Start Subscription'].Id;
            //cas[0].COA__c = true;
            cas[0].Account = parentAcc;
            cas[0].Accountid = parentAcc.id;
            //cas[0].Temp_Stop_Sub__c = sub[0].id;
            //cas[0].Temp_Stop_Date__c = date.today();
            //cas[0].Restart_Date__c = date.today()+1;
            cas[0].Status = 'Closed';


            database.insert(cas);
            
            // test.startTest();
            // Set<Id> subIDs = new Set<Id>();
            // for(Zuora__Subscription__c s : sub){
            //     subIDs.add(s.Id);
            // }
            // SP_VendorNotifChainBatch spchain = new SP_VendorNotifChainBatch(subIDs);
            // Database.executeBatch(spchain);
            // test.stopTest();
    }
    
    static testmethod void test_normalExpiry(){
        // prepareTestData();
        
        user  u = TestDataFactory.prepareTestusers();
        u.Validation_Exempted__c = true;
        System.runAs(u){
            Project__c pro = TestDataFactory.createProject(1)[0];
            pro.Project_Description__c = 'This is a new confidential project.';
            database.insert(pro);
            
            acc = TestDataFactory.createAccount(1, 'Vendor')[0];
            acc.Active__c = true;
            database.insert(acc);

            postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            postal.Name = '10000';
            database.insert(postal);

            ad = TestDataFactory.createAddress(1)[0];
            ad.Postal_Code__c = postal.id;
            database.insert(ad);
            
            Account parentAcc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            parentAcc.Email__c = 'testemailonly@noemail.com';
            parentAcc.Active__c = true;
            insert parentAcc;
            
            Recordtype rectypeConCustomer = [SELECT Id, Name from Recordtype where sObjecttype = 'Contact' and Name = 'Customer Contact' LIMIT 1];
            Contact conRec = TestDataFactory.createContact(1)[0];
            conRec.Recordtypeid = rectypeConCustomer.id;
            conRec.Account = parentAcc;
            conRec.AccountId = parentAcc.id;
            conRec.Recipient_Indicator__c = true; 
            conRec.Billing_Indicator__c = true; 
            conRec.Address__c = ad.id;
            conRec.Active__c = true;
            insert conRec;

            Recordtype rectypeCon = [SELECT Id, Name from Recordtype where sObjecttype = 'Contact' and Name = 'Vendor Staff' LIMIT 1];
            con = TestDataFactory.createContact(3);
            con[0].Recordtypeid = rectypeCon.id;
            con[0].Account = acc;
            con[0].AccountId = acc.id;
            con[0].Recipient_Indicator__c = true; 
            con[0].Address__c = ad.id;
            con[0].Active__c = true;
            con[0].Vendor_Communication_Preference__c  = 'SMS';

            con[1].Recordtypeid = rectypeCon.id;
            con[1].Account = acc;
            con[1].AccountId = acc.id;
            con[1].Recipient_Indicator__c = true; 
            con[1].Address__c = ad.id;
            con[1].Active__c = true;
            con[1].Vendor_Communication_Preference__c  = 'Email';

            con[2].Recordtypeid = rectypeCon.id;
            con[2].Account = acc;
            con[2].AccountId = acc.id;
            con[2].Recipient_Indicator__c = true; 
            con[2].Address__c = ad.id;
            con[2].Active__c = true;
            con[2].Vendor_Communication_Preference__c  = 'Email';
            database.insert(con);  

            Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
            temp.Restart_Date__c = date.today()+1;
            database.insert(temp);

            pack = TestDataFactory.createPackage(1)[0];
            pack.Subscription_Period__c = '15'; 
            pack.Package_Type__c = 'Base'; //packageType;
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Subscription_Period__c = '12'; //subPeriod;
            database.insert(pack);   
            
            Product_Family__c pf = new Product_Family__c();
            pf.Product_Family__c = GlobalVariableClass.PLATFORM_PRINT;
            pf.Product_Family_Name__c = GlobalVariableClass.PLATFORM_PRINT;
            insert pf;
            
            // Raus Ablaza
            // create zProduct and Rate Plan
            List<zqu__ZProduct__c> zProds = TestDataFactory.createZProduct(1);
            zqu__ZProduct__c zProd = zProds[0];
            zProd.ProductPlatform__c = GlobalVariableClass.PLATFORM_PRINT;
            insert zProd;
            
            List<zqu__ProductRatePlan__c> zProdRateList = TestDataFactory.createProductRatePlan(1);
            zqu__ProductRatePlan__c zProdRate = zProdRateList[0];
            zProdRate.zqu__ZProduct__c = zProd.Id;
            insert zProdRate;
            
            pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.id;
                pItem.RecordTypeId = ConstantsSLB.getKeyId('Package Item_Base Product');
                pItem.Product_Family__c = pf.id;
                pItem.Product_Rate_Plan__c = zProdRate.Id;
                //pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                //pItem.RecordTypeId = constantsSLB.getKeyID('Package Item_Discount');
            } //RecordType.Name = 'Discount' && Product_Rate_Plan__r.RatePlanType__c != 'Discount'
            insert pItems;
                
            billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            ARMS_TriggerHandler.isSkipUpdate = true;
            database.insert(billAcc);

            orderRec = TestDataFactory.createOrder(3);
            orderRec[0].Account__c = acc.Id;
            orderRec[0].Informed_Customer__c = TRUE;
            orderRec[0].Recipient_Contact__c = con[0].Id;
            orderRec[0].Subscriber_Charge__c = 100.00;
            

            orderRec[1].Account__c = acc.Id;
            orderRec[1].Informed_Customer__c = TRUE;
            orderRec[1].Recipient_Contact__c = con[1].Id;
            orderRec[1].Subscriber_Charge__c = 100.00;

            orderRec[2].Account__c = acc.Id;
            orderRec[2].Informed_Customer__c = TRUE;
            orderRec[2].Recipient_Contact__c = con[2].Id;
            orderRec[2].Subscriber_Charge__c = 100.00;

            insert orderRec;

            orderline = TestDataFactory.createOrderLineItem(3);
            orderline[0].Order__c = orderRec[0].Id;
            //orderline[0].Subscription__c = sub[0].id;
            orderline[0].Main_Package_ID__c = pack.Id;
            orderline[0].Start_Date__c = date.today()+1;
            orderline[0].End_Date__c = date.today().addMonths(12);

            orderline[1].Order__c = orderRec[1].Id;
            //orderline[1].Subscription__c = sub[1].id;
            orderline[1].Main_Package_ID__c = pack.Id;
            orderline[1].Start_Date__c = date.today()+1;
            orderline[1].End_Date__c = date.today().addMonths(12);
            orderline[1].Qty__c = 51;

            orderline[2].Order__c = orderRec[2].Id;
            //orderline[2].Subscription__c = sub[2].id;
            orderline[2].Main_Package_ID__c = pack.Id;
            orderline[2].Start_Date__c = date.today().addMonths(-12).addDays(1);
            orderline[2].End_Date__c = date.today();
            orderline[2].Qty__c = 5;
            insert orderline;
                       
            sub = TestDataFactory.createSubscription(3);
            sub[0].Zuora__Account__c = parentAcc.id;
            sub[0].Zuora__CustomerAccount__c = billAcc.Id;
            sub[0].Order_Number__c  = orderRec[0].Id;
            sub[0].Order_Number_1__c = orderRec[0].Id;
            sub[0].Zuora__SubscriptionStartDate__c = date.today()+1;
            sub[0].Zuora__SubscriptionEndDate__c = date.today().addMonths(12);
            sub[0].Term_Length1__c = '12';
            sub[0].Term_Length__c = 12;
            sub[0].Order_Line_Item_Number_1__c = orderline[0].Id;
            sub[0].Order_Line_Item_Number__c = orderline[0].Id;
            sub[0].Delivered_By_1__c = 'Vendor';
            sub[0].Delivered_By__c = 'Vendor';
            sub[0].Vendor_1__c = acc.Id;
            sub[0].Vendor__c = acc.Id;
            sub[0].Subscription_Type__c = 'Publication';
            sub[0].Subscription_Type_1__c = 'Publication';
            sub[0].Frequency__c = GlobalVariableClass.FREQUENCY_DEFAULT;
            sub[0].Frequency_1__c = GlobalVariableClass.FREQUENCY_DEFAULT; 
            sub[0].Contact__c = conRec.Id;
            sub[0].Recipient_Contact__c = conRec.Id;
            sub[0].Recipient_Contact_1__c = conRec.Id;
            
            sub[1].Zuora__Account__c = parentAcc.id;
            sub[1].Zuora__CustomerAccount__c = billAcc.Id;
            sub[1].Order_Number__c = orderRec[1].Id;
            sub[1].Order_Number_1__c = orderRec[1].Id;
            sub[1].Delivered_By_1__c = 'Vendor';
            sub[1].Zuora__Status__c = 'Active';
            sub[1].Subscription_Type_1__c = 'Publication';
            sub[1].Zuora__SubscriptionStartDate__c = date.today()+1;
            sub[1].Zuora__SubscriptionEndDate__c = date.today().addMonths(12);
            sub[1].Term_Length1__c = '12';
            sub[1].Term_Length__c = 12;
            sub[1].Order_Line_Item_Number_1__c = orderline[1].Id;
            sub[1].Order_Line_Item_Number__c = orderline[1].Id;
            sub[1].Delivered_By_1__c = 'Vendor';
            sub[1].Delivered_By__c = 'Vendor';
            sub[1].Vendor_1__c = acc.Id;
            sub[1].Vendor__c = acc.Id;
            sub[1].Subscription_Type__c = 'Publication';
            sub[1].Subscription_Type_1__c = 'Publication';
            sub[1].Frequency__c = GlobalVariableClass.SUB_FREQUENCY_FRISUN; 
            sub[1].Frequency_1__c = GlobalVariableClass.SUB_FREQUENCY_FRISUN; 
            sub[1].Contact__c = conRec.Id;
            sub[1].Recipient_Contact__c = conRec.Id;
            sub[1].Recipient_Contact_1__c = conRec.Id;
            sub[1].Ph_d__c = true;
            sub[1].Ph_e__c = true;
            sub[1].Number_of_Copies__c = 51.00;
            sub[1].Number_of_Copies1__c = '51.00';
            sub[1].Qty__c = 51.00;
            sub[1].Qty1__c = '51.00';
            sub[1].Main_Package__c = pack.id;
            sub[1].Main_Package_1__c = pack.id;

            sub[2].Zuora__Account__c = parentAcc.id;
            sub[2].Zuora__CustomerAccount__c = billAcc.Id;
            sub[2].Order_Number__c = orderRec[2].Id;
            sub[2].Order_Number_1__c = orderRec[2].Id;
            sub[2].Delivered_By_1__c = 'Vendor';
            sub[2].Zuora__Status__c = 'Active';
            sub[2].Subscription_Type_1__c = 'Publication';
            sub[2].Zuora__SubscriptionStartDate__c = date.today().addMonths(-12).addDays(1);
            sub[2].Zuora__SubscriptionEndDate__c = date.today();
            sub[2].Term_Length1__c = '12';
            sub[2].Term_Length__c = 12;
            sub[2].Order_Line_Item_Number_1__c = orderline[2].Id;
            sub[2].Order_Line_Item_Number__c = orderline[2].Id;
            sub[2].Delivered_By_1__c = 'Vendor';
            sub[2].Delivered_By__c = 'Vendor';
            sub[2].Vendor_1__c = acc.Id;
            sub[2].Vendor__c = acc.Id;
            sub[2].Subscription_Type__c = 'Publication';
            sub[2].Subscription_Type_1__c = 'Publication';
            sub[2].Frequency__c = GlobalVariableClass.SUB_FREQUENCY_MONFRI;
            sub[2].Frequency_1__c = GlobalVariableClass.SUB_FREQUENCY_MONFRI;
            sub[2].Contact__c = conRec.Id;
            sub[2].Recipient_Contact__c = conRec.Id;
            sub[2].Recipient_Contact_1__c = conRec.Id;
            sub[2].Ph_d__c = true;
            sub[2].Ph_e__c = true;
            sub[2].Number_of_Copies__c = 5.00;
            sub[2].Number_of_Copies1__c = '5.00';
            sub[2].Qty__c = 5.00;
            sub[2].Qty1__c = '5.00';
            sub[2].Main_Package__c = pack.id;
            sub[2].Main_Package_1__c = pack.id;
            database.insert(sub);
            
            
            List<Zuora__SubscriptionProductCharge__c> spcList = TestDataFactory.createSubscriptionProductCharge(5);
            spcList[0].PublicationCode__c = 'DT';
            spcList[0].Zuora__UOM__c = 'Copy Weekday';
            spcList[0].Zuora__Subscription__c = sub[0].Id;
            
            spcList[1].PublicationCode__c = 'DT';
            spcList[1].Zuora__UOM__c = 'Copy Weekday';
            spcList[1].Zuora__Subscription__c = sub[1].Id;
            
            spcList[2].PublicationCode__c = 'DUT';
            spcList[2].Zuora__UOM__c = 'Copy Sunday';
            spcList[2].Zuora__Subscription__c = sub[1].Id;
            
            spcList[3].PublicationCode__c = 'DT';
            spcList[3].Zuora__UOM__c = 'Copy Weekday';
            spcList[3].Zuora__Subscription__c = sub[2].Id;
            
            spcList[4].PublicationCode__c = 'DUT';
            spcList[4].Zuora__UOM__c = 'Copy Sunday';
            spcList[4].Zuora__Subscription__c = sub[2].Id;
            
            insert spcList;
            
            test.startTest();

            List<Case> cas = TestDataFactory.createCase(1, 'Start Subscription');
            //cas[0].Temp_Stop__c = temp.Id;
            //cas[0].Temp_Stop__r = temp;
            //cas[0].Effective_Date__c = date.today()+1;
            //cas[0].Change_of_Address_Type__c = 'Change of Vendor';
            //cas[0].Vendor__c  = acc.Id;
            //cas[0].Contact_To_Update__c = con[0].Id;
            cas[0].RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND Name = 'Start Subscription'].Id;
            //cas[0].COA__c = true;
            cas[0].Account = parentAcc;
            cas[0].Accountid = parentAcc.id;
            //cas[0].Temp_Stop_Sub__c = sub[0].id;
            //cas[0].Temp_Stop_Date__c = date.today();
            //cas[0].Restart_Date__c = date.today()+1;
            cas[0].Status = 'Closed';


            database.insert(cas);
                
            List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
            caseSub[0].Case__c = cas[0].Id;
            caseSub[0].Subscription__c = sub[0].Id;
            caseSub[0].Account__c = parentAcc.Id;
            caseSub[0].isComplaint__c = false;

            //caseSub[1].Case__c = cas[1].Id;
            //caseSub[1].Subscription__c = sub[0].Id;    

            //caseSub[2].Case__c = cas[2].Id;
            //caseSub[2].Subscription__c = sub[0].Id;    
            database.insert(caseSub);
                         
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'DUT';
            database.insert(pub);
                
            Publication__c pubSun = TestDataFactory.createPublication(1)[0];
            pubSun.Sunday_Publication__c = pub.Id;
            pubSun.Publication_Code__c = 'DT';
            //pubSun.Has_Sunday_Pub__c = TRUE;
            pubSun.Platform_Type__c = 'Print';
            pubSun.Published_Days__c = 'YYYYYYY';
            pubSun.Publish_Pattern__c = null;
            database.insert(pubSun);

            Parcel__c par = TestDataFactory.createParcel(1)[0];
            par.Project_Name__c = pro.Id;
            par.Allocation_Type__c = 'SDA';
            par.Description__c = 'Description';
            insert par;

            List<Vendor_Allocation__c> venAlloc = TestDataFactory.createVendorAlloc(4);
            venAlloc[0].SingPost_Address__c = postal.Id;
            venAlloc[0].Vendor_Account__c = acc.Id;
            venAlloc[0].Parcel_Name__c = par.Id;
            venAlloc[0].Allocated__c = TRUE;

            venAlloc[1].SingPost_Address__c = postal.Id;
            venAlloc[1].Vendor_Account__c = acc.Id;
            venAlloc[1].Parcel_Name__c = par.Id;
            venAlloc[1].Allocated__c = TRUE;

            venAlloc[2].SingPost_Address__c = postal.Id;
            venAlloc[2].Vendor_Account__c = acc.Id;
            venAlloc[2].Parcel_Name__c = par.Id;
            venAlloc[2].Allocated__c = TRUE;

            venAlloc[3].SingPost_Address__c = postal.Id;
            venAlloc[3].Vendor_Account__c = acc.Id;
            venAlloc[3].Parcel_Name__c = par.Id;
            venAlloc[3].Allocated__c = TRUE;
            venAlloc[3].SingPost_Address__c = postal.Id;
            venAlloc[3].Vendor_Account__c = acc.Id;
            venAlloc[3].Parcel_Name__c = par.Id;
            venAlloc[3].Allocated__c = TRUE;
            insert venAlloc;
            Database.BatchableContext BC;

            Postal_Zone__c postalSector = new Postal_Zone__c();
            postalSector.Name = '10';
            database.insert(postalSector);

            Post_Sector_Ops_Rep_Mapping__c postSectorOps = TestdataFactory.createPostSector(1)[0];
            postSectorOps.Zone__c = postalSector.id;
            postSectorOps.Vendor_Ops__c = u.id; 
            database.insert(postSectorOps);
        // }
        
        // user  u = [select Id from User where UserName = 'userstand3541987*@testorg.com'];
        // u.Validation_Exempted__c = true;
        // System.runAs(u){
        
            SP_VendorNotificationsBatch sp = new SP_VendorNotificationsBatch();
            Id testBatchId = Database.executeBatch(sp, 200);
            System.assertNotEquals(testBatchId, null);
            test.stopTest();
        }
    }
    
    static testmethod void constructMail_Test(){
        
        SP_VendorNotifChainBatch.mailTextWrapper mWrapper = New SP_VendorNotifChainBatch.mailTextWrapper();
            mWrapper.mailBodyTop = 'sss';
            mWrapper.mailBodyMid = 'sss';
            mWrapper.mailBodyBottom = 'sss';
            mWrapper.mailtoAddress = new List<String>{'aaa@yahoo.com', 'bbb@yahoo.com'}; 
            
            mWrapper.SMSmessageTop = 'sss';
            mWrapper.SMSmessageMid = 'sss';
            mWrapper.SMSmessageBottom = 'ssdasdasdasdasds';
            mWrapper.SMSMobile = new List<String>{'aaa@yahoo.com', 'bbb@yahoo.com'};
            
            mWrapper.OwnerId = 'sss';
            mWrapper.WhoId = new List<String>{'aaa', 'bbb'};
            mWrapper.Description = 'sss';
            mWrapper.taskSubject = 'sss';
            
            mWrapper.sendMailKey = TRUE;
            mWrapper.RecordTypeId = 'sss';
            mWrapper.transactionPartnerCOS = 'sss';
            mWrapper.transactionNameCOS = 'sss';
            mWrapper.addressId = 'sss';
            mWrapper.vendorId = 'sss';
            
        String transactionNameParam = 'HelloWorld'; 
        List<String> toAddressesParam = new List<String>{'aaa@yahoo.com', 'bbb@yahoo.com'};
        
        List<Account> accList = TestDataFactory.createAccount(1, 'Vendor');   
            accList[0].Name = 'mailing Acct';
            accList[0].Mailing_Agent_Code__c = '0012156';
            acclist[0].PostalCode__c = '545848';
            insert accList;
            
        Singpost_Address__c singPost = TestDataFactory.createSingpostAddress(1)[0];
            singPost.Name = '123';
            singPost.House_Block_Number__c = 'TEST';
            singPost.Address_Type__c = 'A'; 
            singPost.SingPost_Key__c = '1212';
            singPost.Street_Name__c = 'Guada';
            insert singPost; 
            
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = singPost.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            insert addressRec;
     
     
        Contact cont = TestDataFactory.createContact(1)[0];
            cont.Address__c = addressRec.Id;
            cont.AccountId = accList[0].Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            cont.Recipient_Indicator__c = true;
            cont.Billing_Indicator__c = true;
            insert cont;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList;
        
        Package__c packa = TestDataFactory.createPackage(1)[0];
            database.insert(packa);
            
        List<Order__c> orderList = TestDataFactory.createOrder(1);
            //set order values 
            orderList[0].Account__c = accList[0].id;
            //orderList[0].Status__c = 'Draft';
            orderList[0].DTL_Date__c = date.today();
            orderList[0].Account__c = accList[0].id;
            //orderList[0].Status__c = 'Draft';
            orderList[0].Recipient_Contact__c = cont.id;
            orderList[0].Vendor_Sms_Remarks__c = 'dsdasdsadsa lkflkdflkdflkdkfhkjfhlkdhf';
            
          database.insert(orderList); 
          System.debug('CHECK == '+ orderList);
        
        Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];
            zsub.Name = 'Ron';
            zsub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zsub.Main_Package_1__c = packa.id;
            zsub.Main_Package__c = packa.Id;
            zsub.Zuora__Account__c = acclist[0].id;
            zsub.Recipient_Contact__c = cont.Id;
            //zsub.Recipient_Contact_1__c = con.Id;
            zsub.Subscriber_Contact__c = cont.Id;
            //zsub.Subscriber_Contact_1__c = con.Id;
            zsub.Frequency_1__c = 'Mon - Fri';
            zsub.Frequency__c = 'Mon - Fri';
            zsub.Number_of_Copies__c = 2;
            zsub.Subscription_End_Date__c = string.valueOf(date.today());
            zSub.Contact__c = cont.id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Delivered_By_1__c = 'Vendor';
            zSub.Vendor_1__c = accList[0].id;
            zsub.Order_Number_1__c = orderList[0].id;
            
            database.insert(zsub); 
            System.debug('CHECK == '+zsub.Order_Number_1__c);
            
       Zuora__Subscription__c zuSub = [SELECT Id, Name, Order_Number_1__r.Vendor_Sms_Remarks__c, Vendor_1__c, Recipient_Contact__c, Zuora__CustomerAccount__c, Main_Package_1__c, 
                                        Main_Package__c, Zuora__Account__c, Subscriber_Contact__c, Contact__c FROM Zuora__Subscription__c where Id =:zsub.Id];
            
        
       // Zuora__Subscription__c subscriptionParam, 
        Map<Id, String> conId_AliasMapParam = new Map<Id, String>();
        conId_AliasMapParam.put(zSub.Recipient_Contact__c, 'dsadas'); 
        
        String issueDateParam = '00:00:00'; 
        String subParam = ''; 
        //Address__c addressObjParam, 
        //Singpost_Address__c singpostAddressObjParam, 
        String classificationParam = '';
        Map<Id, id> conId_NameMapParam = new Map<Id, id>();
        conId_NameMapParam.put(cont.Id, zSub.Vendor_1__c); 
        boolean isSendEmailParam = TRUE;
        
        test.startTest();
        SP_VendorNotifChainBatch sp = new SP_VendorNotifChainBatch(new Set<id>());
        sp.constructMail(transactionNameParam, toAddressesParam, zuSub, conId_AliasMapParam, issueDateParam, subParam, addressRec, singPost, classificationParam, conId_NameMapParam, isSendEmailParam);
        test.stopTest();
        
    }
    
    static testmethod void constructMail_Test2(){
        
        SP_VendorNotifChainBatch.mailTextWrapper mWrapper = New SP_VendorNotifChainBatch.mailTextWrapper();
            mWrapper.mailBodyTop = 'sss';
            mWrapper.mailBodyMid = 'sss';
            mWrapper.mailBodyBottom = 'sss';
            mWrapper.mailtoAddress = new List<String>{'aaa@yahoo.com', 'bbb@yahoo.com'}; 
            
            mWrapper.SMSmessageTop = 'sss';
            mWrapper.SMSmessageMid = 'sss';
            mWrapper.SMSmessageBottom = 'ssdasdasdasdasds';
            mWrapper.SMSMobile = new List<String>{'aaa@yahoo.com', 'bbb@yahoo.com'};
            
            mWrapper.OwnerId = 'sss';
            mWrapper.WhoId = new List<String>{'aaa', 'bbb'};
            mWrapper.Description = 'sss';
            mWrapper.taskSubject = 'sss';
            
            mWrapper.sendMailKey = TRUE;
            mWrapper.RecordTypeId = 'sss';
            mWrapper.transactionPartnerCOS = 'sss';
            mWrapper.transactionNameCOS = 'sss';
            mWrapper.addressId = 'sss';
            mWrapper.vendorId = 'sss';
            
        SP_VendorNotifChainBatch mMap = New SP_VendorNotifChainBatch(new Set<id>());
        mMap.mailText_Map.put('dsdss', mWrapper);
        
        System.debug('CHECK =='+mMap.mailText_Map.put('dsdss', mWrapper));
            
        String transactionNameParam = 'HelloWorld'; 
        List<String> toAddressesParam = new List<String>{'aaa@yahoo.com', 'bbb@yahoo.com'};
        
        List<Account> accList = TestDataFactory.createAccount(1, 'Vendor');   
            accList[0].Name = 'mailing Acct';
            accList[0].Mailing_Agent_Code__c = '0012156';
            acclist[0].PostalCode__c = '545848';
            insert accList;
            
        Singpost_Address__c singPost = TestDataFactory.createSingpostAddress(1)[0];
            singPost.Name = '123';
            singPost.House_Block_Number__c = 'TEST';
            singPost.Address_Type__c = 'A'; 
            singPost.SingPost_Key__c = '1212';
            singPost.Street_Name__c = 'Guada';
            insert singPost; 
            
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = singPost.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            insert addressRec;
     
     
        Contact cont = TestDataFactory.createContact(1)[0];
            cont.Address__c = addressRec.Id;
            cont.AccountId = accList[0].Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            cont.Recipient_Indicator__c = true;
            cont.Billing_Indicator__c = true;
            insert cont;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList;
        
        Package__c packa = TestDataFactory.createPackage(1)[0];
            database.insert(packa);
            
        List<Order__c> orderList = TestDataFactory.createOrder(1);
            //set order values 
            orderList[0].Account__c = accList[0].id;
            //orderList[0].Status__c = 'Draft';
            orderList[0].DTL_Date__c = date.today();
            orderList[0].Account__c = accList[0].id;
            //orderList[0].Status__c = 'Draft';
            orderList[0].Recipient_Contact__c = cont.id;
            orderList[0].Vendor_Sms_Remarks__c = 'dsdasdsadsa lkflkdflkdflkdkfhkjfhlkdhf';
            
          database.insert(orderList); 
          System.debug('CHECK == '+ orderList);
        
        Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];
            zsub.Name = 'Ron';
            zsub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zsub.Main_Package_1__c = packa.id;
            zsub.Main_Package__c = packa.Id;
            zsub.Zuora__Account__c = acclist[0].id;
            zsub.Recipient_Contact__c = cont.Id;
            //zsub.Recipient_Contact_1__c = con.Id;
            zsub.Subscriber_Contact__c = cont.Id;
            //zsub.Subscriber_Contact_1__c = con.Id;
            zsub.Frequency_1__c = 'Mon - Fri';
            zsub.Frequency__c = 'Mon - Fri';
            zsub.Number_of_Copies__c = 2;
            zsub.Subscription_End_Date__c = string.valueOf(date.today());
            zSub.Contact__c = cont.id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Delivered_By_1__c = 'Vendor';
            zSub.Vendor_1__c = accList[0].id;
            zsub.Order_Number_1__c = orderList[0].id;
            
            database.insert(zsub); 
            
       Zuora__Subscription__c zuSub = [SELECT Id, Name, Order_Number_1__r.Vendor_Sms_Remarks__c, Vendor_1__c,  Recipient_Contact__c, Zuora__CustomerAccount__c, Main_Package_1__c, 
                                        Main_Package__c, Zuora__Account__c, Subscriber_Contact__c, Contact__c FROM Zuora__Subscription__c where Id =:zsub.Id];
            System.debug('CHECKVendor == '+zsub.Vendor_1__r.Id);
        
       // Zuora__Subscription__c subscriptionParam, 
        Map<Id, String> conId_AliasMapParam = new Map<Id, String>();
        conId_AliasMapParam.put(zSub.Recipient_Contact__c, 'dsadas'); 
        
        String issueDateParam = '00:00:00'; 
        String subParam = ''; 
        //Address__c addressObjParam, 
        //Singpost_Address__c singpostAddressObjParam, 
        String classificationParam = '';
        Map<Id, id> conId_NameMapParam = new Map<Id, id>();
        conId_NameMapParam.put(cont.Id, zSub.Vendor_1__c); 
        boolean isSendEmailParam = TRUE;
        
        // test.startTest();
        // SP_VendorNotifChainBatch sp = new SP_VendorNotifChainBatch(new Set<id>());
        // sp.constructMail(transactionNameParam, toAddressesParam, zuSub, conId_AliasMapParam, issueDateParam, subParam, addressRec, singPost, classificationParam, conId_NameMapParam, isSendEmailParam);
        // test.stopTest();
        
    }
    
    static testmethod void test_normalExpirySelective(){
        // prepareTestData();
        
        user  u = TestDataFactory.prepareTestusers();
        u.Validation_Exempted__c = true;
        System.runAs(u){
            Project__c pro = TestDataFactory.createProject(1)[0];
            pro.Project_Description__c = 'This is a new confidential project.';
            database.insert(pro);
            
            acc = TestDataFactory.createAccount(1, 'Vendor')[0];
            acc.Active__c = true;
            database.insert(acc);

            postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            postal.Name = '10000';
            database.insert(postal);

            ad = TestDataFactory.createAddress(1)[0];
            ad.Postal_Code__c = postal.id;
            database.insert(ad);
            
            Account parentAcc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            parentAcc.Email__c = 'testemailonly@noemail.com';
            parentAcc.Active__c = true;
            insert parentAcc;
            
            Recordtype rectypeConCustomer = [SELECT Id, Name from Recordtype where sObjecttype = 'Contact' and Name = 'Customer Contact' LIMIT 1];
            Contact conRec = TestDataFactory.createContact(1)[0];
            conRec.Recordtypeid = rectypeConCustomer.id;
            conRec.Account = parentAcc;
            conRec.AccountId = parentAcc.id;
            conRec.Recipient_Indicator__c = true; 
            conRec.Billing_Indicator__c = true; 
            conRec.Address__c = ad.id;
            conRec.Active__c = true;
            insert conRec;

            Recordtype rectypeCon = [SELECT Id, Name from Recordtype where sObjecttype = 'Contact' and Name = 'Vendor Staff' LIMIT 1];
            con = TestDataFactory.createContact(3);
            con[0].Recordtypeid = rectypeCon.id;
            con[0].Account = acc;
            con[0].AccountId = acc.id;
            con[0].Recipient_Indicator__c = true; 
            con[0].Address__c = ad.id;
            con[0].Active__c = true;
            con[0].Vendor_Communication_Preference__c  = 'SMS';

            con[1].Recordtypeid = rectypeCon.id;
            con[1].Account = acc;
            con[1].AccountId = acc.id;
            con[1].Recipient_Indicator__c = true; 
            con[1].Address__c = ad.id;
            con[1].Active__c = true;
            con[1].Vendor_Communication_Preference__c  = 'Email';

            con[2].Recordtypeid = rectypeCon.id;
            con[2].Account = acc;
            con[2].AccountId = acc.id;
            con[2].Recipient_Indicator__c = true; 
            con[2].Address__c = ad.id;
            con[2].Active__c = true;
            con[2].Vendor_Communication_Preference__c  = 'Email';
            database.insert(con);  

            Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
            temp.Restart_Date__c = date.today()+1;
            database.insert(temp);

            pack = TestDataFactory.createPackage(1)[0];
            pack.Subscription_Period__c = '15'; 
            pack.Package_Type__c = 'Base'; //packageType;
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Subscription_Period__c = '12'; //subPeriod;
            database.insert(pack);   
            
            Product_Family__c pf = new Product_Family__c();
            pf.Product_Family__c = GlobalVariableClass.PLATFORM_PRINT;
            pf.Product_Family_Name__c = GlobalVariableClass.PLATFORM_PRINT;
            insert pf;
            
            // Raus Ablaza
            // create zProduct and Rate Plan
            List<zqu__ZProduct__c> zProds = TestDataFactory.createZProduct(1);
            zqu__ZProduct__c zProd = zProds[0];
            zProd.ProductPlatform__c = GlobalVariableClass.PLATFORM_PRINT;
            insert zProd;
            
            List<zqu__ProductRatePlan__c> zProdRateList = TestDataFactory.createProductRatePlan(1);
            zqu__ProductRatePlan__c zProdRate = zProdRateList[0];
            zProdRate.zqu__ZProduct__c = zProd.Id;
            insert zProdRate;
            
            pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.id;
                pItem.RecordTypeId = ConstantsSLB.getKeyId('Package Item_Base Product');
                pItem.Product_Family__c = pf.id;
                pItem.Product_Rate_Plan__c = zProdRate.Id;
                //pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                //pItem.RecordTypeId = constantsSLB.getKeyID('Package Item_Discount');
            } //RecordType.Name = 'Discount' && Product_Rate_Plan__r.RatePlanType__c != 'Discount'
            insert pItems;
                
            billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            ARMS_TriggerHandler.isSkipUpdate = true;
            database.insert(billAcc);

            orderRec = TestDataFactory.createOrder(3);
            orderRec[0].Account__c = acc.Id;
            orderRec[0].Informed_Customer__c = TRUE;
            orderRec[0].Recipient_Contact__c = con[0].Id;
            orderRec[0].Subscriber_Charge__c = 100.00;
            

            orderRec[1].Account__c = acc.Id;
            orderRec[1].Informed_Customer__c = TRUE;
            orderRec[1].Recipient_Contact__c = con[1].Id;
            orderRec[1].Subscriber_Charge__c = 100.00;

            orderRec[2].Account__c = acc.Id;
            orderRec[2].Informed_Customer__c = TRUE;
            orderRec[2].Recipient_Contact__c = con[2].Id;
            orderRec[2].Subscriber_Charge__c = 100.00;

            insert orderRec;

            orderline = TestDataFactory.createOrderLineItem(3);
            orderline[0].Order__c = orderRec[0].Id;
            //orderline[0].Subscription__c = sub[0].id;
            orderline[0].Main_Package_ID__c = pack.Id;
            orderline[0].Start_Date__c = date.today()+1;
            orderline[0].End_Date__c = date.today().addMonths(12);

            orderline[1].Order__c = orderRec[1].Id;
            //orderline[1].Subscription__c = sub[1].id;
            orderline[1].Main_Package_ID__c = pack.Id;
            orderline[1].Start_Date__c = date.today()+1;
            orderline[1].End_Date__c = date.today().addMonths(12);
            orderline[1].Qty__c = 51;

            orderline[2].Order__c = orderRec[2].Id;
            //orderline[2].Subscription__c = sub[2].id;
            orderline[2].Main_Package_ID__c = pack.Id;
            orderline[2].Start_Date__c = date.today().addMonths(-12).addDays(1);
            orderline[2].End_Date__c = date.today();
            orderline[2].Qty__c = 5;
            insert orderline;
                       
            sub = TestDataFactory.createSubscription(3);
            sub[0].Zuora__Account__c = parentAcc.id;
            sub[0].Zuora__CustomerAccount__c = billAcc.Id;
            sub[0].Order_Number__c  = orderRec[0].Id;
            sub[0].Order_Number_1__c = orderRec[0].Id;
            sub[0].Zuora__SubscriptionStartDate__c = date.today()+1;
            sub[0].Zuora__SubscriptionEndDate__c = date.today().addMonths(12);
            sub[0].Term_Length1__c = '12';
            sub[0].Term_Length__c = 12;
            sub[0].Order_Line_Item_Number_1__c = orderline[0].Id;
            sub[0].Order_Line_Item_Number__c = orderline[0].Id;
            sub[0].Delivered_By_1__c = 'Vendor';
            sub[0].Delivered_By__c = 'Vendor';
            sub[0].Vendor_1__c = acc.Id;
            sub[0].Vendor__c = acc.Id;
            sub[0].Subscription_Type__c = 'Publication';
            sub[0].Subscription_Type_1__c = 'Publication';
            sub[0].Frequency__c = GlobalVariableClass.FREQUENCY_DEFAULT;
            sub[0].Frequency_1__c = GlobalVariableClass.FREQUENCY_DEFAULT; 
            sub[0].Contact__c = conRec.Id;
            sub[0].Recipient_Contact__c = conRec.Id;
            sub[0].Recipient_Contact_1__c = conRec.Id;
            
            sub[1].Zuora__Account__c = parentAcc.id;
            sub[1].Zuora__CustomerAccount__c = billAcc.Id;
            sub[1].Order_Number__c = orderRec[1].Id;
            sub[1].Order_Number_1__c = orderRec[1].Id;
            sub[1].Delivered_By_1__c = 'Vendor';
            sub[1].Zuora__Status__c = 'Active';
            sub[1].Subscription_Type_1__c = 'Publication';
            sub[1].Zuora__SubscriptionStartDate__c = date.today()+1;
            sub[1].Zuora__SubscriptionEndDate__c = date.today().addMonths(12);
            sub[1].Term_Length1__c = '12';
            sub[1].Term_Length__c = 12;
            sub[1].Order_Line_Item_Number_1__c = orderline[1].Id;
            sub[1].Order_Line_Item_Number__c = orderline[1].Id;
            sub[1].Delivered_By_1__c = 'Vendor';
            sub[1].Delivered_By__c = 'Vendor';
            sub[1].Vendor_1__c = acc.Id;
            sub[1].Vendor__c = acc.Id;
            sub[1].Subscription_Type__c = 'Publication';
            sub[1].Subscription_Type_1__c = 'Publication';
            sub[1].Frequency__c = GlobalVariableClass.SUB_FREQUENCY_FRISUN; 
            sub[1].Frequency_1__c = GlobalVariableClass.SUB_FREQUENCY_FRISUN; 
            sub[1].Contact__c = conRec.Id;
            sub[1].Recipient_Contact__c = conRec.Id;
            sub[1].Recipient_Contact_1__c = conRec.Id;
            sub[1].Ph_d__c = true;
            sub[1].Ph_e__c = true;
            sub[1].Number_of_Copies__c = 51.00;
            sub[1].Number_of_Copies1__c = '51.00';
            sub[1].Qty__c = 51.00;
            sub[1].Qty1__c = '51.00';
            sub[1].Main_Package__c = pack.id;
            sub[1].Main_Package_1__c = pack.id;

            sub[2].Zuora__Account__c = parentAcc.id;
            sub[2].Zuora__CustomerAccount__c = billAcc.Id;
            sub[2].Order_Number__c = orderRec[2].Id;
            sub[2].Order_Number_1__c = orderRec[2].Id;
            sub[2].Delivered_By_1__c = 'Vendor';
            sub[2].Zuora__Status__c = 'Active';
            sub[2].Subscription_Type_1__c = 'Publication';
            sub[2].Zuora__SubscriptionStartDate__c = date.today().addMonths(-12).addDays(1);
            sub[2].Zuora__SubscriptionEndDate__c = date.today();
            sub[2].Term_Length1__c = '12';
            sub[2].Term_Length__c = 12;
            sub[2].Order_Line_Item_Number_1__c = orderline[2].Id;
            sub[2].Order_Line_Item_Number__c = orderline[2].Id;
            sub[2].Delivered_By_1__c = 'Vendor';
            sub[2].Delivered_By__c = 'Vendor';
            sub[2].Vendor_1__c = acc.Id;
            sub[2].Vendor__c = acc.Id;
            sub[2].Subscription_Type__c = 'Publication';
            sub[2].Subscription_Type_1__c = 'Publication';
            sub[2].Frequency__c = GlobalVariableClass.SUB_FREQUENCY_MONFRI;
            sub[2].Frequency_1__c = GlobalVariableClass.SUB_FREQUENCY_MONFRI;
            sub[2].Contact__c = conRec.Id;
            sub[2].Recipient_Contact__c = conRec.Id;
            sub[2].Recipient_Contact_1__c = conRec.Id;
            sub[2].Ph_d__c = true;
            sub[2].Ph_e__c = true;
            sub[2].Number_of_Copies__c = 5.00;
            sub[2].Number_of_Copies1__c = '5.00';
            sub[2].Qty__c = 5.00;
            sub[2].Qty1__c = '5.00';
            sub[2].Main_Package__c = pack.id;
            sub[2].Main_Package_1__c = pack.id;
            database.insert(sub);
            
            
            List<Zuora__SubscriptionProductCharge__c> spcList = TestDataFactory.createSubscriptionProductCharge(5);
            spcList[0].PublicationCode__c = 'DT';
            spcList[0].Zuora__UOM__c = 'Copy Weekday';
            spcList[0].Zuora__Subscription__c = sub[0].Id;
            
            spcList[1].PublicationCode__c = 'DT';
            spcList[1].Zuora__UOM__c = 'Copy Weekday';
            spcList[1].Zuora__Subscription__c = sub[1].Id;
            
            spcList[2].PublicationCode__c = 'DUT';
            spcList[2].Zuora__UOM__c = 'Copy Sunday';
            spcList[2].Zuora__Subscription__c = sub[1].Id;
            
            spcList[3].PublicationCode__c = 'DT';
            spcList[3].Zuora__UOM__c = 'Copy Weekday';
            spcList[3].Zuora__Subscription__c = sub[2].Id;
            
            spcList[4].PublicationCode__c = 'DUT';
            spcList[4].Zuora__UOM__c = 'Copy Sunday';
            spcList[4].Zuora__Subscription__c = sub[2].Id;
            
            insert spcList;
            
            test.startTest();

            List<Case> cas = TestDataFactory.createCase(1, 'Start Subscription');
            //cas[0].Temp_Stop__c = temp.Id;
            //cas[0].Temp_Stop__r = temp;
            //cas[0].Effective_Date__c = date.today()+1;
            //cas[0].Change_of_Address_Type__c = 'Change of Vendor';
            //cas[0].Vendor__c  = acc.Id;
            //cas[0].Contact_To_Update__c = con[0].Id;
            cas[0].RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND Name = 'Start Subscription'].Id;
            //cas[0].COA__c = true;
            cas[0].Account = parentAcc;
            cas[0].Accountid = parentAcc.id;
            //cas[0].Temp_Stop_Sub__c = sub[0].id;
            //cas[0].Temp_Stop_Date__c = date.today();
            //cas[0].Restart_Date__c = date.today()+1;
            cas[0].Status = 'Closed';


            database.insert(cas);
                
            List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
            caseSub[0].Case__c = cas[0].Id;
            caseSub[0].Subscription__c = sub[0].Id;
            caseSub[0].Account__c = parentAcc.Id;
            caseSub[0].isComplaint__c = false;

            //caseSub[1].Case__c = cas[1].Id;
            //caseSub[1].Subscription__c = sub[0].Id;    

            //caseSub[2].Case__c = cas[2].Id;
            //caseSub[2].Subscription__c = sub[0].Id;    
            database.insert(caseSub);
                         
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'DUT';
            database.insert(pub);
                
            // Publication__c pubSun = TestDataFactory.createPublication(1)[0];
            // pubSun.Sunday_Publication__c = pub.Id;
            // pubSun.Publication_Code__c = 'DT';
            // //pubSun.Has_Sunday_Pub__c = TRUE;
            // pubSun.Platform_Type__c = 'Print';
            // pubSun.Published_Days__c = 'YYYYYYY';
            // pubSun.Publish_Pattern__c = null;
            // database.insert(pubSun);
            
            List<Publication__c> pubSun = TestDataFactory.createPublication(9);
            pubSun[0].Sunday_Publication__c = pub.Id;
            pubSun[0].Publication_Code__c = 'DT';
            //pubSun.Has_Sunday_Pub__c = TRUE;
            pubSun[0].Platform_Type__c = 'Print';
            pubSun[0].Published_Days__c = 'YYYYYYY';
            pubSun[0].Publish_Pattern__c = null;
            
            List<String> pubDates = new List<String>{'YYYYYYN', 'NNNNYYN', 'NNNNNYN', 'YYYYYYY', 'YYYYYNN', 'NNNNYYY', 'NNNNNYY', 'YYYYYYN'};
            Integer pubCtr = 1;
            for(String pd : pubDates){
                pubSun[pubCtr].Publication_Code__c = 'DT';
                pubSun[pubCtr].Platform_Type__c = 'Print';
                pubSun[pubCtr].Published_Days__c = pd;
            }
            
            pubSun[1].Sunday_Publication__c = pub.Id;
            pubSun[2].Sunday_Publication__c = pub.Id;
            
            database.insert(pubSun);
            

            Parcel__c par = TestDataFactory.createParcel(1)[0];
            par.Project_Name__c = pro.Id;
            par.Allocation_Type__c = 'SDA';
            par.Description__c = 'Description';
            insert par;

            List<Vendor_Allocation__c> venAlloc = TestDataFactory.createVendorAlloc(4);
            venAlloc[0].SingPost_Address__c = postal.Id;
            venAlloc[0].Vendor_Account__c = acc.Id;
            venAlloc[0].Parcel_Name__c = par.Id;
            venAlloc[0].Allocated__c = TRUE;

            venAlloc[1].SingPost_Address__c = postal.Id;
            venAlloc[1].Vendor_Account__c = acc.Id;
            venAlloc[1].Parcel_Name__c = par.Id;
            venAlloc[1].Allocated__c = TRUE;

            venAlloc[2].SingPost_Address__c = postal.Id;
            venAlloc[2].Vendor_Account__c = acc.Id;
            venAlloc[2].Parcel_Name__c = par.Id;
            venAlloc[2].Allocated__c = TRUE;

            venAlloc[3].SingPost_Address__c = postal.Id;
            venAlloc[3].Vendor_Account__c = acc.Id;
            venAlloc[3].Parcel_Name__c = par.Id;
            venAlloc[3].Allocated__c = TRUE;
            venAlloc[3].SingPost_Address__c = postal.Id;
            venAlloc[3].Vendor_Account__c = acc.Id;
            venAlloc[3].Parcel_Name__c = par.Id;
            venAlloc[3].Allocated__c = TRUE;
            insert venAlloc;
            Database.BatchableContext BC;

            Postal_Zone__c postalSector = new Postal_Zone__c();
            postalSector.Name = '10';
            database.insert(postalSector);

            Post_Sector_Ops_Rep_Mapping__c postSectorOps = TestdataFactory.createPostSector(1)[0];
            postSectorOps.Zone__c = postalSector.id;
            postSectorOps.Vendor_Ops__c = u.id; 
            database.insert(postSectorOps);
        // }
        
        // user  u = [select Id from User where UserName = 'userstand3541987*@testorg.com'];
        // u.Validation_Exempted__c = true;
        // System.runAs(u){
            Set<Id> subIDs = new Set<Id>();
            for(Zuora__Subscription__c s : sub){
                subIDs.add(s.Id);
            }
            SP_VendorNotifChainBatch spchain = new SP_VendorNotifChainBatch(subIDs);
            Id testBatchId = Database.executeBatch(spchain, 200);
            System.assertNotEquals(testBatchId, null);
            test.stopTest();
        }
    }
    
    static testmethod void test_convertDateToString(){
      // SP_VendorNotifChainBatch.convertDateToString(Date.today());
      test.startTest();
      SP_VendorNotifChainBatch controller = new SP_VendorNotifChainBatch(new Set<id>());
      controller.testCoveragePatch();
      test.stopTest();
    }
    
}