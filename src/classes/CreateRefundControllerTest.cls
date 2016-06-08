/**
* Class Name: CreateRefundControllerTest
* @author: Jensar Joey Z. Sayson
* Date: 3/5/2016
* Requirement/Project Name: <SPH>
* @description Test Class for CreateRefundController
*/


@isTest
public class CreateRefundControllerTest{

    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createMASS_CONFIG();
        insert CustomSettingsDataFactory.createError_Messages();
    }


    static List<Case> caseList = null;
    static Account zAcc = null;
    static Zuora__CustomerAccount__c zBillAcct = null;
    static Zuora__Refund__c refundRecord = null;
    static Profile getProfile(){
        Profile someProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        return someProfile;
    }
    
    
    //initializing
    static testMethod void test01(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'CreditCard';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'Check';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        zuoraPayment.Zuora__External_Id__c = '1234567890qwerfdsaqwsedsxa123412';
        insert zuoraPayment;
        
        Zuora__PaymentMethod__c createdPaymentMethod = TestDataFactory.createPaymentMethod(1)[0];
        createdPaymentMethod.Zuora__BillingAccount__c = billAcc.Id;
        insert createdPaymentMethod;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'CreditCard';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
        Zuora__Payment__c createdPayment = TestDataFactory.createPayment(1)[0];
        createdPayment.Zuora__BillingAccount__c = billAcc.Id;
        insert createdPayment; 
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Cash';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);
        
        controller.paymentRecs = 'test';
        controller.amountToRefund = 1.00;
        controller.thisBillingAccount = billAcc;
        controller.paymentMethodId = zuoraPayment.Zuora__External_Id__c;
        controller.billingAcct = billAcc;
        controller.thisCase = comCase;
        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        controller.Payments();
        
    }
    static testMethod void test05(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'Cash';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'Cash';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        zuoraPayment.Zuora__External_Id__c = '1234567890qwerfdsaqwsedsxa123412';
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Cheque';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);
        
        controller.paymentRecs = 'test';
        controller.amountToRefund = 1.00;
        controller.thisBillingAccount = billAcc;
        controller.paymentMethodId = zuoraPayment.Zuora__External_Id__c;
        controller.billingAcct = billAcc;
        controller.thisCase = comCase;
        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        
        
    }
    
    static testMethod void test02(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'Other';
        billAcc.Other_PaymentMethod__c = 'Cash';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'ACH';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'Other';
        billAcc.Other_PaymentMethod__c = 'Cash';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Invoice';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);

        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        
        
    }
    
    static testMethod void test04(){
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec; 
     

        List<Contact> conList = TestDataFactory.createContact(1); 
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';  
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'BankTransfer';
        billAcc.Other_PaymentMethod__c = 'Cash';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'BankTransfer';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'Other';
        billAcc.Other_PaymentMethod__c = 'BankTransfer';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Credit Card';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund; 
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);

        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();
        controller.getWrapper();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.dummySubscription = zuoSubList[0];
        controller.fetchBillingAccount();
        
        
    }

