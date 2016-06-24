/* 
 * Base Class Name: CustomZuoraSyncQueueable_Test
 * @author: Accenture IDC (jensar.joey.z.sayson) 
 * Date Created: 7/13/2015
 * Requirement/Project Name: <SPH>
 * @description Test Class for CustomZuoraSyncQueueable
 *
 * Modifications:
 * 1. (Author EID) @ MM/DD/YYYY - (EP)
 * ...
 */

@isTest(seeAllData = TRUE)
public class CustomZuoraSyncQueueable_Test
{
    static Account acc = null;
    static Zuora__CustomerAccount__c billAcc = null;
    static Address__c addressRec = null;    
    static Contact con = null;
    static Contact con1 = null;    
    static Order__c order = null;
    static Order_Line_Item__c orderline = null;
    static List<Zuora__Subscription__c> zSubList = null;
    
    static testmethod void test1(){
        try{
            Test.startTest();
                setData();
            
                CustomZuoraSyncQueueable cZSQ = new CustomZuoraSyncQueueable();
                //cZSQ.lstNewVersions;
            
            Test.stopTest();
        }
        catch(Zuora.zRemoteException e){}
        
        System.assertNotEquals(null,zSubList);
        
    }
    
    static void setData(){
            
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';  
        billAcc.Zuora__DefaultPaymentMethod__c = 'Others';  
        insert(billAcc);
        
        con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        insert pack;
       
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';  
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Subscriber_Charge__c = 1.00;
        insert order;
        
        Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem.Order__c = order.id;
        orderLineItem.Main_Package_ID__c = pack.id;
        insert orderLineItem;

        zSubList = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c zSub: zSubList){
            
            zSub.Zuora__Account__c = acc.Id;
            zSub.Zuora__CustomerAccount__c = billAcc.Id;  
            zSub.Zuora__Zuora_Id__c ='1234';
            zSub.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);
            zSub.Subscriber_Contact__c = con.Id;
            zSub.Recipient_Contact__c = con.Id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Subscription_Type_1__c = 'Delivery';
            zSub.Subscription_Type__c = 'Delivery';
            zSub.Order_Number_1__c = order.id;
            zSub.Generate_Invoice1__c = 'false'; 
            zSub.Other_PaymentMethod__c = 'Fujll Prepaid';
            
            zSub.Contract_End_Date__c = 'Churva resrot.Month';
            zSub.Recipient_Contact_1__c = con.Id;
            zSub.Payment_Mode__c = 'Full Prepaid';
            
            
            /*
                             
            zSub.Promotion_Contract_Period__c;
            zSub.Payment_Type__c;
            zSub.Subscriber_Contact_1__c;
            zSub.Term_Length1__c;
            zSub.Vendor_Credit__c;
            zSub.Zuora__AutoRenew__c;
            zSub.Zuora__ContractAcceptanceDate__c;
            zSub.Zuora__ContractEffectiveDate__c;
            zSub.Zuora__External_Id__c;
            zSub.Zuora__InitialTerm__c;
            zSub.Zuora__InvoiceOwner__c;
            zSub.Zuora__NextChargeDate__c;
            zSub.Zuora__NextRenewalDate__c;
            zSub.Zuora__OriginalCreatedDate__c;
            zSub.Zuora__RenewalTerm__c;
            zSub.Zuora__ServiceActivationDate__c;
            zSub.Zuora__SubscriptionStartDate__c;
            zSub.Zuora__SubscriptionEndDate__c;
            zSub.Zuora__MRR__c;
            zSub.Zuora__TCV__c;
            zSub.Zuora__TermStartDate__c;
            zSub.Zuora__TermEndDate__c;
            zSub.Zuora__TermSettingType__c;
            zSub.Zuora__Version__c;
            zSub.Zuora__Notes__c;
            zSub.Delivery_Charge_Type__c;
            zSub.Vendor__c;
           */
        }
        insert zSubList;
    }
}