/**
* Class Name: <Identify_Urgent_OrderLineItemTest>
* @author: Marjorie Gaelo
* Date: <02/24/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for Identify_Urgent_OrderLineItem>
*/

@isTest(SeeAllData=True)
    private class Identify_Urgent_OrderLineItem_Test{
        
    static testMethod void testUrgentVendor() {
    
        List<Account> accList = new List<Account>();
        List<Order__c> lO = new List<Order__c>();

        Account acct = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
        acct.NRIC__c = 'T1234567R';
        accList.add(acct);
        insert accList;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        Country__c cntry = TestDataFactory.createCountry(1)[0];
        cntry.Account__c = acct.id;
        cntry.Zonal_Code__c = 'D';
        insert cntry;

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = cntry.id;
        insert addressRec;

        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountID = accList[0].Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;

        Order__c o = new Order__c();
        o.Account__c = accList[0].id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = con.Id; 
        lO.add(o);
        Insert lO;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = 'NYNYNYY';
        pub.Publication_Type__c = 'N';
        pub.Product_Category__c = 'Print';
        pub.Publication_Code__c = '1234';
        pub.Platform_Type__c = 'PRINT';
        pub.Earliest_Start_Date__c = date.today()+30;
        insert pub;

        Order_Line_Item_Vendor__c vOli = new Order_Line_Item_Vendor__c();
        vOli= TestDataFactory.createOrderLineItemVendor(1)[0];
        vOli.Publication__c = pub.id;
        vOli.Urgent__c = False;
        vOli.Order__c = o.id;
        vOli.Start_Date__c = date.today() + 1 ;
        
        Test.startTest();
        insert vOli;
        Identify_Urgent_OrderLineItem iuo = new Identify_Urgent_OrderLineItem();
        iuo.Identify_Urgent_OrderLineItem(lo,false);
        Test.stopTest();
    }
    
    static testMethod void testUrgentDirect() {
        
        List<Order__c> lO = new List<Order__c>();
        
        Account acct = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
        acct.NRIC__c = 'T1234567R';
        insert acct;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        Country__c cntry = TestDataFactory.createCountry(1)[0];
        cntry.Account__c = acct.id;
        cntry.Zonal_Code__c = 'D';
        insert cntry;

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = cntry.id;
        insert addressRec;

        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountID = acct.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;

        Order__c o = new Order__c();
        o.Account__c = acct.id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = con.Id; 
        lo.add(o);
        insert lo;
        
        Test.startTest();
        Identify_Urgent_OrderLineItem iuo = new Identify_Urgent_OrderLineItem();
        iuo.Identify_Urgent_OrderLineItem(lo,true);
        Test.stopTest();
    }
}