static testMethod void test03(){
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        
        Error_Messages__c errmsg = new Error_Messages__c(); 
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'CreditCard';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'CreditCard';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'CreditCard';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Paypal';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;

        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        //system.assertequals(zuoraRefund, null);
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);

        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        Decimal decTest = controller.totalRefundAmount;
        
        String strTest = controller.getSource();
    }
    
    static testMethod void test06(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'CreditCardReferenceTransaction';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'CreditCardReferenceTransaction';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        zuoraPayment.Zuora__External_Id__c = '1234567890qwerfdsaqwsedsxa123412';
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'CreditCardReferenceTransaction';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'eNets';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);
        
        controller.paymentRecs = 'test';
        controller.amountToRefund = 1.00;
        controller.thisBillingAccount = billAcc;
        controller.paymentMethodId = zuoraPayment.Zuora__External_Id__c;
        controller.billingAcct = billAcc;
        controller.thisCase = comCase;
        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        
        
    }
    
    static testMethod void test07(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'DebitCard';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'DebitCard';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        zuoraPayment.Zuora__External_Id__c = '1234567890qwerfdsaqwsedsxa123412';
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'DebitCard';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'External Parties';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);
        
        controller.paymentRecs = 'test';
        controller.amountToRefund = 1.00;
        controller.thisBillingAccount = billAcc;
        controller.paymentMethodId = zuoraPayment.Zuora__External_Id__c;
        controller.billingAcct = billAcc;
        controller.thisCase = comCase;
        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        
        
    }
    
    static testMethod void test08(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'Other';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'Other';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        zuoraPayment.Zuora__External_Id__c = '1234567890qwerfdsaqwsedsxa123412';
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'Other';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Internal Charge';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);
        
        controller.paymentRecs = 'test';
        controller.amountToRefund = 1.00;
        controller.thisBillingAccount = billAcc;
        controller.paymentMethodId = zuoraPayment.Zuora__External_Id__c;
        controller.billingAcct = billAcc;
        controller.thisCase = comCase;
        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        
    }
    
    static testMethod void test09(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'PayPal';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'PayPal';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        zuoraPayment.Zuora__External_Id__c = '1234567890qwerfdsaqwsedsxa123412';
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Payment_Mode__c = 'PayPal';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Internal Charge';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);
        
        controller.paymentRecs = 'test';
        controller.amountToRefund = 1.00;
        controller.thisBillingAccount = billAcc;
        controller.paymentMethodId = zuoraPayment.Zuora__External_Id__c;
        controller.billingAcct = billAcc;
        controller.thisCase = comCase;
        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        
    }
    
    static testMethod void test10(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 20;
        billAcc.Payment_Mode__c = 'WireTransfer';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'WireTransfer';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        zuoraPayment.Zuora__External_Id__c = '1234567890qwerfdsaqwsedsxa123412';
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c =20;
        billAcc.Payment_Mode__c = 'WireTransfer';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Internal Charge';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);
        
        controller.paymentRecs = 'test';
        controller.amountToRefund = 1.00;
        controller.thisBillingAccount = billAcc;
        controller.paymentMethodId = zuoraPayment.Zuora__External_Id__c;
        controller.billingAcct = billAcc;
        controller.thisCase = comCase;
        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        
    }
    
    static testMethod void test101(){
        
        Zuora_HPM_Settings__c testzuo = new Zuora_HPM_Settings__c();
        testzuo.Name = 'Default';
        insert testzuo;
        
        Error_Messages__c errmsg = new Error_Messages__c();
        errmsg.Name = 'NoExistingPaymentForPayPal';
        errmsg.Message__c = 'NoExistingPaymentForPayPal';
        insert errmsg;
        
        Error_Messages__c errmsg2 = new Error_Messages__c();
        errmsg2.Name = 'AmountToRefund';
        errmsg2.Message__c = 'AmountToRefund';
        insert errmsg2;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Vendor');
        accList2[0].NRIC__c = 'T1632567R';
        insert accList2;
        
        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;   
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;
    

        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 20;
        billAcc.Payment_Mode__c = 'CreditCardReferenceTransaction';
        //billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        insert billAcc;
        
        Zuora__PaymentMethod__c zuoraPayment = New Zuora__PaymentMethod__c();
        zuoraPayment.Zuora__Type__c = 'CreditCardReferenceTransaction';
        zuoraPayment.Zuora__BillingAccount__c = billAcc.Id;
        zuoraPayment.Zuora__External_Id__c = '1234567890qwerfdsaqwsedsxa123412';
        insert zuoraPayment;
        
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c =20;
        billAcc.Payment_Mode__c = 'CreditCardReferenceTransaction';
        billAcc.Zuora__Default_Payment_Method__c = zuoraPayment.id;
        update billAcc;
        
    
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;  
/*
        caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
        Case stdObj = caseList[0];
        stdObj.Status = 'New';
        insert stdObj;
*/      
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                //caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList[0].id;
                caseSub.Complaint_From__c = Date.today()-4;
                caseSub.Complaint_To__c = Date.today()-2;
                caseSub.Complaint_Copies__c = 1;
                caseSubscription.add(caseSub);

                //List<Case> complaintCase = new List<Case>();
                Case comCase = new Case();
                comCase.AccountId = accList[0].Id;
                //comCase.Effective_Date__c = Date.today()+1;
                comCase.ContactId = conList[0].Id;
                comCase.Priority = 'Medium';
                comCase.Subject = 'Test';
                comCase.Description = 'Test';
                comCase.Status = 'New';
                comCase.Payment_Mode__c = 'Internal Charge';
                //comCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                comCase.Subscription_Name__c = zuoSubList[0].id;
                //comCase.Vendor__c = accList3[0].Id;
                comCase.Within_Circulation_Planning_Schedule__c = false;
                //complaintCase.add(comCase);
                insert comCase;
                
                
        Zuora__Refund__c zuoraRefund = new Zuora__Refund__c();      
        zuoraRefund.Zuora__Amount__c = 14.00;
        zuoraRefund.Zuora__Account__c = accList[0].Id;
        zuoraRefund.Zuora__BillingAccount__c = billAcc.Id;      
        zuoraRefund.Subscription__c = zuoSubList[0].id;
        zuoraRefund.Case__c = comCase.id;
        zuoraRefund.Case_1__c = String.valueof(comCase.id);
        insert zuoraRefund;
        
        //mockData01();

        ApexPages.StandardController sc = new ApexPages.StandardController(comCase);
        CreateRefundController controller = new CreateRefundController(sc);
        controller.paymentRecs = 'test';
        controller.amountToRefund = 1.00;
        controller.thisBillingAccount = billAcc;
        controller.paymentMethodId = zuoraPayment.Zuora__External_Id__c;
        controller.billingAcct = billAcc;
        controller.thisCase = comCase;
        controller.thisRefund = zuoraRefund;
        controller.updateAcctList();
        CreateRefundController.BillingAccountWrapper instance = new CreateRefundController.BillingAccountWrapper(billAcc);
        controller.saveRecord();

        PageReference pageRef = Page.CreateRefund;
        system.test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', comCase.Id); 
        controller.fetchBillingAccount();
        
    }
    
    //mock data
    static void mockData01(){
        
        zAcc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Database.insert(zAcc);
        
        zBillAcct = TestDataFactory.createBillingAccount(1)[0];
        zBillAcct.Zuora__Account__c = zAcc.id;
        Database.insert(zBillAcct);
        
        refundRecord = new Zuora__Refund__c(Name='Test Refund', Zuora__Amount__c=100.00);
        refundRecord.Zuora__BillingAccount__c = zBillAcct.id;
        
        Database.insert(refundRecord);
        
    }
    
    
}