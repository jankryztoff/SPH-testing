@isTest(SeeAllData=true)
private class BT_CO_INT_UtilitiesTest{
    static testMethod void testBT_CO_INT_Utilities(){
       List<Id> IdsPack = new List<Id>();
       List<Id> IdsOrder = new List<Id>();
       List<Id> IdsCase = new List<Id>();
       Set<String> str = new Set<String>();
       str.add('Sample');
        
       Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
       database.insert(acc);
        
       List<Package__c> packList = TestDataFactory.createPackage(10);
       database.insert(packList);
        
       zqu__ZProduct__c prod = TestDataFactory.createZProduct(1)[0];
       database.insert(prod);
        
       zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
       prp.RatePlanType__c = 'Bill Plan';
       prp.zqu__ZProduct__c = prod.Id;
       database.insert(prp);
        
       zqu__ProductRatePlanCharge__c prpCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
       prpCharge.zqu__ProductRatePlan__c = prp.Id;
       prpCharge.PublicationCode__c = 'code01';
       database.insert(prpCharge);
        
       Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
       packItem.Package__c = packList[0].Id;
       packItem.Product_Rate_Plan__c = prp.Id;
       database.insert(packItem);
        
       for(Package__c pack: packList){
           IdsPack.add(pack.Id);    
       }
       
       Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
       defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
       defaultPayment.Zuora__Account__c = acc.id; 
       insert defaultPayment;
        
       Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
       sub.Zuora__CustomerAccount__c = defaultPayment.Id;
       sub.Subscription_Type_1__c = 'Publication';
       sub.Subscription_Type__c = 'Publication';
       sub.Zuora__Account__c = acc.Id;
       sub.Product_Code__c = 'test123';
       sub.Zuora__Status__c = 'Active';
       database.insert(sub);
       /*
       Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
       caseSub.Subscription__c = sub.Id;
       Case__c
       database.insert(caseSub); */
       
       Order__c ord = TestDataFactory.createOrder(1)[0];
       ord.Account__c = acc.Id;
       ord.isChangeOfSubEntry__c = true;
       ord.Subscription__c = sub.Id;
       ord.Base_Subscription__c = sub.Id;
       ord.isChangeOfSubEntry__c = false;
       ord.Order_Type__c = 'Change of Subscription';
       database.insert(ord);
       
       IdsOrder.add(ord.id);
       
       List<BA_INT_DATA_POOL__c> ldpValid = new List<BA_INT_DATA_POOL__c>();
       
       Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
       database.insert(cas);
       
       IdsCase.add(cas.Id);
       
       Address__c add = TestDataFactory.createAddress(1)[0];
       database.insert(add);
       
       Contact con = TestDataFactory.createContact(1)[0];
       database.insert(con);
       
       Address_Assignment__c aa = new Address_Assignment__c();
       aa.Case__c = cas.Id;
       aa.Address__c = add.Id;
       aa.Contact__c = con.Id;
       aa.Effective_Date__c = date.today(); 
       database.insert(aa);
       
       Publication__c pub = TestDataFactory.createPublication(1)[0];
       database.insert(pub);
       
       Set<Publication__c> p = new Set<Publication__c>();
       p.add(pub);
       
       List<BA_INT_DATA_FAILED_POOL__c> ldpFailed = new List<BA_INT_DATA_FAILED_POOL__c>();
        
       test.StartTest();
        
       BT_CO_INT_Utilities.packageToPublication(IdsPack);
        
       BT_CO_INT_Utilities.exportDataItem('interface_id', 'group_id', 'zInput', system.now(), ldpValid);
       BT_CO_INT_Utilities.exportDataItem('interface_id', 'group_id', 'zRecordID', 'zInput', system.now(), ldpValid);
       BT_CO_INT_Utilities.exportFailedDataItem('interface_id', 'group_id', 'zRecordID', 'zErrorMsg', 'zErrorCode', 'zData', system.now(), ldpFailed);
        
       BT_CO_INT_Utilities.orderToSubscription(IdsOrder);
        
       BT_CO_INT_Utilities.getAddressAssignmentMap(Idscase);
       
       BT_CO_INT_Utilities.checkValidation('123');
       
       BT_CO_INT_Utilities.exportDataItemDuplicateCheck('zVALIDATION_CODE', str);
       
       BT_CO_INT_Utilities.convert('12345');
       
       BT_CO_INT_Utilities.sendCallOutMessage('interfaceId');
       
       BT_CO_INT_Utilities.getErrorMessageMap('interfaceId');
       
       BT_CO_INT_Utilities.getEffectiveIssueDate(system.now(), system.now(), 'zPattern');
       
       BT_CO_INT_Utilities.getComplaintDescription(date.today(), date.today());
       
       BT_CO_INT_Utilities.parseValidationCode('zVALIDATION_CODE', new Map<Decimal, String>());
       
       BT_CO_INT_Utilities.extractLegacyID('z-InputStr', '-');
       
       BT_CO_INT_Utilities.prodPubMapping();
       
       BT_CO_INT_Utilities.prodPubMapping(p, sub.Product_Code__c, BT_CO_INT_Utilities.prodPubMapping());
       
       test.StopTest();
    }
}