/**
* Class Name: SP_SendEmailNotifForFailedPayPalTest
* @author: Recuerdo Bregente
* @date: 07/09/2015
* @requirement/Project Name: SPH Project
* @description Batch Apex Class to retrieve Failed PayPal Payments and send Notifications 
* to the Subscriber via Email.
*/
@isTest(seeAllData=True)
private class SP_SendEmailNotifForFailedPayPalTest {

    static Account acc;
    static Singpost_Address__c postal;
    static Address__c address;
    //START UD-2624 GDelrosario 
    static Country__c countr;
    //END UD-2624 GDelrosario   
    static List<Contact> con;
    static List<Package__c> pkg;
    static List<Zuora__CustomerAccount__c> zcaList;
    static List<Zuora__CustomerAccount__c> zcaList2;
    static List<Zuora__Subscription__c> zSubs;
    static List<Zuora__PaymentMethod__c> zpmList;
    static List<Zuora__Payment__c> zuoraPayment;
    static List<Zuora__SubscriptionProductCharge__c> subProdAndCharge;
    static RecordType recType;

    /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/09/2015
    */ 
    static void prepareTestData(String addressRecordType){
            acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber'); 
            insert acc;
            
            //START UD-2624 GDelrosario 
            Country__c countr1 = new Country__c();
            countr1.Code__c = 'Zz';
            insert countr1;
            //END UD-2624 GDelrosario 

            postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            List<RecordType> recTypes = 
                [Select Id, Name, SObjectType From RecordType WHERE Name = :addressRecordType LIMIT 1];
            
            address = TestDataFactory.createAddress(1)[0];
            //START UD-2624 GDelrosario 
            address.Country__c = countr1.Id;
            //END UD-2624 GDelrosario 
            address.Postal_Code__c = postal.Id;
            
            if(recTypes.size() > 0) {
                recType = recTypes[0];
                address.recordTypeID = recType.Id;
            }
            
            insert address;
            
    // if (payment.Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c != null) { 
            
            con = TestDataFactory.createContact(1);
            con[0].Phone = '1234567';
            con[0].Address__c = address.Id;
            insert con;
                   
            pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15'; 
            insert pkg;
            
                        
            zcaList = TestDataFactory.createBillingAccount(1);
            zcaList[0].Name = 'Zuora Customer Account';
            zcaList[0].Zuora__Account__c = acc.Id;
            zcalist[0].Billing_Contact__c = con[0].Id;
            zcaList[0].Zuora__Credit_Balance__c = 1;
            zcaList[0].Refund_Amount__c = 100;
            zcaList[0].Zuora__AutoPay__c =false;
            zcaList[0].Zuora__Balance__c = 1;
            zcaList[0].Payment_Mode__c = 'PayPal';
            zcaList[0].Other_PaymentMethod__c= 'PayPal';
            zcaList[0].Zuora__PaymentMethodType__c = 'PayPal'; 
            zcalist[0].Zuora__External_Id__c = '22544AA';  
            zcalist[0].Zuora__Zuora_Id__c = '0124';   
            insert zcaList;
        
            //START : D-1929 3/2/2015 added to create Default Payment Method
            zpmList = TestDataFactory.createPaymentMethod(1);
            zpmList[0].Name = 'Zuora Customer Account';
            zpmList[0].Zuora__Type__c = 'Electronic';
            zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
            zpmList[0].Zuora__PaypalEmail__c = 'dee.bregente@gmail.com';
            insert zpmList;  
            //End: D-1929 3/2/2015 added to create Default Payment Method
        
            zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
            update zcaList;
            
            //create billing account      
            zSubs =  TestDataFactory.createSubscription(2);
            for(Zuora__Subscription__c zuoraSubRec: zSubs) {
                zuoraSubRec.Subscriber_Contact__c = con[0].id;
                zuoraSubRec.Main_Package_1__c = pkg[0].id;
                zuoraSubRec.Main_Package__c = pkg[0].id;
                zuoraSubRec.Zuora__Account__c = acc.id;
                zuoraSubRec.Order_Number__c = null;
                zuoraSubRec.Zuora__CustomerAccount__c = zcaList[0].Id;
                zuoraSubRec.Billing_Type__c = 'Full Prepaid';
                zuoraSubRec.Legacy_Create_Date__c = 'a';
                zuoraSubRec.Legacy_Create_By__c = 'a';
                zuoraSubRec.Legacy_Update_By__c = 'a';
                zuoraSubRec.Legacy_Subscription_ID__c = 'a';
                zuoraSubRec.Legacy_Update_Date__c = 'a';
                zuoraSubRec.Number_of_Copies__c = 100;
                zuoraSubRec.Number_of_Copies1__c = '100';
                zuoraSubRec.Zuora__Status__c = 'Active';
                zuoraSubRec.Subscription_Type_1__c = 'Publication';
                zuoraSubRec.Subscription_Type__c = 'Publication';
            }
            
            insert zSubs;
            
            subProdAndCharge = TestDataFactory.createSubProductCharge(1);
            subProdAndCharge[0].Zuora__Subscription__c = zSubs[0].Id;
            subProdAndCharge[0].PublicationCode__c = 'asas';
            insert subProdAndCharge;
            
            zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
            update zcaList;
            
            External_Payment__c externalPayment = TestDataFactory.createExternalPayment(1)[0];
            externalPayment.Transaction_Type__c = 'F';
            externalPayment.Billing_Account__c = zcaList[0].id ;
            database.insert(externalPayment);
    }
    
