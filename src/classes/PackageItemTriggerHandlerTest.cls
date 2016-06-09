/**
   @Author <Miguel Oabel>
   @name <PackageItemTriggerHandlerTest>
   @Description <Test class for PackageItemTriggerHandler>
   @CreateDate <10/21/2015>
   @Author <Marjorie Gaelo>
   @Modified Date <2/3/2015>
  */

@isTest (Seealldata = TRUE)
private class PackageItemTriggerHandlerTest {
    /**
    *  @description This method executes during class instantiation. 
    *  @name <testPackageItemTrigger>
    */
    static  testmethod void  testPackageItemTrigger(){
    
    Package__c pack = new Package__c();
    pack.Package_Type__c = 'Base';
    pack.Name = 'testpackB';
    pack.Package_Code__c = 'pcode';
    pack.Subscription_Type__c = 'Termed';
    pack.Subscription_Period__c= '1';
    pack.Effective_End_Date__c = date.today().addDays(20);
    pack.Effective_Start_Date__c = date.today();
    insert pack;
            

    zqu__ProductRatePlan__c prPlan = new zqu__ProductRatePlan__c();
    zqu__ZProduct__c zprod = new zqu__ZProduct__c();
    zprod.Name = 'testzprod';
    zprod.zqu__SKU__c = '123456';
    zprod.ProductCode__c ='pcode123';
    zprod.zqu__ZuoraId__c = 'zoura1234567';
    zprod.ProductType__c = 'Print';
    insert zprod;
    
        
    prPlan.Name = 'testrateplan';
    prPlan.zqu__ZProduct__c = zprod.id;
    prPlan.RatePlanCode__c = 'rpcode';
    prPlan.zqu__ZuoraId__c = 'zoura123';
    prPlan.RatePlanType__c = 'Bill Plan';
    insert prPlan;
    

    
    Package_Item__c packItem = new Package_Item__c();
            packItem.Product_Rate_Plan__c = prPlan.id;
            packItem.Package__c = pack.id;
            packItem.Name = 'testbase';                      

            
    Test.startTest();
    insert packItem;
    update packItem;
    delete packItem;
    Test.stopTest();
    }
}