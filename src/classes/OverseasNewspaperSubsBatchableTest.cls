/**
@Author <Rom Edison Reyes>
@name <OverseasNewspaperSubsBatchableTest>
@CreateDate <02/24/2015>
@Description <Test Class for OverseasNewspaperSubscriptionBatchable>
@Version <1.0>
@reference <none>
*/
@isTest(SeeAllData = true)
private class OverseasNewspaperSubsBatchableTest {

    /**
    * Testmethod for OverseasNespaperSubscription batch 
    * @name <testOverseasNewspaperSubs>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testOverseasNewspaperSubs()
    {
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        postal.Street_Name__c = 'Test Street';
        postal.Building_Name__c = 'Test Building';
        postal.House_Block_Number__c = '13';
        insert postal;
        
        
        //Create Country   
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Name = 'SINGAPORE';
        country.Country_Name__c = 'SINGAPORE';
        country.Code__c = 'XY';
        insert country;
        
        //Create Address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Name = 'Test Address';
        add.Postal_Code__c = postal.id;
        add.Legacy_Created_By__c = 'Creator';
        add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
        add.Legacy_Updated_By__c = 'Modifier';
        add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
        add.Block_House_Number__c = '22';
        add.Level_Number__c = '30';
        add.Unit_Number__c = '13';
        add.Country__c = country.Id;
        insert add;
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
        insert acc;
        
        //Create Contact   
        Contact con = TestDataFactory.createContactRecType(1, 'Internal')[0] ;
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        
        insert con;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Recipient_Contact__c = con.id;
        order.Subscriber_Charge__c = 10;
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];    
        pack.Package_Type__c = 'Base';
        pack.Name = 'ST Print Test';
        pack.Subscription_Type__c = 'Termed';
        pack.Package_Code__c = 'STEST12';
        pack.Subscription_Period__c = '12';
        pack.Effective_Start_Date__c = date.today().addDays(1);
        pack.Effective_End_Date__c = date.today() + 5;
        insert pack;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today().addDays(1);
        oli.Start_Date__c = date.today().addDays(1);
        oli.Order__c = order.id;
        oli.Main_Package_Period__c = 2;
        oli.Qty__c = 3;
        oli.Term_Length__c = 5;
        oli.Main_Package_ID__c = pack.id;  
        insert oli;
        
        Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
        bill.Zuora__Account__c = acc.Id;
        insert bill;    
        
        //Create Zuora Subscription    
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(2);
        
        for(Zuora__Subscription__c zSub: zSubs)
        {
            zSub.Subscriber_Contact__c = con.Id;
            zSub.Recipient_Contact__c = con.Id;
            zSub.Recipient_Contact_1__c = con.Id;    
            zSub.Contact__c = con.Id;
            zSub.Zuora__Account__c = acc.id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Order_Line_Item_Number__c =  oli.id; 
            zSub.Order_Line_Item_Number_1__c =  oli.id;
            zSub.Frequency__c = 'Default';    
            zSub.Frequency_1__c = 'Default';
            zSub.Number_of_Copies__c = 1;
            zSub.Number_of_Copies1__c = '1';
            zSub.Subscription_End_Date__c = String.valueOf(date.today()+5);
            zSub.Main_Package__c = pack.id;
            zSub.Main_Package_1__c = pack.id;
            zSub.Zuora__SubscriptionEndDate__c = date.today() +5;
            zSub.Zuora__CustomerAccount__c = bill.Id;
            zSub.Subscription_Charge__c = 30;
            zSub.Delivered_By__c = 'Mailing Agent';
            zSub.Delivered_By_1__c = 'Mailing Agent';
        }
        zSubs[0].Name = 'BA-S00002264';
        zSubs[1].Name = 'BA-S12342264';    
        zSubs[1].Subscription_Type__c = 'Delivery';
        insert zSubs;  
        
        Test.startTest();
        OverseasNewspaperSubscriptionBatchable batch = new OverseasNewspaperSubscriptionBatchable();
        Id batchprocessid = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        List<Zuora__Subscription__c> subs = [SELECT Id, Delivered_By__c from Zuora__Subscription__c WHERE Delivered_By__c = 'Mailing Agent' 
and Recipient_Contact__r.RecordType.Name = 'Internal'];
        System.debug('>>>SUBS: ' + subs);
        System.debug('>>>CON REC: ' + con.RecordTypeId);
        System.debug('>>>CON RECNAME: ' + con.RecordType.name);
        //System.assert(zSubs[0].id == subs[0].id || zSubs[1].id == subs[0].id);
        //System.assertEquals('Mailing Agent', subs[0].Delivered_By__c);     
    }
}