/*
 * Class Name: PackageTriggerHandlerTest 
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * Project/Requirement: 
 * @description: to test PackageTriggerHandlerclass
 */
         
@isTest(SeeAllData=true)
private class PackageTriggerHandlerTest {
    
    private static List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
    //private static List<Promotion__c> promotionList = new List<Promotion__c>();
    private static List<Package__c> pkgList = new List<Package__c>();
    private static List<Package__c> packagelist = new List<Package__c>();
    private static Order__c orderRecord;
    
    /**
    *  To set up test data to be used by other test method
    *  @name prepareTestData
    *  @param none
    *  @return none
    *  @throws na
    */    
    public static void prepareTestData(){
        Account acct = new Account(
            Name = 'Test Account'
        );
        insert acct;
        
        /*Contact con = new Contact(
            HomePhone = '123456987', 
            LastName = 'Test LastName',
            AccountId = acct.Id
        );*/
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        system.assertNotEquals(null, addressRec);        
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acct.Id;
        // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        // END : CCB 002 12/2/2014
                    
        insert con;
        
        /**Package__c pkgRecord = new Package__c(
            Name='TestPkg',
            Package_Code__c='10001', 
            Effective_Start_Date__c=Date.today(), 
            Effective_End_Date__c=Date.today()
        );
        insert pkgRecord;*/
        
        Promotion__c prom = new Promotion__c(
            Promotion_Code__c = 'Test Pcode',
            Name = 'Test Promotion',
            Effective_Start_Date__c = Date.today(),
            Effective_End_Date__c = Date.today().addDays(5)
        );
        insert prom;
        
        packagelist = TestDataFactory.createPackage(1);
         for(Package__c item : packagelist){
             item.name = 'sample package';
             item.Package_Type__c = 'Discount';
             item.Package_Sub_Type__c = 'Tiered';
             item.Package_code__c = 'T0013ABS';
             item.Effective_Start_Date__c = date.today();
             item.Effective_End_Date__c = date.today().addDays(1);
             item.Subscription_Period__c = '18';
             
         }        
         insert packagelist ;
        
        for(Integer i = 0; i < 200; i++){
            pkgList.add(
                new Package__c(
                    Name = 'Test Pkg' + i,
                    Package_Code__c = '000123' + i,
                    Effective_Start_Date__c = Date.today(),
                    Effective_End_Date__c = Date.today().addDays(5),
                    Subscription_Type__c = 'Termed',
                    Subscription_Period__c = '12'
                )
            );
        }
        insert pkgList;
        
        Set<Id> packageIds= new Set<Id>();
        for(Package__c pkg: pkgList){
            packageIds.add(pkg.id);
        }
        
        for(Package__c pkg: packagelist){
            packageIds.add(pkg.id);
        }
        
        
        orderRecord = new Order__c(
            Account__c = acct.Id,
            Informed_Customer__c = true,
            Recipient_Contact__c = con.Id,
            Credit_Balance__c = 150.0, 
            Delivery_Charge__c = 50.0, 
            Monthly_Delivery_Charge_for_Full_Payment__c = 10.0
        );
        insert orderRecord;
        
        for(Integer i = 0; i < 100; i++){
            oliList.add(
                new Order_Line_Item__c(
                    Promotion_ID__c = prom.Id,
                    Order__c = orderRecord.Id,
                    Delivered_By__c = 'Mailing Agent',
                    Main_Package_Billing_Type__c = 'Recurring Prepaid',
                    Main_Package_Frequency__c = 'TestPackFreq',
                    Main_Package_Sub_Type__c = 'TestSubType',
                    Main_Package_Type__c = 'TestPackType',
                    End_Date__c = Date.today().addDays(30),
                    Main_Package_ID__c = pkgList[i].Id
                )
            );
        }
        insert oliList;
        
    } 
    
    
    /**
    *  To test PackageTriggerHandler
    *  @name triggerHandlerTest
    *  @param none
    *  @return none
    *  @throws na
    */    
    public static testMethod void triggerHandlerTest(){
        prepareTestData();
        Test.startTest();
        
            Package__c pack = pkgList[0];
            pack.Id = null;
            pack.Package_Code__c = '000123' + 201;            
            insert pack;
            system.assertNotEquals(null, pack);             
            
            update pack;
            delete oliList;
            delete pkgList;
            //START JMG
            delete packagelist;
            
            PackageTriggerHandler run = new PackageTriggerHandler();
                run.runBeforeInsertTrigger();
                run.runBeforeUpdateTrigger();
                run.runBeforeDeleteTrigger();
                run.runAfterInsertTrigger();
                run.runAfterUpdateTrigger();
                run.runAfterDeleteTrigger();
            //END JMG
        Test.stopTest();
    }
}