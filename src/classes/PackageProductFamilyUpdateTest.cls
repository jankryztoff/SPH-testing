//*********************************************************************************************
//
// Author: Von Carlo V. Villaruel
// Date: 1/14/2015
// Description: Test Class for PackageProductFamilyUpdate
//
//*********************************************************************************************

@isTest
Private Class PackageProductFamilyUpdateTest {
        // This prepares the data needed for testing.
    Public Static testMethod void testPackageProductUpdate() {

        List<Package__c> lPackages = new  List<Package__c>();
        
        Package__c pkg1 = new Package__c(Name = 'Test_Package01/14/2015');
        pkg1.Package_Type__c = 'Add On';
        pkg1.Subscription_Type__c = 'Termed';
        pkg1.Package_Code__c = '10142015';
        pkg1.Subscription_Period__c = '1';
        pkg1.Effective_Start_Date__c = System.Today();
        pkg1.Effective_End_Date__c = System.Today() + 1;
        lPackages.add(pkg1);
        //Test.StartTest();  
        
        insert lPackages;
        
        List<Product_Family__c> lPackageFam = new List<Product_Family__c>();
        
        Product_Family__c pkgFam1 = new Product_Family__c();
        pkgFam1.Product_Family__c = 'Test_PackageFam01';
        pkgFam1.Product_Family_Name__c = 'Test_PackageFamName01';
        lPackageFam.add(pkgFam1);
        
        Product_Family__c pkgFam2 = new Product_Family__c();
        pkgFam2.Product_Family__c = 'Test_PackageFam02';
        pkgFam2.Product_Family_Name__c = 'Test_PackageFamName02';
        lPackageFam.add(pkgFam2);
        
        insert lPackageFam;
        
        List<Package_Product_Family__c> lPackageProdFam = new List<Package_Product_Family__c>();
        
        Package_Product_Family__c pkgProdFam1 = new Package_Product_Family__c();
        pkgProdFam1.Package_Name__c = pkg1.id;
        pkgProdFam1.Product_Family__c = pkgFam1.id;
        
        Package_Product_Family__c pkgProdFam2 = new Package_Product_Family__c();
        pkgProdFam2.Package_Name__c = pkg1.id;
        pkgProdFam2.Product_Family__c = pkgFam1.id;
        
        lPackageProdFam.add(pkgProdFam1);
        lPackageProdFam.add(pkgProdFam2);    
        insert lPackageProdFam;
        
        Test.StartTest();
        PackageProductFamilyUpdate ppfu = new PackageProductFamilyUpdate();
        ppfu.updateEligibleProductFamily(lPackageProdFam);
        ppfu.updateDeletedEligibleProductFamily(lPackageProdFam);
        
        delete lPackageProdFam;
        Test.StopTest();            

    }

}