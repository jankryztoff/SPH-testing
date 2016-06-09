/**
   @Author Joy Suarez
   @name PromotionGiftTrigger_Test
   @CreateDate 02/04/2015
   @Description Test class for PromotionGiftTrigger
   @Version <1.0>
   @reference 
*/


@isTest(SeeAllData=true)
private class PromotionGiftTrigger_Test {
    
    private static List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
    private static List<Promotion__c> promotionList = new List<Promotion__c>();
    private static List<Promotion_Gift__c> promoGift = new List<Promotion_Gift__c>();
    private static List<Gift__c> gift = new List<Gift__c>();
    private static Order__c orderRecord;
    
    /**
    *  @desc this method prepares test data
    *  @name prepareTestData
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static void prepareTestData(){
    
        Account acctRecord = new Account(
            Name='TestAcct'
        );
        insert acctRecord;
        
        Contact contRecord = new Contact(
            HomePhone='1115632', 
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
        
        gift = TestDataFactory.createGift(3);
        
        insert gift;
        
        promoGift = TestDataFactory.createPromotionGift(3);
        promoGift[0].Promotion__c = promotionList[0].Id;
        promoGift[0].gift__c = gift[0].Id;
        
        promoGift[1].Promotion__c = promotionList[1].Id;
        promoGift[1].gift__c = gift[1].Id;
        
        promoGift[2].Promotion__c = promotionList[2].Id;
        promoGift[2].gift__c = gift[2].Id;
        
        insert promoGift;
        
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
                    Start_Date__c = Date.today().addDays(1),
                    End_Date__c = Date.today().addDays(10),
                    Main_Package_ID__c = pkgRecord.Id
                )
            );
        }
        insert oliList;
        
        //create Case
        Case c = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        c.Order__c = orderRecord.Id;
        insert c;
        
        system.assertNotEquals(null, c);      
        
    }
    /**
    *  @desc this method is for testing promotion removal
    *  @name PromotionRemovalValidationTest
    *  @param none
    *  @return none
    *  @throws na
    */ 
    
    public static testMethod void PromotionRemovalValidationTest(){
        prepareTestData();
        Test.startTest();
            delete promotionList[0];
        Test.stopTest();
    }
    /**
    *  @desc this method is for testing promotion gift removal
    *  @name PromotionGiftRemovalValidationTest
    *  @param none
    *  @return none
    *  @throws na
    */
    
    public static testMethod void PromotionGiftRemovalValidationTest(){
        prepareTestData();
        Test.startTest();
            delete promoGift[0];
        Test.stopTest();
    }
    /**
    *  @desc this method is for testing gift removal
    *  @name GiftRemovalValidationTest
    *  @param none
    *  @return none
    *  @throws na
    */
   
    public static testMethod void GiftRemovalValidationTest(){
        prepareTestData();
        Test.startTest();
            delete gift[0];
        Test.stopTest();
    }
}