/**
 * Class Name: <CaseVendorSubTriggerHandler_Test>
 * @author: <April Banaag>
 * Date: <23/10/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for CaseVendorSubTriggerHandler>
*/

@isTest(seeAllData=false)
private class CaseVendorSubTriggerHandler_Test {
    
    public static User testUserCVSTH;
    public static Other__c othr;
    public static Account acct;
    public static Contact con;
    public static Key_Id__c k;

    //Marvin Gatchalian - Refactored test class April 11, 2016 
    static testMethod void testCaseComplaintNP (){
        List<Case_Vendor_Subscription__c> cvss = new List<Case_Vendor_Subscription__c> ();
        othr = new Other__c();
        othr.Name = 'ARMS CSO Admin';
        othr.Value__c = 'CSO Admin';
        insert othr;
        othr = new Other__c();
        othr.Name = 'Complaint counter days';
        othr.Value__c = '1';
        insert othr;
        othr = new Other__c();
        othr.Name = 'Complaint counter weeks';
        othr.Value__c = '1';
        insert othr;
        
        createUser ();
        testDataPreparation();
        Id caseRecorType = [SELECT Id FROM Recordtype where sObjectType = 'Case' and Name = 'Complaint - Newspaper' LIMIT 1].id;
        createCustomSettings(caseRecorType, 'Complaint_Newspaper');
        createCustomSettings('Cir Planner', 'Cir Predefined Case Team');
        
        Case_Vendor_Subscription__c cvs = addCase (caseRecorType, true);
        cvss.add(cvs);
        insert cvss;
    } 
    
     static testMethod void testComplaintMagazine (){
        List<Case_Vendor_Subscription__c> cvss = new List<Case_Vendor_Subscription__c> ();
        Set <id> caseVendorSubsIDs = new Set <id>();
        othr = new Other__c();
        othr.Name = 'ARMS CSO Admin';
        othr.Value__c = 'CSO Admin';
        insert othr;
        createUser ();
        
        testDataPreparation();
        Id caseRecorType = [SELECT Id FROM Recordtype where sObjectType = 'Case' and Name = 'Complaint - Magazine' LIMIT 1].Id;
        createCustomSettings(caseRecorType, 'Case_Complaint Magazine');
        createCustomSettings('CSO Admin', 'CSO Predefined Case Team');
        
        Case_Vendor_Subscription__c cvs1 = addCase (caseRecorType, false);
        cvss.add(cvs1);

        insert cvss;

    } 
    
    static testMethod void testCaseTempStop (){
        List<Case_Vendor_Subscription__c> cvss = new List<Case_Vendor_Subscription__c> ();
        Set <id> caseVendorSubsIDs = new Set <id>();
        othr = new Other__c();
        othr.Name = 'ARMS CSO Admin';
        othr.Value__c = 'CSO Admin';
        insert othr;
        createUser ();
        
        testDataPreparation();
        Id caseRecorType = [SELECT Id FROM Recordtype where sObjectType = 'Case' and Name = 'Temp Stop Subscription' LIMIT 1].Id;
        createCustomSettings(caseRecorType, 'Case_Temp Stop');
        Case_Vendor_Subscription__c cvs1 = addCase (caseRecorType, false);
        cvss.add(cvs1);
        
        caseRecorType = [SELECT Id FROM Recordtype where sObjectType = 'Case' and Name = 'Change of Address/Vendor' LIMIT 1].Id;
        createCustomSettings(caseRecorType, 'Case_Change in Address');
        Case_Vendor_Subscription__c cvs2 = addCase (caseRecorType, false);
        cvss.add(cvs2);
        insert cvss;
        
        cvss.clear();
        cvs1.Replace_To__c = System.Today();
        cvss.add(cvs1);
        cvs2.Replace_To__c = System.Today();
        cvss.add(cvs2);
        update cvss;
               
    } 
    
    static testMethod void runOtherEvent () {
        CaseVendorSubscriptionTriggerHandler cvs = new CaseVendorSubscriptionTriggerHandler ();
        Boolean var1 = cvs.runBeforeInsertTrigger();
        Boolean var2 = cvs.runBeforeUpdateTrigger();
        Boolean var3 = cvs.runBeforeDeleteTrigger();
        Boolean var4 = cvs.runAfterInsertTrigger();
        Boolean var5 = cvs.runAfterUpdateTrigger();
        Boolean var6 = cvs.runAfterDeleteTrigger();
    }
    
