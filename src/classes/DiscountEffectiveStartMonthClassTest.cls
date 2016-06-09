/*
 * Class Name: DiscountEffectiveStartMonthClassTest
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * Project/Requirement: 
 * @description: 
 */

@isTest(SeeAllData = True)
private class DiscountEffectiveStartMonthClassTest{

    /*
    *   @description: This test method executes the constructor of the base class
    *               and provides the right Account for the conditions in it.
    *   @Parameters: N/A
    *   @return: N/A
    */     
    static testmethod void DiscountEffectiveStartMonthClass(){
        Test.startTest();
        
        List<Package__c> packagelist = TestDataFactory.createPackage(1);
         for(Package__c item : packagelist){
             item.name = 'sample package';
             item.Package_Type__c = 'Discount';
             item.Package_Sub_Type__c = 'Tiered';
             item.Package_code__c = 'T0013ABS';
             item.Effective_Start_Date__c = date.today();
             item.Effective_End_Date__c = date.today().addDays(1);
             
         }
        database.insert(packagelist);
                
      
        List<zqu__ZProduct__c> zqu = TestDataFactory.createZProduct(1);
        for(zqu__ZProduct__c item : zqu){
            item.name='BORJ';
            item.zqu__SKU__c = 'TESTES121';
            item.ProductCode__c = 'QWERTY';
        }
        database.insert(zqu);
        
      
        //LIST product rate plan
        List<zqu__ProductRatePlan__c> rateplan = TestDataFactory.createProductRatePlan(2);
        Integer counter =0;
        for(zqu__ProductRatePlan__c item : rateplan){
            if(counter == 0){
            item.name = 'my product rate plan';
            item.zqu__ZProduct__c = zqu[0].id;
            item.RatePlanCode__c = 'forumula text';
            item.zqu__ZuoraId__c = 'somezuoraID';
            item.RatePlanType__c = 'Discount';
            } else{
            item.name = 'my product rate plan2';
            item.zqu__ZProduct__c = zqu[0].id;
            item.RatePlanCode__c = 'forumula text2';
            item.zqu__ZuoraId__c = 'somezuoraID2';
            item.RatePlanType__c = 'Bill Plan';
            }
            counter++;
        }
        database.insert(rateplan);

        Package_Item__c basePackItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];        
            basePackItem .Package__c = packagelist[0].id;
            basePackItem .Duration_in_months__c = '3';
            basePackItem .Product_Rate_Plan__c = rateplan[1].id; 
        
        database.insert(basePackItem);
        
        Package_Item__c extproduct = TestDataFactory.createPackageItem(1, 'Discount')[0];        
            extproduct.Package__c = packagelist[0].id;
            extproduct .Duration_in_months__c = '3';
            extproduct .Product_Rate_Plan__c = rateplan[0].id; 
        
        database.insert(extproduct); 
                
        List<Package_Item__c> currentPackageItems = TestDataFactory.createPackageItem(1, 'Discount');        
        
        for(Package_Item__c item : currentPackageItems){
            item.name = 'sampleontwothree';
            item.Package__c = packagelist[0].id;            
            item.Duration_in_months__c = '4';
            item.Effective_Start_Month__c = '4';            
            item.Product_Rate_Plan__c = rateplan[0].id;           
        }
        database.insert(currentPackageItems); 

  
        List<Package_Item__c> consolidated = new List<Package_Item__c>();   
        consolidated.addAll(currentPackageItems);
        consolidated.add(extproduct); 
        consolidated.add(basePackItem);                              
        
        system.assertEquals('4', currentPackageItems[0].Effective_Start_Month__c);
        
        DiscountEffectiveStartMonthClass package_mc = new DiscountEffectiveStartMonthClass();
        package_mc.DiscountEffectiveStartMonth(currentPackageItems);
        
        
        Test.stopTest();
    }    
}//END EOF