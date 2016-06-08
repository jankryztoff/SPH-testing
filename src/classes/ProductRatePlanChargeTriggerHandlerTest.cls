/**
     * Class Name: ProductRatePlanChargeTriggerHandlerTest
     * @author: Joban Bir Singh     
     * Date: 8/4/2014
     * Requirement/Project Name: <SPH>
     * @Modified by Hazel Jurna M. Limot
     * @description Test Class for ProductRatePlanChargeTriggerHandler
     * 
*/
@isTest (seeAllData = True)
public class ProductRatePlanChargeTriggerHandlerTest{
    // List initializations    
    public static List<zqu__ZProduct__c> listProducts = TestDataFactory.createZProduct(1);
    public static List<zqu__ProductRatePlan__c> listProductRatePlan = TestDataFactory.createProductRatePlan(1);       
    public static List<zqu__ProductRatePlanCharge__c> listProductRatePlanCharge = TestDataFactory.createProductRatePlanCharge(100);
    public static List<Publication__c> listPublication = TestDataFactory.createPublication(100); 
   /* public static Contact testCont;
    public static Contact testCont2; */
    
    // Test method 
  /*  static TestMethod void createChargeRecord(){
         // get the records in their respective lists   
         list<zqu__ZProduct__c> prodListForInsert = new list<zqu__ZProduct__c>(); 
         list<zqu__ProductRatePlan__c> prodRatePlanListForInsert = new list<zqu__ProductRatePlan__c>();  
         list<Publication__c> prodPublicationListForInsert = new list<Publication__c>(); 
         list<zqu__ProductRatePlanCharge__c> prodRatePlanListInsert = new List<zqu__ProductRatePlanCharge__c>();
         
         // insert products with the desired data
         for(zqu__ZProduct__c prodRec :  listProducts){
            prodRec.ProductType__c = 'Product';
            prodRec.zqu__Deleted__c= false;
            prodListForInsert.add(prodRec);         
         }
         insert prodListForInsert; 
         System.assertEquals(1, prodListForInsert.size());
         System.assertEquals('Product', prodListForInsert[0].ProductType__c);
         
         // insert product rate plans with the desired data
         for(zqu__ProductRatePlan__c proRatePlan : listProductRatePlan){
             proRatePlan.zqu__ZProduct__c = prodListForInsert[0].Id;             
             proRatePlan.RatePlanType__c = 'Bill Plan';  
             prodRatePlanListForInsert.add(proRatePlan);               
         }
         insert prodRatePlanListForInsert;
         System.assertEquals(1, prodRatePlanListForInsert.size());
         System.assertEquals('Bill Plan', prodRatePlanListForInsert[0].RatePlanType__c);
         
         // insert publication records with desired data
         for(Publication__c prodPublication : listPublication){
             prodPublication.Publication_Code__c = 'CODE';
             prodPublication.Publication_Type__c = 't';
             prodPublication.Published_Days__c ='NNNNYYY';               
             prodPublicationListForInsert.add(prodPublication);         
          } 
          insert prodPublicationListForInsert; 
          
          // insert producation rate plan charge records with desired data
          for(zqu__ProductRatePlanCharge__c prodRatePlan : listProductRatePlanCharge){
             prodRatePlan.zqu__ProductRatePlan__c = prodRatePlanListForInsert[0].Id;
             prodRatePlan.PublicationCode__c = 'CODE';
             prodRatePlanListInsert.add(prodRatePlan);              
          }            
           insert prodRatePlanListInsert;    
          
          ProductRatePlanChargeTriggerHandler prrct = new ProductRatePlanChargeTriggerHandler();
          prrct.runBeforeInsertTrigger();
          prrct.runBeforeUpdateTrigger();
          prrct.runBeforeDeleteTrigger();
          prrct.runAfterInsertTrigger();
          prrct.runAfterUpdateTrigger();
          prrct.runAfterDeleteTrigger();
          prrct.bulkBefore();
          prrct.bulkAfter();
          prrct.beforeInsert(listProductRatePlanCharge[0]);
          prrct.beforeUpdate(listProductRatePlanCharge[0], listProductRatePlanCharge[1]);
          prrct.beforeDelete(listProductRatePlanCharge[0]);
          
          prrct.afterInsert(listProductRatePlanCharge[0]);
          system.assertNOTEquals(NULL,listProductRatePlanCharge[0]);
          update listProductRatePlanCharge[0]; 
          
          prrct.afterDelete(listProductRatePlanCharge[0]);
          zqu__ProductRatePlanCharge__c newrec = new zqu__ProductRatePlanCharge__c(); 
          newrec = (zqu__ProductRatePlanCharge__c)listProductRatePlanCharge[0];
          update newrec;          
    }      */
    
    static TestMethod void testProductRatePlanChargeTriggerHandler(){
        //start test data
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductType__c = 'Product';
        zProduct.zqu__Deleted__c = false;
        zProduct.ProductCode__c = '01';
        database.insert(zProduct);
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        insert pub;
        //end test data
    
        test.startTest();
          zqu__ProductRatePlanCharge__c  prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
          prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
          prpc.PublicationCode__c = '01';
          insert prpc;
          
          zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
          prpct.zqu__Price__c = 2;
          prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
          insert prpct;
          
          zqu__ProductRatePlanCharge__c  prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
          prpc2.zqu__Deleted__c = true;
          prpc2.zqu__ZuoraId__c = 'ZID123';
          prpc2.PublicationCode__c = '01';
          prpc2.zqu__ProductRatePlan__c = prdRatePlan.Id;
          insert prpc2;
          
          prpc.Name = 'Name Update';
          prpc.zqu__Deleted__c = true;
          update prpc;
        
          ProductRatePlanChargeTriggerHandler prrct = new ProductRatePlanChargeTriggerHandler();
          prrct.runBeforeInsertTrigger();
          prrct.runBeforeUpdateTrigger();
          prrct.runBeforeDeleteTrigger();
          prrct.runAfterInsertTrigger();
          prrct.runAfterUpdateTrigger();
          prrct.runAfterDeleteTrigger();
        test.stopTest();
    }   
   
}