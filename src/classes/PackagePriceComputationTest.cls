/**
 * Class Name: <PackagePriceComputation>
 * @author: <Jessica Palapal>
 * Date: <10/21/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for PackagePriceComputation>
 */
 // Start D-4633 05Apr Code Coverage Team
@isTest (seeAllData= true)

public class PackagePriceComputationTest{
 
    static Profile getProfile(){
        Profile someProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        return someProfile;
    }
 
    //PackageType: Base
        static testMethod void testBase(){
            
             //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = getProfile().Id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardppc1@test.com'
            );
            
            System.runAs(testUser) {
            
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
               
                
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base';                               
                
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 100;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};               
                               
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Postal_Zone__c pZone = new Postal_Zone__c();
                pZone.Postal_Zone__c = 'A';
                pZone.Name = 'test';
                insert pZone;
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                Product_Family__c prodFam = new Product_Family__c();
                prodFam.Product_Family__c = 'TestSample';
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                //pItem.RecordTypeId = ConstantsSLB.getKeyId('Package Item_Base Product');
                pItem.Package__c = pack.Id;
                pItem.Product_Family__c = prodFam.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Allocated__c = true;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, prodFam, pItem, venAlloc};
                
                List <Decimal> ListDecimal = New List <Decimal>{100};              
                PackagePriceComputation obj = new PackagePriceComputation();
                obj.deletePackageItems(new List<Package_Item__c>{pItem});
                obj.computePackagePrice('Percentage', ListDecimal, 10);
            }
    }
    
    //PackageType: Discount with Subtype: Tiered     
    static testMethod void testDiscountTiered(){
    
             //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = getProfile().Id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardppc2@test.com'
            );
            
            System.runAs(testUser) {
            
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Discount';
                pack.Package_Sub_Type__c = 'Tiered';
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 50;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Postal_Zone__c pZone = new Postal_Zone__c();
                pZone.Postal_Zone__c = 'A';
                pZone.Name = 'test';
                insert pZone;
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                Product_Family__c prodFam = new Product_Family__c();
                prodFam.Product_Family__c = 'TestSample';

                pItem.Package__c = pack.Id;
                pItem.Product_Family__c = prodFam.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Allocated__c = true;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, prodFam, pItem, venAlloc};
                
                List <Decimal> ListDecimal = New List <Decimal>{100};              
                PackagePriceComputation obj = new PackagePriceComputation();
                obj.deletePackageItems(new List<Package_Item__c>{pItem});
                obj.computePackagePrice('Percentage', ListDecimal, 10);

                
                zqu__ZProduct__c zProduct2 = TestDataFactory.createZProduct(2)[1];
               Gift__c gift2 = TestDataFactory.createGift(2)[1];
                gift2.Gift_Type__c = 'Premium';
                gift2.One_Time_Charge__c = 50;
                insert new List<sObject>{zProduct2, gift2};
                

                zqu__ProductRatePlan__c prdRatePlan2 = TestDataFactory.createProductRatePlan(2)[1];
                prdRatePlan2.zqu__ZProduct__c = zProduct2.Id;
                prdRatePlan2.RatePlanType__c = 'Discount';  
    
                Address__c add2 = TestDataFactory.createAddress(2)[1];
                add2.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc2 = TestDataFactory.createBillingAccount(2)[1];
                billingAcc2.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg2 = TestDataFactory.createPromotionGift(1)[0];
                pg2.Gift__c = gift.Id;
                Parcel__c par2 = TestDataFactory.createParcel(1)[0];
                par2.Project_Name__c = pro.Id;
                par2.Allocation_Type__c = 'SDA';
                par2.Description__c = 'Description';
                Postal_Zone__c pZone2 = new Postal_Zone__c();
                pZone2.Postal_Zone__c = 'A';
                pZone2.Name = 'test';
                insert pZone2;
                Post_Sector_Ops_Rep_Mapping__c psorm2 = TestDataFactory.createPostSector(2)[1];
                psorm2.Postal_Sector_Code__c = Decimal.valueOf('98');//singpostAdd.Name;
                psorm2.Vendor_Ops__c = UserInfo.getUserId();

                insert new List<sObject>{prdRatePlan2, add2, billingAcc2, pg2, par2, psorm2};
                
                zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(2)[1];
                prpc2.zqu__ProductRatePlan__c = prdRatePlan2.Id;
                Package_Item__c pItem2 = TestDataFactory.createPackageItem(1, 'Discount')[0];
                
                pItem2.Base_Package_Item__c = pItem.Id;
                pItem2.Package__c = pack.Id;
                pItem2.Product_Rate_Plan__c = prdRatePlan2.Id;
                pItem2.Duration_in_months__c = '3';
                pItem2.Effective_Start_Month__c = '1';
                Vendor_Allocation__c venAlloc2 = TestDataFactory.createVendorAlloc(2)[1];
                venAlloc2.SingPost_Address__c = singpostAdd.Id;
                venAlloc2.Vendor_Account__c = venAccount.Id;
                venAlloc2.Allocated__c = true;
                venAlloc2.Parcel_Name__c = par2.Id;
                insert new List<sObject>{prpc2, pItem2, venAlloc2};
                
                
                PackagePriceComputation obj2 = new PackagePriceComputation();
                obj2.deletePackageItems(new List<Package_Item__c>{pItem2});
                obj2.computePackagePrice('Percentage', ListDecimal, 10);

            }
    }

    
    //PackageType: Discount with Subtype: Extension     
    static testMethod void testDiscountExtension(){
    
             //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = getProfile().Id,  
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardppc3@test.com'
            );
            
            System.runAs(testUser) {
            
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                
                pack.Package_Type__c = 'Discount';
                pack.Package_Sub_Type__c = 'Extension';
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 50;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Postal_Zone__c pZone = new Postal_Zone__c();
                pZone.Postal_Zone__c = 'A';
                pZone.Name = 'test';
                insert pZone;
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                Product_Family__c prodFam = new Product_Family__c();
                prodFam.Product_Family__c = 'TestSample';

                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Family__c = prodFam.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Allocated__c = true;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, prodFam, pItem, venAlloc};
                
                List <Decimal> ListDecimal = New List <Decimal>{100}; 
                PackagePriceComputation obj = new PackagePriceComputation();
                obj.deletePackageItems(new List<Package_Item__c>{pItem});
                obj.computePackagePrice('Percentage', ListDecimal, 10);

                
                zqu__ZProduct__c zProduct2 = TestDataFactory.createZProduct(2)[1];
               Gift__c gift2 = TestDataFactory.createGift(2)[1];
                gift2.Gift_Type__c = 'Premium';
                gift2.One_Time_Charge__c = 50;
                insert new List<sObject>{zProduct2, gift2};
                

                zqu__ProductRatePlan__c prdRatePlan2 = TestDataFactory.createProductRatePlan(2)[1];
                prdRatePlan2.zqu__ZProduct__c = zProduct2.Id;
                prdRatePlan2.RatePlanType__c = 'Discount';  
    
                Address__c add2 = TestDataFactory.createAddress(2)[1];
                add2.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc2 = TestDataFactory.createBillingAccount(2)[1];
                billingAcc2.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg2 = TestDataFactory.createPromotionGift(1)[0];
                pg2.Gift__c = gift.Id;
                Parcel__c par2 = TestDataFactory.createParcel(1)[0];
                par2.Project_Name__c = pro.Id;
                par2.Allocation_Type__c = 'SDA';
                par2.Description__c = 'Description';
                Postal_Zone__c pZone2 = new Postal_Zone__c();
                pZone2.Postal_Zone__c = 'A';
                pZone2.Name = 'test';
                insert pZone2;
                Post_Sector_Ops_Rep_Mapping__c psorm2 = TestDataFactory.createPostSector(2)[1];
                psorm2.Postal_Sector_Code__c = Decimal.valueOf('98');//singpostAdd.Name;
                psorm2.Vendor_Ops__c = UserInfo.getUserId();

                insert new List<sObject>{prdRatePlan2, add2, billingAcc2, pg2, par2, psorm2};
                
                zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(2)[1];
                prpc2.zqu__ProductRatePlan__c = prdRatePlan2.Id;
                Package_Item__c pItem2 = TestDataFactory.createPackageItem(1, 'Discount')[0];

                pItem2.Base_Package_Item__c = pItem.Id;
                pItem2.Package__c = pack.Id;
                pItem2.Product_Rate_Plan__c = prdRatePlan2.Id;
                pItem2.Duration_in_months__c = '3';
                pItem2.Effective_Start_Month__c = '1';
                Vendor_Allocation__c venAlloc2 = TestDataFactory.createVendorAlloc(2)[1];
                venAlloc2.SingPost_Address__c = singpostAdd.Id;
                venAlloc2.Vendor_Account__c = venAccount.Id;
                venAlloc2.Allocated__c = true;
                venAlloc2.Parcel_Name__c = par2.Id;
                insert new List<sObject>{prpc2, pItem2, venAlloc2};
                 
                PackagePriceComputation obj2 = new PackagePriceComputation();
                obj2.deletePackageItems(new List<Package_Item__c>{pItem2});
                obj2.computePackagePrice('Percentage', ListDecimal, 10);

            }
    }
    
    //PackageType: Discount with Single Sub Type    
    static testMethod void testDiscountSingle(){
    
             //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = getProfile().Id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardppc4@test.com'
            );
            
            System.runAs(testUser) {
            
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Discount';
                pack.Package_Sub_Type__c = 'Single';
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 50;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;

                
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Postal_Zone__c pZone = new Postal_Zone__c();
                pZone.Postal_Zone__c = 'A';
                pZone.Name = 'test';
                insert pZone;
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                Product_Family__c prodFam = new Product_Family__c();
                prodFam.Product_Family__c = 'TestSample';
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                PItem.Product_Family__c = prodFam.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Allocated__c = true;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, prodFam, pItem, venAlloc};
                
                List <Decimal> ListDecimal = New List <Decimal>{100}; 
                PackagePriceComputation obj = new PackagePriceComputation();
                obj.deletePackageItems(new List<Package_Item__c>{pItem});
                obj.computePackagePrice('Percentage', ListDecimal, 10);
                
                
                //ZProduct
                
                zqu__ZProduct__c zProduct2 = TestDataFactory.createZProduct(2)[1];
               Gift__c gift2 = TestDataFactory.createGift(2)[1];
                gift2.Gift_Type__c = 'Premium';
                gift2.One_Time_Charge__c = 50;
                insert new List<sObject>{zProduct2, gift2};
                
                //zqu__ProductRatePlan__c and zqu__ProductRatePlanCharge__c
                zqu__ProductRatePlan__c prdRatePlan2 = TestDataFactory.createProductRatePlan(2)[1];
                prdRatePlan2.zqu__ZProduct__c = zProduct2.Id;
                prdRatePlan2.RatePlanType__c = 'Discount';  
    
                Address__c add2 = TestDataFactory.createAddress(2)[1];
                add2.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc2 = TestDataFactory.createBillingAccount(2)[1];
                billingAcc2.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg2 = TestDataFactory.createPromotionGift(1)[0];
                pg2.Gift__c = gift.Id;
                Parcel__c par2 = TestDataFactory.createParcel(1)[0];
                par2.Project_Name__c = pro.Id;
                par2.Allocation_Type__c = 'SDA';
                par2.Description__c = 'Description';
                Postal_Zone__c pZone2 = new Postal_Zone__c();
                pZone2.Postal_Zone__c = 'A';
                pZone2.Name = 'test';
                insert pZone2;
                Post_Sector_Ops_Rep_Mapping__c psorm2 = TestDataFactory.createPostSector(2)[1];
                psorm2.Postal_Sector_Code__c = Decimal.valueOf('98');//singpostAdd.Name;
                psorm2.Vendor_Ops__c = UserInfo.getUserId();

                insert new List<sObject>{prdRatePlan2, add2, billingAcc2, pg2, par2, psorm2};
                
                zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(2)[1];
                prpc2.zqu__ProductRatePlan__c = prdRatePlan2.Id;
                Package_Item__c pItem2 = TestDataFactory.createPackageItem(1, 'Discount')[0];

                pItem2.Base_Package_Item__c = pItem.Id;
                pItem2.Package__c = pack.Id;
                pItem2.Product_Rate_Plan__c = prdRatePlan2.Id;
                pItem2.Duration_in_months__c = '3';
                pItem2.Effective_Start_Month__c = '1';
                Vendor_Allocation__c venAlloc2 = TestDataFactory.createVendorAlloc(2)[1];
                venAlloc2.SingPost_Address__c = singpostAdd.Id;
                venAlloc2.Vendor_Account__c = venAccount.Id;
                venAlloc2.Allocated__c = true;
                venAlloc2.Parcel_Name__c = par2.Id;
                insert new List<sObject>{prpc2, pItem2, venAlloc2};
                
                
                PackagePriceComputation obj2 = new PackagePriceComputation();
                obj2.deletePackageItems(new List<Package_Item__c>{pItem2});
                obj2.computePackagePrice('Percentage', ListDecimal, 10);

            }
    }
    
    //PackageType: AddOn     
    static testMethod void testAddOn(){
    
             //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = getProfile().Id,  
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardppc5@test.com'
            );
            
            System.runAs(testUser) {
            
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Add On';
          
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 50;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Postal_Zone__c pZone = new Postal_Zone__c();
                pZone.Postal_Zone__c = 'A';
                pZone.Name = 'test';
                insert pZone;
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                Product_Family__c prodFam = new Product_Family__c();
                prodFam.Product_Family__c = 'TestSample';
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Family__c = prodFam.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Allocated__c = true;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                
                insert new List<sObject>{prpc, prodFam, pItem, venAlloc};
                
                List <Decimal> ListDecimal = New List <Decimal>{100}; 
                PackagePriceComputation obj = new PackagePriceComputation();
                obj.deletePackageItems(new List<Package_Item__c>{pItem});
                obj.computePackagePrice('Percentage', ListDecimal, 10);

                
                zqu__ZProduct__c zProduct2 = TestDataFactory.createZProduct(2)[1];
               Gift__c gift2 = TestDataFactory.createGift(2)[1];
                gift2.Gift_Type__c = 'Premium';
                gift2.One_Time_Charge__c = 50;
                insert new List<sObject>{zProduct2, gift2};
                

                zqu__ProductRatePlan__c prdRatePlan2 = TestDataFactory.createProductRatePlan(2)[1];
                prdRatePlan2.zqu__ZProduct__c = zProduct2.Id;
                prdRatePlan2.RatePlanType__c = 'Discount';  
    
                Address__c add2 = TestDataFactory.createAddress(2)[1];
                add2.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc2 = TestDataFactory.createBillingAccount(2)[1];
                billingAcc2.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg2 = TestDataFactory.createPromotionGift(1)[0];
                pg2.Gift__c = gift.Id;
                Parcel__c par2 = TestDataFactory.createParcel(1)[0];
                par2.Project_Name__c = pro.Id;
                par2.Allocation_Type__c = 'SDA';
                par2.Description__c = 'Description';
                Postal_Zone__c pZone2 = new Postal_Zone__c();
                pZone2.Postal_Zone__c = 'A';
                pZone2.Name = 'test';
                insert pZone2;
                Post_Sector_Ops_Rep_Mapping__c psorm2 = TestDataFactory.createPostSector(2)[1];
                psorm2.Postal_Sector_Code__c = Decimal.valueOf('98');//singpostAdd.Name;
                psorm2.Vendor_Ops__c = UserInfo.getUserId();

                insert new List<sObject>{prdRatePlan2, add2, billingAcc2, pg2, par2, psorm2};
                
                zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(2)[1];
                prpc2.zqu__ProductRatePlan__c = prdRatePlan2.Id;
                Package_Item__c pItem2 = TestDataFactory.createPackageItem(1, 'Discount')[0];

                pItem2.Base_Package_Item__c = pItem.Id;
                pItem2.Package__c = pack.Id;
                pItem2.Product_Rate_Plan__c = prdRatePlan2.Id;
                pItem2.Duration_in_months__c = '3';
                pItem2.Effective_Start_Month__c = '1';
                Vendor_Allocation__c venAlloc2 = TestDataFactory.createVendorAlloc(2)[1];
                venAlloc2.SingPost_Address__c = singpostAdd.Id;
                venAlloc2.Vendor_Account__c = venAccount.Id;
                venAlloc2.Allocated__c = true;
                venAlloc2.Parcel_Name__c = par2.Id;
                insert new List<sObject>{prpc2, pItem2, venAlloc2};
                
                
                PackagePriceComputation obj2 = new PackagePriceComputation();
                obj2.deletePackageItems(new List<Package_Item__c>{pItem2});
                obj2.computePackagePrice('Percentage', ListDecimal, 10);

            }
    }   

    //PackageType: Bundle     
    static testMethod void testBundle(){
    
             //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = getProfile().Id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardppc6@test.com'
            );
            
            System.runAs(testUser) {
            
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Bundle';
          
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 50;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Postal_Zone__c pZone = new Postal_Zone__c();
                pZone.Postal_Zone__c = 'A';
                pZone.Name = 'test';
                insert pZone;
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                Product_Family__c prodFam = new Product_Family__c();
                prodFam.Product_Family__c = 'TestSample';                
               
               
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Family__c = prodFam.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Allocated__c = true;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, prodFam, pItem, venAlloc};
                
                List <Decimal> ListDecimal = New List <Decimal>{100}; 
                PackagePriceComputation obj = new PackagePriceComputation();
                obj.deletePackageItems(new List<Package_Item__c>{pItem});
                obj.computePackagePrice('Percentage', ListDecimal, 10);

                
                zqu__ZProduct__c zProduct2 = TestDataFactory.createZProduct(2)[1];
               Gift__c gift2 = TestDataFactory.createGift(2)[1];
                gift2.Gift_Type__c = 'Premium';
                gift2.One_Time_Charge__c = 50;
                insert new List<sObject>{zProduct2, gift2};
                

                zqu__ProductRatePlan__c prdRatePlan2 = TestDataFactory.createProductRatePlan(2)[1];
                prdRatePlan2.zqu__ZProduct__c = zProduct2.Id;
                prdRatePlan2.RatePlanType__c = 'Discount';  
    
                Address__c add2 = TestDataFactory.createAddress(2)[1];
                add2.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc2 = TestDataFactory.createBillingAccount(2)[1];
                billingAcc2.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg2 = TestDataFactory.createPromotionGift(1)[0];
                pg2.Gift__c = gift.Id;
                Parcel__c par2 = TestDataFactory.createParcel(1)[0];
                par2.Project_Name__c = pro.Id;
                par2.Allocation_Type__c = 'SDA';
                par2.Description__c = 'Description';
                Postal_Zone__c pZone2 = new Postal_Zone__c();
                pZone2.Postal_Zone__c = 'A';
                pZone2.Name = 'test';
                insert pZone2;
                Post_Sector_Ops_Rep_Mapping__c psorm2 = TestDataFactory.createPostSector(2)[1];
                psorm2.Postal_Sector_Code__c = Decimal.valueOf('98');//singpostAdd.Name;
                psorm2.Vendor_Ops__c = UserInfo.getUserId();

                insert new List<sObject>{prdRatePlan2, add2, billingAcc2, pg2, par2, psorm2};
                
                zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(2)[1];
                prpc2.zqu__ProductRatePlan__c = prdRatePlan2.Id;
                Package_Item__c pItem2 = TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];

                pItem2.Base_Package_Item__c = pItem.Id;
                pItem2.Package__c = pack.Id;
                pItem2.Product_Rate_Plan__c = prdRatePlan2.Id;
                pItem2.Duration_in_months__c = '3';
                pItem2.Effective_Start_Month__c = '1';
                Vendor_Allocation__c venAlloc2 = TestDataFactory.createVendorAlloc(2)[1];
                venAlloc2.SingPost_Address__c = singpostAdd.Id;
                venAlloc2.Vendor_Account__c = venAccount.Id;
                venAlloc2.Allocated__c = true;
                venAlloc2.Parcel_Name__c = par2.Id;
                insert new List<sObject>{prpc2, pItem2, venAlloc2};
                
                
                PackagePriceComputation obj2 = new PackagePriceComputation();
                obj2.deletePackageItems(new List<Package_Item__c>{pItem2});
                obj2.computePackagePrice('Percentage', ListDecimal, 10);

            }
    }   
    
    static testMethod void testComputePackagePrice01() {
        PackagePriceComputation testObj = new PackagePriceComputation();

        String discType;
        List <Decimal> sumCharges;
        Decimal disc;
        
       //if(discType == 'Percentage'){
        discType = 'Percentage';
        
        //else
        sumCharges = null;
        disc = 1.1;
        System.assertEquals(null, testObj.computePackagePrice(discType, sumCharges, disc));
        
        //if(sumCharges != Null)
         //if(disc >= 0) {
          //if(discInte == 2){
        sumCharges = new List <Decimal>{1.0};
        disc = 50.0;
        System.assertEquals(0.5, testObj.computePackagePrice(discType, sumCharges, disc));
        
        
        //if(sumCharges != Null)
         //if(disc >= 0) {
          //else if(discInte == 1){
        sumCharges = new List <Decimal>{1.0};
        disc = 1.0;
        System.assertEquals(0.99, testObj.computePackagePrice(discType, sumCharges, disc));
        
        
        //if(sumCharges != Null)
         //if(disc >= 0) {
          //else if(discInte == 3){
        sumCharges = new List <Decimal>{1.0};
        disc = 100.0;
        System.assertEquals(0.0, testObj.computePackagePrice(discType, sumCharges, disc));
                
        
        //if(sumCharges != Null)
         //else
          //else if(discInte == 2){
        sumCharges = new List <Decimal>{1.0};
        disc = -10.0;
        System.assertEquals(1.1, testObj.computePackagePrice(discType, sumCharges, disc));
        
        
        //if(sumCharges != Null)
         //else
          //else if(discInte == 2){
        sumCharges = new List <Decimal>{1.0};
        disc = -1.0;
        System.assertEquals(1.01, testObj.computePackagePrice(discType, sumCharges, disc));
        
        
        //if(sumCharges != Null)
         //else
          //else if(discInte == 4){
        sumCharges = new List <Decimal>{1.0};
        disc = -100.0;
        System.assertEquals(2.0, testObj.computePackagePrice(discType, sumCharges, disc));
        
        
        //if(sumCharges != Null)
         //if(disc > 100 || disc < -100) {
        sumCharges = new List <Decimal>{1.0};
        disc = -101.0;
        System.assertEquals(1.0, testObj.computePackagePrice(discType, sumCharges, disc));
        
        
       //else if(discType == 'Fixed'){
        discType = 'Fixed';
        
        //else
        sumCharges = new List <Decimal>{1.0};
        disc = 50;
        System.assertEquals(-49.0, testObj.computePackagePrice(discType, sumCharges, disc));
        
        
       //else if(discType == null){
        discType = null;
        
        //else
        sumCharges = new List <Decimal>{1.0};
        disc = 0;
        System.assertEquals(1.0, testObj.computePackagePrice(discType, sumCharges, disc));
    }
    
    
    /*static testMethod void testExtensionDiscount(){ //joy
    
             //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standardppc3@test.com'
            );
            
            System.runAs(testUser) {
            
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Discount';
                pack.Package_Sub_Type__c = 'Extension';
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 50;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Postal_Zone__c pZone = new Postal_Zone__c();
                pZone.Postal_Zone__c = 'A';
                pZone.Name = 'test';
                insert pZone;
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                Product_Family__c prodFam = new Product_Family__c();
                prodFam.Product_Family__c = 'TestSample';

                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Extension Discount')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Family__c = prodFam.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Allocated__c = true;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, prodFam, pItem, venAlloc};
                
                PackagePriceComputation obj = new PackagePriceComputation();
                obj.deletePackageItems(new List<Package_Item__c>{pItem});
                obj.computePackagePrice('Percentage', 100, 10);

                
                zqu__ZProduct__c zProduct2 = TestDataFactory.createZProduct(2)[1];
               Gift__c gift2 = TestDataFactory.createGift(2)[1];
                gift2.Gift_Type__c = 'Premium';
                gift2.One_Time_Charge__c = 50;
                insert new List<sObject>{zProduct2, gift2};
                

                zqu__ProductRatePlan__c prdRatePlan2 = TestDataFactory.createProductRatePlan(2)[1];
                prdRatePlan2.zqu__ZProduct__c = zProduct2.Id;
                prdRatePlan2.RatePlanType__c = 'Delivery Charge';  
    
                Address__c add2 = TestDataFactory.createAddress(2)[1];
                add2.Postal_Code__c = singpostAdd.Id;

                Zuora__CustomerAccount__c billingAcc2 = TestDataFactory.createBillingAccount(2)[1];
                billingAcc2.Zuora__Account__c = vendorSubsAcct.Id;
                Promotion_Gift__c pg2 = TestDataFactory.createPromotionGift(1)[0];
                pg2.Gift__c = gift.Id;
                Parcel__c par2 = TestDataFactory.createParcel(1)[0];
                par2.Project_Name__c = pro.Id;
                par2.Allocation_Type__c = 'SDA';
                par2.Description__c = 'Description';
                Postal_Zone__c pZone2 = new Postal_Zone__c();
                pZone2.Postal_Zone__c = 'A';
                pZone2.Name = 'test';
                insert pZone2;
                Post_Sector_Ops_Rep_Mapping__c psorm2 = TestDataFactory.createPostSector(2)[1];
                psorm2.Postal_Sector_Code__c = Decimal.valueOf('98');//singpostAdd.Name;
                psorm2.Vendor_Ops__c = UserInfo.getUserId();

                insert new List<sObject>{prdRatePlan2, add2, billingAcc2, pg2, par2, psorm2};
                
                zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(2)[1];
                prpc2.zqu__ProductRatePlan__c = prdRatePlan2.Id;
                Package_Item__c pItem2 = TestDataFactory.createPackageItem(1, 'Extension Discount')[0];

                pItem2.Base_Package_Item__c = pItem.Id;
                pItem2.Package__c = pack.Id;
                pItem2.Product_Rate_Plan__c = prdRatePlan2.Id;
                pItem2.Duration_in_months__c = '3';
                pItem2.Effective_Start_Month__c = '1';
                Vendor_Allocation__c venAlloc2 = TestDataFactory.createVendorAlloc(2)[1];
                venAlloc2.SingPost_Address__c = singpostAdd.Id;
                venAlloc2.Vendor_Account__c = venAccount.Id;
                venAlloc2.Allocated__c = true;
                venAlloc2.Parcel_Name__c = par2.Id;
                insert new List<sObject>{prpc2, pItem2, venAlloc2};
                
                
                PackagePriceComputation obj2 = new PackagePriceComputation();
                obj2.deletePackageItems(new List<Package_Item__c>{pItem2});
                obj2.computePackagePrice('Percentage', 100, 10);

            }
    }*/
}
// End D-4633 05Apr Code Coverage Team