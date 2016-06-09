//*********************************************************************************************
//
// Author: Von Carlo V. Villaruel
// Date: 1/18/2015
// Description: Test Class for BundlePackageOneBundleDiscountClass
// Last Modified by: Jp Ocariz
// Last Modified on: 2/16/2015
//
//*********************************************************************************************

@isTest
Private Class BundlePackageOneBundleDiscountClassTest{

    public Static testMethod void testBundlePackageOneBundle() {

        //List Zoura
        List<zqu__ZProduct__c> lZoura = new List<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProd1 = new zqu__ZProduct__c(Name = 'The Straits Times Print');
        zProd1.zqu__Description__c = 'Test Description';
        zProd1.zqu__SKU__c = 'SKU-00000071';
        zProd1.ProductCode__c = 'STSU';
        zProd1.ProductPlatform__c = 'Print';
        zProd1.ProductFamily__c = 'ST';
        zProd1.zqu__ZuoraId__c = '2c92c0f847cdc31e0147ce522f6217fd';
        zProd1.ProductType__c = 'Product';
        zProd1.ProductSubType__c = 'Newspaper';
        zProd1.zqu__EffectiveStartDate__c = System.Today();
        zProd1.zqu__EffectiveEndDate__c = System.Today() + 30;
        lZoura.add(zProd1);
        
        zqu__ZProduct__c zProd2 = new zqu__ZProduct__c(Name = 'DISCOUNT');
        zProd2.zqu__Description__c = 'Test Description';
        zProd2.zqu__SKU__c = 'SKU-00000045';
        zProd2.ProductCode__c = '4557';
        zProd2.ProductPlatform__c = 'Print';
        zProd2.zqu__ZuoraId__c = '2c92c0f9464768910146629b278c2ffa';
        zProd2.ProductType__c = 'Discount';
        zProd2.zqu__EffectiveStartDate__c = System.Today();
        zProd2.zqu__EffectiveEndDate__c = System.Today() + 30;
        lZoura.add(zProd2);
        
        insert lZoura;
        
        //List Product Rate Plan
        List<zqu__ProductRatePlan__c> lProdRatePlan = new List<zqu__ProductRatePlan__c>();
        
        zqu__ProductRatePlan__c zProdRate1 = new zqu__ProductRatePlan__c (Name = 'Full Prepaid - 1 Yr');
        zProdRate1.zqu__ZProduct__c = zProd1.id;
        zProdRate1.zqu__Description__c = 'Test Description';
        zProdRate1.RatePlanCode__c = 'STSUTFP'; 
        zProdRate1.BillingType__c = 'Full Prepaid';
        zProdRate1.BillingPeriod__c = '12';
        zProdRate1.SubscriptionFrequency__c = '0';
        zProdRate1.zqu__ZuoraId__c = '2c92c0f947cddc240147ce556eba3212';
        zProdRate1.RatePlanType__c = 'Bill Plan';
        zProdRate1.RatePlanSubType__c = 'HDB';
        zProdRate1.zqu__EffectiveStartDate__c = System.Today();
        zProdRate1.zqu__EffectiveEndDate__c = System.Today() + 30;
        lProdRatePlan.add(zProdRate1);
        
        zqu__ProductRatePlan__c zProdRate2 = new zqu__ProductRatePlan__c (Name = 'Discount 10%');
        zProdRate2.zqu__ZProduct__c = zProd2.id;
        zProdRate2.zqu__Description__c = 'Test Description';
        zProdRate2.RatePlanCode__c = 'ABC123'; 
        zProdRate2.BillingType__c = 'Full Prepaid';
        zProdRate2.zqu__ZuoraId__c = '2c92c0f8464760e00146629bdf775449';
        zProdRate2.RatePlanType__c = 'Discount';
        zProdRate2.RatePlanSubType__c = 'Percentage';
        zProdRate2.zqu__EffectiveStartDate__c = System.Today();
        zProdRate2.zqu__EffectiveEndDate__c = System.Today() + 30;
        zProdRate2.BillingPeriod__c = '12';
        lProdRatePlan.add(zProdRate2);
        
        insert lProdRatePlan;
        
        //List Package
        List<Package__c> lPackages = new List<Package__c>();
        
        Package__c pkg1 = new Package__c(Name = 'Sample Bundle Package');
        pkg1.Package_Type__c = 'Bundle';
        pkg1.Subscription_Type__c = 'Termed';
        pkg1.Subscription_Period__c = '12';
        pkg1.Package_Code__c = '01118';
        //pkg1.Subscription_Period__c = '1';
        pkg1.Effective_Start_Date__c = System.Today();
        pkg1.Effective_End_Date__c = System.Today() + 4;
        pkg1.Package_Price__c = 1026;
        pkg1.Frequency_Identifier__c = '0';
        pkg1.Channel_E_shop_public__c = True;
        pkg1.Channel_E_shop_private__c = True;
        pkg1.Channel_E_shop_overseas__c = True;
        lPackages.add(pkg1);
        
        Package__c pkg2 = new Package__c(Name = 'Test_Package01_01/14/2015');
        pkg2.Package_Type__c = 'Bundle';
        pkg2.Subscription_Type__c = 'Termed';
        pkg2.Subscription_Period__c = '12';
        pkg2.Package_Code__c = '02_10142015';
        pkg2.Subscription_Period__c = '1';
        pkg2.Effective_Start_Date__c = System.Today();
        pkg2.Effective_End_Date__c = System.Today() + 4;
        pkg2.Package_Price__c = 1026;
        pkg2.Frequency_Identifier__c = '0';
        pkg2.Channel_E_shop_public__c = True;
        pkg2.Channel_E_shop_private__c = True;
        pkg2.Channel_E_shop_overseas__c = True;
        lPackages.add(pkg2);
        
        insert lPackages;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Package_Item__c; 
        Map<String,Schema.RecordTypeInfo> PackageItemRecordType = cfrSchema.getRecordTypeInfosByName(); 
        Id BunddleProdID = PackageItemRecordType.get('Bundle Product').getRecordTypeId();
        
        //System.assertEquals(expected, actual)
        
        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Package_Item__c; 
        Map<String,Schema.RecordTypeInfo> PackageItemRecordType2 = cfrSchema2.getRecordTypeInfosByName(); 
        Id BunddleDiscID = PackageItemRecordType2.get('Bundle Discount').getRecordTypeId();
        
        Key_Id__c keyId = new Key_Id__c();
        keyId.Name='Package Item_Bundle Discount';
        keyId.Id__c= BunddleDiscID;
        keyId.Type__c = 'RecordType';
        insert keyId;
        
        //List Package Items
        List<Package_Item__c> lPackageItem = new List<Package_Item__c>();
        
        Package_Item__c pkgItem6 = new Package_Item__c (Name = 'Sample 6');
        pkgItem6.Package__c = pkg1.id;
        pkgItem6.Product_Rate_Plan__c = zProdRate2.id;
        pkgItem6.RecordTypeId = BunddleDiscID;
        pkgItem6.Effective_Start_Month__c = '2';
        insert pkgItem6;
        
        Package_Item__c pkgItem1 = new Package_Item__c (Name = 'Sample 1');
        pkgItem1.Package__c = pkg1.id;
        pkgItem1.Product_Rate_Plan__c = zProdRate1.id;
        pkgItem1.RecordTypeId = BunddleProdID;
        insert pkgItem1;
//lPackageItem.add(pkgItem1);
        
        Package_Item__c pkgItem2 = new Package_Item__c (Name = 'Sample 2');
        pkgItem2.Package__c = pkg1.id;
        pkgItem2.Product_Rate_Plan__c = zProdRate2.id;
        pkgItem2.Base_Package_Item__c = pkgItem1.id;
        pkgItem2.RecordTypeId = BunddleDiscID;
        pkgItem2.Effective_Start_Month__c = '1';
        insert pkgItem2;
        //lPackageItem.add(pkgItem2);
        
        Package_Item__c pkgItem3 = new Package_Item__c (Name = 'Sample 3');
        pkgItem3.Package__c = pkg1.id;
        pkgItem3.Product_Rate_Plan__c = zProdRate1.id;
        pkgItem3.RecordTypeId = BunddleProdID;
        insert pkgItem3;
        //lPackageItem.add(pkgItem3);
            
        Package_Item__c pkgItem5 = new Package_Item__c (Name = 'Sample 5');
        pkgItem5.Package__c = pkg1.id;
        pkgItem5.Product_Rate_Plan__c = zProdRate2.id;
        pkgItem5.Base_Package_Item__c = pkgItem3.id;
        pkgItem5.RecordTypeId = BunddleDiscID;
        pkgItem5.Effective_Start_Month__c = '2';
        insert pkgItem5;        
        
        //lPackageItem.add(pkgItem5);
        
        //insert lPackageItem;
        //
                
        Test.StartTest();    
        //Bundle Discount 
        try{
           update pkgItem5;
           //[JPO 02/16] New approach, call method to populate query
           
           //BundlePackageOneBundleDiscountClass testBundle = new BundlePackageOneBundleDiscountClass();
            //testBundle.currentPackageItems = null;
            
            //testBundle.BundlePackageOneBundleDiscount(lPackageItem);            
           
        }
        catch (DmlException e){
                system.assertEquals(true, e.getMessage().contains('There is already a Bundle Discount Package Item connected to the selected Bundle Product. Please select a different Bundle Product:'));        
        
        
        }
        
        
        Test.StopTest();         
  
    }


}