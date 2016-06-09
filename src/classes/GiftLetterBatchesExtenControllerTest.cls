/**
   @author Christian Coquilla
   @name GiftLetterBatchesExtenControllerTest
   @createDate 09 Apr 2016
   @description Test for class GiftLetterBatchesExtenController
   @version 1.0 
*/

@isTest(seeAllData=true)
public class GiftLetterBatchesExtenControllerTest{
  
    static testMethod void test01(){
    
    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
    promo.Contract_Period__c = '10';
    insert promo;
    
    Gift__c gift = TestDataFactory.createGift(1)[0];
    insert gift;
    
    List<Gift_Letter_Batch__c> glbList = new List<Gift_Letter_Batch__c>();
    Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c();
    glb.End_Date__c = date.Today()+5;
    glb.Gift__c = gift.Id;
    glb.Promotion__c = promo.Id;
    glb.Start_Date__c = date.Today()+5;
    insert glb;
    
    //system.assertEquals(null, glb.Id);
    
     test.starttest();         
        //ApexPages.currentPage().getParameters().put('Id',glb.Id);
        
        ApexPages.StandardController stdController = new ApexPages.Standardcontroller(new Gift_Letter_Batch__c());
        GiftLetterBatchesExtenController controller = new GiftLetterBatchesExtenController(stdController);
        controller.g = glb;
    test.StopTest();    
    
    
    }
    
	static testMethod void test02(){
    
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '10';
        insert promo;
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Name = 'Test Gift';
        insert gift;
        
        List<Gift_Letter_Batch__c> glbList = new List<Gift_Letter_Batch__c>();
        Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c();
        glb.End_Date__c = date.Today()+5;
        glb.Gift__c = gift.Id;
        glb.Promotion__c = promo.Id;
        glb.Start_Date__c = date.Today()+5;
        insert glb;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.Id;
        promoGift.Gift__c = gift.Id;
        insert promoGift;
        
        //system.assertEquals(null, glb.Id);
        
         test.starttest();         
            ApexPages.currentPage().getParameters().put('Id',glb.Id);  
        
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(glb);
            GiftLetterBatchesExtenController controller = new GiftLetterBatchesExtenController(stdController);
        	controller.saveNew();
        	controller.getGiftOptions();
        	controller.save();
            //controller.g = glb;
        test.StopTest();    
    
    
    }
    
    static testMethod void test03(){
    
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '10';
        insert promo;
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Name = 'Test Gift';
        insert gift;
        
        List<Gift_Letter_Batch__c> glbList = new List<Gift_Letter_Batch__c>();
        Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c();
        glb.End_Date__c = date.Today()+5;
        glb.Gift__c = gift.Id;
        glb.Promotion__c = promo.Id;
        glb.Start_Date__c = date.Today()+5;
        //insert glb;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.Id;
        promoGift.Gift__c = gift.Id;
        insert promoGift;
        
         test.starttest();          
        
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(glb);
            GiftLetterBatchesExtenController controller = new GiftLetterBatchesExtenController(stdController);
        	controller.saveNew();
        	controller.getGiftOptions();
        	controller.save();
        test.StopTest();    
    
    
    }
    
    static testMethod void test04(){
    
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '10';
        insert promo;
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Name = 'Test Gift';
        insert gift;
        
        List<Gift_Letter_Batch__c> glbList = new List<Gift_Letter_Batch__c>();
        Gift_Letter_Batch__c glb = new Gift_Letter_Batch__c();
        glb.End_Date__c = date.Today()+5;
        glb.Gift__c = gift.Id;
        //glb.Promotion__c = promo.Id;
        glb.Start_Date__c = date.Today()+5;
        //insert glb;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.Id;
        promoGift.Gift__c = gift.Id;
        insert promoGift;
        
         test.starttest();          
        
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(glb);
            GiftLetterBatchesExtenController controller = new GiftLetterBatchesExtenController(stdController);
        	controller.save();
        test.StopTest();    
    
    
    }

 }