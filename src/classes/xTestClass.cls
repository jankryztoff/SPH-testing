@isTest
private class xTestClass {

    @testSetup
    static void setupData() {
   		
   		insert CustomSettingsDataFactory.createSpecial_Product_Families();
   		insert CustomSettingsDataFactory.createPublic_Holiday_Pub_Indiators();
   		insert CustomSettingsDataFactory.createProduct_Frequency();
   		insert CustomSettingsDataFactory.createProduct_Code();
   		insert CustomSettingsDataFactory.createPostage_Charge();
   		insert CustomSettingsDataFactory.createOther();
   		insert CustomSettingsDataFactory.createKey_Id();
   		insert CustomSettingsDataFactory.createPlannerSched();

		/*** start product catalogue ***/
		
		// start publication
        Publication__c sundayPub = TestDataFactory.createPublication(1)[0];
        sundayPub.Name = 'BERITA MINGGU';
        sundayPub.publication_code__c = 'BH';
        sundayPub.Product_Family__c = 'BH';
        sundayPub.Platform_Type__c = 'Print';
        sundayPub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        sundayPub.Published_Days__c = 'NNNNNNY';
        sundayPub.Publication_Type__c = 'N';
        sundayPub.Publication_Next_Start_Date__c = date.today().addDays(1);
        sundayPub.Earliest_Start_Date__c = date.today().addDays(1);
        sundayPub.Frequency_Code__c = 'W';
        sundayPub.Active_Date__c = date.today();
        sundayPub.Publisher_Code__c = 'SPH LTD';
        sundayPub.Language_Medium__c = 'M';
        sundayPub.Publish_Pattern__c = 'Weekends';
        database.insert(sundayPub);
        
        Publication__c weekdayPub = TestDataFactory.createPublication(1)[0];
        weekdayPub.Name = 'BERITA HARIAN';
        weekdayPub.publication_code__c = 'BH';
        weekdayPub.Product_Family__c = 'BH';
        weekdayPub.Platform_Type__c = 'Print';
        weekdayPub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        weekdayPub.Published_Days__c = 'YYYYYYN';
        weekdayPub.Publication_Type__c = 'N';
        weekdayPub.Publication_Next_Start_Date__c = date.today().addDays(1);
        weekdayPub.Earliest_Start_Date__c = date.today().addDays(1);
        weekdayPub.Frequency_Code__c = 'D';
        weekdayPub.Active_Date__c = date.today();
        weekdayPub.Publisher_Code__c = 'SPH LTD';
        weekdayPub.Language_Medium__c = 'M';
        weekdayPub.Publish_Pattern__c = 'Weekdays';
        weekdayPub.Sunday_Publication__c = sundayPub.Id;
        weekdayPub.Public_Holiday_Weekday_Pub_Indicator__c = true;
        weekdayPub.Public_Holiday_Weekend_Pub_Indicator__c = true;
        database.insert(weekdayPub);
		// end publication

		// start zproduct
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.Name = 'BERITA HARIAN PRINT';
        zProduct.zqu__Deleted__c = false;
        zProduct.ProductCode__c = 'BHBM';
        zProduct.zqu__SKU__c = 'SKU-00000000';
        zProduct.zqu__EffectiveStartDate__c = date.today();
        zProduct.zqu__EffectiveEndDate__c = date.today().addYears(20);
        zProduct.ProductPlatform__c = 'Print';
        zProduct.ProductType__c = 'Product';
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.ProductFamily__c = 'BH';
        zProduct.zqu__ZuoraId__c = ResponseUtility.generateExternalId();
        database.insert(zProduct);
		// end zproduct

		// start product publication
		list<Product_Publication__c> productPublicationList = TestDataFactory.createProductPublication(2);
		productPublicationList[0].ZProduct__c = zProduct.Id;
		productPublicationList[0].Publication_Code__c = sundayPub.Id;
		productPublicationList[1].ZProduct__c = zProduct.Id;
		productPublicationList[1].Publication_Code__c = weekdayPub.Id;
		database.insert(productPublicationList);
		// end product publication

		// start product rate plan
        list<zqu__ProductRatePlan__c> prdRatePlanList = TestDataFactory.createProductRatePlan(4);
		prdRatePlanList[0].Name = 'BHBM Non Chargeable Prorations';
		prdRatePlanList[0].zqu__ZProduct__c = zProduct.Id;
		prdRatePlanList[0].zqu__EffectiveStartDate__c = date.today();
		prdRatePlanList[0].zqu__EffectiveEndDate__c = date.today().addYears(20);
		prdRatePlanList[0].RatePlanCode__c = '_PRBHBM';
		prdRatePlanList[0].RatePlanType__c = 'Proration';
		prdRatePlanList[0].RatePlanSubType__c = 'NonChargeable';
		prdRatePlanList[0].SubscriptionFrequency__c = '0';
		prdRatePlanList[0].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
		prdRatePlanList[1].Name = 'Berita Harian Print Mon - Fri -- Full 12 Mths Plan';
		prdRatePlanList[1].zqu__ZProduct__c = zProduct.Id;
		prdRatePlanList[1].zqu__EffectiveStartDate__c = date.today();
		prdRatePlanList[1].zqu__EffectiveEndDate__c = date.today().addYears(20);
		prdRatePlanList[1].	RatePlanCode__c = 'BHBM12FPMFNP';
		prdRatePlanList[1].RatePlanType__c = 'Bill Plan';
		prdRatePlanList[1].BillingType__c ='Full Prepaid';
		prdRatePlanList[1].BillingPeriod__c = '12';
		prdRatePlanList[1].SubscriptionFrequency__c = '1';
		prdRatePlanList[1].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
		prdRatePlanList[2].Name = 'Berita Harian Print Sat - Sun -- Full 12 Mths Plan';
		prdRatePlanList[2].zqu__ZProduct__c = zProduct.Id;
		prdRatePlanList[2].zqu__EffectiveStartDate__c = date.today();
		prdRatePlanList[2].zqu__EffectiveEndDate__c = date.today().addYears(20);
		prdRatePlanList[2].	RatePlanCode__c = 'BHBM12FPSSNP';
		prdRatePlanList[2].RatePlanType__c = 'Bill Plan';
		prdRatePlanList[2].BillingType__c ='Full Prepaid';
		prdRatePlanList[2].BillingPeriod__c = '12';
		prdRatePlanList[2].SubscriptionFrequency__c = '2';
		prdRatePlanList[2].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
		prdRatePlanList[3].Name = 'BHBM Prorations (Mon - Fri)';
		prdRatePlanList[3].zqu__ZProduct__c = zProduct.Id;
		prdRatePlanList[3].zqu__EffectiveStartDate__c = date.today();
		prdRatePlanList[3].zqu__EffectiveEndDate__c = date.today().addYears(20);
		prdRatePlanList[3].	RatePlanCode__c = '_PRBHBM';
		prdRatePlanList[3].RatePlanType__c = 'Proration';
		prdRatePlanList[3].RatePlanSubType__c = 'Standard';
		prdRatePlanList[3].SubscriptionFrequency__c = '1';
		prdRatePlanList[3].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
        database.insert(prdRatePlanList);		
		// end product rate plan

		// start product rate plan charge
        list<zqu__ProductRatePlanCharge__c> zprpcList =  TestDataFactory.createProductRatePlanCharge(15);
        // prorations (mon-fri)
        zprpcList[0].Name = 'Credit Copy Weekday';
        zprpcList[0].zqu__ProductRatePlan__c = prdRatePlanList[3].Id;
		zprpcList[0].zqu__Type__c = 'Usage';
		zprpcList[0].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[0].zqu__UOM__c = 'Credit Copy Weekday';
		zprpcList[0].PublicationCode__c = weekdayPub.publication_code__c;
		zprpcList[0].zqu__RecurringPeriod__c = 'Month';
		zprpcList[0].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
        zprpcList[1].Name = 'Adjustment';
        zprpcList[1].zqu__ProductRatePlan__c = prdRatePlanList[3].Id;
		zprpcList[1].zqu__Type__c = 'Usage';
		zprpcList[1].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[1].zqu__UOM__c = 'Adjustment';
		zprpcList[1].zqu__RecurringPeriod__c = 'Month';
		zprpcList[1].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
        zprpcList[2].Name = 'Copy Weekday';
        zprpcList[2].zqu__ProductRatePlan__c = prdRatePlanList[3].Id;
		zprpcList[2].zqu__Type__c = 'Usage';
		zprpcList[2].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[2].zqu__UOM__c = 'Copy Weekday';
		zprpcList[2].PublicationCode__c = weekdayPub.publication_code__c;
		zprpcList[2].zqu__RecurringPeriod__c = 'Month';
		zprpcList[2].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

        zprpcList[3].Name = 'Dummy Charge';
        zprpcList[3].zqu__ProductRatePlan__c = prdRatePlanList[3].Id;
		zprpcList[3].zqu__Type__c = 'Usage';
		zprpcList[3].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[3].zqu__UOM__c = 'Dummy Charge';
		zprpcList[3].zqu__RecurringPeriod__c = 'Month';
		zprpcList[3].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

        zprpcList[4].Name = 'Adjustment No Tax';
        zprpcList[4].zqu__ProductRatePlan__c = prdRatePlanList[3].Id;
		zprpcList[4].zqu__Type__c = 'Usage';
		zprpcList[4].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[4].zqu__UOM__c = 'Adjustment No Tax';
		zprpcList[4].zqu__RecurringPeriod__c = 'Month';
		zprpcList[4].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

        zprpcList[5].Name = 'Credit Copy Month BH';
        zprpcList[5].zqu__ProductRatePlan__c = prdRatePlanList[3].Id;
		zprpcList[5].zqu__Type__c = 'Usage';
		zprpcList[5].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[5].zqu__UOM__c = 'Credit Copy Month BH';
		zprpcList[5].zqu__RecurringPeriod__c = 'Month';
		zprpcList[5].PublicationCode__c = weekdayPub.publication_code__c;
		zprpcList[5].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

        zprpcList[6].Name = 'Goodwill Credit Copy';
        zprpcList[6].zqu__ProductRatePlan__c = prdRatePlanList[3].Id;
		zprpcList[6].zqu__Type__c = 'Usage';
		zprpcList[6].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[6].zqu__UOM__c = 'Goodwill Credit Copy';
		zprpcList[6].zqu__RecurringPeriod__c = 'Month';
		zprpcList[6].PublicationCode__c = weekdayPub.publication_code__c;
		zprpcList[6].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		// prorations (mon-fri)
		
		// start non-chargeable prorations
        zprpcList[7].Name = 'No Credit Copy Sat';
        zprpcList[7].zqu__ProductRatePlan__c = prdRatePlanList[0].Id;
		zprpcList[7].zqu__Type__c = 'Usage';
		zprpcList[7].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[7].zqu__UOM__c = 'No Credit Copy Sat';
		zprpcList[7].zqu__RecurringPeriod__c = 'Month';
		zprpcList[7].PublicationCode__c = weekdayPub.publication_code__c;
		zprpcList[7].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
        zprpcList[8].Name = 'No Credit Copy Sun';
        zprpcList[8].zqu__ProductRatePlan__c = prdRatePlanList[0].Id;
		zprpcList[8].zqu__Type__c = 'Usage';
		zprpcList[8].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[8].zqu__UOM__c = 'No Credit Copy Sun';
		zprpcList[8].zqu__RecurringPeriod__c = 'Month';
		zprpcList[8].PublicationCode__c = sundayPub.publication_code__c;
		zprpcList[8].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

        zprpcList[9].Name = 'No Credit Copy Weekday';
        zprpcList[9].zqu__ProductRatePlan__c = prdRatePlanList[0].Id;
		zprpcList[9].zqu__Type__c = 'Usage';
		zprpcList[9].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[9].zqu__UOM__c = 'No Credit Copy Weekday';
		zprpcList[9].zqu__RecurringPeriod__c = 'Month';
		zprpcList[9].PublicationCode__c = weekdayPub.publication_code__c;
		zprpcList[9].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

        zprpcList[10].Name = '100% Non Chargeable Proration';
        zprpcList[10].zqu__ProductRatePlan__c = prdRatePlanList[0].Id;
		zprpcList[10].zqu__Type__c = 'Recurring';
		zprpcList[10].zqu__Model__c = 'Discount-Percentage';
		zprpcList[10].zqu__RecurringPeriod__c = 'Month';
		zprpcList[10].zqu__Discount_Level__c = 'RatePlan';
		zprpcList[10].zqu__Discount_Apply_Type__c = 4;
		zprpcList[10].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		// end non-chargeable prorations
		
        zprpcList[11].Name = 'BH Annual Recurring Per Unit Pricing Charges';
        zprpcList[11].zqu__ProductRatePlan__c = prdRatePlanList[1].Id;
		zprpcList[11].zqu__Type__c = 'Recurring';
		zprpcList[11].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[11].zqu__RecurringPeriod__c = 'Annual';
		zprpcList[11].zqu__DefaultQuantity__c = 1;
		zprpcList[11].zqu__UOM__c = 'Copy';
		zprpcList[11].PublicationCode__c = weekdayPub.publication_code__c;
		zprpcList[11].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
        zprpcList[12].Name = 'BH Annual Recurring Per Unit Pricing Charges';
        zprpcList[12].zqu__ProductRatePlan__c = prdRatePlanList[2].Id;
		zprpcList[12].zqu__Type__c = 'Recurring';
		zprpcList[12].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[12].zqu__RecurringPeriod__c = 'Annual';
		zprpcList[12].zqu__DefaultQuantity__c = 1;
		zprpcList[12].zqu__UOM__c = 'Copy';
		zprpcList[12].PublicationCode__c = weekdayPub.publication_code__c;
		zprpcList[12].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

        zprpcList[13].Name = 'BM Annual Recurring Per Unit Pricing Charges';
        zprpcList[13].zqu__ProductRatePlan__c = prdRatePlanList[2].Id;
		zprpcList[13].zqu__Type__c = 'Recurring';
		zprpcList[13].zqu__Model__c = 'Per Unit Pricing';
		zprpcList[13].zqu__RecurringPeriod__c = 'Annual';
		zprpcList[13].zqu__DefaultQuantity__c = 1;
		zprpcList[13].zqu__UOM__c = 'Copy';
		zprpcList[13].PublicationCode__c = sundayPub.publication_code__c;
		zprpcList[13].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
		database.insert(zprpcList);	
		// end product rate plan charge

		// start product rate plan charge tier
        list<zqu__ProductRatePlanChargeTier__c> zprpctList = TestDataFactory.createProductRatePlanChargeTier(25);
		// prorations (mon-fri)
		zprpctList[0].zqu__ProductRatePlanCharge__c = zprpcList[0].Id;
		zprpctList[0].zqu__Currency__c = 'SGD';
		zprpctList[0].zqu__Deleted__c = false;
		zprpctList[0].zqu__Price__c = -0.45;
		zprpctList[0].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[0].zqu__Tier__c = 1;
		zprpctList[0].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[1].zqu__ProductRatePlanCharge__c = zprpcList[1].Id;
		zprpctList[1].zqu__Currency__c = 'SGD';
		zprpctList[1].zqu__Deleted__c = false;
		zprpctList[1].zqu__Price__c = -0.01;
		zprpctList[1].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[1].zqu__Tier__c = 1;
		zprpctList[1].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[2].zqu__ProductRatePlanCharge__c = zprpcList[2].Id;
		zprpctList[2].zqu__Currency__c = 'SGD';
		zprpctList[2].zqu__Deleted__c = false;
		zprpctList[2].zqu__Price__c = 0.45;
		zprpctList[2].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[2].zqu__Tier__c = 1;
		zprpctList[2].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[3].zqu__ProductRatePlanCharge__c = zprpcList[3].Id;
		zprpctList[3].zqu__Currency__c = 'SGD';
		zprpctList[3].zqu__Deleted__c = false;
		zprpctList[3].zqu__Price__c = 0;
		zprpctList[3].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[3].zqu__Tier__c = 1;
		zprpctList[3].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[4].zqu__ProductRatePlanCharge__c = zprpcList[4].Id;
		zprpctList[4].zqu__Currency__c = 'SGD';
		zprpctList[4].zqu__Deleted__c = false;
		zprpctList[4].zqu__Price__c = -0.01;
		zprpctList[4].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[4].zqu__Tier__c = 1;
		zprpctList[4].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[5].zqu__ProductRatePlanCharge__c = zprpcList[5].Id;
		zprpctList[5].zqu__Currency__c = 'SGD';
		zprpctList[5].zqu__Deleted__c = false;
		zprpctList[5].zqu__Price__c = -9.70;
		zprpctList[5].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[5].zqu__Tier__c = 1;
		zprpctList[5].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[6].zqu__ProductRatePlanCharge__c = zprpcList[6].Id;
		zprpctList[6].zqu__Currency__c = 'SGD';
		zprpctList[6].zqu__Deleted__c = false;
		zprpctList[6].zqu__Price__c = -9.70;
		zprpctList[6].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[6].zqu__Tier__c = 1;
		zprpctList[6].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		// end prorations (mon-fri)
		
		// start non-chargeable prorations
		zprpctList[7].zqu__ProductRatePlanCharge__c = zprpcList[7].Id;
		zprpctList[7].zqu__Currency__c = 'SGD';
		zprpctList[7].zqu__Deleted__c = false;
		zprpctList[7].zqu__Price__c = 0.55;
		zprpctList[7].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[7].zqu__Tier__c = 1;
		zprpctList[7].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
		zprpctList[8].zqu__ProductRatePlanCharge__c = zprpcList[8].Id;
		zprpctList[8].zqu__Currency__c = 'SGD';
		zprpctList[8].zqu__Deleted__c = false;
		zprpctList[8].zqu__Price__c = 0.55;
		zprpctList[8].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[8].zqu__Tier__c = 1;
		zprpctList[8].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[9].zqu__ProductRatePlanCharge__c = zprpcList[9].Id;
		zprpctList[9].zqu__Currency__c = 'SGD';
		zprpctList[9].zqu__Deleted__c = false;
		zprpctList[9].zqu__Price__c = 0.45;
		zprpctList[9].zqu__PriceFormat__c = 'Per Unit';
		zprpctList[9].zqu__Tier__c = 1;
		zprpctList[9].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[10].zqu__ProductRatePlanCharge__c = zprpcList[10].Id;
		zprpctList[10].zqu__Currency__c = 'SGD';
		zprpctList[10].zqu__Deleted__c = false;
		zprpctList[10].zqu__Price__c = 100;
		zprpctList[10].zqu__PriceFormat__c = 'Flat Fee';
		zprpctList[10].zqu__Tier__c = 1;
		zprpctList[10].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		// end non-chargeable prorations
		
		zprpctList[11].zqu__ProductRatePlanCharge__c = zprpcList[11].Id;
		zprpctList[11].zqu__Currency__c = 'SGD';
		zprpctList[11].zqu__Deleted__c = false;
		zprpctList[11].zqu__Price__c = 116.10;
		zprpctList[11].zqu__PriceFormat__c = 'Flat Fee';
		zprpctList[11].zqu__Tier__c = 1;
		zprpctList[11].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[12].zqu__ProductRatePlanCharge__c = zprpcList[12].Id;
		zprpctList[12].zqu__Currency__c = 'SGD';
		zprpctList[12].zqu__Deleted__c = false;
		zprpctList[12].zqu__Price__c = 28.60;
		zprpctList[12].zqu__PriceFormat__c = 'Flat Fee';
		zprpctList[12].zqu__Tier__c = 1;
		zprpctList[12].zqu__ZuoraId__c = ResponseUtility.generateExternalId();

		zprpctList[13].zqu__ProductRatePlanCharge__c = zprpcList[13].Id;
		zprpctList[13].zqu__Currency__c = 'SGD';
		zprpctList[13].zqu__Deleted__c = false;
		zprpctList[13].zqu__Price__c = 28.60;
		zprpctList[13].zqu__PriceFormat__c = 'Flat Fee';
		zprpctList[13].zqu__Tier__c = 1;
		zprpctList[13].zqu__ZuoraId__c = ResponseUtility.generateExternalId();
		
		database.insert(zprpctList);	
		// end product rate plan charge tier

		// start promotion
		
		// end promotion
		
		// start package
        Package__c pkg = TestDataFactory.createPackage(1)[0];
        pkg.Name = 'Berita Harian Print Mon - Fri -- Full 12 Mths';
        pkg.Package_Type__c = 'Base';
        pkg.Subscription_Type__c = 'Termed';
        pkg.Channel_Direct__c = true;
        pkg.Package_Code__c = 'BeritaHarianPrintMon-Fri--Full12Mths';
        pkg.Product_Family_Current_Package__c = 'BH';
        pkg.Effective_Start_Date__c = date.today();
        pkg.Effective_End_Date__c = date.today().addYears(20);
        pkg.Frequency_Identifier__c = '1';
        pkg.Subscription_Period_1__c = '12';
        pkg.Billing_Type__c = 'Full Prepaid';
        pkg.Platform__c = 'Print';
        pkg.Package_Price__c = 116.10;
        database.insert(pkg);		
		// end package
		
		// start promotion package
		
		// end promotion package
		
		// start package item
        Package_Item__c pkgItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pkgItem.Package__c = pkg.Id;
        pkgItem.Product_Rate_Plan__c = prdRatePlanList[1].Id;
        pkgItem.Price__c = 116.10;
        database.insert(pkgItem);
		// end packate item
		
		

		/*** end product catalogue ***/
		
		/*	
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = add.Id;
        con.Billing_Indicator__c = true;
        con.Recipient_Indicator__c = true;
        database.insert(con);

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        database.insert(billAcc);
        





        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        database.insert(flag);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '1';
        database.insert(prom);
        
        Case cas = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cas.Status = 'Closed';
        database.insert(cas);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '2';
        subRecs.Promotion__c = prom.Id;
        subRecs.Main_Package__c = pack.ID;
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Product_Code__c = '01';
        subRecs.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        subRecs.Zuora__External_Id__c = subRecs.Zuora__Zuora_Id__c;
        database.insert(subRecs);

        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Zuora__RatePlanName__c = 'Name';
        spc.Zuora__ProductSKU__c = 'SKU01';
        database.insert(spc);
        */
    }	
}