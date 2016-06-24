@isTest (seeAllData= true)
public class Test_UpdatePromotionGiftClass{

    public static testMethod void testUpdatePromotionGiftClass(){
    
    Account acc = new Account();
    acc.Name = 'Test Account CIO User';
    acc.Contact_Person__c = 'Test Person';
    insert acc;
    
    /*Contact c = new Contact();
    c.AccountId = acc.Id;
    c.FirstName = 'Lorenz';
    c.LastName = 'Seminiano';
    c.Recipient_Indicator__c = TRUE;
    insert c;*/
    
    Contact con = TestDataFactory.createContact(1)[0];
    con.AccountId = acc.Id;
    con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    con.Recipient_Indicator__c = true;  
    insert con;
    
    Order__c o = new Order__c();
    o.Account__c = acc.Id;
    o.Order_Legacy_Id__c = '0001';
    o.Legacy_Create_Date__c = '12/1/2015';
    o.Legacy_Create_By__c = 'Lorenz Seminiano';
    o.Legacy_Update_Date__c = '12/1/2015';
    o.Legacy_Update_By__c= 'Lorenz Seminiano';
    o.Delivery_Charge__c = 10000;
    o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
    o.Credit_Balance__c = 10000;
    o.Informed_Customer__c = TRUE;
    o.Recipient_Contact__c = con.Id;
    insert o;
    
    Package__c p = new Package__c();
    p.Package_Type__c = 'Base';
    p.Name = 'Test Package Name';
    p.Package_Code__c = '112191TSTPCKGcd';
    p.Effective_Start_Date__c = system.today();
    p.Effective_End_Date__c = system.today();
    insert p;
    
    
    Order_Line_Item__c oli = new Order_Line_Item__c();
    oli.Earliest_Start_Date__c = system.today();
    oli.Start_Date__c = date.today()+1;
    oli.Main_Package_Period__c = 3;
    oli.Order__c = o.id;
    oli.Qty__c = 3;
    oli.Term_Length__c = 12;
    oli.Main_Package_ID__c = p.id;
    oli.Delivered_By__c = 'Vendor';
    oli.Main_Package_Billing_Type__c = 'Full Prepaid';
    oli.Main_Package_Type__c = 'Base';
    oli.Main_Package_Sub_Type__c = 'Evergreen';
    oli.Main_Package_Frequency__c = 'Default';
    insert oli;
    
    Promotion_Gift__c pg = new Promotion_Gift__c();
    pg.Gift_Inventory__c = 100;
    pg.Gift_Issued__c = 50;
    pg.Gift_Redeemed__c = 25;
    insert pg;
    
    Order_Line_Item_Gift__c olig = new Order_Line_Item_Gift__c();
    olig.Order_Line_Item__c = oli.id;
    olig.Promotion_Gift__c = pg.id;
    olig.Redemption_Date__c = system.today();
    olig.Order_Quantity__c = 10;
    olig.Redemption_Quantity__c = 10;
    insert olig;
    
    
    
    }
}