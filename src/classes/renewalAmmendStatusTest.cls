/**
 * Class Name: <renewalAmmendStatus>
 * @author: <JhustinPinoy>
 * Date: <10/02/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for 

renewalAmmendStatus

>
 */

@isTest (Seealldata = FALSE)
public class renewalAmmendStatusTest {
    
    
    static testMethod void testrenewalAmmendStatus(){
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) {
            //Test.startTest();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
           Other__c other = new Other__c();
           other.Name = 'DTL';
           other.Value__c = '23:59';
           insert(other);
                    
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
           // pack.Name = 'Pack name';
            insert new List<sObject>{postal, acc, pack};
            
            /*Package_Product_Family__c ppf = new Package_Product_Family__c();
            ppf.Package_Name__c = pack.id;*/
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
            
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            }
            insert pItems;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            /*
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            insert(key);
            */
            
            Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
            cir.Name = 'CIR Plan Schedule';
            cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
            cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
            cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
            cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            insert (cir);        
            
                            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            con.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name ='Customer Contact'].id;
            con.Recipient_Indicator__c = TRUE;
            insert con;
            
           
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.today()+2;
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                //subRec.Order_Number__c = orderRec.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Zuora__CustomerAccount__c = billAcc.id;
                subRec.Term_Length__c = 1;
                subRec.Term_Length1__c = '1';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.order_type__c = 'Renewal';
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Base_Subscription__c = subRecs[0].id;
            orderRec.Order_Type__c = 'Renewal'; //joy
            insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today()+3;
           // orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = pack.Id;
            insert new List<sObject>{cas, subrecs[0], subrecs[1], subrecs[2], subrecs[3], orderline};
            
            
            
            
            String zuoraId = '2c92c0f8489db3ba0148a08143pp3638b';
            Date dayAfterEndDate = date.newInstance(2020, 12, 30);
            Date formatDate = date.newInstance(2015, 12, 30);
            
            try{
                test.setMock(WebServiceMock.class, new zApiTest());
                Test.startTest();
                
                renewalAmmendStatus ras = new renewalAmmendStatus();
                //renewalAmmendStatus.cancelAmendment(zuoraId, dayAfterEndDate);
                renewalAmmendStatus.formatDateToZuora(formatDate);
                renewalAmmendStatus.getSubscriptionParams(subRecs[0].Id);
                
                
                Test.stopTest();
            }
            catch(Exception e){
            }
        }
    }
    
    static testMethod void testrenewalAmmendStatus2(){
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) {
            //Test.startTest();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            
           Other__c other = new Other__c();
           other.Name = 'DTL';
           other.Value__c = '23:59';
           insert(other);
                    
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
           // pack.Name = 'Pack name';
            insert new List<sObject>{postal, acc, pack};
            
            /*Package_Product_Family__c ppf = new Package_Product_Family__c();
            ppf.Package_Name__c = pack.id;*/
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
            
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            }
            insert pItems;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
           
            /*
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            insert(key);
            */
            
            Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
            cir.Name = 'CIR Plan Schedule';
            cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
            cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
            cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
            cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            insert (cir);        
            
                            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            con.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name ='Customer Contact'].id;
            con.Recipient_Indicator__c = TRUE;
            insert con;
            
           
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__SubscriptionEndDate__c = date.today()+2;
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                //subRec.Order_Number__c = orderRec.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                subRec.Zuora__CustomerAccount__c = billAcc.id;
                subRec.Term_Length__c = 1;
                subRec.Term_Length1__c = '1';
            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.order_type__c = 'Renewal';
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Base_Subscription__c = subRecs[0].id;
            orderRec.Order_Type__c = 'Renewal'; //joy
            insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = date.today()+3;
           // orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = pack.Id;
            insert new List<sObject>{cas, subrecs[0], subrecs[1], subrecs[2], subrecs[3], orderline};
            
            
            
            
            String zuoraId = '2c92c0f8489db3ba0148a08143pp3638b';
            Date dayAfterEndDate = date.newInstance(2020, 12, 30);
            Date formatDate = date.newInstance(2015, 12, 30);
            
            try{
                test.setMock(WebServiceMock.class, new zApiTest());
                Test.startTest();
                
                renewalAmmendStatus ras = new renewalAmmendStatus();
                renewalAmmendStatus.cancelAmendment(zuoraId, dayAfterEndDate);
                renewalAmmendStatus.formatDateToZuora(formatDate);
                renewalAmmendStatus.getSubscriptionParams(subRecs[0].Id);
                renewalAmmendStatus.amendApiCall(new List<Zuora.zObject>());
                
                Test.stopTest();
            }
            catch(Exception e){
            }
        }
    }
    
    static testMethod void testrenewalAmmendStatus3(){
        try{
                test.setMock(WebServiceMock.class, new zApiTest());
                Test.startTest();
                
                renewalAmmendStatus.amendApiCall(new List<Zuora.zObject>());
                
                Test.stopTest();
            }
            catch(Exception e){
            }
    }
}