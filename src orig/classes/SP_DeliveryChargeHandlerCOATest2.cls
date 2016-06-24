@isTest(SeeAllData=true)
private class SP_DeliveryChargeHandlerCOATest2{
    static testMethod void testSP_DeliveryChargeHandlerCOA(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Type__c = 'H';
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        counter=0;
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c s: sub){
            s.Zuora__CustomerAccount__c = billAcc.Id;
            s.Zuora__Zuora_Id__c = '123456';
            s.Recipient_Contact__c = con.Id;
            s.Zuora__Account__c = acc.Id;
            s.Zuora__Status__c = 'Active';
            if(counter==0){
                s.Subscription_Type__c = 'Publication';   
            }
            else{
                s.Subscription_Type__c = 'Delivery'; 
                s.Zuora__External_Id__c = acc.Id;
            }
            counter++;
        }
        database.insert(sub);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductType__c = 'Charge';
        zp.ProductSubType__c = 'Delivery';
        database.insert(zp);
               
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.Name = ConstantsSLB.getKeyId('DELCHG_ZERO');
        database.insert(prp);
              
        
        zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.Name = 'Zero Charge Amount';
        database.insert(prpc);
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        insert quote;
        
        zqu__QuoteCharge__c quotecharge = TestDataFactory.createQuoteCharge(1)[0];
        quotecharge.zqu__Quote__c = quote.Id;
        insert quotecharge;
        //end test data
    
        test.startTest();
            SP_DeliveryChargeHandlerCOA handler = new SP_DeliveryChargeHandlerCOA();
            handler.checkDeliveryCharge(sub[0].Id, acc.Id, add.Id, add, 12.50);
            handler.createDeliveryCharge();
            handler.zBuildQoutesPackageDELIVERY(acc.Id, sub[0]);
            handler.zPopulateQuoteChargeDELIVERY(quote, 12.50, add);
            
        test.stopTest();
    }
    static testMethod void testSP_DeliveryChargeHandlerCOA01(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Type__c = 'H';
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        counter=0;
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c s: sub){
            s.Zuora__CustomerAccount__c = billAcc.Id;
            s.Zuora__Zuora_Id__c = '123456';
            s.Recipient_Contact__c = con.Id;
            s.Zuora__Account__c = acc.Id;
            s.Zuora__Status__c = 'Active';
            if(counter==0){
                s.Subscription_Type__c = 'Publication';   
            }
            else{
                s.Subscription_Type__c = 'Delivery'; 
                s.Zuora__External_Id__c = acc.Id;
            }
            counter++;
        }
        database.insert(sub);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductType__c = 'Charge';
        zp.ProductSubType__c = 'Delivery';
        database.insert(zp);
               
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.Name = ConstantsSLB.getKeyId('DELCHG_HDB');
        database.insert(prp);
              
        
        zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.Name = 'Zero Charge Amount';
        database.insert(prpc);
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        insert quote;
        
        zqu__QuoteCharge__c quotecharge = TestDataFactory.createQuoteCharge(1)[0];
        quotecharge.zqu__Quote__c = quote.Id;
        insert quotecharge;
        //end test data
    
        test.startTest();
            SP_DeliveryChargeHandlerCOA handler = new SP_DeliveryChargeHandlerCOA();
            handler.checkDeliveryCharge(sub[0].Id, acc.Id, add.Id, add, 12.50);
            handler.createDeliveryCharge();
            handler.zBuildQoutesPackageDELIVERY(acc.Id, sub[0]);
            handler.zPopulateQuoteChargeDELIVERY(quote, 12.50, add);
            
        test.stopTest();
    }
    static testMethod void testSP_DeliveryChargeHandlerCOA02(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Type__c = 'A';
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        counter=0;
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c s: sub){
            s.Zuora__CustomerAccount__c = billAcc.Id;
            s.Zuora__Zuora_Id__c = '123456';
            s.Recipient_Contact__c = con.Id;
            s.Zuora__Account__c = acc.Id;
            s.Zuora__Status__c = 'Active';
            if(counter==0){
                s.Subscription_Type__c = 'Publication';   
            }
            else{
                s.Subscription_Type__c = 'Delivery'; 
                s.Zuora__External_Id__c = acc.Id;
            }
            counter++;
        }
        database.insert(sub);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductType__c = 'Charge';
        zp.ProductSubType__c = 'Delivery';
        database.insert(zp);
               
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.Name = ConstantsSLB.getKeyId('DELCHG_APT');
        database.insert(prp);
              
        
        zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.Name = 'Zero Charge Amount';
        database.insert(prpc);
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        insert quote;
        
        zqu__QuoteCharge__c quotecharge = TestDataFactory.createQuoteCharge(1)[0];
        quotecharge.zqu__Quote__c = quote.Id;
        insert quotecharge;
        //end test data
    
        test.startTest();
            SP_DeliveryChargeHandlerCOA handler = new SP_DeliveryChargeHandlerCOA();
            handler.checkDeliveryCharge(sub[0].Id, acc.Id, add.Id, add, 12.50);
            handler.createDeliveryCharge();
            handler.zBuildQoutesPackageDELIVERY(acc.Id, sub[0]);
            handler.zPopulateQuoteChargeDELIVERY(quote, 12.50, add);
            
        test.stopTest();
    }
    
    static testMethod void testSP_DeliveryChargeHandlerCOA03(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Type__c = 'S';
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        counter=0;
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c s: sub){
            s.Zuora__CustomerAccount__c = billAcc.Id;
            s.Zuora__Zuora_Id__c = '123456';
            s.Recipient_Contact__c = con.Id;
            s.Zuora__Account__c = acc.Id;
            s.Zuora__Status__c = 'Active';
            if(counter==0){
                s.Subscription_Type__c = 'Publication';   
            }
            else{
                s.Subscription_Type__c = 'Delivery'; 
                s.Zuora__External_Id__c = acc.Id;
            }
            counter++;
        }
        database.insert(sub);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductType__c = 'Charge';
        zp.ProductSubType__c = 'Delivery';
        database.insert(zp);
               
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.Name = ConstantsSLB.getKeyId('DELCHG_LAND');
        database.insert(prp);
              
        
        zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.Name = 'Zero Charge Amount';
        database.insert(prpc);
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        insert quote;
        
        zqu__QuoteCharge__c quotecharge = TestDataFactory.createQuoteCharge(1)[0];
        quotecharge.zqu__Quote__c = quote.Id;
        insert quotecharge;
        //end test data
    
        test.startTest();
            SP_DeliveryChargeHandlerCOA handler = new SP_DeliveryChargeHandlerCOA();
            handler.checkDeliveryCharge(sub[0].Id, acc.Id, add.Id, add, 12.50);
            handler.createDeliveryCharge();
            handler.zBuildQoutesPackageDELIVERY(acc.Id, sub[0]);
            handler.zPopulateQuoteChargeDELIVERY(quote, 12.50, add);
            
        test.stopTest();
    }
}