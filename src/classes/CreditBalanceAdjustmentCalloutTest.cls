@isTest//(seeAllData=True)
private class CreditBalanceAdjustmentCalloutTest {

    static testMethod void testCreditBalanceAdjustmentCallout(){
    
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Account acct = new Account();
        Zuora__CustomerAccount__c billingAcc = new Zuora__CustomerAccount__c();
        Singpost_Address__c singpostAdd = new Singpost_Address__c();
        Address__c add = new Address__c();
        Contact con = new Contact();
        Order__c order = new Order__c();
        Subscription_Vendor__c subsVen = new Subscription_Vendor__c();
        Package__c pack = new Package__c();
        Order_Line_Item__c oli = new Order_Line_Item__c();
        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        
        //Added by: JPSulit 4/25/2016
        Cir_Planner_Schedule__c cps = CustomSettingsDataFactory.createPlannerSched();
        insert cps;
        //Added by: JPSulit 4/25/2016
        
        Case cas = TestDataFactory.createCase(1, 'Adjustments')[0];
        insert cas;
        
        acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        insert acct;
             
        billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        billingAcc.Zuora__Credit_Balance__c = 1000;
        billingAcc.Payment_Mode__c = 'Cash';
        insert billingAcc;
        
        singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singpostAdd;
         
        add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;

        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test Invoice';
        zInvoice.Zuora__Account__c = acct.id;
        zInvoice.Zuora__BillingAccount__c = billingAcc.Id;
        zInvoice.Zuora__Balance2__c = 500; 
        insert zInvoice;        
        
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        
        for(integer i=0; i<=50; i++){
            Zuora__ZInvoice__c zInvoice1 = new Zuora__ZInvoice__c();
            zInvoice1.Name = 'Test Invoice';
            zInvoice1.Zuora__Account__c = acct.id;
            zInvoice1.Zuora__BillingAccount__c = billingAcc.Id;
            zInvoice1.Zuora__Balance2__c = 500; 
            invoiceList.add(zInvoice1);    
        }
        insert invoiceList;
        set<id> idSets = new set<id>();
        for(Zuora__ZInvoice__c invLoop : [SELECT Id FROM Zuora__ZInvoice__c]){
            idSets.add(invLoop.Id);
        }
        
        Test.startTest(); 
        
        CreditBalanceAdjustmentCallout.send(idSets);
        Test.stopTest(); 
        
          }catch(Zuora.zRemoteException e) {
          }  
        }
}