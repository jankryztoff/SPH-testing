/**
   @Author <Marjorie Gaelo>
   @name <BaseExtensionProductFamilyClassTest>
   @Description <Test class for BaseExtensionProductFamilyClass>
   @CreateDate <2/3/2015>
   @Version <1.0>
  */

@isTest (Seealldata = TRUE)
private class BaseExtensionProductFamilyClassTest {
    /**
    *  @description This method executes during class instantiation. 
    *  @name <testBaseExtensionProductFamilyClass>
    */
    static  testmethod void  testBaseExtensionProductFamilyClass(){
    
    List<Package__c> packagelist = TestDataFactory.createPackage(1);
         for(Package__c item : packagelist){
             item.name = 'sample package';
             item.Package_Type__c = 'Discount';
             item.Package_Sub_Type__c = 'Extension';
             item.Package_code__c = 'T0013ABS';
             item.Effective_Start_Date__c = date.today();
             item.Effective_End_Date__c = date.today().addDays(1);
             
         }
        insert packagelist;
        
        List<zqu__ZProduct__c> zqu = TestDataFactory.createZProduct(1);
        for(zqu__ZProduct__c item : zqu){
            item.name='BORJ';
            item.zqu__SKU__c = 'TESTES121';
            item.ProductCode__c = 'QWERTY';
            item.ProductFamily__c = 'asdasd';
        }
        insert zqu;
        
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
        insert rateplan;
        
        Package_Item__c basePackItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];        
        basePackItem .Package__c = packagelist[0].id;
        basePackItem .Duration_in_months__c = '2';
        basePackItem .Product_Rate_Plan__c = rateplan[1].id; 
        insert basePackItem;
        
        Package_Item__c extproduct = TestDataFactory.createPackageItem(1, 'Extension Product')[0];        
        extproduct.Package__c = packagelist[0].id;
        extproduct .Duration_in_months__c = '2';
        extproduct .Product_Rate_Plan__c = rateplan[1].id; 
        insert extproduct;
        
        
        List<Package_Item__c> currentPackageItems = TestDataFactory.createPackageItem(1, 'Extension Discount');        
        
        for(Package_Item__c item : currentPackageItems){
            //item.recordtypeId = constantsSLB.getKeyID('Package Item_Extension Discount');
            item.Package__c = packagelist[0].id;
            //item.RecordType = 'Extension Product';
            item.Duration_in_months__c = '2';
            //product rate plan
            item.Product_Rate_Plan__c = rateplan[0].id;            
        }
        insert currentPackageItems;       
        
        List<Package_Item__c> consolidated = new List<Package_Item__c>();   
        consolidated.addAll(currentPackageItems);
        consolidated.add(extproduct); 
        consolidated.add(basePackItem);  
    
    Test.startTest();
    BaseExtensionProductFamilyClass bpc = new BaseExtensionProductFamilyClass();
    bpc.BaseExtensionProductFamily(consolidated);
    Test.stopTest();
    
    }   
    
    static  testmethod void  testBaseExtensionProductFamilyClass2(){

    Product_Family__c prodFam = new Product_Family__c();
    prodFam.Product_Family__c = 'baseextprodfam';
    insert prodFam;
    
    Package__c pack = new Package__c();
    pack.Package_Type__c = 'Base';
    pack.Name = 'testpackd';
    pack.Package_Code__c = 'pcode27';
    pack.Subscription_Type__c = 'Termed';
    pack.Subscription_Period__c= '1';
    pack.Effective_End_Date__c = date.today().addDays(20);
    pack.Effective_Start_Date__c = date.today();
    pack.Product_Family_Current_Package__c = prodFam.id;
    insert pack;
    
    zqu__ZProduct__c zprod = new zqu__ZProduct__c();
    zprod.Name = 'testzprod2';
    zprod.zqu__SKU__c = '1234598';
    zprod.ProductCode__c ='pcode198';
    zprod.zqu__ZuoraId__c = 'zoura1234598';
    zprod.ProductType__c = 'Print';
    insert zprod;
    
    zqu__ProductRatePlan__c prPlan = new zqu__ProductRatePlan__c();
    prPlan.Name = 'testrateplan279';
    prPlan.zqu__ZProduct__c = zprod.id;
    prPlan.RatePlanCode__c = 'rpcode79';
    prPlan.zqu__ZuoraId__c = 'zoura179';
    prPlan.RatePlanType__c = 'Bill Plan';
    insert prPlan;
    
    Package_Item__c packItem = new Package_Item__c();
    packItem.Product_Rate_Plan__c = prPlan.id;
    packItem.Package__c = pack.id;
    packItem.Name = 'testdiscounts2';   
    
    Test.startTest();
    insert packItem;
    update packItem;
    delete packItem;
    Test.stopTest();
    }
}