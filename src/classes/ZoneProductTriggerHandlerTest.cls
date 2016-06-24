/**
@Author <Rom Edison Reyes>
@name <ZoneProductTriggerHandlerTest>
@CreateDate <02/16/2015>
@Description <Test class for ZoneProductTriggerHandler>
@Version <1.0>
@reference <none>
*/
@isTest
private class ZoneProductTriggerHandlerTest {

/**
* Testmethod to test insert zone product
* @name <testInsertUpdateDeleteZoneProduct>
* @param <none>
* @return <none>
* @throws exception-<none>
* @see 
*/    
static testmethod void testInsertUpdateDeleteZoneProduct()    
{
    //Create Zone
    Zone__c zone = new Zone__c();
    insert zone;
    
    //Create ZProduct
    zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
    zProd.Name = 'BT Invest Test';
    zProd.zqu__ZuoraId__c = '2c92c0f84495ff400144a9c8701b012b';
    zProd.zqu__SKU__c = 'SKU-00000005';
    zProd.ProductCode__c = 'Test Code';
    zProd.ProductType__c = 'Test Type';
    insert zProd;
    
    //Create Zone Product
    Zone_Product__c zoneProd = new Zone_Product__c();
    zoneProd.Effective_Start_Date__c = date.today();
    zoneProd.Zone__c = zone.id;
    zoneProd.Postage_Charge__c = 30;
    zoneProd.Product__c = zProd.Id;
    
    Test.startTest();
    insert zoneProd;
    zoneProd.Effective_Start_Date__c = date.today() + 3;
    update zoneProd;
    delete zoneProd;
    Test.stopTest();
    List<Zone_Product__c> zProdList = [SELECT Id FROM Zone_Product__c WHERE id=:zoneProd.id];
    System.assertEquals(0, zProdList.size());
}
 
/**
* Testmethod to test insert zone product with 1 record already using the same data
* @name <testInsertWith1ZoneProductUsingData>
* @param <none>
* @return <none>
* @throws exception-<none>
* @see 
*/  
static testmethod void testInsertWith1ZoneProductUsingData()    
{
    //Create Zone
    Zone__c zone = new Zone__c();
    insert zone;
    
    //Create ZProduct
    zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
    zProd.Name = 'BT Invest Test';
    zProd.zqu__ZuoraId__c = '2c92c0f84495ff400144a9c8701b012b';
    zProd.zqu__SKU__c = 'SKU-00000005';
    zProd.ProductCode__c = 'Test Code';
    zProd.ProductType__c = 'Test Type';
    insert zProd;
    
    //Create Zone Product
    Zone_Product__c zoneProd = new Zone_Product__c();
    zoneProd.Effective_Start_Date__c = date.today();
    zoneProd.Zone__c = zone.id;
    zoneProd.Postage_Charge__c = 30;
    zoneProd.Product__c = zProd.Id;
    
    Test.startTest();
    insert zoneProd;
    
    //Create Zone Product 2
    Zone_Product__c zoneProd2 = new Zone_Product__c();
    zoneProd2.Effective_Start_Date__c = date.today() + 3;
    zoneProd2.Zone__c = zone.id;
    zoneProd2.Postage_Charge__c = 30;
    zoneProd2.Product__c = zProd.Id;
    insert zoneProd2;
  
    Test.stopTest(); 
    System.assertNotEquals(null, zoneProd2);
}

/**
* Testmethod to test insert zone product with 2 records already using the same data
* @name <testInsertWith2ZoneProductsUsingData>
* @param <none>
* @return <none>
* @throws exception-<none>
* @see 
*/        
static testmethod void testInsertWith2ZoneProductsUsingData()    
{
    //Create Zone
    Zone__c zone = new Zone__c();
    insert zone;
    
    //Create ZProduct
    zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
    zProd.Name = 'BT Invest Test';
    zProd.zqu__ZuoraId__c = '2c92c0f84495ff400144a9c8701b012b';
    zProd.zqu__SKU__c = 'SKU-00000005';
    zProd.ProductCode__c = 'Test Code';
    zProd.ProductType__c = 'Test Type';
    insert zProd;
    
    //Create Zone Product
    Zone_Product__c zoneProd = new Zone_Product__c();
    zoneProd.Effective_Start_Date__c = date.today();
    zoneProd.Zone__c = zone.id;
    zoneProd.Postage_Charge__c = 30;
    zoneProd.Product__c = zProd.Id;
    
    Test.startTest();
    insert zoneProd;
    
    //Create Zone Product 2
    Zone_Product__c zoneProd2 = new Zone_Product__c();
    zoneProd2.Effective_Start_Date__c = date.today() + 3;
    zoneProd2.Zone__c = zone.id;
    zoneProd2.Postage_Charge__c = 30;
    zoneProd2.Product__c = zProd.Id;
    insert zoneProd2;
  
    //Create Zone Product 3
    Zone_Product__c zoneProd3 = new Zone_Product__c();
    zoneProd3.Effective_Start_Date__c = date.today() + 3;
    zoneProd3.Zone__c = zone.id;
    zoneProd3.Postage_Charge__c = 30;
    zoneProd3.Product__c = zProd.Id;
    
    Boolean error = false;
    try{
        insert zoneProd3;
    }
    catch(exception e)
    { 
        error = true;
        System.debug('Error: ' + e.getMessage());
    }   
    Test.stopTest();  
    System.assertEquals(null, zoneProd3.Id);
}

}