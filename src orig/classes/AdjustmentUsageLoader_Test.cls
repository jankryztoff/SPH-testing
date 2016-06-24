/**
* Class Name: AdjustmentUsageLoader_Test
* @author: Accenture April Veloso
* Date: 08/25/2015
* @Description: This class is used to code coverage of the AdjustmentUsageLoader class.
*
*/
@isTest (Seealldata=true)
public class AdjustmentUsageLoader_Test
{

    static testMethod void testMe01() {
    
            //caseList = [SELECT Id, Invoice__c, Invoice__r.Zuora__Zuora_Id__c, Invoice__r.Zuora__BillingAccount__c, ClosedDate, Adjustment_Amount__c, Invoice__r.Zuora__TaxAmount__c, Subscription_Name__c FROM Case WHERE Id IN: caseIdSet AND RecordTypeId = :CASE_ADJUSTMENT AND Adjustment_Amount__c > 0];
            List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual');
            acc[0].Name = 'TEST';
            acc[0].NRIC__c = 'T1234567R';
            insert acc;
            
            List<Contact> contactList = TestDataFactory.createContact(1);
        //for (Contact obj : contactList) {
            contactList[0].Account = acc[0];
            contactList[0].Email__c = 'a@a.com';
            contactList[0].Email_Secondary__c = 'a@a.com';
            insert contactList;
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c = acc[0].Id;
            billAcc[0].Billing_Type__c = 'Full Prepaid';
            billAcc[0].Billing_Contact__c = contactList[0].id;
            billAcc[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            insert billAcc;
            
          
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Name = 'Adjustment';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Zuora__CustomerAccount__c = billAcc[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc[0].id;
            zSub.Zuora__Status__c = 'Active';
            //zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = contactList[0].id;
            //zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            insert zSub; 
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__BillingAccount__c = billAcc[0].id;
            zInv.Zuora__Zuora_Id__c = 'ZID';
            //zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 10;
            //zInv.Zuora__TotalAmount__c = 10;
            //zInv.Zuora__InvoiceDate__c = date.today();
            //zInv.ARMS_Invoice_ID__c = 'AB12';
            zInv.Zuora__Account__c = acc[0].id;
            insert zInv;
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = 'ZID'; //zInv.Zuora__Zuora_Id__c;
            invLineItem.Name = 'SPH';
            invLineItem.Charge_Amount__c = 100.00;
            invLineItem.Tax_Amount__c = 10.00;
            
            insert invLineItem;
            
            Case caseRec = new Case();
            caseRec.Account__c = acc[0].id;
            caseRec.AccountId = acc[0].id;
            caseRec.RecordtypeID = ConstantsSLB.getKeyID('Case_Adjustments');
            caseRec.Status = 'Closed';
            caseRec.Invoice__c = zInv.id;
            caseRec.Sub_Status__c = 'Ready for Submission';
            caseRec.Adjustment_Amount__c = 10;
            caseRec.Subscription_Name__c = zSub.id;
            insert caseRec ;    
            
            Zuora__SubscriptionProductCharge__c  subProdCharge = new Zuora__SubscriptionProductCharge__c ();
            subProdCharge.Name = 'Adjustment';
            subProdCharge.Zuora__Subscription__c = zSub.id;
            //subProdCharge.Zuora__UOM__c = '10' ; 
            subProdCharge.Zuora__Price__c = 10.00;
            //subProdCharge.Zuora__ChargeNumber__c = 2;
            insert subProdCharge ;
            
            Set<id> setId = new Set<id>();
            setId.add(caseRec.id);
 
             AdjustmentUsageLoader adj = new AdjustmentUsageLoader();
             AdjustmentUsageLoader.loadAdjustmentUsages(setId);
    }
    static testMethod void testTaxAmountEqualtoZero() {
    
            //caseList = [SELECT Id, Invoice__c, Invoice__r.Zuora__Zuora_Id__c, Invoice__r.Zuora__BillingAccount__c, ClosedDate, Adjustment_Amount__c, Invoice__r.Zuora__TaxAmount__c, Subscription_Name__c FROM Case WHERE Id IN: caseIdSet AND RecordTypeId = :CASE_ADJUSTMENT AND Adjustment_Amount__c > 0];
            List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual');
            acc[0].Name = 'TEST';
            acc[0].NRIC__c = 'T1234567R';
            insert acc;
            
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            //zInv.Zuora__BillingAccount__c = billAccountList[0].id;
            zInv.Zuora__Zuora_Id__c = 'ID456';
            //zInv.Zuora__AmountWithoutTax__c = 100;
            zInv.Zuora__TaxAmount__c = 0;
            //zInv.Zuora__TotalAmount__c = 10;
            //zInv.Zuora__InvoiceDate__c = date.today();
            //zInv.ARMS_Invoice_ID__c = 'AB12';
            zInv.Zuora__Account__c = acc[0].id;
            insert zInv;
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Name = 'SPH';
            invLineItem.Charge_Amount__c = 100.00;
            invLineItem.Tax_Amount__c = 10.00;
            
            insert invLineItem;
            
            Case caseRec = new Case();
            caseRec.Account = acc[0];
            caseRec.Account__c = acc[0].id;
            caseRec.AccountId = acc[0].id;
            caseRec.RecordtypeID = ConstantsSLB.getKeyID('Case_Adjustments');
            caseRec.Status = 'Closed';
            caseRec.Invoice__c = zInv.id;
            caseRec.Sub_Status__c = 'Ready for Submission';
            caseRec.Adjustment_Amount__c = 10;
            insert caseRec ;    
            
            Set<id> setId = new Set<id>();
            setId.add(caseRec.id);
 
             AdjustmentUsageLoader adj = new AdjustmentUsageLoader();
             AdjustmentUsageLoader.loadAdjustmentUsages(setId);
    }
     static testMethod void testMe03() {
    
            //caseList = [SELECT Id, Invoice__c, Invoice__r.Zuora__Zuora_Id__c, Invoice__r.Zuora__BillingAccount__c, ClosedDate, Adjustment_Amount__c, Invoice__r.Zuora__TaxAmount__c, Subscription_Name__c FROM Case WHERE Id IN: caseIdSet AND RecordTypeId = :CASE_ADJUSTMENT AND Adjustment_Amount__c > 0];
            List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual');
            acc[0].Name = 'TEST';
            acc[0].NRIC__c = 'T1234567R';
            insert acc;
            
            List<Contact> contactList = TestDataFactory.createContact(1);
        //for (Contact obj : contactList) {
            contactList[0].Account = acc[0];
            contactList[0].Email__c = 'a@a.com';
            contactList[0].Email_Secondary__c = 'a@a.com';
            insert contactList;
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c = acc[0].Id;
            billAcc[0].Billing_Type__c = 'Full Prepaid';
            billAcc[0].Billing_Contact__c = contactList[0].id;
            billAcc[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            insert billAcc;
            
          
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Name = 'NUM124';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Zuora__CustomerAccount__c = billAcc[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc[0].id;
            zSub.Zuora__Status__c = 'Active';
            //zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = contactList[0].id;
            //zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            insert zSub; 
    
            Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
            zInv.Zuora__Zuora_Id__c = 'ID456';
            zInv.Zuora__TaxAmount__c = 100;
            zInv.Zuora__Account__c = acc[0].id;
            zInv.Zuora__BillingAccount__c = billAcc[0].id;
            //zInv.Zuora__AmountWithoutTax__c = 100;
            //zInv.Zuora__TotalAmount__c = 10;
            //zInv.Zuora__InvoiceDate__c = date.today();
            //zInv.ARMS_Invoice_ID__c = 'AB12';
            insert zInv;
            
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Invoice_ID__c = zInv.Zuora__Zuora_Id__c;
            invLineItem.Name = 'SPH';
            invLineItem.Charge_Amount__c = 100.00;
            invLineItem.Tax_Amount__c = 10.00;
            insert invLineItem;
            
            
           //Recordtype recType = [SELECT id, DeveloperName from RecordType Where sObjectType = 'Case' and DeveloperName = 'Complaint_Magazine'];
            Case caseRec = new Case();
            caseRec.Account__c = acc[0].id;
            caseRec.Account = acc[0];
            caseRec.AccountId = acc[0].id;
            caseRec.RecordtypeID = ConstantsSLB.getKeyID('Case_Adjustments');
           // caseRec.RecordtypeID = recType.id;
            caseRec.Status = 'Closed';
            caseRec.Invoice__c = zInv.id;
            caseRec.Sub_Status__c = 'Ready for Submission';
            caseRec.Adjustment_Amount__c = 10;
            caseRec.Subscription_Name__c = zSub.id;
            insert caseRec ;    
          
          /*  
            Zuora__SubscriptionProductCharge__c  subProdCharge = new Zuora__SubscriptionProductCharge__c ();
            subProdCharge.Name = 'Adjustment';
            subProdCharge.Zuora__Subscription__c = zSub.id;
            subProdCharge.Zuora__UOM__c = 10 ; 
            subProdCharge.Zuora__Price__c = 10.00;
            subProdCharge.Zuora__ChargeNumber__c = 2;
            insert subProdCharge ;
          */  
            Set<id> setId = new Set<id>();
            setId.add(caseRec.id);
 
             AdjustmentUsageLoader adj = new AdjustmentUsageLoader();
             AdjustmentUsageLoader.loadAdjustmentUsages(setId);
    }
}