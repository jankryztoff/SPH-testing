/**
 * Class Name: SP_VenSubsNotifChainBatch_Test
 * @author: Sherwin Puli
 * Date: 15-June-2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test class for SP_VenSubsNotifChainBatch
 */
@isTest
public class SP_VenSubsNotifChainBatch_Test{

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
    
    static Account acc;
    static Singpost_Address__c postal;
    static Address__c ad;
    static List<Contact> con;
    static List<Order__c> orderRec;
    static List<Subscription_Vendor__c> subVenList;
    static List<Case_Vendor_Subscription__c> caseVenSubList;
    
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
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'DUT';
            database.insert(pub);
                
            Publication__c pubSun = TestDataFactory.createPublication(1)[0];
            pubSun.Sunday_Publication__c = pub.Id;
            pubSun.Publication_Code__c = 'DT';
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
            
            Postal_Zone__c postalSector = new Postal_Zone__c();
            postalSector.Name = '10';
            database.insert(postalSector);

            Post_Sector_Ops_Rep_Mapping__c postSectorOps = TestdataFactory.createPostSector(1)[0];
            postSectorOps.Zone__c = postalSector.id;
            postSectorOps.Vendor_Ops__c = u.id; 
            database.insert(postSectorOps);
            
            Account parentAcc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
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
            
            subVenList = TestDataFactory.createSubscriptionVendor(3);
            subVenList[0].Subscription_Start_Date__c = date.today()+1;
            subVenList[0].Subscription_Stop_Date__c = date.today().addMonths(12);
            subVenList[0].Recipient__c = conRec.Id;
            subVenList[0].Vendor__c = acc.id;
            
            subVenList[1].Subscription_Start_Date__c = date.today()+1;
            subVenList[1].Subscription_Stop_Date__c = date.today().addMonths(12);
            subVenList[1].Recipient__c = conRec.Id;
            subVenList[1].Vendor__c = acc.id;
            
            subVenList[2].Subscription_Start_Date__c = date.today().addMonths(-12).addDays(2);
            subVenList[2].Subscription_Stop_Date__c = date.today()+1;
            subVenList[2].Recipient__c = conRec.Id;
            subVenList[2].Vendor__c = acc.id;
            
            insert subVenList;
            
            List < Subscription_Vendor_Publication__c > subVenPub = TestDataFactory.createVendorPublication(3);
            subVenPub[0].Subscription_Vendor__c = subVenList[0].id;
            subVenPub[0].Publication__c = pubSun.id;
            subVenPub[0].Mon__c = 1;
            subVenPub[0].Tue__c = 2;
            subVenPub[0].Wed__c = 3;
            subVenPub[0].Thu__c = 4;
            subVenPub[0].Fri__c = 5;
            subVenPub[0].Sat__c = 6;
            subVenPub[0].Sun__c = 7;

            subVenPub[1].Subscription_Vendor__c = subVenList[1].id;
            subVenPub[1].Publication__c = pubSun.id;
            subVenPub[1].Mon__c = 1;
            subVenPub[1].Tue__c = 2;
            subVenPub[1].Wed__c = 3;
            subVenPub[1].Thu__c = 4;
            subVenPub[1].Fri__c = 5;
            subVenPub[1].Sat__c = 6;
            subVenPub[1].Sun__c = 7;


            subVenPub[2].Subscription_Vendor__c = subVenList[2].id;
            subVenPub[2].Publication__c = pubSun.id;
            subVenPub[2].Mon__c = 1;
            subVenPub[2].Tue__c = 2;
            subVenPub[2].Wed__c = 3;
            subVenPub[2].Thu__c = 4;
            subVenPub[2].Fri__c = 5;
            subVenPub[2].Sat__c = 6;
            subVenPub[2].Sun__c = 7;
            
            insert subVenPub;
                
        }
        
        
    }
    
    static testmethod void test_normalExpiryVenSub(){
        
        prepareTestData();
        
        test.startTest();
        SP_VendorSubscriptionNotificationsBatch sp = new SP_VendorSubscriptionNotificationsBatch();
        Database.executeBatch(sp);
        test.stopTest();
        
    }
    
    static testmethod void test_normalExpiryVenSubSelective(){
        
        prepareTestData();
        
        test.startTest();
        Set<Id> subIDs = new Set<Id>();
        for(Subscription_Vendor__c s : subVenList){
            subIDs.add(s.Id);
        }
        SP_VenSubsNotifChainBatch spSelective = new SP_VenSubsNotifChainBatch(subIDs);
        Database.executeBatch(spSelective);
        test.stopTest();
        
    }
    
}