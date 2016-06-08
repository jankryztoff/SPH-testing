/*
 * Class Name: ExtProductDiscountDurationClassTest
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * Project/Requirement: 
 * @description: to test ExtensionProductDiscountDurationClass
 */
 
@isTest(SeeAllData = True)
private class ExtProductDiscountDurationClassTest{

    /*
    *   @description: tests ExtProductDiscountDuration
    *   @Parameters: N/A
    *   @return: N/A
    */  
    static testmethod void ExtProductDiscountDuration(){
        Test.startTest();
        List<Package__c> packagelist = TestDataFactory.createPackage(1);
        for(Package__c item : packagelist){
             item.name = 'sample package';
             item.Package_Type__c = 'Extension'; //Discount
             item.Package_Sub_Type__c = 'Extension';
             item.Package_code__c = 'T0013ABS';
             item.Effective_Start_Date__c = date.today();
             item.Effective_End_Date__c = date.today().addDays(1);
             
        }
        insert packagelist;
        system.assertNotEquals(null, packagelist);
        
        List<zqu__ZProduct__c> zqu = TestDataFactory.createZProduct(1);
        for(zqu__ZProduct__c item : zqu){
            item.name='BORJ';
            item.zqu__SKU__c = 'TESTES121';
            item.ProductCode__c = 'QWERTY';
        }
        insert zqu;
        system.assertNotEquals(null, zqu);        
        
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
        Package_Item__c pac = [Select RecordTypeId From PAckage_Item__c Where id=:currentPackageItems[0].id];
        ExtensionProductDiscountDurationClass Ext = new ExtensionProductDiscountDurationClass();
        Ext.ExtensionProductDiscountDuration(consolidated);      
     
        system.debug('*************************** TEST' + packagelist[0].id);               
        
        Test.stopTest();
        
    }    
}//END <MethodName>