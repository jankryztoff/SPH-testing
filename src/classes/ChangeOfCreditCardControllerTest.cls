/*
 * Class Name: ChangeOfCreditCardControllerTest 
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * @modified by: Kirk Yngwie M. Enriquez
 * Modified Date: 06/19/2015
 * Project/Requirement: 
 * @description: to test ChangeOfCreditCardController class
 */


@IsTest (SeeAllData = true)
private with sharing class ChangeOfCreditCardControllerTest {
   
    private static Account acctRecord;
    //private static RecordType recType;
    private static Contact contRecord;
    private static List<Zuora__CustomerAccount__c> zAccounts = new List<Zuora__CustomerAccount__c>();
    //private static List<Zuora__Subscription__c> zSub = new List<Zuora__Subscription__c>();
    private static Zuora__Subscription__c zSub;
    private static Case caseRec, caseRec2;
    private static Address__c addressRec;
    private static Order__c order;
    private static Order_Line_Item__c orderline;
    private static Package__c pack;
   
    
    /*
    *   @description: This method sets all test data needed by the main test method
    *   @Parameters: N/A
    *   @return: N/A
    */     
    /*private static void prepareTestData(){
        
        acctRecord = new Account(Name = 'TestAcc',
         //RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
         Generate_Account_Number__c = TRUE
        );
       insert acctRecord;
       
        
        recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
        
        
        //check if contRecord is not equals to null
 
       contRecord = new Contact(HomePhone='11152632', LastName='TestLastName', Email='abc@test.com');
        insert contRecord;        //check if zAccounts is not equal to null
        
        system.assertNotEquals(null, contRecord);     
                
       zAccounts.add(
            new Zuora__CustomerAccount__c(Zuora__Account__c=acctRecord.Id, Billing_Contact__c=contRecord.id));*/
            
   /*     zAccounts.add(
            new Zuora__CustomerAccount__c(
                Zuora__Account__c=acctRecord.Id
            )
        );*/
        
        /*insert zAccounts;
        system.assertNotEquals(null, zAccounts);        

        contRecord.Billing_Account_Name_2__c=zAccounts[0].Id;
        update contRecord;       
                   
        
        
        zSub = new Zuora__Subscription__c();
        
           caseRec = new Case(
            //RecordTypeId = recType.Id, 
            AccountId = acctRecord.id,
            Billing_Account_Name__c=zAccounts[0].Id 
            
        );
        insert caseRec;
             
        
      //check if caseRec is not equals to null
       // system.assertNotEquals(null, caseRec);
        
       
    }*/
    
    private static void prepareTestData(){
        
        RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
    
        //Account acctRecord = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acctRecord = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acctRecord.Name = 'TestAccount';
        acctRecord.Generate_Account_Number__c = TRUE;
        insert acctRecord;
        
        //Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec = TestDataFactory.createAddress(1)[0];
        insert addressRec; 
        
        //Contact contRecord = TestDataFactory.createContact(1)[0];
        contRecord = TestDataFactory.createContact(1)[0];
        contRecord.Address__c = addressRec.Id;
        contRecord.AccountId = acctRecord.Id;
        contRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contRecord.Recipient_Indicator__c = true;
        contRecord.Billing_Indicator__c = true;
        contRecord.FirstName = 'Test';
        contRecord.LastName = 'Testtest';
        contRecord.HomePhone__c = '123 456';
        contRecord.Email = 'test@test.com';
        insert contRecord;
        
        //List<Zuora__CustomerAccount__c> zAccounts = TestDataFactory.createBillingAccount(2);
        zAccounts = TestDataFactory.createBillingAccount(2);
        zAccounts[0].Zuora__Account__c = acctRecord.Id;
        zAccounts[0].Billing_Contact__c = contRecord.Id;
        zAccounts[0].Billing_Type__c = 'Full Prepaid';
        zAccounts[0].Payment_Mode__c = GlobalVariableClass.CREDITCARD;
        zAccounts[0].Zuora__BillCycleDay__c = 'test';
        zAccounts[0].Zuora__Currency__c = 'test';
        zAccounts[0].Zuora__PaymentTerm__c = 'test';
        zAccounts[1].Zuora__Account__c = acctRecord.Id;
        zAccounts[1].Billing_Contact__c = contRecord.Id;
        zAccounts[1].Billing_Type__c = 'Full Prepaid';
        zAccounts[1].Payment_Mode__c = 'Other';
        insert zAccounts;
        
        //Order__c order = TestDataFactory.createOrder(1)[0];
        order = TestDataFactory.createOrder(1)[0];
        order.Subscriber_Charge__c = 10.00;
        order.Account__c = acctRecord.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = contRecord.Id;
        order.Eligible_for_Retention__c = TRUE;
        order.Case_Record_Type__c = 'Change of Credit Card';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = zAccounts[0].id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = contRecord.id;
        order.Delivery_Charge__c = 0;
        insert order;
        
        //Case caseRec = TestDataFactory.createCase(1, 'Change of Credit Card')[0];
        caseRec = TestDataFactory.createCase(1, 'Change of Credit Card')[0];
        caseRec.Order__c = order.Id;
        caseRec.AccountId = acctRecord.id;
        caseRec.Billing_Account_Name__c = zAccounts[0].Id;
        caseRec.RecordTypeId = recType.Id;
        insert caseRec;
        
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        pack.Package_Code__c = 'testcode';
        insert pack;
        
        orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(5);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
         
        set<id> oliIDs = new set<id>();
        oliIDs.add(orderline.Id);
        
        //Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__CustomerAccount__c = zAccounts[0].Id;
        zSub.Zuora__Account__c = acctRecord.Id;
        zSub.Subscriber_Contact__c = contRecord.Id;
        zSub.Recipient_Contact__c = contRecord.Id;
        zSub.Zuora__Status__c = 'Active';
        zSub.Order_Number__c = order.Id;
        zSub.Billing_Type__c = 'Full Prepaid';
        zSub.Number_of_Copies1__c = '100';
        zSub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        zSub.Order_Line_Item_Number_1__c = orderline.Id;
        zSub.Order_Line_Item_Number__c = orderline.Id;
        insert zSub;   
    }
        
        
    static testmethod void testWrapSubscription() {
        Zuora__Subscription__c zuoraSubs = new Zuora__Subscription__c(
            Is_Active__c=false
        );
        
       
        ChangeOfCreditCardController.WrapSubscription wrapSubs = 
            new ChangeOfCreditCardController.WrapSubscription(zuoraSubs);
        System.assertEquals(zuoraSubs.Is_Active__c, wrapSubs.SubRec.Is_Active__c);
        System.assertEquals(false, wrapSubs.selected);
        
       
    }
   
 /*  static testmethod void testWrapSubscription2() {
       Zuora__Subscription__c zuoraSubs = new Zuora__Subscription__c(
            Is_Active__c=true
        );
        
        ChangeOfCreditCardController.WrapSubscription wrapSubs = 
            new ChangeOfCreditCardController.WrapSubscription(zuoraSubs);
        //System.assertEquals(zuoraSubs.Is_Active__c, wrapSubs.SubRec.Is_Active__c);
       // System.assertEquals(true, wrapSubs.selected);
        prepareTestData();
        system.debug('TEST');        
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
        //ApexPages.currentPage().getParameters().put('RecordType', recType.Id);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        //ChangeOfCreditCardController control = new ChangeOfCreditCardController(stdControl);
        ChangeOfCreditCardController control = new ChangeOfCreditCardController();
        
        control.ProcessSelected();        
       
        
        }*/
        
    /*
    *   @description: This test method executes the testExistingCase.
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    
  
   static testmethod void testExistingCase() {
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        prepareTestData();
        
        system.debug('TEST');        
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
        ApexPages.currentPage().getParameters().put('RecordType', caseRec.RecordTypeId);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        //ChangeOfCreditCardController control = new ChangeOfCreditCardController(stdControl);
        ChangeOfCreditCardController control = new ChangeOfCreditCardController();

        //check if control is not equal to null
        system.assertNotEquals(null, control);        
        
        control.getSource();
        control.thisCase.Billing_Account_Name__c = zAccounts[0].Id;
        control.thisCase = caseRec;
        control.fetchBillingAccount();
        control.cancel();
        control.cloneBillingAccount = new Zuora__CustomerAccount__c();
        control.thisBillingAccount = new Zuora__CustomerAccount__c();
         }
         catch(Zuora.zRemoteException e) {
          }
    }

    /*
    *   @description: This test method executes the testFailCases.
    *   @Parameters: N/A
    *   @return: N/A
    */    
   static testmethod void testFailCases() {
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        prepareTestData();
        
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
       // ApexPages.currentPage().getParameters().put('RecordType', recType.Id);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        //ChangeOfCreditCardController control = new ChangeOfCreditCardController(stdControl);
        ChangeOfCreditCardController control = new ChangeOfCreditCardController();
        
        //check if control is not equals to null
        system.assertNotEquals(null, control);         
        
                //List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
        control.getSource();
        control.thisCase.Billing_Account_Name__c = '00100000000XXXX';
        control.cancel();
        control.fetchBillingAccount();
        control.cloneBillingAccount = new Zuora__CustomerAccount__c();
        control.thisBillingAccount = new Zuora__CustomerAccount__c();
        try{
            //check if the saved record is equals to null
            System.assertEquals(control.saveRecord(), null);
        }catch(QueryException e){
        
        }
        }
         catch(Zuora.zRemoteException e) {
          }

    }
    /*
    *   @description: This test method executes the other testCases.
    *   @Parameters: N/A
    *   @return: N/A
    */    
    static testmethod void testCases() {
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        prepareTestData();
        
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
       // ApexPages.currentPage().getParameters().put('RecordType', recType.Id);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email);         
        
        
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        //ChangeOfCreditCardController control = new ChangeOfCreditCardController(stdControl);
        ChangeOfCreditCardController control = new ChangeOfCreditCardController();
        
        //check if control is not equals to null
        system.assertNotEquals(null, control);         
        
        control.getSource();
        control.thisCase.Billing_Account_Name__c = '00100000000XXXX';
        control.cancel();
        control.fetchBillingAccount();
        control.cloneBillingAccount = new Zuora__CustomerAccount__c();
        control.thisBillingAccount = new Zuora__CustomerAccount__c();
        try{
            System.assertEquals(control.saveRecord(), null);
        }catch(QueryException e){
        
        }
     }
     
         catch(Zuora.zRemoteException e) {
          }
   }  
