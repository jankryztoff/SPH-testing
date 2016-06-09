/**
 * Class Name: ComplaintNewspaperCounterTest
 * @author: Recuerdo Bregente
 * Date: 07/08/2015
 * Requirement/Project Name: SPH
 * @description Test Class for complaintNewspaperCounter
 */
@isTest(seeAllData=True)
private class ComplaintNewspaperCounterTest {
    
    static List<Case> cases;
    static List<Package__c> pack;
    static List<Zuora__Subscription__c> sub;
    static List<Case_Subscription__c> casSub;
    static List<Product_Publication__c> proPub;
    static List<Publication__c> publication;
    static List<zqu__ZProduct__c> zPro;
    static List<Order__c> order;
    static List<Account> acc;
    static List<Zuora__CustomerAccount__c> bAcc;
    static List<Contact> contact;
    static complaintNewspaperCounter complaintNewsPaperCounterRec;
    
    /**
    /* @author : Recuerdo Bregente
    /* @description : Prepares the test data objects.
    /* @date: 07/08/2015
    */
    static void prepareTestData() {
    
        complaintNewsPaperCounterRec = new complaintNewspaperCounter();
    
        cases = TestDataFactory.createCase(1, 'Complaint - Newspaper'); //needed
        pack = TestDataFactory.createPackage(1); //needed
        sub = TestDataFactory.createSubscription(1); //needed
        casSub = TestDataFactory.createCaseSubscription(1);  //needed
        proPub =TestDataFactory.createProductPublication(1);  //needed
        publication = TestDataFactory.createPublication(1); //needed
        zPro = TestDataFactory.createZProduct(1); //needed
        order = TestDataFactory.createOrder(1); //needed
        acc = TestDataFactory.createAccount(1, 'Vendor Subscriber'); //needed
        bAcc = TestDataFactory.createBillingAccount(1);
        contact = TestDataFactory.createContactRecType(1, 'Vendor Contact');        
        
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
            c.ContactId = contact[0].Id;      
            c.Goodwill_Amount__c = 3;      
            c.Status = 'New';
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
            cSub.Goodwill_Amount__c = 3;
        }       
        insert casSub;
    }
    
    /**
    /* @author : Recuerdo Bregente
    /* @description : Tests the complaintCounter method.
    /* @date: 07/08/2015
    */
    static testMethod void testcomplaintCounter() {
        boolean errorExist = false;
        try {
            Test.startTest();
            prepareTestData();
            complaintNewsPaperCounterRec.complaintCounter(cases);
            Test.stopTest();
        }
        catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        //System.assertEquals(true, errorExist);
    }
    
    /**
    /* @author : Recuerdo Bregente
    /* @description : Tests the complaintCounter method With no Case Records available.
    /* @date: 07/08/2015
    */
    static testMethod void testcomplaintCounterWithZeroCaseRecords() {
        boolean errorExist = false;
        try {
            Test.startTest();
            prepareTestData();
            complaintNewsPaperCounterRec.complaintCounter(new List<Case>());
            Test.stopTest();
        }
        catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        //System.assertEquals(true, errorExist);
    }

}