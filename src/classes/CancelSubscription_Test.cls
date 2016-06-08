/**
 * Class Name: <CancelSubscription_Test>
 * @author: <JhustinPinoy / AMiranda>
 * Date: <10/02/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for CancelSubscription>
 */
@isTest (seeAllData=true)
private class CancelSubscription_Test {

    /**
        @name amendApiCall
        @param none
        @return void
        @description tests the amendApiCall method
    */
    static testMethod void amendApiCall() {
        try{
            Test.startTest();
            
            String zuoraId = '2c92c0f8489db3ba0148a08143pp3638b';
            
            Zuora.zObject amendment = new Zuora.zObject(globalvariableclass.AMENDMENT);
            amendment.setValue(globalvariableclass.CONTRACT_EFFECTIVEDATE,Zuora.zUtil.getZuoraDate(System.today()));
            amendment.setValue(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
            amendment.setValue(globalvariableclass.EFFECTIVE_DATE, Zuora.zUtil.getZuoraDate(System.today()));
            amendment.setValue(globalvariableclass.NAME, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
            amendment.setValue(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
            amendment.setValue(globalvariableclass.SUBSCRIPTION_ID, zuoraId);
            amendment.setValue(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
            
            System.assertNotEquals(amendment, null);
                    
            CancelSubscription.amendApiCall(amendment);
            System.debug('*****amendApiCallTest*****');
    
            Test.stopTest();
        }
        catch(Zuora.zRemoteException e){}
    }
    
    
    private static Singpost_Address__c postal;
    private static Account acc;
    private static Package__c pack;
    private static zqu__ZProduct__c zProduct;
    private static zqu__ProductRatePlan__c prdRatePlan;
    private static zqu__ProductRatePlanCharge__c zprpc;
    private static Package_Item__c pItem;
    private static Zuora__CustomerAccount__c billAcc;
    private static Address__c addressRec;
    private static Contact con;
    private static Contact con1;
    private static Order__c order;
    private static Case aCase; 
    private static Order_Line_Item__c orderline;
    private static List<Zuora__Subscription__c> zSubsList;
    private static Zuora__Subscription__c zSubs2;
        
    
    /**
        @name setUpData
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setupData() {
    
        /*
        Cir_Planner_Schedule__c cirPlannerSched = new Cir_Planner_Schedule__c(); //Cir_Planner_Schedule__c.getInstance('CIR Plan Schedule');
        cirPlannerSched.Name = 'CIR Plan Schedule';
        cirPlannerSched.Mon_Fri_Start_Time__c = Date.today();
        cirPlannerSched.Mon_Fri_End_Time__c = Date.today().addDays(5);
        insert cirPlannerSched;            
        
        Key_Id__c keyId = new Key_Id__c();          
        keyId.Id__c = '1';
        keyId.Name = 'NEXT_RECIPIENT_NUMBER';
        insert keyId; 
        */
                    
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;          
        
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;         

        pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        insert pack;            
        
        zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;                               
        
        billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; //added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
        addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = '012N00000008r43IAA'; //ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = '012N00000008r43IAA'; //ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id; // added by jjzs
        order.Billing_Type__c = billAcc.Billing_Type__c;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Subscriber_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        aCase = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        aCase.Order__c = order.Id;
        
        orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.today() +2;
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Start_Date__c = Date.today().addDays(1);
        orderline.Earliest_Start_Date__c = Date.today();
        orderline.Earliest_Stop_Date__c = Date.today().addDays(2);
        orderline.Stop_Request_Date__c =  Date.today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        zSubsList = TestDataFactory.createSubscription(2);
        zSubsList[0].Zuora__Account__c = acc.Id;
        zSubsList[0].Zuora__CustomerAccount__c = billAcc.id; //added by jjzs
        zSubsList[0].Zuora__Zuora_Id__c = '1234';
        zSubsList[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(30);
        zSubsList[0].Subscriber_Contact__c = con.Id;
        zSubsList[0].Recipient_Contact__c = con.Id;
        zSubsList[0].Main_Package_1__c = pack.id;
        zSubsList[0].Zuora__Status__c = 'Active';
        zSubsList[0].Order_Number__c = order.Id;
        zSubsList[0].Suppress_Vendor_Start_Notice__c = 'false';
        zSubsList[0].Supressed_Acknowledgement_Letter__c = 'false';
        zSubsList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubsList[0].Urgent__c = 'false';
        zSubsList[0].Vendor_Conversion__c = 'false';
        zSubsList[0].Charity__c = 'false';
        zSubsList[0].Billing_Type__c = 'Full Prepaid';
        zSubsList[0].Order_Line_Item_Number__c = orderline.id;
        zSubsList[0].Subscription_Type_1__c = 'Delivery';
        zSubsList[0].Subscription_Type__c = 'Delivery';
        zSubsList[0].Zuora__Status__c = 'Active';
        zSubsList[0].Order_Number_1__c = order.id;
        zSubsList[0].Zuora__Status__c = 'Active';
        zSubsList[0].Generate_Invoice1__c = 'false';
        zSubsList[0].Zuora__CustomerAccount__c = billAcc.Id;
        
        zSubsList[1].Zuora__Account__c = acc.Id;
        zSubsList[1].Zuora__CustomerAccount__c = billAcc.id; //added by jjzs
        zSubsList[1].Zuora__Zuora_Id__c = '12345';
        zSubsList[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(30);
        zSubsList[1].Subscriber_Contact__c = con.Id;
        zSubsList[1].Recipient_Contact__c = con.Id;
        zSubsList[1].Main_Package_1__c = pack.id;
        zSubsList[1].Zuora__Status__c = 'Active';
        zSubsList[1].Order_Number__c = order.Id;
        zSubsList[1].Suppress_Vendor_Start_Notice__c = 'false';
        zSubsList[1].Supressed_Acknowledgement_Letter__c = 'false';
        zSubsList[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubsList[1].Urgent__c = 'false';
        zSubsList[1].Vendor_Conversion__c = 'false';
        zSubsList[1].Charity__c = 'false';
        zSubsList[1].Billing_Type__c = 'Full Prepaid';
        zSubsList[1].Order_Line_Item_Number__c = orderline.Id;
        zSubsList[1].Order_Line_Item_Number_1__c = orderline.Id;
        zSubsList[1].Subscription_Type_1__c = 'Postage';
        zSubsList[1].Subscription_Type__c = 'Postage';
        zSubsList[1].Zuora__Status__c = 'Active';
        zSubsList[1].Order_Number_1__c = order.id;
        zSubsList[1].Zuora__Status__c = 'Active';
        zSubsList[1].Generate_Invoice1__c = 'false';
        zSubsList[1].Zuora__CustomerAccount__c = billAcc.Id;
        zSubsList[1].Zuora__Zuora_Id__c = zSubsList[0].Id;
        insert zSubsList;
         
    }
    
    /**
        @name checkPostageChargeTest
        @param none
        @return void
        @description tests the checkPostageCharge method
    */
    static testMethod void checkPostageChargeTest(){
        try{
            setupData();        
            Test.startTest();
            
            String subsId = Id.valueOf(zSubsList[0].Id);
            System.debug('ASM subsId: ' + subsId);
            
            List<Zuora__Subscription__c> selectedSubs = 
            [SELECT Id, Name, Zuora__Account__c, Order_Line_Item_Number_1__c, Subscription_Type_1__c
            FROM Zuora__Subscription__c
            WHERE Zuora__Zuora_Id__c = :subsId]; 
        
     
//IANCOMMENT// lacking subscription data
//                    CancelSubscription.checkPostageCharge(subsId);
        
            Test.stopTest();
        } catch(Zuora.zRemoteException e) {System.debug(e);}    
    }
    
    /**
        @name testCancelSubscription
        @param none
        @return void
        @description tests the amendForSubCancelation, checkDeliveryCharge, and formatDateToZuora methods
    */
    static testMethod void testCancelSubscription(){
    
        try {
            
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email ='standarduser@test.com', 
                EmailEncodingKey ='UTF-8',
                LastName ='Test',
                LanguageLocaleKey ='en_US', 
                LocaleSidKey ='en_US',
                ProfileId = '00e90000001VZOw', //(Id) ConstantsSLB.getKeyId('Profile_Standard User'),              
                TimeZoneSidKey='America/Los_Angeles',
                UserName='cancelsubscription@test.com'
            ); 
            
            System.runAs(testUser) {
                            
                setupData();
                Test.startTest();
                
                String zuoraId = '2c92c0f8489db3ba0148a08143pp3638b';
                Date stopDate = System.today();
                Date stopReqDate = Date.newInstance(2020, 12, 30);
                Date formatDate = Date.newInstance(2015, 12, 30);
                
                //CancelSubscription.createCancelAmendment(zuoraId, stopDate);
                CancelSubscription.amendForSubCancelation(zuoraId, stopDate);
                CancelSubscription.formatDateToZuora(formatDate);
                
                // update for SUBSCRIPTION_TYPE_POSTAGE
                zSubsList[0].Subscription_Type_1__c = 'Postage';
                zSubsList[0].Subscription_Type__c = 'Postage';
                zSubsList[0].Zuora__Zuora_Id__c = zSubsList[0].Id;
                update zSubsList[0];
    
                System.debug('ASM SUBSCRIPTION_TYPE_POSTAGE zSubsList[0]: ' + zSubsList[0]);  
                        
                Id subsId = zSubsList[0].Id;
    
                Zuora__Subscription__c zSubs =             
                [SELECT Id, Zuora__Zuora_Id__c, Zuora__Account__c, Zuora__Status__c, Subscription_Type_1__c, Recipient_Contact__c
                FROM Zuora__Subscription__c Where Id = :subsId];
                
                System.assertEquals(zSubs.Subscription_Type_1__c, 'Postage');
                
                // update for SUBSCRIPTION_TYPE_DELIVERY
                zSubsList[0].Subscription_Type_1__c = 'Delivery';
                zSubsList[0].Subscription_Type__c = 'Delivery';
                zSubsList[0].Zuora__Zuora_Id__c = zSubsList[0].Id;
                update zSubsList[0];
    
                System.debug('ASM SUBSCRIPTION_TYPE_DELIVERY zSubsList[0]: ' + zSubsList[0]);         
                
                subsId = zSubsList[0].Id; 
    
                zSubs = 
                [SELECT Id, Zuora__Zuora_Id__c, Zuora__Account__c, Zuora__Status__c, Subscription_Type_1__c, Recipient_Contact__c
                FROM Zuora__Subscription__c Where Id = :subsId];
                
                System.assertEquals(zSubs.Subscription_Type_1__c, 'Delivery');
                
                CancelSubscription cancelSubs = new CancelSubscription();
                cancelSubs.checkDeliveryCharge(subsId, stopReqDate);
                                                                                          
                Test.stopTest();
            }
        
        } catch(Zuora.zRemoteException e) {System.debug(e);}    

    }
}