/*
   static testmethod void testSelectedSubscriptionEmpty(){
   try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        prepareTestData();
        system.debug('TEST');        
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
        //ApexPages.currentPage().getParameters().put('RecordType', recType.Id);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        //ChangeOfCreditCardController control = new ChangeOfCreditCardController(stdControl);
        ChangeOfCreditCardController control = new ChangeOfCreditCardController();

        //check if control is not equal to null
        system.assertNotEquals(null, control);        
        
        control.getSource();
        control.thisCase.Billing_Account_Name__c = zAccounts[0].Id;
        //control.thisCase = caseRec;
        control.thisCase.Payment_Method_ID__c = 'Credit Card';        
        control.fetchBillingAccount();
        control.cancel();
        control.saveRecord();
        control.thisCase = caseRec;
        control.cloneBillingAccount = new Zuora__CustomerAccount__c();
        control.thisBillingAccount = new Zuora__CustomerAccount__c();
        
        ChangeOfCreditCardController.WrapSubscription wrapper = new ChangeOfCreditCardController.WrapSubscription(zSub);
            wrapper.selected = true;
        List<ChangeOfCreditCardController.WrapSubscription> wrapperList = new List<ChangeOfCreditCardController.WrapSubscription>();
            wrapperList.add(wrapper);
        control.WrapSubList = wrapperList;
        //control.saveRecord();
         }
            catch(Zuora.zRemoteException e) {
          }
    }
*/
/*
   static testmethod void testSelectedSubscriptionEmpty2(){
  try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        prepareTestData();
        
        List <Zuora__CustomerAccount__c> zA = TestDataFactory.createBillingAccount(2);
        zA[0].Zuora__Account__c = acctRecord.Id;
        zA[0].Billing_Contact__c = contRecord.Id;
        zA[0].Billing_Type__c = 'Full Prepaid';
        zA[0].Payment_Mode__c = GlobalVariableClass.CREDITCARD;
        zA[0].Zuora__BillCycleDay__c = 'test';
        zA[0].Zuora__Currency__c = 'test';
        zA[0].Zuora__PaymentTerm__c = 'test';
        zA[1].Zuora__Account__c = acctRecord.Id;
        zA[1].Billing_Contact__c = contRecord.Id;
        zA[1].Billing_Type__c = 'Full Prepaid';
        zA[1].Payment_Mode__c = 'Other';
        insert zA;
        
        system.debug('TEST');        
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
        //ApexPages.currentPage().getParameters().put('RecordType', recType.Id);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        ChangeOfCreditCardController control = new ChangeOfCreditCardController();

        //check if control is not equal to null
        system.assertNotEquals(null, control);        
        
        control.getSource();
        control.thisCase = caseRec;
        control.thisCase.Billing_Account_Name__c = zA[0].Id;
        control.thisCase.Payment_Method_ID__c = 'Credit Card';        
        control.fetchBillingAccount();
        control.cancel();
        control.saveRecord();
        control.thisCase = caseRec;
        control.cloneBillingAccount = new Zuora__CustomerAccount__c();
        control.thisBillingAccount = new Zuora__CustomerAccount__c();
        
        ChangeOfCreditCardController.WrapSubscription wrapper = new ChangeOfCreditCardController.WrapSubscription(zSub);
            wrapper.selected = true;
        List<ChangeOfCreditCardController.WrapSubscription> wrapperList = new List<ChangeOfCreditCardController.WrapSubscription>();
            wrapperList.add(wrapper);
        control.WrapSubList = wrapperList;
        control.saveRecord();
         }
            catch(Zuora.zRemoteException e) {
          }
    }
*/
/*
   static testmethod void testSelectedSubscriptionNotEmpty(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        prepareTestData();
        List<Zuora__CustomerAccount__c> zuoraList = [SELECT Id  FROM Zuora__CustomerAccount__c WHERE Id =:caseRec.Billing_Account_Name__c];
        List<Contact> contactList = [SELECT Id
          //Name, AccountId, MailingCountry, FirstName, LastName, Email, Mailing_Address__c, City_Code__c, Address__r.Postal_Code__r.Name, Address__r.City__r.City_Name__c                            
         FROM Contact WHERE Id =:caseRec.Billing_Account_Name__r.Billing_Contact__c];        
        
         System.assertNotEquals(caseRec.id, zAccounts[0].id);
         //System.assertEquals('', zAccounts[0].Billing_Contact__c);
       
        system.debug('TEST');        
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
        //ApexPages.currentPage().getParameters().put('RecordType', recType.Id);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        //ChangeOfCreditCardController control = new ChangeOfCreditCardController(stdControl);
        ChangeOfCreditCardController control = new ChangeOfCreditCardController();

        //check if control is not equal to null
        system.assertNotEquals(null, control); 
        
        control.paymentMethodId = 'test';
        
           
        List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');   
        insert accList;   
        
         //Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                                                                                      
        
      //  List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
//       zAccounts[0].Zuora__Account__c = accList[0].id;         
       zAccounts[0].Payment_Mode__c = 'Credit Card';  
        //zAccounts[0].Zuora__Subscription__c = subRecs.id;    
        update zAccounts;
        
        
        List<Order__c> orderList = TestDataFactory.createOrder(1);
        orderList[0].Account__c = accList[0].id;
        insert orderList;        
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);        
        insert packageList;        
        
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);  
        orderLineItemList[0].Order__c = orderList[0].id;        
        orderLineItemList[0].Main_Package_ID__c = packageList[0].id;      
        insert orderLineItemList;  
              
         zSub = TestDataFactory.createSubscription(1)[0];
         //zSub = TestDataFactory.createSubscription(2);
         zSub.Zuora__Account__c = accList[0].Id;
         zSub.Zuora__Zuora_Id__c = '1123';      
         zSub.Zuora__Status__c = 'Active';        
         //subRecs.Order_Number__c = order.Id;                  
         zSub.Subscription_Type_1__c = 'Publication';        
         zSub.Subscription_Type__c = 'Publication';        
         zSub.Zuora__CustomerAccount__c = zAccounts[0].Id; 
         zSub.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
         /*zSub[1].Zuora__Account__c = accList[0].Id;
         zSub[1].Zuora__Zuora_Id__c = '1123';      
         zSub[1].Zuora__Status__c = 'Active';        
         //subRecs.Order_Number__c = order.Id;                  
         zSub[1].Subscription_Type_1__c = 'Publication';        
         zSub[1].Subscription_Type__c = 'Publication';        
         zSub[1].Zuora__CustomerAccount__c = zAccounts[0].Id;
         zSub[1].Order_Line_Item_Number_1__c = orderLineItemList[0].id; */  
