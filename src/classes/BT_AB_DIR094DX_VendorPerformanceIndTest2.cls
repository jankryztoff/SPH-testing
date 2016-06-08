@isTest (seeAllData= True)
public class BT_AB_DIR094DX_VendorPerformanceIndTest2 {

    private static Account acc_global;
    private static Address__c add_global;
    private static Singpost_Address__c singpostAdd_global;    
    private static User testUser;
    private static Case case_global;
    private static Contact con_global;
    private static Case_Subscription__c caseSub_global;
    private static Zuora__Subscription__c zSub_global;
    
    private static Case_Vendor_Subscription__c caseVendorSub_global;
    private static Subscription_Vendor__c subVendor_global;
    
    private static void setTestUser()
    {
        //Create a new user with Standard User Profile
        testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );  
    }
    
    private static void setAccount() {
      
        System.debug('Account Start');
        acc_global = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc_global.Vendor_Code__c = '12345';
        System.debug('Account End');
        insert acc_global;
    }
    
    private static void setSingPost() {
        singpostAdd_global= TestDataFactory.createSingpostAddress(1)[0];
            singpostAdd_global.Name = '99';            
        insert singpostAdd_global;
    }
    
    
    private static void setAddress() {
        RecordType rtype = [Select Name, Id 
                                   from RecordType 
                                   where sObjectType='Address__c' 
                                    and Name='Overseas'
                                    limit 1];
        
        add_global= TestDataFactory.createAddress(1)[0];
            add_global.RecordTypeId = rtype.Id;
            add_global.Postal_Code__c = singpostAdd_global.Id;
        insert add_global;
        
    }
    
    private static void setContact() {
         con_global = TestDataFactory.createContact(1)[0];          
            con_global.AccountId = acc_global.Id;
            con_global.Address__c = add_global.Id;
            //con_global.AccountId = acc_global.Id;
            con_global.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con_global.Recipient_Indicator__c = true;
        insert con_global;         
        System.debug('con_global last');        
        
    }
    
    private static void setCase() {
        System.debug('setCase start');
        RecordType rtype = [Select Name, Id, DeveloperName
                                   from RecordType 
                                   where sObjectType='Case' 
                                    //and Name = 'Start Subscription'
                                    and Name='Complaint - Newspaper'
                                    //and Name='Complaint_Magazine'
                                    and isActive=true
                                    limit 1];
                                    
        case_global = new Case(recordTypeId = rtype.Id);
        case_global.Account__c = acc_global.Id;
        case_global.AccountId = acc_global.Id;
        case_global.New_Address__c = add_global.Id;
        case_global.Contact_To_Update__c = con_global.Id;
        
        case_global.Creation_Mode_picklist__c = 'Fax';
        case_global.Status = 'Closed';
        case_global.Sub_Status__c = 'Approved';
        case_global.Sub_Category__c = 'Miscellaneous';
        case_global.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
        //case_global.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;        
        //case_global.Order__c = order.id;
        insert case_global; 
        
        System.debug('case_global: ' + case_global);
        System.debug('Case__r.CreatedDate: ' + case_global.CreatedDate);
        System.debug('Case of Account: ' + [SELECT  Id,
                                                    Account__c, Creation_Mode_picklist__c, 
                                                    Status, Offer_Promotion__c,
                                                    Offer_Package__c, Offer_AddOn_Package__c,
                                                    Sub_Status__c, Sub_Category__c, Order__c,
                                                    Change_of_Address_Type__c,
                                                    CreatedDate
                                           FROM Case
                                           WHERE Account__r.Id = :acc_global.Id]);
        
    }
    
    
    /*
    private static void setOrderLineItem() {
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Vendor_Subscription_ID__c = subsVen.Id;
            oli.Main_Package_ID__c = pack.Id;
            oli.Vendor_Mailing_Agent__c = venAccount.Id;
            insert oli;
        return oli;
    }
    
    private static void setZSub() {
        zSub_global = TestDataFactory.createSubscription(1)[0]; 
            zSub_global.Zuora__Account__c = acc_global.Id;
            zSub_global.Order_Line_Item_Number__c = oli.Id;
            zSub_global.Order_Number__c = order.Id;
            zSub_global.Suppress_Vendor_Start_Notice__c = 'false';
            zSub_global.Supressed_Acknowledgement_Letter__c = 'false';
            zSub_global.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub_global.Urgent__c = 'false';
            zSub_global.Vendor_Conversion__c = 'false';
            zSub_global.Charity__c = 'false';
            zSub_global.Sponsor__c = 'false';
            zSub_global.Recipient_Contact__c = con.Id;
            zSub_global.Zuora__CustomerAccount__c = billingAcc.Id;
            zSub_global.Number_of_Copies__c=100;
            zSub_global.Number_of_Copies1__c =  '100';
            zSub_global.Qty__c = 20;
            zSub_global.Zuora__Status__c='Cancelled';
            zSub_global.Zuora__SubscriptionStartDate__c=date.today();
            //zSub.Zuora__SubscriptionEndDate__c= date.today().addDays(100);
            zSub_global.Zuora__SubscriptionEndDate__c= null;
            zSub_global.Term_Length__c= 2;
   
            insert zSub_global;        
    }*/
    
    private static void setSubVendor() {
        subVendor_global = new Subscription_Vendor__c();
        subVendor_global.Vendor__c = acc_global.Id;
        insert subVendor_global;
    }
    
    private static void setCaseVendorSub() {
        caseVendorSub_global = new Case_Vendor_Subscription__c();
        caseVendorSub_global.Subscription_Vendor__c = subVendor_global.Id;
        caseVendorSub_global.Case__c = case_global.Id;
        insert caseVendorSub_global;
    }
    
    private static void setCaseSub() {
        caseSub_global = TestDataFactory.createCaseSubscription(1)[0];
        caseSub_global.Case__c = case_global.Id;
        //caseSub_global.Subscription__c
        insert caseSub_global;
    }
    
    
    private static void setAllData() {
        System.debug('setAccount start');
        setAccount();
        System.debug('setSingPost start');
        setSingPost();
        System.debug('setAddress start');
        setAddress();
        System.debug('setContact start');
        setContact();
        System.debug('setCase start');
        setCase();
        System.debug('setCaseVendorSub start');
        setCaseVendorSub();
        System.debug('setCaseSub start');
        setCaseSub();
        System.debug('setAllData last');
    }
    
    static testMethod void executeTest() {
        System.debug('executeTest start');
        boolean errorExist = false;
        try { 
            
            setAllData();
            Test.startTest();                        
                System.debug('executeTest mid1');
                BT_AB_DIR094DX_VendorPerformanceIndirect batch = new BT_AB_DIR094DX_VendorPerformanceIndirect();
                ID batchProcessId = Database.executeBatch(batch, 200);
                System.debug('executeTest mid2');               
            Test.stopTest();
            
        } catch(Exception e) {
            //System.debug('zRemoteException: ' + e);
            System.debug('Exception1: ' + e);
            System.debug('Exception2: ' + e.getMessage());
            System.debug('Exception3: ' + e.getStackTraceString());            
            errorExist = true;
        }
        
    }
    
}