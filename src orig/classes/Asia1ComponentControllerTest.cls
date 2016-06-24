@isTest
private class Asia1ComponentControllerTest{
    static testMethod void testAsia1ComponentController(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Account = acc;
        database.insert(con);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Package_Access_Flag__c flag = TestDataFactory.createPackageAccessFlag(1)[0];
        flag.Package__c = pack.Id;
        flag.No_of_Concurrent_Users__c = 2;
        database.insert(flag);
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Display_Name__c = 'sample@email.com';
        asia1.User_ID_LDAP_ID__c = 'sample@email.com';
        asia1.Password__c = 'password123';
        asia1.Contact__c = con.Id;
        database.insert(asia1);
        //end test data
    
        test.startTest();
            Asia1ComponentController cont = new Asia1ComponentController();
            //cont.addAsia1Account();
            cont.asia1SelectedExistingId = asia1.Id;
            cont.selectedPackageId = pack.Id;
            cont.addAsia1ExistingAccount();
            cont.validateNewAsia1Account();
            
            cont.asia1SingleAccount = asia1;
            cont.validateNewAsia1Account();
            
            asia1.Display_Name__c = 'dislaynametest';
            asia1.User_ID_LDAP_ID__c = 'ldaptest';
            database.update(asia1);
            cont.validateNewAsia1Account();
            
            cont.removeAsia1Subscription();
            
            cont.accountId = acc.Id;
            cont.getAsia1ExistingAccounts();
            
            cont.asia1SingleSubscription = null;
            cont.selectedAsia1Creation = '';
        test.stopTest();
    }
}