/*
         insert zSub; 
        
         List<Zuora__Subscription__c> returnedSub = [SELECT Id, Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c, Name, Zuora__CustomerAccount__c,                                                     
         Zuora__CustomerAccount__r.Payment_Mode__c, Subscription_Type_1__c, Zuora__Zuora_Id__c, Order_Line_Item_Number_1__c                                                        
         FROM Zuora__Subscription__c                                                             
         WHERE Zuora__CustomerAccount__c = :zAccounts[0].Id                                                                 
         AND Zuora__CustomerAccount__r.Payment_Mode__c = 'Credit Card' AND Subscription_Type_1__c= 'Publication'                                                               
         AND Zuora__Status__c = 'Active' ] ;
        
        System.assertEquals(1, returnedSub.size());
        
      
               
       /* Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0];
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other';     
        defaultPayment.Zuora__Account__c = accList[0].id;    
        insert defaultPayment;  */
                    
 /*                
        control.getSource();
        control.thisCase.Billing_Account_Name__c = zAccounts[0].Id;
        control.thisCase = caseRec;
       // control.thisCase.Payment_Mode__c = 'Credit Card';       
        control.thisCase.Payment_Method_ID__c = 'Credit Card';    
       // control.fetchBillingAccount();
       
        List<ChangeOfCreditCardController.WrapSubscription> wrapSubList = new List<ChangeOfCreditCardController.WrapSubscription>();
        ChangeOfCreditCardController.WrapSubscription wrapper = new ChangeOfCreditCardController.WrapSubscription(zSub);
        wrapper.selected = true;
        wrapSubList.add(wrapper);           
        control.WrapSubList = wrapSubList;         
        control.ProcessSelected();
        control.saveRecord();
        //control.activateAccount();
               
       // System.assertEquals(-1,control.WrapSubList.size());
        
        control.cancel();
               
        control.cloneBillingAccount = new Zuora__CustomerAccount__c();
        control.thisBillingAccount = new Zuora__CustomerAccount__c();
        }
            catch(Zuora.zRemoteException e) {
          }
    }
*/
    static testmethod void testActivateAccount(){
     prepareTestData();
        system.debug('TEST');        
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
        //ApexPages.currentPage().getParameters().put('RecordType', recType.Id);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        //ChangeOfCreditCardController control = new ChangeOfCreditCardController(stdControl);
        ChangeOfCreditCardController control = new ChangeOfCreditCardController();

        List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');   
        insert accList;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = accList[0].id; 
       // billAccountList[0].Payment_Mode__c = 'Credit Card';       
        insert billAccountList;
        control.cloneBillingAccount = zAccounts[0];
        control.activateAccount();
        control.fetchBillingAccount();        
        control.createContactBilling();  
    }    
    static testmethod void test(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //prepareTestData();
        
        RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
    
        //Account acctRecord = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acctRecord = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acctRecord.Name = 'TestAccount';
        acctRecord.Generate_Account_Number__c = TRUE;
        insert acctRecord;
        
        //Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec = TestDataFactory.createAddress(1)[0];
        insert addressRec; 
        
        //Contact contRecord = TestDataFactory.createContact(1)[0];
        contRecord = TestDataFactory.createContact(1)[0];
        contRecord.Address__c = addressRec.Id;
        contRecord.AccountId = acctRecord.Id;
        contRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contRecord.Recipient_Indicator__c = true;
        contRecord.Billing_Indicator__c = true;
        contRecord.FirstName = 'Test';
        contRecord.LastName = 'Testtest';
        contRecord.HomePhone__c = '123 456';
        contRecord.Email = 'test@test.com';
        insert contRecord;
        
        //List<Zuora__CustomerAccount__c> zAccounts = TestDataFactory.createBillingAccount(2);
        zAccounts = TestDataFactory.createBillingAccount(2);
        zAccounts[0].Zuora__Account__c = acctRecord.Id;
        zAccounts[0].Billing_Contact__c = contRecord.Id;
        zAccounts[0].Billing_Type__c = 'Full Prepaid';
        zAccounts[0].Payment_Mode__c = GlobalVariableClass.CREDITCARD;
        zAccounts[1].Zuora__Account__c = acctRecord.Id;
        zAccounts[1].Billing_Contact__c = contRecord.Id;
        zAccounts[1].Billing_Type__c = 'Full Prepaid';
        zAccounts[1].Payment_Mode__c = 'Other';
        insert zAccounts;
        
        //Order__c order = TestDataFactory.createOrder(1)[0];
        order = TestDataFactory.createOrder(1)[0];
        order.Subscriber_Charge__c = 10.00;
        order.Account__c = acctRecord.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = contRecord.Id;
        order.Eligible_for_Retention__c = TRUE;
        order.Case_Record_Type__c = 'Change of Credit Card';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = zAccounts[0].id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = contRecord.id;
        order.Delivery_Charge__c = 0;
        insert order;
        
        //Case caseRec = TestDataFactory.createCase(1, 'Change of Credit Card')[0];
        caseRec = TestDataFactory.createCase(1, 'Change of Credit Card')[0];
        caseRec.Order__c = order.Id;
        caseRec.AccountId = acctRecord.id;
        caseRec.Billing_Account_Name__c=zAccounts[0].Id;
        caseRec.RecordTypeId = recType.Id;
        insert caseRec;
        
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        pack.Package_Code__c = 'testcode';
        insert pack;
        
        orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(5);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
         
        set<id> oliIDs = new set<id>();
        oliIDs.add(orderline.Id);
        
        //Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__CustomerAccount__c = zAccounts[0].Id;
        zSub.Zuora__Account__c = acctRecord.Id;
        zSub.Subscriber_Contact__c = contRecord.Id;
        zSub.Recipient_Contact__c = contRecord.Id;
        zSub.Zuora__Status__c = 'Active';
        zSub.Order_Number__c = order.Id;
        zSub.Billing_Type__c = 'Full Prepaid';
        zSub.Number_of_Copies1__c = '100';
        zSub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        //zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
        //zSub.Order_Line_Item_Number_1__c = orderline.Id;
        zSub.Order_Line_Item_Number__c = orderline.Id;
        insert zSub;   
  
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
        ApexPages.currentPage().getParameters().put('RecordType', caseRec.RecordTypeId);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        ChangeOfCreditCardController changecredcardctrlr = new ChangeOfCreditCardController();
            changecredcardctrlr.ProcessSelected();
            //changecredcardctrlr.activateAccount();
            changecredcardctrlr.createAmendments();
            changecredcardctrlr.createContactBilling();

        }
            catch(Zuora.zRemoteException e) {
          }
    }
    
    static testmethod void test2(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //prepareTestData();
        
        RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
    
        //Account acctRecord = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acctRecord = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acctRecord.Name = 'TestAccount';
        acctRecord.Generate_Account_Number__c = TRUE;
        insert acctRecord;
        
        //Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec = TestDataFactory.createAddress(1)[0];
        insert addressRec; 
        
        //Contact contRecord = TestDataFactory.createContact(1)[0];
        contRecord = TestDataFactory.createContact(1)[0];
        contRecord.Address__c = addressRec.Id;
        contRecord.AccountId = acctRecord.Id;
        contRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contRecord.Recipient_Indicator__c = true;
        contRecord.Billing_Indicator__c = true;
        contRecord.FirstName = 'Test';
        contRecord.LastName = 'Testtest';
        contRecord.HomePhone__c = '123 456';
        contRecord.Email = 'test@test.com';
        insert contRecord;
        
        //List<Zuora__CustomerAccount__c> zAccounts = TestDataFactory.createBillingAccount(2);
        zAccounts = TestDataFactory.createBillingAccount(2);
        zAccounts[0].Zuora__Account__c = acctRecord.Id;
        zAccounts[0].Billing_Contact__c = contRecord.Id;
        zAccounts[0].Billing_Type__c = 'Full Prepaid';
        zAccounts[0].Payment_Mode__c = GlobalVariableClass.CREDITCARD;
        zAccounts[1].Zuora__Account__c = acctRecord.Id;
        zAccounts[1].Billing_Contact__c = contRecord.Id;
        zAccounts[1].Billing_Type__c = 'Full Prepaid';
        zAccounts[1].Payment_Mode__c = 'Other';
        insert zAccounts;
        
        //Order__c order = TestDataFactory.createOrder(1)[0];
        order = TestDataFactory.createOrder(1)[0];
        order.Subscriber_Charge__c = 10.00;
        order.Account__c = acctRecord.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = contRecord.Id;
        order.Eligible_for_Retention__c = TRUE;
        order.Case_Record_Type__c = 'Change of Credit Card';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = zAccounts[0].id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = contRecord.id;
        order.Delivery_Charge__c = 0;
        insert order;
        
        //Case caseRec = TestDataFactory.createCase(1, 'Change of Credit Card')[0];
        caseRec = TestDataFactory.createCase(1, 'Change of Credit Card')[0];
        caseRec.Order__c = order.Id;
        caseRec.AccountId = acctRecord.id;
        caseRec.Billing_Account_Name__c=zAccounts[0].Id;
        caseRec.RecordTypeId = recType.Id;
        insert caseRec;
        
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base';
        pack.Name = 'Test Package';
        pack.Package_Code__c = 'testcode';
        insert pack;
        
        orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(5);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
         
        set<id> oliIDs = new set<id>();
        oliIDs.add(orderline.Id);
        
        //Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__CustomerAccount__c = zAccounts[0].Id;
        zSub.Zuora__Account__c = acctRecord.Id;
        zSub.Subscriber_Contact__c = contRecord.Id;
        zSub.Recipient_Contact__c = contRecord.Id;
        zSub.Zuora__Status__c = 'Active';
        zSub.Order_Number__c = order.Id;
        zSub.Billing_Type__c = 'Full Prepaid';
        zSub.Number_of_Copies1__c = '100';
        zSub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        //zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
        //zSub.Order_Line_Item_Number_1__c = orderline.Id;
        zSub.Order_Line_Item_Number__c = orderline.Id;
        insert zSub;   
  
        PageReference currPage = Page.CustomHpmPageCase;
        Test.setCurrentPage(currPage);
        
        ApexPages.currentPage().getParameters().put('accountId', acctRecord.Id);
        ApexPages.currentPage().getParameters().put('RecordType', caseRec.RecordTypeId);
        ApexPages.currentPage().getParameters().put('contactId', contRecord.Id); 
        ApexPages.currentPage().getParameters().put('email', contRecord.Email); 
        ApexPages.currentPage().getParameters().put('id', caseRec.Id);
        
        ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
        ChangeOfCreditCardController changecredcardctrlr = new ChangeOfCreditCardController();
            changecredcardctrlr.ProcessSelected();
            //changecredcardctrlr.activateAccount();
            changecredcardctrlr.createAmendments();
            changecredcardctrlr.createContactBilling();
            
        ChangeOfCreditCardController.WrapSubscription wrapper = new ChangeOfCreditCardController.WrapSubscription(zSub);
            wrapper.Selected = true;
        List<ChangeOfCreditCardController.WrapSubscription> wrapperList = new List<ChangeOfCreditCardController.WrapSubscription>();
            wrapperList.add(wrapper);
            changecredcardctrlr.WrapSubList = wrapperList;
            changecredcardctrlr.saveRecord();
        }
            catch(Zuora.zRemoteException e) {
          }
    }
}