    static Case_Vendor_Subscription__c addCase (id caseRecorType, Boolean isComplaintNP) {
        Case_Vendor_Subscription__c newCaseVendorSub = new Case_Vendor_Subscription__c();
        List<Case> resultCases = new List<Case>();
        
        Subscription_Vendor__c subVen = new Subscription_Vendor__c();
        List<Contact> resultCon = new List<Contact>();
        resultCon = [SELECT id FROM Contact WHERE id =: con.id LIMIT 1];
        subven.Recipient__c = resultCon[0].id;
        insert subVen;
        
        if (!isComplaintNP) {         
            Case cas = new Case();
            cas.AccountId = acct.id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'new';
            cas.RecordTypeId = caseRecorType;
            cas.Effective_Date__c = system.today() + 2;
            cas.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
            cas.Contact_To_Update__c = resultCon[0].id;
            cas.Vendor__c = acct.id;
            cas.Within_Circulation_Planning_Schedule__c = true;
            cas.Replacement_Required__c = true;
            insert cas;
            resultCases.add(cas);
        }
        
        if (isComplaintNP) {
            Case caseRec = new Case();
            caseRec.AccountId = acct.id;
            caseRec.ContactId= con.id;
            caseRec.subject = 'Subject';
            caseRec.subject__c = 'Subject';
            caseRec.description = 'Subject';
            caseRec.Priority = 'Medium';
            caseRec.Recordtypeid= caseRecorType;
            caseRec.Status = 'Pending';
            caseRec.Sub_Status__c = 'Wating for Urgent Start Approval';
            caseRec.Within_Circulation_Planning_Schedule__c = true;
            caseRec.Replacement_Required__c = true;
            insert caseRec;
            resultCases.add(caseRec);
        }
        
        newCaseVendorSub.case__c = resultCases[0].id;
        List<Subscription_Vendor__c> resultSubVen = new List<Subscription_Vendor__c>();
        resultSubVen = [SELECT id FROM Subscription_Vendor__c WHERE id =: subVen.id LIMIT 1];
        newCaseVendorSub.Subscription_Vendor__c = resultSubVen[0].id;  
        newCaseVendorSub.Replacement_Required__c = true;
        newCaseVendorSub.Replace_From__c = Date.today().addDays(-13);
        newCaseVendorSub.Replace_To__c = Date.today();
        return newCaseVendorSub;
    
    }
    
    static void createCustomSettings(string caseRecorType, String recordTypeName){
        k = new Key_Id__c();
        k.Name = recordTypeName;
        k.Id__c = String.valueOf(caseRecorType);
        insert k;
    }
    
    static void testDataPreparation (){
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '30012551';

        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other); 
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
       //try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
       
        System.runAs(testUserCVSTH) {
            
                Account newAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                newAccount.NRIC__c = 'T1234567R';
                insert new List<sObject>{newAccount};

                acct = TestDataFactory.createAccount(1, 'Vendor')[0];
                insert acct;
    
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = '33';
                insert postal;
    
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
           
                //START EGC 4/9/2016
                Recordtype conRec = [SELECT Id FROM Recordtype where sObjectType = 'Contact' and Name = 'Customer Contact' LIMIT 1];
                con = TestDataFactory.createContact(1)[0];
                con.AccountId = acct.Id;
                con.Address__c = addressRec.Id;
                con.RecordTypeId = conRec.Id; //ConstantsSLB.getKeyId('Contact_customer contact');
                con.Recipient_Indicator__c = TRUE;
                insert con;
                //END EGC 4/9/2016
               
                Postal_Zone__c pZone = new Postal_Zone__c();
                insert pZone; 
            
                Post_Sector_Ops_Rep_Mapping__c postSec = TestDataFactory.createPostSector(1)[0];
                postSec.Zone__c = pZone.id;
                postSec.Postal_Sector_Code__c = integer.valueOf(postal.Name.substring(0,2));
                postSec.Vendor_Ops__c = UserInfo.getUserId();
                insert postSec;
         }
        
    }
    
    static void createUser () {
        String recType = ConstantsSLB.getOther('ARMS CSO Admin');
            testUserCVSTH = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [Select Id From Profile Where Name = :recType Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='cvsth1@test.com'
        );
    }
  
}