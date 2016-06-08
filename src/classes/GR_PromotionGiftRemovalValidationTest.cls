/**
 * Class Name: CourierFeeComputationTest
 * @author: Alfred Abrina
 * Date: 02.15.2015
 * Requirement/Project Name: SPH
 * @description Test Class for GR_PromotionGiftRemovalValidation
 */
@isTest(SeeAllData=true)
private class GR_PromotionGiftRemovalValidationTest {
    
    private static List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
    private static List<Promotion__c> promotionList = new List<Promotion__c>();
    private static List<Promotion_Gift__c> promoGift = new List<Promotion_Gift__c>();
    private static List<Gift__c> gift = new List<Gift__c>();
    private static Order__c orderRecord;
    
/**
* preparation of data. 
* @name prepareTestData
* @param none
* @return none
* @throws exception-<exception description>
* @see com.ac.sample.SuperObject#get
*/  
    public static void prepareTestData(){
        Account acctRecord = new Account(
            Name='TestAcct'
        );
        insert acctRecord;
        
        Contact contRecord = new Contact();
        contRecord.HomePhone='1115632'; 
        contRecord.LastName='TestLastName';
        contRecord.AccountId=acctRecord.Id;
        contRecord.Recipient_Indicator__c = true;    
        contRecord.Email = 'johndoe@test.org';
        insert contRecord;
        
        Package__c pkgRecord = new Package__c();
        pkgRecord.Name='TestPkg';
        pkgRecord.Package_Code__c='10001'; 
        pkgRecord.Effective_Start_Date__c=Date.today(); 
        pkgRecord.Effective_End_Date__c=Date.today();
        
        insert pkgRecord;
        
        for(Integer i = 0; i < 200; i++){
            Promotion__c pcc = 
                new Promotion__c(
                    Promotion_Code__c='Pcode' + i,
                    Name='Promotion ' + i,
                    Effective_Start_Date__c = Date.today(),
                    Effective_End_Date__c = Date.today().addDays(5)
            );
          promotionList.add(pcc);  
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
        
        orderRecord = new Order__c();
        orderRecord.Account__c=acctRecord.Id;
        orderRecord.Informed_Customer__c=true;
        orderRecord.Recipient_Contact__c=contRecord.Id;
        orderRecord.Credit_Balance__c=10.0; 
        orderRecord.Delivery_Charge__c=10.0; 
        orderRecord.Monthly_Delivery_Charge_for_Full_Payment__c=10.0;
        insert orderRecord;
        
        for(Integer i = 0; i < 100; i++){
            Order_Line_Item__c olt = 
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
                );
            oliList.add(olt);
        }
        insert oliList;
        
        //create Case
        Case c = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        c.Order__c = orderRecord.Id;
        insert c;
        
        //create Subscription record
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Main_Package_1__c = pkgRecord.Id;
        sub.Zuora__Account__c = acctRecord.Id;
        sub.Subscriber_Contact__c = contRecord.Id;
        sub.Recipient_Contact__c  = contRecord.Id;
        sub.Order_Number__c = orderRecord.Id;
        sub.Zuora__Status__c = 'Active';
        sub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
        sub.Contract_End_Date__c = String.valueof(date.Today());
        sub.Promotion_1__c = promotionList[0].Id;
        //insert sub;
        
    }
 
  
/**
* preparation of data. 
* @name PromotionRemovalValidationTest
* @param none
* @return none
* @throws exception-FIELD_CUSTOM_VALIDATION_EXCEPTION
*/     
    public static testMethod void PromotionRemovalValidationTest(){
    try{
        prepareTestData();
        Test.startTest();
            try {
                delete promotionList[0];
            } catch (DmlException e) {
                //Assert Status Code
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', 
                                     e.getDmlStatusCode(0) );
            } //catch
        Test.stopTest();
    }catch(Exception e){
        System.debug('Error: ' + e.getMessage());
        }
    }

/**
* preparation of data. 
* @name PromotionGiftRemovalValidationTest
* @param none
* @return none
* @throws exception-FIELD_CUSTOM_VALIDATION_EXCEPTION
*/         
    public static testMethod void PromotionGiftRemovalValidationTest(){
    try{
        prepareTestData();
        Test.startTest();
            try {
                delete promoGift[0];
            } catch (DmlException e) {
                //Assert Status Code
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', 
                                     e.getDmlStatusCode(0) );
            } //catch
        Test.stopTest();
    }catch(Exception e){
        System.debug('Error: ' + e.getMessage());
        }
    }
/**
* preparation of data. 
* @name GiftRemovalValidationTest
* @param none
* @return none
* @throws exception-FIELD_CUSTOM_VALIDATION_EXCEPTION
*/             
    public static testMethod void GiftRemovalValidationTest(){
    try{
        prepareTestData();
        Test.startTest();
            try {
                delete gift[0];
            } catch (DmlException e) {
                //Assert Status Code
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', 
                                     e.getDmlStatusCode(0) );
            } //catch
        Test.stopTest();
        }catch(Exception e){
        System.debug('Error: ' + e.getMessage());
        }
    }
}