    /**
    * @name : prepareZuoraPaymentMethodRecord
    * @author : Recuerdo Bregente
    * @description : Prepares the Zuora Payment Method Record.
    * @date: 07/09/2015
    */ 
    static void prepareZuoraPaymentMethodRecord(Integer recordCount) {
        zuoraPayment = TestDataFactory.createPayment(recordCount);
            for(Zuora__Payment__c zuoraPaymentRec : zuoraPayment){
                zuoraPaymentRec.Zuora__BillingAccount__c = zcaList[0].id;
                zuoraPaymentRec.Zuora__Type__c = 'Electronic';
                zuoraPaymentRec.Zuora__Status__c = 'Error';
                zuoraPaymentRec.Zuora__PaymentMethod__c = 'Paypal';
            }
             
            insert zuoraPayment;
    }
       //   payment.Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c != nul 
    
      /**
    * @name: testBatchAddressRecordTypeIsLocal
    * @author : Recuerdo Bregente
    * @description : Handles the testing for SP_SendEmailNotifForFailedPayPalBatch execution
    *                with Local Address RecordType.
    * @date: 07/08/2015
    */
    static testMethod void testBatchAddressRecordTypeIsLocal(){
        boolean errorExist = false;
        
        try{
            Test.StartTest();
            prepareTestData('Local');
            prepareZuoraPaymentMethodRecord(1);
        
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        System.assertEquals(false, errorExist);
    }
    
    /**
    * @name: testBatchAddressRecordTypeIsAirline
    * @author : Recuerdo Bregente
    * @description : Handles the testing for SP_SendEmailNotifForFailedPayPalBatch execution
    *                with Airline Address RecordType.
    * @date: 07/08/2015
    */
    static testMethod void testBatchAddressRecordTypeIsAirline(){
        boolean errorExist = false;
        
        try{
            Test.StartTest();
            prepareTestData('Airline');
            prepareZuoraPaymentMethodRecord(1);
        
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        System.assertEquals(false, errorExist);
    }
    
    /**
    * @name: testBatchAddressRecordTypeIsOverseas
    * @author : Recuerdo Bregente
    * @description : Handles the testing for SP_SendEmailNotifForFailedPayPalBatch execution
    *                with Overseas Address RecordType.
    * @date: 07/08/2015
    */
    static testMethod void testBatchAddressRecordTypeIsOverseas(){
        boolean errorExist = false;
        
        try{
            Test.StartTest();
            prepareTestData('Overseas');
            prepareZuoraPaymentMethodRecord(1);
        
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        System.assertEquals(false, errorExist);
    }
    
    /**
    * @name: testBatchAddressRecordTypeIsInternal
    * @author : Recuerdo Bregente
    * @description : Handles the testing for SP_SendEmailNotifForFailedPayPalBatch execution
    *                with Internal Address RecordType.
    * @date: 07/08/2015
    */
    static testMethod void testBatchAddressRecordTypeIsInternal(){
        boolean errorExist = false;
        
        try{
            Test.StartTest();
            prepareTestData('Internal');
            prepareZuoraPaymentMethodRecord(1);
        
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        System.assertEquals(false, errorExist);
    }
    
    static testMethod void testBatchAddressRecordTypeIsInternal2(){
        boolean errorExist = false;
        
        try{
            Test.StartTest();
            prepareTestData('Internal');
          //  prepareZuoraPaymentMethodRecord(1);
            
    /*        Account accT = new Account();
            accT.Name = 'Test Account';
            accT.RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber'); 
            insert acc;
            
            Singpost_Address__c postal1 = new Singpost_Address__c();
            postal1 = TestDataFactory.createSingpostAddress(1)[0];
            insert postal1;
            
                    
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Postal_Code__c = postal1.Id;         
            insert add;
            
    // if (payment.Zuora__BillingAccount__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c != null) { 
            
            List<Contact> cont = TestDataFactory.createContact(1);
            cont[0].Phone = '1234567';
            cont[0].Address__c = add.Id;
            insert cont;
                              
            List<Zuora__CustomerAccount__c> billaAcc = TestDataFactory.createBillingAccount(1);
            billaAcc [0].Name = 'Zuora Customer Account';
            billaAcc [0].Zuora__Account__c = acct.Id;
            billaAcc [0].Billing_Contact__c = cont[0].Id;
            billaAcc [0].Zuora__Credit_Balance__c = 1;
            billaAcc [0].Refund_Amount__c = 100;
            billaAcc [0].Zuora__AutoPay__c =false;
            billaAcc [0].Zuora__Balance__c = 1;
            billaAcc [0].Payment_Mode__c = 'PayPal';
            billaAcc [0].Other_PaymentMethod__c= 'PayPal';
            billaAcc [0].Zuora__PaymentMethodType__c = 'PayPal'; 
            billaAcc [0].Zuora__External_Id__c = '22544AA';  
            billaAcc [0].Zuora__Zuora_Id__c = '0124';   
            insert zcaList;
        */    
            List<Zuora__Payment__c> zuoraPay = TestDataFactory.createPayment(1);
            zuoraPay[0].Zuora__BillingAccount__c = zcaList [0].id;
            zuoraPay[0].Zuora__Type__c = 'Electronic';
            zuoraPay[0].Zuora__Status__c = 'Error';
            zuoraPay[0].Zuora__PaymentMethod__c = 'Paypal';
            insert zuoraPay;
            
       
            List<Zuora__PaymentMethod__c> PAYList = TestDataFactory.createPaymentMethod(1);
            PAYList [0].Name = 'Zuora Customer Account';
            PAYList [0].Zuora__Type__c = 'Electronic';
            PAYList [0].Zuora__BillingAccount__c = zcaList [0].id;
            PAYList [0].Zuora__PaypalEmail__c = 'dee.bregente@gmail.com';
            insert PAYList ;  
            //End: D-1929 3/2/2015 added to create Default Payment Method
        
            zcaList[0].Zuora__Default_Payment_Method__c = PAYList[0].id;         
            update zcaList;
            
            
            List<External_Payment__c> externalPayment = TestDataFactory.createExternalPayment(1);
            externalPayment[0].Transaction_Type__c = 'F';
            externalPayment[0].Billing_Account__c = zcaList[0].id ;
            database.insert(externalPayment);

            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            Database.BatchableContext BC;
            //ID batchprocessid = Database.executeBatch(batch, 200);
           // batch.start(BC);
            
            //batch.execute(BC, externalPayment);

            Test.StopTest();  
        } catch (Exception e) {
            errorExist = true;
        }
        
        //System.assertNotEquals(false, errorExist);
    }
   
    static testMethod void testPaypalEmailLocalAd(){
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        database.insert(postal);

        //START UD-2624 GDelrosario 
        countr = TestDataFactory.createCountry(1)[0];
        countr.Code__c = 'Zz';
        database.insert(countr);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.Id;
        ad.Country__c = countr.Id;
        //END UD-2624 GDelrosario 
        database.insert(ad);
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = ad.Id;
        database.insert(cont);
        
        Zuora__CustomerAccount__c billAccS = TestDataFactory.createBillingAccount(1)[0];
        billAccS.Zuora__Account__c = acc.Id;
        billAccS.Billing_Contact__c = cont.Id;
        database.insert(billAccS);
        
        Zuora__PaymentMethod__c defaultPayment = TestDataFactory.createPaymentMethod(1)[0];
        defaultPayment.Zuora__Type__c = 'PayPal';
        defaultPayment.Zuora__BillingAccount__c = billAccS.Id;
        defaultPayment.Zuora__PaypalEmail__c = 'abc@ab.c';
        database.insert(defaultPayment);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = cont.Id;
        billAcc.Zuora__Default_Payment_Method__c = defaultPayment.Id;
        database.insert(billAcc);
    
        List<Zuora__Payment__c> payment = TestDataFactory.createPayment(2);
        for(Zuora__Payment__c p: payment){
            p.Zuora__Type__c = 'Electronic';
            p.Zuora__Status__c = 'Error';
            p.Zuora__BillingAccount__c = billAcc.Id;
        }
        database.insert(payment);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type__c = 'Publication';
            sub.Main_Package__c = pack.Id;
        }
        database.insert(subs);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
    
        test.startTest();
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            Id BatchId = database.executeBatch(batch, 200);
            system.assert(BatchId<>null);
        test.stopTest();
    }
    
    static testMethod void testPaypalEmailAirlineAd(){
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        database.insert(postal);

        //START UD-2624 GDelrosario 
        countr = TestDataFactory.createCountry(1)[0];
        countr.Code__c = 'Zz';
        database.insert(countr);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.Id;
        ad.Country__c = countr.Id;
        //END UD-2624 GDelrosario 
        ad.RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Address__c' AND Name='Airline'].Id;
        ad.RecordType = [SELECT id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Airline'];
        ad.recordtype.name = 'Airline';
        database.insert(ad);
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = ad.Id;
        database.insert(cont);
        
        Zuora__CustomerAccount__c billAccS = TestDataFactory.createBillingAccount(1)[0];
        billAccS.Zuora__Account__c = acc.Id;
        billAccS.Billing_Contact__c = cont.Id;
        database.insert(billAccS);
        
        Zuora__PaymentMethod__c defaultPayment = TestDataFactory.createPaymentMethod(1)[0];
        defaultPayment.Zuora__Type__c = 'PayPal';
        defaultPayment.Zuora__BillingAccount__c = billAccS.Id;
        defaultPayment.Zuora__PaypalEmail__c = 'abc@ab.c';
        database.insert(defaultPayment);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = cont.Id;
        billAcc.Zuora__Default_Payment_Method__c = defaultPayment.Id;
        database.insert(billAcc);
    
        List<Zuora__Payment__c> payment = TestDataFactory.createPayment(2);
        for(Zuora__Payment__c p: payment){
            p.Zuora__Type__c = 'Electronic';
            p.Zuora__Status__c = 'Error';
            p.Zuora__BillingAccount__c = billAcc.Id;
        }
        database.insert(payment);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type__c = 'Publication';
            sub.Main_Package__c = pack.Id;
        }
        database.insert(subs);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
    
        test.startTest();
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            Id BatchId = database.executeBatch(batch, 200);
            system.assert(BatchId<>null);
        test.stopTest();
    }
    
    static testMethod void testPaypalEmailOverseasAd(){
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        database.insert(postal);

        //START UD-2624 GDelrosario 
        countr = TestDataFactory.createCountry(1)[0];
        countr.Code__c = 'Zz';
        database.insert(countr);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.Id;
        ad.Country__c = countr.Id;
        //END UD-2624 GDelrosario
        ad.RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Address__c' AND Name='Overseas'].Id;
        ad.RecordType = [SELECT id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Overseas'];
        ad.recordtype.name = 'Overseas';
        database.insert(ad);
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = ad.Id;
        database.insert(cont);
        
        Zuora__CustomerAccount__c billAccS = TestDataFactory.createBillingAccount(1)[0];
        billAccS.Zuora__Account__c = acc.Id;
        billAccS.Billing_Contact__c = cont.Id;
        database.insert(billAccS);
        
        Zuora__PaymentMethod__c defaultPayment = TestDataFactory.createPaymentMethod(1)[0];
        defaultPayment.Zuora__Type__c = 'PayPal';
        defaultPayment.Zuora__BillingAccount__c = billAccS.Id;
        defaultPayment.Zuora__PaypalEmail__c = 'abc@ab.c';
        database.insert(defaultPayment);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = cont.Id;
        billAcc.Zuora__Default_Payment_Method__c = defaultPayment.Id;
        database.insert(billAcc);
    
        List<Zuora__Payment__c> payment = TestDataFactory.createPayment(2);
        for(Zuora__Payment__c p: payment){
            p.Zuora__Type__c = 'Electronic';
            p.Zuora__Status__c = 'Error';
            p.Zuora__BillingAccount__c = billAcc.Id;
        }
        database.insert(payment);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type__c = 'Publication';
            sub.Main_Package__c = pack.Id;
        }
        database.insert(subs);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        database.insert(pub);
    
        test.startTest();
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            Id BatchId = database.executeBatch(batch, 200);
            system.assert(BatchId<>null);
        test.stopTest();
    }
    
    static testMethod void testPaypalEmailInternalAd(){
        Integer counter;
        
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        database.insert(postal);

        //START UD-2624 GDelrosario 
        countr = TestDataFactory.createCountry(1)[0];
        countr.Code__c = 'Zz';
        database.insert(countr);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.Id;
        ad.Country__c = countr.Id;
        //END UD-2624 GDelrosario 
        ad.RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'].Id;
        ad.RecordType = [SELECT id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'];
        ad.recordtype.name = 'Internal';
        database.insert(ad);
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = ad.Id;
        database.insert(cont);
        
        Zuora__CustomerAccount__c billAccS = TestDataFactory.createBillingAccount(1)[0];
        billAccS.Zuora__Account__c = acc.Id;
        billAccS.Billing_Contact__c = cont.Id;
        database.insert(billAccS);
        
        Zuora__PaymentMethod__c defaultPayment = TestDataFactory.createPaymentMethod(1)[0];
        defaultPayment.Zuora__Type__c = 'PayPal';
        defaultPayment.Zuora__BillingAccount__c = billAccS.Id;
        defaultPayment.Zuora__PaypalEmail__c = 'abc@ab.c';
        database.insert(defaultPayment);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = cont.Id;
        billAcc.Zuora__Default_Payment_Method__c = defaultPayment.Id;
        database.insert(billAcc);
    
        List<Zuora__Payment__c> payment = TestDataFactory.createPayment(2);
        for(Zuora__Payment__c p: payment){
            p.Zuora__Type__c = 'Electronic';
            p.Zuora__Status__c = 'Error';
            p.Zuora__BillingAccount__c = billAcc.Id;
        }
        database.insert(payment);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type__c = 'Publication';
            sub.Main_Package__c = pack.Id;
        }
        database.insert(subs);
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==0){
                sp.PublicationCode__c = '01';
            }
            else{
                sp.PublicationCode__c = '02';
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(2);
        for(Publication__c p: pub){
            if(counter==0){
                p.Publication_Code__c = '01';
            }
            else{
                p.Publication_Code__c = '02';
            }
            counter++;
        }
        database.insert(pub);
    
        test.startTest();
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            Id BatchId = database.executeBatch(batch, 200);
            system.assert(BatchId<>null);
        test.stopTest();
    }
    
    /*
    static testMethod void newTest01(){
        Integer counter;
        
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        database.insert(postal);

        //START UD-2624 GDelrosario 
        countr = TestDataFactory.createCountry(1)[0];
        countr.Code__c = 'Zz';
        database.insert(countr);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.Id;
        ad.Country__c = countr.Id;
        //END UD-2624 GDelrosario 
        ad.RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'].Id;
        ad.RecordType = [SELECT id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'];
        ad.recordtype.name = 'Internal';
        database.insert(ad);
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = ad.Id;
        cont.HomePhone__c = '1234567890';
        cont.Office_Number__c = '1234567890';
        cont.Mobile_Number__c = '1234567890';
        database.insert(cont);
        
        Zuora__CustomerAccount__c billAccS = TestDataFactory.createBillingAccount(1)[0];
        billAccS.Zuora__Account__c = acc.Id;
        billAccS.Billing_Contact__c = cont.Id;
        database.insert(billAccS);
        
        Zuora__PaymentMethod__c defaultPayment = TestDataFactory.createPaymentMethod(1)[0];
        defaultPayment.Zuora__Type__c = 'PayPal';
        defaultPayment.Zuora__BillingAccount__c = billAccS.Id;
        defaultPayment.Zuora__PaypalEmail__c = 'abc@ab.c';
        database.insert(defaultPayment);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = cont.Id;
        billAcc.Zuora__Default_Payment_Method__c = defaultPayment.Id;
        database.insert(billAcc);
    
        List<Zuora__Payment__c> payment = TestDataFactory.createPayment(2);
        for(Zuora__Payment__c p: payment){
            p.Zuora__Type__c = 'Electronic';
            p.Zuora__Status__c = 'Error';
            p.Zuora__BillingAccount__c = billAcc.Id;
        }
        database.insert(payment);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Subscription_Type__c = 'Publication';
            sub.Main_Package__c = pack.Id;
        }
        database.insert(subs);
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==0){
                sp.PublicationCode__c = '01';
            }
            else{
                sp.PublicationCode__c = '02';
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(2);
        for(Publication__c p: pub){
            if(counter==0){
                p.Publication_Code__c = '01';
            }
            else{
                p.Publication_Code__c = '02';
            }
            counter++;
        }
        database.insert(pub);
        
        Zuora__ZInvoice__c invRec = TestDataFactory.createInvoice(1)[0];
        invRec.Zuora__Account__c = acc.Id;
        invRec.Zuora__BillingAccount__c = billAcc.Id;
        invRec.Zuora__Zuora_Id__c = 'test123';
        insert invRec;
        
        Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
        invLineItem.Subscription__c = subs[0].Id;
        invLineItem.Invoice_ID__c = invRec.Zuora__Zuora_Id__c;
        invLineItem.Charge_Amount__c = 10.00;
        insert invLineItem; 
    
        Set<Id> newpaymentIds = new Set<Id>();
        newpaymentIds.add(payment[0].id);
        newpaymentIds.add(payment[1].id);
        
    
        test.startTest();
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch(newpaymentIds);
            Id BatchId = database.executeBatch(batch, 200);
            
            system.assert(BatchId<>null);
        test.stopTest();
    }*/
 
       static testMethod void newTest02(){
        Integer counter;
        
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        database.insert(postal);

        //START UD-2624 GDelrosario 
        countr = TestDataFactory.createCountry(1)[0];
        countr.Code__c = 'Zz';
        database.insert(countr);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.Id;
        ad.Country__c = countr.Id;
        //END UD-2624 GDelrosario 
        ad.RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'].Id;
        ad.RecordType = [SELECT id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'];
        ad.recordtype.name = 'Internal';
        database.insert(ad);
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = ad.Id;
        cont.Office_Number__c = '0213251234';
        cont.HomePhone__c = '02132512334';
        database.insert(cont);
        
        Zuora__CustomerAccount__c billAccS = TestDataFactory.createBillingAccount(1)[0];
        billAccS.Zuora__Account__c = acc.Id;
        billAccS.Billing_Contact__c = cont.Id;
        database.insert(billAccS);
        
        Zuora__PaymentMethod__c defaultPayment = TestDataFactory.createPaymentMethod(1)[0];
        defaultPayment.Zuora__Type__c = 'PayPal';
        defaultPayment.Zuora__BillingAccount__c = billAccS.Id;
        defaultPayment.Zuora__PaypalEmail__c = 'abc@ab.c';
        database.insert(defaultPayment);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = cont.Id;
        billAcc.Zuora__Default_Payment_Method__c = defaultPayment.Id;
        database.insert(billAcc);
    
        List<Zuora__Payment__c> payment = TestDataFactory.createPayment(2);
        for(Zuora__Payment__c p: payment){
            p.Zuora__Type__c = 'Electronic';
            p.Zuora__Status__c = 'Error';
            p.Zuora__BillingAccount__c = billAcc.Id;
        }
        database.insert(payment);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
            subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            subs[0].Zuora__Account__c = acc.id;
            subs[0].Zuora__Status__c = 'Active';
            subs[0].Subscription_Type__c = 'Publication';
            subs[0].Main_Package__c = pack.Id;
            subs[1].Zuora__Account__c = acc.id;
            subs[1].Zuora__CustomerAccount__c = billAcc.Id;
            subs[1].Zuora__Status__c = 'Active';
            subs[1].Subscription_Type__c = 'Publication';
            subs[1].Main_Package__c = pack.Id;
        database.insert(subs);
       
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[0].Id;
            if(counter==0){
                sp.PublicationCode__c = '01';
            }
            else{
                sp.PublicationCode__c = '02';
            }
            counter++;
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(2);
        for(Publication__c p: pub){
            if(counter==0){
                p.Publication_Code__c = '01';
            }
            else{
                p.Publication_Code__c = '02';
            }
            counter++;
        }
        database.insert(pub);
    
        test.startTest();
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            Id BatchId = database.executeBatch(batch, 200);
            system.assert(BatchId<>null);
        test.stopTest();
       }
   
    static testMethod void newTest03(){
        Integer counter;
        
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        database.insert(postal);
        
        //START UD-2624 GDelrosario 
        countr = TestDataFactory.createCountry(1)[0];
        countr.Code__c = 'Zz';
        database.insert(countr);

        Address__c ad = TestDataFactory.createAddress(1)[0];
        ad.Postal_Code__c = postal.Id;
        ad.Country__c = countr.Id;
        //END UD-2624 GDelrosario 
        ad.RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'].Id;
        ad.RecordType = [SELECT id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'];
        ad.recordtype.name = 'Internal';
        database.insert(ad);
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = ad.Id;
        cont.Office_Number__c = '0213251234';
        cont.HomePhone__c = '02132512334';
        database.insert(cont);
        
        Zuora__CustomerAccount__c billAccS = TestDataFactory.createBillingAccount(1)[0];
        billAccS.Zuora__Account__c = acc.Id;
        billAccS.Billing_Contact__c = cont.Id;
        database.insert(billAccS);
        
        Zuora__PaymentMethod__c defaultPayment = TestDataFactory.createPaymentMethod(1)[0];
        defaultPayment.Zuora__Type__c = 'PayPal';
        defaultPayment.Zuora__BillingAccount__c = billAccS.Id;
        defaultPayment.Zuora__PaypalEmail__c = 'abc@ab.c';
        database.insert(defaultPayment);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = cont.Id;
        billAcc.Zuora__Default_Payment_Method__c = defaultPayment.Id;
        database.insert(billAcc);
    
        List<Zuora__Payment__c> payment = TestDataFactory.createPayment(2);
        for(Zuora__Payment__c p: payment){
            p.Zuora__Type__c = 'Electronic';
            p.Zuora__Status__c = 'Error';
            p.Zuora__BillingAccount__c = billAcc.Id;
        }
        database.insert(payment);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
            subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            subs[0].Zuora__Account__c = acc.id;
            subs[0].Zuora__Status__c = 'Active';
            subs[0].Subscription_Type__c = 'Publication';
            subs[0].Main_Package__c = pack.Id;
            subs[1].Zuora__Account__c = acc.id;
            subs[1].Zuora__CustomerAccount__c = billAcc.Id;
            subs[1].Zuora__Status__c = 'Active';
            subs[1].Subscription_Type__c = 'Publication';
            subs[1].Main_Package__c = pack.Id;
        database.insert(subs);
       
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subs[1].Id;
            sp.PublicationCode__c = null;
            /*if(counter==0){
                sp.PublicationCode__c = '01';
            }
            else{
                sp.PublicationCode__c = '02';
            }
            counter++;*/
        }
        database.insert(spc);
        
        counter=0;
        List<Publication__c> pub = TestDataFactory.createPublication(2);
        for(Publication__c p: pub){
            if(counter==0){
                p.Publication_Code__c = '01';
            }
            else{
                p.Publication_Code__c = '02';
            }
            counter++;
        }
        database.insert(pub);
    
        test.startTest();
            SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch();
            Id BatchId = database.executeBatch(batch, 200);
            system.assert(BatchId<>null);
        test.stopTest();
       }
    
    static testMethod void testSP_SendEmailNotifForFailedPayPalApril(){
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber'); 
            acct.Generate_Account_Number__c = true;
            acct.AccountNumber = 'ACC123456';
            insert acct;
            
            Packing_Grp__c packGroup = new Packing_Grp__c();
            packGroup .Airline__c = 'PAL';
            database.insert(packGroup );
            
            Singpost_Address__c postal1 = TestDataFactory.createSingpostAddress(1)[0];
            postal1.Name = 'Postal';
            postal1.Street_Name__c = 'StreetA';
            postal1.Building_Name__c = 'Ebloc2';
            insert postal1;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Country_Name__c = 'SINGAPORE'; 
            country.Code__c = 'SW46';
            country.Name = 'SINGAPORE';
            insert country;
                    
            City__c city = TestDataFactory.createCity(1)[0];
            city.Flight_Number_1__c = '1';
            city.Flight_Number_2__c ='2';
            database.insert(city);
            
            SPH_Section__c sectionCode = new SPH_Section__c();
            sectionCode.Name = 'Section';
            sectionCode.Section_Name__c = 'Test';
            database.insert(sectionCode);
            
            SPH_Department__c department = new SPH_Department__c();
            department.Name = 'Department';
            department.Department_Name__c = 'Dept';
            database.insert(department);
            
            SPH_Division__c divisionCode = new SPH_Division__c();
            divisionCode.Name = 'Division';
            divisionCode.Name = 'Test1';
            database.insert(divisionCode);
            
            SPH_Company__c companyCode = new SPH_Company__c();
            companyCode.Name = 'Company';
            database.insert(companyCode);
            
            SPH_Location__c locationCode = new SPH_Location__c();
            locationCode.Name = 'Location';
            database.insert(locationCode);
            
            RecordType recType2 = [Select Id, Name From RecordType WHERE sObjectType = 'Address__c' and Name = 'Local' LIMIT 1];
            
            Address__c address1 = TestDataFactory.createAddress(1)[0];
            address1.RecordtypeId = ConstantsSLB.getKeyId('Address_Local');
            address1.Postal_Code__c = postal1.Id;
            address1.Block_House_Number__c = '90';
            address1.Level_Number__c = '17';
            address1.Unit_Number__c = '23';
            address1.Packing_Code__c = packGroup .id;
            address1.City__c = city.id;
            address1.Address_1__c = 'IT square';
            address1.Country__c = country.id;
            address1.Section_Code__c = sectionCode.id;
            address1.Department__c = department.id;
            address1.Location_Code__c = locationCode.id;
            address1.Division_Code__c = divisionCode.id;
            address1.Company_Code__c = companyCode.id;
            address1.Address_2__c = 'Lahug';
            address1.Address_3__c = 'New York';
            address1.Address_4__c = 'Manhattan';
            insert address1;
            
   
            List<Contact> cont = TestDataFactory.createContact(1);
            cont[0].FirstName = 'Fname';
            cont[0].LastName = 'Lname';
            cont[0].Phone = '1234567';
            cont[0].Address__c = address1.Id;
            cont[0].HomePhone__c = '256235868';
            cont[0].Office_Number__c = '65892845';
            cont[0].Mobile_Number__c = '3698521475';
            insert cont;
                   
            List<Package__C> pack = TestDataFactory.createPackage(1);
            pack [0].Subscription_Period__c = '15'; 
            insert pack ;
            
                        
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc [0].Name = 'Zuora Customer Account';
            billAcc [0].Zuora__Account__c = acct.Id;
            billAcc [0].Billing_Contact__c = cont[0].Id;
            billAcc [0].Zuora__Credit_Balance__c = 1;
            billAcc [0].Refund_Amount__c = 100;
            billAcc [0].Zuora__AutoPay__c =false;
            billAcc [0].Zuora__Balance__c = 1;
            billAcc [0].Payment_Mode__c = 'PayPal';
            billAcc [0].Other_PaymentMethod__c= 'PayPal';
            billAcc [0].Zuora__PaymentMethodType__c = 'PayPal'; 
            billAcc [0].Zuora__External_Id__c = '22544AA';  
            billAcc [0].Zuora__Zuora_Id__c = '0124';  
            billAcc [0].Zuora__AccountNumber__c = 'ACC135243';
            insert billAcc ;
        
            //START : D-1929 3/2/2015 added to create Default Payment Method
            List<Zuora__PaymentMethod__c> paymentMethod = TestDataFactory.createPaymentMethod(1);
            paymentMethod [0].Name = 'Zuora Customer Account';
            paymentMethod [0].Zuora__Type__c = 'Electronic';
            paymentMethod [0].Zuora__BillingAccount__c = billAcc [0].id;
            paymentMethod [0].Zuora__PaypalEmail__c = 'april.grace@gmail.com';
            insert paymentMethod ;  
            //End: D-1929 3/2/2015 added to create Default Payment Method
        
            billAcc [0].Zuora__Default_Payment_Method__c = paymentMethod [0].id;         
            update billAcc ;
            
            //create billing account      
            List<Zuora__Subscription__c> zSub =  TestDataFactory.createSubscription(1);
            
                zSub[0].Subscriber_Contact__c = cont[0].id;
                zSub[0].Main_Package_1__c = pack[0].id;
                zSub[0].Main_Package__c = pack[0].id;
                zSub[0].Zuora__Account__c = acct.id;
                zSub[0].Order_Number__c = null;
                zSub[0].Zuora__CustomerAccount__c = billAcc[0].Id;
                zSub[0].Billing_Type__c = 'Full Prepaid';
                zSub[0].Legacy_Create_Date__c = 'a';
                zSub[0].Legacy_Create_By__c = 'a';
                zSub[0].Legacy_Update_By__c = 'a';
                zSub[0].Legacy_Subscription_ID__c = 'a';
                zSub[0].Legacy_Update_Date__c = 'a';
                zSub[0].Number_of_Copies__c = 100;
                zSub[0].Number_of_Copies1__c = '100';
                zSub[0].Zuora__Status__c = 'Active';
                zSub[0].Subscription_Type_1__c = 'Publication';
                zSub[0].Subscription_Type__c = 'Publication';
                //zSub[0].PublicationCode__c = 'Pub1';
                      
            insert zSub;

            
            Zuora__ZInvoice__c invRec = TestDataFactory.createInvoice(1)[0];
            invRec.Zuora__Account__c = acct.Id;
            invRec.Zuora__BillingAccount__c = billAcc[0].Id;
            invRec.Zuora__Zuora_Id__c = 'test123';
            insert invRec;
             
            Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
            invLineItem.Subscription__c = zSub[0].Id;
            invLineItem.Invoice_ID__c = invRec.Zuora__Zuora_Id__c;
            invLineItem.Charge_Amount__c = 10.00;
            insert invLineItem;
        
            List<Zuora__SubscriptionProductCharge__c> subProdAndCharge1 = TestDataFactory.createSubProductCharge(1);
            subProdAndCharge1[0].Zuora__Subscription__c = zSub[0].Id;
            subProdAndCharge1[0].PublicationCode__c = 'asas';
            insert subProdAndCharge1;
            
            billAcc[0].Zuora__Default_Payment_Method__c = paymentMethod[0].id;         
            update billAcc;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Test';
            pub.Publication_Code__c = 'asas';
            database.insert(pub);
            
            External_Payment__c externalPayment = TestDataFactory.createExternalPayment(1)[0];
            externalPayment.Name = 'External';
            externalPayment.Transaction_Amount__c = 15.00;
            externalPayment.Transaction_Date__c = date.today();
            externalPayment.Account_Name__c = acct.id;
            externalPayment.Transaction_Type__c = 'F';
            externalPayment.Billing_Account__c = billAcc[0].id ;
            externalPayment.Payment_Type__c = 'Paypal';
            database.insert(externalPayment);
            //START UD-2624 Gderosario
            System.debug('gio >> externalPayment'+ externalPayment);
            //List<External_Payment__c>
            Set<Id> exPaymentIds = new Set<Id>{};
            exPaymentIds.add(externalPayment.id);
            
            List<External_Payment__c> exPay = [SELECT Id, Name, Transaction_Amount__c, Transaction_Date__c, Account_Name__c, Transaction_Type__c, Billing_Account__c, Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__c,
            Billing_Account__r.Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c, Account_Name__r.AccountNumber, Billing_Account__r.Zuora__AccountNumber__c,Billing_Account__r.Billing_Contact__r.Address__r.RecordtypeID,
            Billing_Account__r.Billing_Contact__r.FirstName,Billing_Account__r.Billing_Contact__r.LastName,Billing_Account__r.Billing_Contact__r.Address__r.Block_House_Number__c,Billing_Account__r.Billing_Contact__r.Address__r.Street_Name__c,
            Billing_Account__r.Billing_Contact__r.Address__r.Level_Number__c,Billing_Account__r.Billing_Contact__r.Address__r.Unit_Number__c,Billing_Account__r.Billing_Contact__r.Address__r.Building_Name__c,Billing_Account__r.Billing_Contact__r.Address__r.Country__r.Country_Name__c,
            Billing_Account__r.Billing_Contact__r.Address__r.Postal_Code__r.Name  FROM External_Payment__c  WHERE id =: externalPayment.id];
           

            Set<Id> newExPaymentIds = new Set<Id>{};
            for(External_Payment__c exP : exPay){
                newExPaymentIds.add(exP.Id);
            }

            System.debug('gio >> exPay'+ exPay);

            Test.startTest(); 
            /*SP_SendEmailNotifForFailedPayPalBatch batch = new SP_SendEmailNotifForFailedPayPalBatch(newExPaymentIds);
            //SP_SendEmailNotifForFailedPayPalBatch batch2 = SP_SendEmailNotifForFailedPayPalBatch(exPaymentIds);
            Database.BatchableContext BC;
            ID batchprocessid = Database.executeBatch(batch, 200);
            batch.start(BC);
            batch.execute(BC, exPay);*/

            SP_SendEmailNotifForFailedPayPalBatch emailforPaypal = new SP_SendEmailNotifForFailedPayPalBatch(newExPaymentIds);
            Database.executeBatch(emailforPaypal);
            
            Test.stopTest();
            //END UD-2624 Gderosario


    
     }
 
}