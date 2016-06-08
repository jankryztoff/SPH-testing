/**
   @Author Joy Suarez    
   @name AdjustmentExtensionEdit_Test
   @CreateDate 02/06/2015
   @Description test class for AdjustmentExtensionEdit
   @Version <1.0>
   @reference <Referenced program names>
  */



@isTest(seeAllData = TRUE)
private class AdjustmentExtensionEdit_Test{

    /**
    *  To test AdjustmentExtensionEdit
    *  @name testAdjustment
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testAdjustment()
    {
        //variables
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
        
        Case cas = TestDataFactory.createCase(1, 'Adjustments')[0];
        insert cas;
        
        acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        insert acct;
             
        billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        insert billingAcc;
        
        singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singpostAdd;
        
        add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;

        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test Invoince';
        zInvoice.Zuora__Account__c = acct.id;
        zInvoice.Zuora__BillingAccount__c = billingAcc.Id;
        zInvoice.Zuora__Balance2__c = 500;
        insert zInvoice;        
        
        Test.startTest(); 
        PageReference pRef = Page.AdjustmentsCaseEditPage;
        Test.setCurrentPage(pRef);
            
            ApexPages.CurrentPage().getParameters().put('billingaccountId',billingAcc.id);
            ApexPages.CurrentPage().getParameters().put('RecordType',cas.id);
     
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(new Case());
            AdjustmentExtensionEdit  controller = new AdjustmentExtensionEdit(stdController);
            controller.adjustment.Billing_Account_Name__c = billingAcc.id;
            controller.adjustment.Accountid = acct.id;
            controller.adjustment.contactid = con.id;
            controller.adjustment.Subscription_Name__c = subs.id;
            controller.adjustment.Invoice__c = zInvoice.id;
            controller.adjustment.Category__c = 'Subscription Request';
            controller.adjustment.Sub_Category__c = 'Adjustment';
            controller.adjustment.Status = 'New';
            controller.adjustment.Origin = 'Email';
            controller.adjustment.Priority = 'Medium';
            controller.adjustment.Adjustment_Status__c = 'Sucess';
            controller.adjustment.Subject__c = 'Invoice Adjustment';
            controller.adjustment.Description = 'Invoice Adjustment';
            controller.adjustment.recordtypeid = ConstantsSLB.getKeyId('Case_Adjustments');
            
            //Test Negative Amount
            controller.adjustment.Adjustment_Amount__c = -10;
            pRef = controller.submitAdjustment();
            
            System.assertEquals(null, pRef);
            
            controller.adjustment.Adjustment_Amount__c = 10;
            controller.submitAndNew();
            Test.stopTest(); 
    }    
    /**
    *  To test AdjustmentExtensionEdit
    *  @name testAdjustment
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testAdjustment2()
    {

            
         //variables
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
        
        Case cas = TestDataFactory.createCase(1,'Adjustments')[0];
        insert cas;
        
        
        //create account
        acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        insert acct;
             
        //create billing acct
        billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        insert billingAcc;
        
        //create singpost address
        singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singpostAdd;
        
        //create address
        add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;

        //Create Invoice
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test Invoince';
        zInvoice.Zuora__Account__c = acct.id;
        zInvoice.Zuora__BillingAccount__c = billingAcc.Id;
        //zInvoice.Zuora__DueDate__c = Date.newInstance(2015, 01, 01);
        zInvoice.Zuora__Balance2__c = 500;
        insert zInvoice;        
        
            Test.startTest(); 
            PageReference pRef = Page.AdjustmentsCaseEditPage;
            Test.setCurrentPage(pRef);
            
            ApexPages.CurrentPage().getParameters().put('billingaccountId',billingAcc.id);
     
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(new Case());
            AdjustmentExtensionEdit  controller = new AdjustmentExtensionEdit(stdController);
            controller.adjustment.Billing_Account_Name__c = billingAcc.id;
            controller.adjustment.Accountid = acct.id;
            controller.adjustment.contactid = con.id;
            controller.adjustment.Subscription_Name__c = subs.id;
            controller.adjustment.Invoice__c = zInvoice.id;
            controller.adjustment.Category__c = 'Subscription Request';
            controller.adjustment.Sub_Category__c = 'Adjustment';
            controller.adjustment.Status = 'New';
            controller.adjustment.Origin = 'Email';
            controller.adjustment.Priority = 'Medium';
            controller.adjustment.Adjustment_Status__c = 'Sucess';
            controller.adjustment.Subject__c = 'Invoice Adjustment';
            controller.adjustment.Description = 'Invoice Adjustment';
            
            //Test Negative Amount
            controller.adjustment.Adjustment_Amount__c = -10;
            pRef = controller.submitAdjustment();
            
            System.assertEquals(null, pRef);
            
            controller.adjustment.Adjustment_Amount__c = 10;
            controller.submitAndNew();
            Test.stopTest(); 
    }    
    /**
    *  To test AdjustmentExtensionEdit
    *  @name testAdjustment3
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testAdjustment3()
    {
            
         //variables
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
        
        Case cas = TestDataFactory.createCase(1,'Adjustments')[0];
        insert cas;
        
        
        //create account
        acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        insert acct;
             
        //create billing acct
        billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        insert billingAcc;
        
        //create singpost address
        singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singpostAdd;
        
        //create address
        add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;

        //Create Invoice
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test Invoince';
        zInvoice.Zuora__Account__c = acct.id;
        zInvoice.Zuora__BillingAccount__c = billingAcc.Id;
        zInvoice.Zuora__Balance2__c = 500;
        insert zInvoice;        
        
        Test.startTest(); 
        PageReference pRef = Page.AdjustmentsCaseEditPage;
        Test.setCurrentPage(pRef);
            
        ApexPages.CurrentPage().getParameters().put('billingaccountId',billingAcc.id);
     
        ApexPages.StandardController stdController = new ApexPages.Standardcontroller(new Case());
        AdjustmentExtensionEdit  controller = new AdjustmentExtensionEdit(stdController);
        controller.adjustment.Billing_Account_Name__c = billingAcc.id;
        controller.adjustment.Accountid = acct.id;
        controller.adjustment.contactid = con.id;
        controller.adjustment.Subscription_Name__c = subs.id;
        controller.adjustment.Invoice__c = zInvoice.id;
        controller.adjustment.Category__c = 'Subscription Request';
        controller.adjustment.Sub_Category__c = 'Adjustment';
        controller.adjustment.Status = 'New';
        controller.adjustment.Origin = 'Email';
        controller.adjustment.Priority = 'Medium';
        controller.adjustment.Adjustment_Status__c = 'Sucess';
        controller.adjustment.Subject__c = 'Invoice Adjustment';
        controller.adjustment.Description = 'Invoice Adjustment';
        insert controller.adjustment;
            
        //Test Negative Amount
        controller.adjustment.Adjustment_Amount__c = -10;
        pRef = controller.submitAdjustment();
            
        System.assertEquals(null, pRef);
            
        controller.adjustment.Adjustment_Amount__c = 10;
        controller.submitAndNew();
        Test.stopTest(); 
    }       
}