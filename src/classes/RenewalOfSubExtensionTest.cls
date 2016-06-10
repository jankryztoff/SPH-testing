@isTest (seeAllData= False)
private class RenewalOfSubExtensionTest{


    @testSetup static void methodName() {
            insert(CustomSettingsDataFactory.createKey_Id());
            //insert(CustomSettingsDataFactory.createPlannerSched());
            insert(CustomSettingsDataFactory.createOther());
            insert(CustomSettingsDataFactory.createError_Messages());
    } 

   static testMethod void test(){
        
        //Create a new user with Standard User Profile

        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
            );

        //The test will run as the user created.
        System.runAs(u) {
        
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            List<Case> caseList = new List<Case>(); 
            List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            List<Order__c> orderList = new List<Order__c>();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            //create Account Records
            accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
            accList[0].NRIC__c = 'T1234567R';
            insert accList;
            
            //create Main Package Records
            List<Package__c> packageList = TestDataFactory.createPackage(2);
            insert packageList[0];
            
            //List<Package__c> packageList = TestDataFactory.createPackage(1);
            packageList[1].Billing_Type__c = 'Full Prepaid';
            insert packageList[1];
            
            //create Billing Account Records
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = accList[0].Id;
            insert billAcc;
            
            //create Address Records
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            //create Contact Records
            conList = TestDataFactory.createContact(1);
            //START: CCB002 Added by April Banaag - to apply changes to contact record type
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList[0].Recipient_Indicator__c = true;
            //END: CCB002 Added by April Banaag - to apply changes to contact record type
            conList[0].AccountId = accList[0].Id;
            conList[0].Address__c = addressRec.Id;
            insert conList;
            
            //create Order Records
            orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].Id;
            orderList[0].Informed_Customer__c = TRUE;
            orderList[0].Recipient_Contact__c = conList[0].Id;
            insert orderList ; 
            
            //insert Case Records
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderList[0].Id;
            cas.Sub_Category__c = 'Change/Reset Password' ;
            
            //create Order Line Item Records
            oliList = TestDataFactory.createOrderLineItem(1);
            oliList[0].Main_Package_ID__c = packageList[0].Id;
            oliList[0].End_Date__c = date.today().addDays(60);
            oliList[0].Order__c = orderList[0].Id;
            insert new List<sObject>{cas, oliList[0]};
            
           //create Zuora Subscription Records
            zuoSubList = TestDataFactory.createSubscription(1);
            zuoSubList[0].Zuora__Account__c = accList[0].Id;
            zuoSubList[0].Subscriber_Contact__c = conList[0].Id;
            zuoSubList[0].Recipient_Contact__c = conList[0].Id;
            zuoSubList[0].Main_Package_1__c = packageList[0].Id;
            zuoSubList[0].Order_Line_Item_Number__c = orderList[0].Id;    
            zuoSubList[0].Order_Number__c = orderList[0].Id;
            zuoSubList[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zuoSubList[0].Zuora__Status__c = 'Active';
            zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'false';
            zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'false';
            zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zuoSubList[0].Urgent__c = 'false';
            zuoSubList[0].Vendor_Conversion__c = 'false';
            zuoSubList[0].Charity__c = 'false';
            try {
                insert zuoSubList;
            } catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
            
            
            Test.startTest();
            /*PageReference pageRef = page.SM_RenewalOfSubscriptionEntry;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('orderId', orderList[0].Id);
            ApexPages.currentPage().getParameters().put('accountId', accList[0].Id);
            ApexPages.currentPage().getParameters().put('contactId', conList[0].Id);
            ApexPages.currentPage().getParameters().put('caseId', cas.Id);
            ApexPages.standardController controller = new ApexPages.standardController(cas);
            //RenewalOfSubExtension createRenOfSubExt = new RenewalOfSubExtension(controller);*/

            Test.stopTest();
            
        }
    }
}