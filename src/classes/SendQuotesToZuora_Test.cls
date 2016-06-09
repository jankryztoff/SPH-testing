/*
 * Class Name: SendQuotesToZuora_Test
 * @author: Rom Edison Reyes
 * Date: 4/14/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for SendQuotesToZuora
 */

@isTest(seeAllData = true)
public class SendQuotesToZuora_Test {
    
    static testMethod void testReceiveData(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Account ma = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        ma.Mailing_Agent_Code__c = '01';
        ma.Type = 'Local';
        ma.Active__c = true;
        database.insert(ma);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);

        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        con.Address__c = address.Id;
        database.insert(con);  

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);

        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);

        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__Account__c = acc.id;
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today()+1;
        database.insert(sub);

        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Change of Subscription'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);

        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = orders[0].Id;
        insert cas;

        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Case__c = cas.id;
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = Date.Today()+2;          
        }
        olis[1].Vendor_Mailing_Agent__c = ma.id;
        database.insert(olis);
         
         
        List<zqu__Quote__c> quoteList = TestDataFactory.createQuote(1);
        for(zqu__Quote__c zq: quoteList ){
        zq.zqu__Account__c = acc.id;
        zq.Order_Line_Item_Number_1__c = olis[0].id;
        zq.Order_Line_Item_Number__c = olis[0].id;
        zq.Order_Number__c = orders[0].id;
        }

        Database.insert(quoteList);
            
        list<Id> lQuoteId = new list<Id>{quoteList[0].id};

        Id accId = acc.id;
        Id baId = billAcc.id;
        Test.StartTest();
        try{
            SendQuotesToZuora sendQuotes = new SendQuotesToZuora();
            sendQuotes.SendQuotesToZuora();
            //sendQuotes.RecievedData(lQuoteId, accId, baId, true);//CLin 25April2016
            //sendQuotes.RecievedData(lQuoteId, accId, baId, false);//CLin 25April2016
        }catch(Exception e){
            
        }
        Test.StopTest();
    }
    
    static testMethod void testCallMethods(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Account ma = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        ma.Mailing_Agent_Code__c = '01';
        ma.Type = 'Local';
        ma.Active__c = true;
        database.insert(ma);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);

        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        con.Address__c = address.Id;
        database.insert(con);  

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);

        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);

        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__Account__c = acc.id;
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today()+1;
        database.insert(sub);

        List<Order__c> orders = TestDataFactory.createOrder(2);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Change of Subscription'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);

        List<Case> lstCase = TestDataFactory.createCase(2, 'Complaint - Magazine');
        lstCase[0].Order__c = orders[0].Id;
        lstCase[1].Order__c = orders[1].Id;
        insert lstCase;

        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Case__c = lstCase[0].id;
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = Date.Today()+2;          
        }
        olis[1].Case__c = lstCase[1].id;
        olis[1].Order__c = orders[1].id;
        olis[1].Vendor_Mailing_Agent__c = ma.id;
        database.insert(olis);
         
         
        List<zqu__Quote__c> quoteList = TestDataFactory.createQuote(2);
        for(zqu__Quote__c zq: quoteList ){
        zq.zqu__Account__c = acc.id;
        zq.Order_Line_Item_Number_1__c = olis[0].id;
        zq.Order_Line_Item_Number__c = olis[0].id;
    
        }
        quoteList[0].Order_Number__c = orders[0].id;
        quoteList[1].Order_Number__c = orders[1].id;
        Database.insert(quoteList);
            
        list<Id> lQuoteId = new list<Id>{quoteList[0].id, quoteList[1].id};

        Test.StartTest();
        SendQuotesToZuora.assessCaseOrderStatus(lQuoteId);
        Test.StopTest();
    }
}