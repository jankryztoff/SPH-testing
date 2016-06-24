@isTest 
private class BatchAddressAssignmentEffectiveDateTest3 {
    
    @testSetup
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface();
        insert CustomSettingsDataFactory.createPlannerSched();
    }
    
    private static testMethod void testUpdateBillingContact() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            //acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
            database.insert(acc);
            
            //RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Local'];
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Billing_Indicator__c = true;
            Database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            Database.insert(con2);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            Database.insert(billAcc);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Billing_Contact__c = con.Id;
            ord.Recipient_Contact__c = con2.Id;
            Database.insert(ord);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__CustomerAccount__c = billAcc[0].Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Subscription_Type_1__c = 'Publication';
                sub.Recipient_Contact__c = con2.Id;
                sub.Delivered_By_1__c = 'Mailing Agent';
                sub.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                sub.Order_Number_1__c = ord.Id;
                sub.Zuora__Status__c = 'Active';
            }
            Database.insert(subList);
            
            Test.startTest();
            
            Map<Id, Contact> subIdToNewContactMap = new Map<Id, Contact>();
            for (Zuora__Subscription__c sub : subList) {
                subIdToNewContactMap.put(sub.Id, con);
            }
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateOrderBillingContact(subIdToNewContactMap);
            batch.updateSubBillingContact(new List<Order__c>{ord}, subIdToNewContactMap);
            
            Test.stopTest();
        }
    }
    
    private static testMethod void testCoaCheckIfArmsContact() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            //RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Local'];
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            List<Contact> billConList = TestDataFactory.createContactRecType(2, 'Customer Contact');
            for (Contact con : billConList) {
                con.Address__c = ad.Id;
                con.AccountId = acc.Id;
                con.Billing_Indicator__c = true;
            }
            Database.insert(billConList);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            Integer index = 0;
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
                bill.Billing_Contact__c = billConList[index].Id;
                bill.ARMS_Customer_Number__c = '12345';
                bill.ARMS_Account_Number__c = '67890';
                ++index;
            }
            Database.insert(billAcc);
           
            
            Test.startTest();
            
            List<Contact> contact_LIST = new List<Contact>();
            contact_LIST.addAll(billConList);
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.coaCheckIfArmsContact(contact_LIST);
            
            Test.stopTest();
        }
    }
    
    private static testMethod void testUpdateRecipientContact() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Billing_Indicator__c = true;
            Database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            Database.insert(con2);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            Database.insert(billAcc);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Billing_Contact__c = con.Id;
            ord.Recipient_Contact__c = con2.Id;
            Database.insert(ord);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            Integer index = 0;
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__CustomerAccount__c = billAcc[0].Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Subscription_Type_1__c = 'Publication';
                sub.Recipient_Contact__c = con2.Id;
                sub.Delivered_By_1__c = 'Mailing Agent';
                sub.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                sub.Order_Number_1__c = ord.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__Zuora_Id__c = 'XXXXX' + index;
                ++index;
            }
            Database.insert(subList);
            
            Test.startTest();
            
            Map<String, Contact> subIdToNewContactMap = new Map<String, Contact>();
            for (Zuora__Subscription__c sub : subList) {
                subIdToNewContactMap.put(sub.Zuora__Zuora_Id__c, con2);
            }
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateOrderRecipientContact(subIdToNewContactMap);
            
            Test.stopTest();
        }
    }
    
    private static testMethod void testUpdateBillAccBillingContact() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            List<Contact> billConList = TestDataFactory.createContactRecType(2, 'Customer Contact');
            for (Contact con : billConList) {
                con.Address__c = ad.Id;
                con.AccountId = acc.Id;
                con.Billing_Indicator__c = true;
            }
            Database.insert(billConList);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            Database.insert(con2);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            Integer index = 0;
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
                bill.Billing_Contact__c = billConList[index].Id;
                ++index;
            }
            Database.insert(billAcc);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            index = 0;
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__CustomerAccount__c = billAcc[index].Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Subscription_Type_1__c = 'Publication';
                sub.Recipient_Contact__c = con2.Id;
                sub.Delivered_By_1__c = 'Mailing Agent';
                sub.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__Zuora_Id__c = 'XXXXX' + index;
                ++index;
            }
            Database.insert(subList);
            
            Test.startTest();
            
            Map<Id, Address_Assignment__c> conIdToAddressAssignIdMap = new Map<Id, Address_Assignment__c>();
            Map<Id, Contact> conIdToConMap = new Map<Id, Contact>();
            Map<Id, Contact> billAccIdToNewContactMap = new Map<Id, Contact>();
            index = 0;
            for (Contact con : billConList) {
                conIdToAddressAssignIdMap.put(con.Id, null);
                conIdToConMap.put(con.Id, con);
                billAccIdToNewContactMap.put( billAcc[index].Id, con);
                ++index;
            }
            
            Map<Id, Zuora__CustomerAccount__c> subIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
            index = 0;
            for (Zuora__Subscription__c sub : subList) {
                subIdToBillAccMap.put(sub.Id, billAcc[index]);
                ++index;
            }
            Map<Id, Set<Zuora__Subscription__c>> accountIdToSubscriptionMap = new Map<Id, Set<Zuora__Subscription__c>>();
            accountIdToSubscriptionMap.put(acc.Id, new Set<Zuora__Subscription__c>(subList));
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateBillAccBillingContact(conIdToAddressAssignIdMap, conIdToConMap, subIdToBillAccMap, billAccIdToNewContactMap, accountIdToSubscriptionMap);
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpdateSubVendor() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            // Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            // database.insert(acc);
            
            Account accV = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accV.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
            database.insert(accV);
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = accV.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);
            
            Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
            subVen.Status__c = 'Active';
            subVen.Account__c = accV.Id;
            Database.insert(subVen);
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Product_Category__c = 'Magazine';
            Database.insert(pub);
            
            Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createSubVendorPublication(1)[0];
            subVenPub.Subscription_Vendor__c = subVen.Id;
            subVenPub.Publication__c = pub.Id;
            Database.insert(subVenPub);
            
            Test.startTest();
            
            Map<Id, Contact> subVendorIdToNewContactMap = new Map<Id, Contact>();
            subVendorIdToNewContactMap.put(subVen.Id, con);
            
            Map<Id, Id> subVendorIdToNewVendorMap = new Map<Id, Id>();
            subVendorIdToNewVendorMap.put(subVen.Id, accV.Id);
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateSubVendor(subVendorIdToNewContactMap, subVendorIdToNewVendorMap);
            
            Test.stopTest();
        }
        
    }
    
    public static testMethod void testUpdateSub() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
            database.insert(acc);
            
            //RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Local'];
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Address_Type__c = 'Local';
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Billing_Indicator__c = true;
            Database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            Database.insert(con2);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            Database.insert(billAcc);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Billing_Contact__c = con.Id;
            ord.Recipient_Contact__c = con2.Id;
            Database.insert(ord);
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            packageList[0].Package_Code__c = 'packsample';
            packageList[0].Subscription_Type__c = 'Termed';
            packageList[0].Package_Sub_Type__c = 'Single';
            packageList[0].Subscription_Period__c = '12';
            packageList[0].Billing_Type__c = 'Full Prepaid';
            insert packageList;
            
            //Start Prod Cat Setup
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0]; //try to loop with many product sub type
            zProduct.ProductPlatform__c = 'Print';
            zProduct.ProductSubType__c = 'Magazine';
            zProduct.ProductCode__c = 'STSU';
            insert zProduct;
            
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '2';
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            insert prdRatePlan;
            
           
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
            
            List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
            prodfam[0].Product_Family_Name__c = 'TestNAme';
            insert prodfam;
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            pItem.Package__c = packageList[0].Id;
            pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            pItem.Duration_in_months__c = '1';
            pItem.Effective_Start_Month__c = '1';
            pItem.Product_Family__c = prodfam[0].id;
            Database.insert(pItem);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__CustomerAccount__c = billAcc[0].Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Subscription_Type_1__c = 'Publication';
                sub.Recipient_Contact__c = con2.Id;
                sub.Delivered_By_1__c = 'Mailing Agent';
                sub.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                sub.Zuora__TermSettingType__c = 'TERMED';
                sub.Order_Number_1__c = ord.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Main_Package_1__c = packageList[0].Id;
            }
            Database.insert(subList);
            
            Test.startTest();
            
            Map<String, Contact> subZuoraIdToNewContactMap = new Map<String, Contact>();
            Map<String, Id> subZuoraIdToNewVendorMap = new Map<String, Id>();
            for (Zuora__Subscription__c sub : subList) {
                //subZuoraIdToNewContactMap.put(sub.Id, con);
                subZuoraIdToNewVendorMap.put(String.valueOf(sub.Id), acc.Id);
            }
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch,200);
            batch.updateSub(subZuoraIdToNewContactMap, subZuoraIdToNewVendorMap);
            
            Test.stopTest();
            
        }
        
    }
    
}