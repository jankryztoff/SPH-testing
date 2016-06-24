/**
 * Class Name: CaseEdiOverrideControllerTest
 * @author Mark Jhustin Pinoy
 * Date: 2014.09.20
 * Requirement: 
 * @description Test class of CaseEditOverrideController.
 */
 
@isTest(seeAllData=true)
                    
private class CaseNewOverrideControllerTest {
    
    //This method covers the coverage of Account Records, Contact, Order Records, and Case Records.
    public static testMethod void testCaseNewOverrideCont() {
        Id account_VendorSubscriber = ConstantsSLB.getKeyId('Account_Direct Individual'); 
        List<Account> accRecList = new List<Account>();
        List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
        List<Contact> contactList = new List<Contact>();
        List<Order__c> ordRecList = new List<Order__c>();
        List<Case> casRecList = new List<Case>(); 
        
        //create Account Records
        accRecList.addAll(TestDataFactory.createAccount(2, 'Direct Corporate'));
        accRecList[0].Name = 'Test Account 1';
        accRecList[0].RecordTypeId = account_VendorSubscriber;
        accRecList[1].Name = 'Test Account 2';
        insert accRecList;
        
        //create Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = accRecList[0].Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        //adding Billing Contact Records
        billingAccountList = TestDataFactory.createBillingAccount(2);
        billingAccountList[0].Zuora__Account__c = accRecList[0].id;
        billingAccountList[0].Billing_Type__c = 'Full Prepaid';
        billingAccountList[1].Zuora__Account__c = accRecList[1].id;
        billingAccountList[1].Billing_Type__c = 'Full Prepaid';
        insert billingAccountList;
        
        //adding Contact Records
        contactList = TestDataFactory.createContact(2); 
        contactList[0].AccountId = accRecList[0].Id;
        contactList[1].AccountId = accRecList[1].Id; 
        contactList[0].Recipient_Indicator__c = true;
        contactList[1].Recipient_Indicator__c = true;
        insert contactList;
        
        
        //create Order Records
        ordRecList = TestDataFactory.createOrder(2);
        ordRecList[0].Account__c = accRecList[0].Id;
        ordRecList[0].Billing_Account__c= billingAccountList[0].Id;
        ordRecList[0].Billing_Type__c = 'Full Prepaid';
        ordRecList[0].Status__c = 'Draft';
        ordRecList[0].Informed_Customer__c = true;
        //ordRecList[0].Recipient_Contact__c = con.Id;
        ordRecList[1].Account__c = accRecList[1].Id;
        ordRecList[1].Billing_Account__c= billingAccountList[1].Id;
        ordRecList[1].Billing_Type__c = 'Full Prepaid';
        ordRecList[1].Status__c = 'New';
        ordRecList[1].Informed_Customer__c = true;
        //ordRecList[1].Recipient_Contact__c = con.Id;
        insert ordRecList;
        
        //create Case Records
        casRecList = TestDataFactory.createCase(1, 'Complaint - Magazine');
        casRecList[0].account__c = accRecList[0].Id;
        casRecList[0].Order__c = ordRecList[0].Id;
        //casRecList.addAll(TestDataFactory.createCase(1, 'Complaint - Newspaper'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Change of Payment Type'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Change of Credit Card'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Bypass Credit Card'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Adjustments'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Start Subscription'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Stop Subscription')); 
        
        casRecList[0].Charging_Date__c= date.Today().addDays(30);
        //casRecList[1].Charging_Date__c= date.Today().addDays(30);
        //casRecList[2].Charging_Date__c= date.Today().addDays(30);
        //casRecList[3].Charging_Date__c= date.Today().addDays(30);
        //casRecList[4].Charging_Date__c= date.Today().addDays(30);
        //casRecList[5].Charging_Date__c= date.Today().addDays(30);
        //casRecList[6].Charging_Date__c= date.Today().addDays(30);
        //casRecList[7].Charging_Date__c= date.Today().addDays(30);
        
        insert casRecList;
        
        
        List<Id> caseRecTypeLIST = new List<Id>{ ConstantsSLB.getKeyId('Case_Complaint Magazine'),
        ConstantsSLB.getKeyId('Complaint_Newspaper'),
        ConstantsSLB.getKeyId('Case_Change of Payment Type'),
        ConstantsSLB.getKeyId('Case_Change of Credit Card'),
        ConstantsSLB.getKeyId('Case_Bypass Credit Card'),
        ConstantsSLB.getKeyId('Case_Adjustments'),
        ConstantsSLB.getKeyId('Case_Change in Address'),
        ConstantsSLB.getKeyId('Case_Start Sub'),
        ConstantsSLB.getKeyId('Case_Stop'),
        ConstantsSLB.getKeyId('Case_Particulars'),
        ConstantsSLB.getKeyId('Case_Reset Password'),
        ConstantsSLB.getKeyId('Case_Retention'),
        ConstantsSLB.getKeyId('Case_Temp Stop'),
        ConstantsSLB.getKeyId('Case_Refund'),
        ConstantsSLB.getKeyId('Case_Digital'), 
        ConstantsSLB.getKeyId('Case_Enquiry'),
        ConstantsSLB.getKeyId('Case Renewal of Subscription'),
        ConstantsSLB.getKeyId('Case_Change of Subscription')
        };
        //Case c = [SELECT Id, RecordTypeId, RecordType.Name, AccountId, ContactId FROM Case LIMIT 1];
        //ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id];
        //create case
        //c = TestDataFactory.createCase(1, 'Complaint - Magazine');
        //c = TestDataFactory.createCase(1, 'Complaint - Newspaper');
        
        //c[0].Account = accRecList[0].Id;
        //c[0].Priority = 'High';
        //c[0].RecordType = ConstantsSLB.getKeyId('Case_Complaint Magazine');
        //
        //c[1].Account = accRecList[1].Id;
        //c[1].Priority = 'High';
        //c[1].RecordType = ConstantsSLB.getKeyId('Complaint_Newspaper');
        //
        //c[2].Account = accRecList[0].Id;
        //c[2].Priority = 'High';
        //c[2].RecordType = ConstantsSLB.getKeyId('Case_Change of Payment Type');
        //
        //c[3].Account = accRecList[1].Id;
        //c[3].Priority = 'High';
        //c[3].RecordType = ConstantsSLB.getKeyId('Case_Change of Credit Card');
        //
        //c[4].Account = accRecList[0].Id;
        //c[4].Priority = 'High';
        //c[4].RecordType = ConstantsSLB.getKeyId('Case_Bypass Credit Card');
        //
        //insert c;
        
        //c.AddAll(TestDataFactory.createCase(1, 'Complaint Magazine'));
        //c.AddAll(TestDataFactory.createCase(1, 'Complaint_Newspaper'));
        //c.AddAll(TestDataFactory.createCase(1, 'Change of Payment Type'));
        //c.AddAll(TestDataFactory.createCase(1, 'Change of Credit Card'));
        
        Test.startTest();
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());  
        //for every record type
        CaseNewOverrideController testController = null;
        for(Id recTypeId: caseRecTypeLIST) {
            //with account Id
            PageReference pageRef = Page.CaseNewOverride;
            pageRef.getParameters().put('def_account_id', accRecList[0].Id);
            pageRef.getParameters().put('RecordType', recTypeId);
            pageRef.getParameters().put('subscriptionId', ordRecList[0].Id);            
            pageRef.getParameters().put(GlobalVariableClass.DEFPARID, accRecList[0].Id); // TODO
            //pageRef.getParameters().put(GlobalVariableClass.DEFPARID, casRecList[0].Id);
            pageRef.getParameters().put('retUrl', '/'+ billingAccountList[0].Id);
//parentId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFPARID);

            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(casRecList[0]);
            testController = new CaseNewOverrideController(sc);
            //testController.getnextcaseIds();
            testController.redirect();
        }
        testController.isNew();
        
         } catch (Exception e) {
         }
        Test.stopTest();
    }
    
    static testMethod void testCaseNewOverrideController01() {
        
        Id account_VendorSubscriber = ConstantsSLB.getKeyId('Account_Direct Individual'); 
        List<Account> accRecList = new List<Account>();
        List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
        List<Contact> contactList = new List<Contact>();
        List<Order__c> ordRecList = new List<Order__c>();
        List<Case> casRecList = new List<Case>(); 
        
        //create Account Records
        accRecList.addAll(TestDataFactory.createAccount(2, 'Direct Corporate'));
        accRecList[0].Name = 'Test Account 1';
        accRecList[0].RecordTypeId = account_VendorSubscriber;
        accRecList[1].Name = 'Test Account 2';
        insert accRecList;
        
        //create Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = accRecList[0].Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        //adding Billing Contact Records
        billingAccountList = TestDataFactory.createBillingAccount(2);
        billingAccountList[0].Zuora__Account__c = accRecList[0].id;
        billingAccountList[0].Billing_Type__c = 'Full Prepaid';
        billingAccountList[1].Zuora__Account__c = accRecList[1].id;
        billingAccountList[1].Billing_Type__c = 'Full Prepaid';
        insert billingAccountList;
        
        //adding Contact Records
        contactList = TestDataFactory.createContact(2); 
        contactList[0].AccountId = accRecList[0].Id;
        contactList[1].AccountId = accRecList[1].Id; 
        contactList[0].Recipient_Indicator__c = true;
        contactList[1].Recipient_Indicator__c = true;
        insert contactList;
        
        
        //create Order Records
        ordRecList = TestDataFactory.createOrder(2);
        ordRecList[0].Account__c = accRecList[0].Id;
        ordRecList[0].Billing_Account__c= billingAccountList[0].Id;
        ordRecList[0].Billing_Type__c = 'Full Prepaid';
        ordRecList[0].Status__c = 'Draft';
        ordRecList[0].Informed_Customer__c = true;
        //ordRecList[0].Recipient_Contact__c = con.Id;
        ordRecList[1].Account__c = accRecList[1].Id;
        ordRecList[1].Billing_Account__c= billingAccountList[1].Id;
        ordRecList[1].Billing_Type__c = 'Full Prepaid';
        ordRecList[1].Status__c = 'New';
        ordRecList[1].Informed_Customer__c = true;
        //ordRecList[1].Recipient_Contact__c = con.Id;
        insert ordRecList;
        
        //create Case Records
        casRecList = TestDataFactory.createCase(1, 'Complaint - Magazine');
        casRecList[0].account__c = accRecList[0].Id;
        casRecList[0].Order__c = ordRecList[0].Id;
        //casRecList.addAll(TestDataFactory.createCase(1, 'Complaint - Newspaper'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Change of Payment Type'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Change of Credit Card'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Bypass Credit Card'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Adjustments'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Start Subscription'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Stop Subscription')); 
        
        casRecList[0].Charging_Date__c= date.Today().addDays(30);
        //casRecList[1].Charging_Date__c= date.Today().addDays(30);
        //casRecList[2].Charging_Date__c= date.Today().addDays(30);
        //casRecList[3].Charging_Date__c= date.Today().addDays(30);
        //casRecList[4].Charging_Date__c= date.Today().addDays(30);
        //casRecList[5].Charging_Date__c= date.Today().addDays(30);
        //casRecList[6].Charging_Date__c= date.Today().addDays(30);
        //casRecList[7].Charging_Date__c= date.Today().addDays(30);
        
        insert casRecList;
        
        
        List<Id> caseRecTypeLIST = new List<Id>{ ConstantsSLB.getKeyId('Case_Complaint Magazine'),
        ConstantsSLB.getKeyId('Complaint_Newspaper'),
        ConstantsSLB.getKeyId('Case_Change of Payment Type'),
        ConstantsSLB.getKeyId('Case_Change of Credit Card'),
        ConstantsSLB.getKeyId('Case_Bypass Credit Card'),
        ConstantsSLB.getKeyId('Case_Adjustments'),
        ConstantsSLB.getKeyId('Case_Change in Address'),
        ConstantsSLB.getKeyId('Case_Start Sub'),
        ConstantsSLB.getKeyId('Case_Stop'),
        ConstantsSLB.getKeyId('Case_Particulars'),
        ConstantsSLB.getKeyId('Case_Reset Password'),
        ConstantsSLB.getKeyId('Case_Retention'),
        ConstantsSLB.getKeyId('Case_Temp Stop'),
        ConstantsSLB.getKeyId('Case_Refund'),
        ConstantsSLB.getKeyId('Case_Digital'), 
        ConstantsSLB.getKeyId('Case_Enquiry'),
        ConstantsSLB.getKeyId('Case Renewal of Subscription'),
        ConstantsSLB.getKeyId('Case_Change of Subscription')
        };
        
        Test.startTest();
        try{
            for(Id recTypeId: caseRecTypeLIST) {
            // Test Proper           
            PageReference pageRef = Page.CaseNewOverride;
            pageRef.getParameters().put('def_account_id', accRecList[0].Id);
            pageRef.getParameters().put('RecordType', recTypeId);
            pageRef.getParameters().put('subscriptionId', ordRecList[0].Id);            
            //pageRef.getParameters().put(GlobalVariableClass.DEFPARID, accRecList[0].Id); // TODO
            pageRef.getParameters().put(GlobalVariableClass.DEFPARID, casRecList[0].Id);
            pageRef.getParameters().put('retUrl', '/'+ billingAccountList[0].Id);
    //parentId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFPARID);
            
            Test.setCurrentPage(pageRef);
            
            try {
                ApexPages.StandardController sc = new ApexPages.StandardController(casRecList[0]);
                CaseNewOverrideController controller = new CaseNewOverrideController(sc);
                //System.assertEquals('&def_parent_id='+casRecList[0].Id, controller.getnextcaseIds());
                //System.assertEquals(true, controller.isNew());
                //System.debug('>>>>>>>>>>: ' + controller.relatedCaseIds());
            }catch (exception e) {}
            


              
           
        }
        } catch (exception e){}
        
         Test.stopTest();
    }
    
    public static testMethod void testCaseNewOverrideCont02() {
        Id account_VendorSubscriber = ConstantsSLB.getKeyId('Account_Direct Individual'); 
        List<Account> accRecList = new List<Account>();
        List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
        List<Contact> contactList = new List<Contact>();
        List<Order__c> ordRecList = new List<Order__c>();
        List<Case> casRecList = new List<Case>(); 
        
        //create Account Records
        accRecList.addAll(TestDataFactory.createAccount(2, 'Direct Corporate'));
        accRecList[0].Name = 'Test Account 1';
        accRecList[0].RecordTypeId = account_VendorSubscriber;
        accRecList[1].Name = 'Test Account 2';
        insert accRecList;
        
        //create Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = accRecList[0].Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        //adding Billing Contact Records
        billingAccountList = TestDataFactory.createBillingAccount(2);
        billingAccountList[0].Zuora__Account__c = accRecList[0].id;
        billingAccountList[0].Billing_Type__c = 'Full Prepaid';
        billingAccountList[1].Zuora__Account__c = accRecList[1].id;
        billingAccountList[1].Billing_Type__c = 'Full Prepaid';
        insert billingAccountList;
        
        //adding Contact Records
        contactList = TestDataFactory.createContact(2); 
        contactList[0].AccountId = accRecList[0].Id;
        contactList[1].AccountId = accRecList[1].Id; 
        contactList[0].Recipient_Indicator__c = true;
        contactList[1].Recipient_Indicator__c = true;
        insert contactList;
        
        
        //create Order Records
        ordRecList = TestDataFactory.createOrder(2);
        ordRecList[0].Account__c = accRecList[0].Id;
        ordRecList[0].Billing_Account__c= billingAccountList[0].Id;
        ordRecList[0].Billing_Type__c = 'Full Prepaid';
        ordRecList[0].Status__c = 'Draft';
        ordRecList[0].Informed_Customer__c = true;
        //ordRecList[0].Recipient_Contact__c = con.Id;
        ordRecList[1].Account__c = accRecList[1].Id;
        ordRecList[1].Billing_Account__c= billingAccountList[1].Id;
        ordRecList[1].Billing_Type__c = 'Full Prepaid';
        ordRecList[1].Status__c = 'New';
        ordRecList[1].Informed_Customer__c = true;
        //ordRecList[1].Recipient_Contact__c = con.Id;
        insert ordRecList;
        
        //create Case Records
        casRecList = TestDataFactory.createCase(1, 'Complaint - Magazine');
        casRecList[0].account__c = accRecList[0].Id;
        casRecList[0].Order__c = ordRecList[0].Id;
        //casRecList.addAll(TestDataFactory.createCase(1, 'Complaint - Newspaper'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Change of Payment Type'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Change of Credit Card'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Bypass Credit Card'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Adjustments'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Start Subscription'));
        //casRecList.addAll(TestDataFactory.createCase(1, 'Stop Subscription')); 
        
        casRecList[0].Charging_Date__c= date.Today().addDays(30);
        //casRecList[1].Charging_Date__c= date.Today().addDays(30);
        //casRecList[2].Charging_Date__c= date.Today().addDays(30);
        //casRecList[3].Charging_Date__c= date.Today().addDays(30);
        //casRecList[4].Charging_Date__c= date.Today().addDays(30);
        //casRecList[5].Charging_Date__c= date.Today().addDays(30);
        //casRecList[6].Charging_Date__c= date.Today().addDays(30);
        //casRecList[7].Charging_Date__c= date.Today().addDays(30);
        
        insert casRecList;
        
        
        List<Id> caseRecTypeLIST = new List<Id>{ ConstantsSLB.getKeyId('Case_Complaint Magazine'),
        ConstantsSLB.getKeyId('Complaint_Newspaper'),
        ConstantsSLB.getKeyId('Case_Change of Payment Type'),
        ConstantsSLB.getKeyId('Case_Change of Credit Card'),
        ConstantsSLB.getKeyId('Case_Bypass Credit Card'),
        ConstantsSLB.getKeyId('Case_Adjustments'),
        ConstantsSLB.getKeyId('Case_Change in Address'),
        ConstantsSLB.getKeyId('Case_Start Sub'),
        ConstantsSLB.getKeyId('Case_Stop'),
        ConstantsSLB.getKeyId('Case_Particulars'),
        ConstantsSLB.getKeyId('Case_Reset Password'),
        ConstantsSLB.getKeyId('Case_Retention'),
        ConstantsSLB.getKeyId('Case_Temp Stop'),
        ConstantsSLB.getKeyId('Case_Refund'),
        ConstantsSLB.getKeyId('Case_Digital'), 
        ConstantsSLB.getKeyId('Case_Enquiry'),
        ConstantsSLB.getKeyId('Case Renewal of Subscription'),
        ConstantsSLB.getKeyId('Case_Change of Subscription')
        };
        
        Test.startTest();
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());  
        //for every record type
        CaseNewOverrideController testController = null;
        for(Id recTypeId: caseRecTypeLIST) {
            //with account Id
            PageReference pageRef = Page.CaseNewOverride;
            pageRef.getParameters().put('def_account_id', null);
            pageRef.getParameters().put('RecordType', recTypeId);
            pageRef.getParameters().put('subscriptionId', null);            
            pageRef.getParameters().put(GlobalVariableClass.DEFPARID, null); // TODO
            //pageRef.getParameters().put(GlobalVariableClass.DEFPARID, casRecList[0].Id);
            pageRef.getParameters().put('retUrl', '/'+ billingAccountList[0].Id);
//parentId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFPARID);

            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(casRecList[0]);
            testController = new CaseNewOverrideController(sc);
            //testController.getnextcaseIds();
            testController.redirect();
        }
        
      } catch (Exception e) {
      }
      Test.stopTest();
    }
}