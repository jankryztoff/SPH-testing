/**
 * Class Name: <CalculateChargesTest>
 * @author: <JhustinPinoy>
 * Date: <9/20/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for CalculateCharges>
 */
@isTest(SeeAllData=true)
public class EligibilityRuleTriggerHandlerTest {
    
    private static List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
    private static List<Eligibility_Rule__c> eligList = new List<Eligibility_Rule__c>();
    private static List<Promotion__c> promotionList = new List<Promotion__c>();
    private static List<Promotion_Eligibility_Rule__c> perList = new List<Promotion_Eligibility_Rule__c>();
    private static Order__c orderRecord;
    
    public static void prepareTestData(){
        Account acctRecord = new Account(
            Name='TestAcct'
        );
        insert acctRecord;
        
        Contact contRecord = new Contact(
            HomePhone='11152632', 
            LastName='TestLastName',
            AccountId=acctRecord.Id,
            Recipient_Indicator__c = true
        );
        insert contRecord;
        
        Package__c pkgRecord = new Package__c(
            Name='TestPkg',
            Package_Code__c='10001', 
            Effective_Start_Date__c=Date.today(), 
            Effective_End_Date__c=Date.today()
        );
        insert pkgRecord;
        
        for(Integer i = 0; i < 200; i++){
            eligList.add(
                new Eligibility_Rule__c(
                    Customer_Status__c = 'Vendor customer',
                    Name = 'TestName',
                    Effective_Start_Date__c = Date.today(), 
                    Effective_End_Date__c = Date.today().addDays(5)
                )
            );
        }
        insert eligList;
        
         for(Integer i = 0; i < 200; i++){
            promotionList.add(
                new Promotion__c(
                    Promotion_Code__c='Pcode' + i,
                    Name='Promotion ' + i,
                    Effective_Start_Date__c = Date.today(),
                    Effective_End_Date__c = Date.today().addDays(5)
                )
            );
        }
        insert promotionList;
        
        for(Integer i = 0; i < 200; i++){
            perList.add(
                new Promotion_Eligibility_Rule__c(
                    Eligibility_Rule__c = eligList[i].Id,
                    Promotion__c = promotionList[i].Id,
                    Package_List__c = 'Test pkg',
                    Days__c = '1'
                )
            );
        }
        insert perList;
        
        orderRecord = new Order__c(
            Account__c=acctRecord.Id,
            Informed_Customer__c=true,
            Recipient_Contact__c=contRecord.Id,
            Credit_Balance__c=10.0, 
            Delivery_Charge__c=10.0, 
            Monthly_Delivery_Charge_for_Full_Payment__c=10.0
        );
        insert orderRecord;
        
        for(Integer i = 0; i < 100; i++){
            oliList.add(
                new Order_Line_Item__c(
                    Promotion_ID__c = promotionList[i].Id,
                    Order__c = orderRecord.Id,
                    Delivered_By__c = 'Mailing Agent',
                    Main_Package_Billing_Type__c = 'Recurring Prepaid',
                    Main_Package_Frequency__c = 'TestPackFreq',
                    Main_Package_Sub_Type__c = 'TestSubType',
                    Main_Package_Type__c = 'TestPackType',
                    End_Date__c = Date.today().addDays(10),
                    Main_Package_ID__c = pkgRecord.Id
                )
            );
        }
        insert oliList;
        
    }
    
    public static testMethod void triggerHandlerTest(){
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarderth@test.com'
        );
        System.runAs(testUser) {
            prepareTestData();
            Test.startTest();
                update eligList;
                delete eligList;
                
                EligibilityRuleTriggerHandler handler = new EligibilityRuleTriggerHandler();
                handler.runBeforeInsertTrigger();
                handler.runBeforeUpdateTrigger();
                handler.runAfterInsertTrigger();
                handler.runAfterUpdateTrigger();
                handler.runBeforeDeleteTrigger();
                handler.runAfterDeleteTrigger();
            Test.stopTest();
        }
    }
}