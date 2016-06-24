@isTest (SeeallData = True)
public class SP_IncreaseDecreaseQuantityBatchTest {
   private static testMethod void testBatch() {
        //create order 200 times
        List<Order__c> createOrderList = TestDataFactory.createOrder(200);
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = 'Street';
        postal.Building_Name__c = 'building';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'country';
        database.insert(country);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Block_House_Number__c = '10';
        add.Postal_Code__c = postal.Id;
        add.Level_Number__c = '12';
        add.Unit_Number__c = '12';
        add.Country__c = country.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'CreditCard';
        database.insert(billAcc);
        
        //create Subscription__c
        List<Zuora__Subscription__c> createSubscriptionList = TestDataFactory.createSubscription(200);
        for(Zuora__Subscription__c zs: createSubscriptionLIST) {
            zs.Order_Number__c = null;
            zs.Zuora__Account__c = acc.Id;
            zs.Billing_Type__c = 'Full Prepaid';
            zs.Zuora__SubscriptionEndDate__c = Date.Today().addDays(5);
            zs.Zuora__CustomerAccount__c = billAcc.id;
            zS.Subscription_Type_1__c = 'Publication';
            zs.Subscription_Type__c = 'Publication';
        }
        insert createSubscriptionList;
        
        List<Zuora__SubscriptionProductCharge__c> spcList = TestDataFactory.createSubProductCharge(14);
        List<Zuora__SubscriptionProductCharge__c> spcToInsertList = new List<Zuora__SubscriptionProductCharge__c>();
        
        //set UOM
        List<String> uomList = new List<String>();
        uomList.add('Copy Mon');
        uomList.add('Copy Tue');
        uomList.add('Copy Wed');
        uomList.add('Copy Thu');
        uomList.add('Copy Fri');
        uomList.add('Copy Sat');
        uomList.add('Copy Sun');
        uomList.add('Credit Copy Mon');
        uomList.add('Credit Copy Tue');
        uomList.add('Credit Copy Wed');
        uomList.add('Credit Copy Thu');
        uomList.add('Credit Copy Fri');
        uomList.add('Credit Copy Sat');
        uomList.add('Credit Copy Sun');

        Integer i = 0;
        for(Zuora__SubscriptionProductCharge__c spc: spcList) {
            spc.Zuora__UOM__c = uomList[i];
            spc.Zuora__Type__c = 'Recurring';
            spc.Zuora__Subscription__c = createSubscriptionList[0].Id; //create 10 per subscription
            spcToInsertList.add(spc);
            i++;
        }
        
        insert spcToInsertList;
        
        
        //create rates
        Integer count = 0;
        List<zqu__ProductRatePlanCharge__c> rateList = TestDataFactory.createProductRatePlanCharge(14);
        for (zqu__ProductRatePlanCharge__c plan: rateList) {
            plan.Name = spcList[count].Name;
            plan.PublicationCode__c = 'Y';//'p'+count;
            count++;
        }
        insert rateList;
        
        
        //insert publication
        Integer z = 0;
        List<Publication__c> pubList = TestDataFactory.createPublication(14);
        for(Publication__c svp: pubList) {
            svp.Publication_Code__c = rateList[z].PublicationCode__c;
            svp.Published_Days__c = 'YYYNYYY';
            svp.Publication_Type__c = 'Y';
            svp.Published_Days__c = 'YYNYYYY';
            z++;
        }
        insert pubList;
        
        for(Order__c o: createOrderList) {
            o.Effective_Date__c = System.today();
            o.Account__c = acc.Id;
            o.Subscription__c = createSubscriptionLIST[0].Id;
            o.New_Quantity__c = 10;
            o.Old_Quantity__c = 100;
            o.isChangeOfSubEntry__c = false;
        }
        insert createOrderList;
        

        
        
        test.startTest();
        //system.runAs(usrTest) {
            SP_IncreaseDecreaseQuantityBatch bh = new SP_IncreaseDecreaseQuantityBatch();
            //Database.executeBatch(bh);
        //}
        test.stopTest();
    }
}