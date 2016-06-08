@isTest
public class BatchCOADeliveryChargeTest{
            static testMethod void testBatchCOADeliveryCharge(){
                        Delivery_Charge_Type__c adType = new Delivery_Charge_Type__c();
                        adType.Name = 'P';
                        adType.Default_Delivery_Charge_Type__c = 'C';
                        database.insert(adType);
                        
                        List<Other__c> otherList = new List<Other__c>{
                            new Other__c(Name='DTL', Value__c='23:59'),
                            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge'),
                            new Other__c(Name='HDB DELIVERY CHARGE', Value__c='HDB Delivery Charge'),
                            new Other__c(Name='APT DELIVERY CHARGE', Value__c='Apt Delivery Charge')
                        };
                        database.insert(otherList);
                        
                        Map<ID, Set<String>> mapNewContactToSub = new Map<ID, Set<String>>();
                        Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Building_Name__c = 'Ebloc2';
                        insert postal;
                        
                        Country__c country = TestDataFactory.createCountry(1)[0]; 
                        country.Country_Name__c = 'SINGAPORE'; 
                        insert country;
                        
                        Address__c ad = TestDataFactory.createAddress(1)[0];
                        ad.Address_Type__c = 'P';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad);
                        
                        List<Contact> cons = TestDataFactory.createContact(3);
                        for(Contact con : cons){
                            con.Address__c =  ad.Id;
                        }
                        database.insert(cons);
                        
                        for(Contact con: cons){
                            mapNewContactToSub.put(con.Id, new Set<String>{ad.Id});
                            mapDelZuoraIdToOldAddressId.put(con.Address__c, ad.Id);
                        }
                        
                        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                        billAcc.Zuora__Account__c = acc.Id;
                        database.insert(billAcc);
                        
                        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                        sub.Zuora__Zuora_Id__c = ad.Id;
                        sub.Zuora__Status__c = 'Active';
                        sub.Subscription_Type__c = 'Delivery';
                        sub.Billing_Type__c = 'Recurring Prepaid';
                        sub.Zuora__CustomerAccount__c = billAcc.Id;
                        sub.Delivery_Charge_Type__c = 'N';
                        database.insert(sub);
                        
                        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
                        zp.ProductCode__c = 'DELCHG';
                        database.insert(zp);
                        
                        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
                        prp.zqu__ZProduct__c = zp.Id;
                        prp.zqu__Deleted__c = false;
                        prp.Name = 'Apt Delivery Charge';
                        database.insert(prp);
                        
                        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
                        job.Batch_Run_Date__c = date.today()+5;
                        database.insert(job);
                        
                        test.startTest();
                            BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId, job.Id);
                            Id batchId = database.executeBatch(batch, 200);
                            system.assert(batchId <> null);
                        test.stopTest();
            }
            
            static testMethod void testBatchCOADeliveryCharge2(){
                        Delivery_Charge_Type__c adType = new Delivery_Charge_Type__c();
                        adType.Name = 'H';
                        adType.Default_Delivery_Charge_Type__c = 'H';
                        database.insert(adType);
                        
                        List<Other__c> otherList = new List<Other__c>{
                            new Other__c(Name='DTL', Value__c='23:59'),
                            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge'),
                            new Other__c(Name='HDB DELIVERY CHARGE', Value__c='HDB Delivery Charge'),
                            new Other__c(Name='APT DELIVERY CHARGE', Value__c='Apt Delivery Charge')
                        };
                        database.insert(otherList);
                        
                        Map<ID, Set<String>> mapNewContactToSub = new Map<ID, Set<String>>();
                        Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Building_Name__c = 'Ebloc2';
                        insert postal;
                        
                        Country__c country = TestDataFactory.createCountry(1)[0]; 
                        country.Country_Name__c = 'SINGAPORE'; 
                        insert country;
                        
                        Address__c ad = TestDataFactory.createAddress(1)[0];
                        ad.Address_Type__c = 'H';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad);
                        
                        Address__c ad2 = TestDataFactory.createAddress(1)[0];
                        ad2.Address_Type__c = 'P';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad2);
                        
                        List<Contact> cons = TestDataFactory.createContact(3);
                        for(Contact con : cons){
                            con.Address__c =  ad2.Id;
                        }
                        database.insert(cons);
                        
                        cons[1].Address__c = ad.Id;
                        database.update(cons);
                        
                        for(Contact con: cons){
                            mapNewContactToSub.put(con.Id, new Set<String>{ad.Id});
                            mapDelZuoraIdToOldAddressId.put(con.Address__c, ad.Id);
                        }
                        
                        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                        billAcc.Zuora__Account__c = acc.Id;
                        database.insert(billAcc);
                        
                        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                        sub.Zuora__Zuora_Id__c = ad.Id;
                        sub.Zuora__Status__c = 'Active';
                        sub.Subscription_Type__c = 'Delivery';
                        sub.Billing_Type__c = 'Recurring Prepaid';
                        sub.Zuora__CustomerAccount__c = billAcc.Id;
                        sub.Delivery_Charge_Type__c = 'P';
                        database.insert(sub);
                        
                        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
                        zp.ProductCode__c = 'DELCHG';
                        database.insert(zp);
                        
                        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
                        prp.zqu__ZProduct__c = zp.Id;
                        prp.zqu__Deleted__c = false;
                        prp.Name = 'HDB Delivery Charge';
                        database.insert(prp);
                        
                        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
                        job.Batch_Run_Date__c = date.today()+5;
                        database.insert(job);
                        
                        test.startTest();
                            BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId, job.Id);
                            Id batchId = database.executeBatch(batch, 200);
                            system.assert(batchId <> null);
                        test.stopTest();
            }
            
            static testMethod void testBatchCOADeliveryCharge3(){
                        Delivery_Charge_Type__c adType = new Delivery_Charge_Type__c();
                        adType.Name = 'L';
                        adType.Default_Delivery_Charge_Type__c = 'L';
                        database.insert(adType);
                        
                        List<Other__c> otherList = new List<Other__c>{
                            new Other__c(Name='DTL', Value__c='23:59'),
                            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge'),
                            new Other__c(Name='HDB DELIVERY CHARGE', Value__c='HDB Delivery Charge'),
                            new Other__c(Name='APT DELIVERY CHARGE', Value__c='Apt Delivery Charge')
                        };
                        database.insert(otherList);
                        
                        Map<ID, Set<String>> mapNewContactToSub = new Map<ID, Set<String>>();
                        Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Building_Name__c = 'Ebloc2';
                        insert postal;
                        
                        Country__c country = TestDataFactory.createCountry(1)[0]; 
                        country.Country_Name__c = 'SINGAPORE'; 
                        insert country;
                        
                        Address__c ad = TestDataFactory.createAddress(1)[0];
                        ad.Address_Type__c = 'L';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad);
                        
                        Address__c ad2 = TestDataFactory.createAddress(1)[0];
                        ad2.Address_Type__c = 'P';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad2);
                        
                        List<Contact> cons = TestDataFactory.createContact(3);
                        for(Contact con : cons){
                            con.Address__c =  ad2.Id;
                        }
                        database.insert(cons);
                        
                        cons[1].Address__c = ad.Id;
                        database.update(cons);
                        
                        for(Contact con: cons){
                            mapNewContactToSub.put(con.Id, new Set<String>{ad.Id});
                            mapDelZuoraIdToOldAddressId.put(con.Address__c, ad.Id);
                        }
                        
                        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                        billAcc.Zuora__Account__c = acc.Id;
                        database.insert(billAcc);
                        
                        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                        sub.Zuora__Zuora_Id__c = ad.Id;
                        sub.Zuora__Status__c = 'Active';
                        sub.Subscription_Type__c = 'Delivery';
                        sub.Billing_Type__c = 'Recurring Prepaid';
                        sub.Zuora__CustomerAccount__c = billAcc.Id;
                        sub.Delivery_Charge_Type__c = 'P';
                        database.insert(sub);
                        
                        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
                        zp.ProductCode__c = 'DELCHG';
                        database.insert(zp);
                        
                        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
                        prp.zqu__ZProduct__c = zp.Id;
                        prp.zqu__Deleted__c = false;
                        prp.Name = 'Landed Delivery Charge';
                        database.insert(prp);
                        
                        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
                        job.Batch_Run_Date__c = date.today()+5;
                        database.insert(job);
                        
                        test.startTest();
                            BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId, job.Id);
                            Id batchId = database.executeBatch(batch, 200);
                            system.assert(batchId <> null);
                        test.stopTest();
            }
            
            static testMethod void testBatchCOADeliveryCharge4(){
                        Delivery_Charge_Type__c adType = new Delivery_Charge_Type__c();
                        adType.Name = 'H';
                        adType.Default_Delivery_Charge_Type__c = 'H';
                        database.insert(adType);
                        
                        List<Other__c> otherList = new List<Other__c>{
                            new Other__c(Name='DTL', Value__c='23:59'),
                            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge'),
                            new Other__c(Name='HDB DELIVERY CHARGE', Value__c='HDB Delivery Charge'),
                            new Other__c(Name='APT DELIVERY CHARGE', Value__c='Apt Delivery Charge')
                        };
                        database.insert(otherList);
                        
                        Map<ID, Set<String>> mapNewContactToSub = new Map<ID, Set<String>>();
                        Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Building_Name__c = 'Ebloc2';
                        insert postal;
                        
                        Country__c country = TestDataFactory.createCountry(1)[0]; 
                        country.Country_Name__c = 'SINGAPORE'; 
                        insert country;
                        
                        Address__c ad = TestDataFactory.createAddress(1)[0];
                        ad.Address_Type__c = 'H';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad);
                        
                        Address__c ad2 = TestDataFactory.createAddress(1)[0];
                        ad2.Address_Type__c = 'P';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad2);
                        
                        List<Contact> cons = TestDataFactory.createContact(3);
                        for(Contact con : cons){
                            con.Address__c =  ad2.Id;
                        }
                        database.insert(cons);
                        
                        cons[1].Address__c = ad.Id;
                        database.update(cons);
                        
                        for(Contact con: cons){
                            mapNewContactToSub.put(con.Id, new Set<String>{ad.Id});
                            mapDelZuoraIdToOldAddressId.put(con.Address__c, ad.Id);
                        }
                        
                        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                        billAcc.Zuora__Account__c = acc.Id;
                        database.insert(billAcc);
                        
                        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                        sub.Zuora__Zuora_Id__c = ad.Id;
                        sub.Zuora__Status__c = 'Active';
                        sub.Subscription_Type__c = 'Delivery';
                        sub.Billing_Type__c = 'Recurring Prepaid';
                        sub.Zuora__CustomerAccount__c = billAcc.Id;
                        sub.Delivery_Charge_Type__c = 'P';
                        database.insert(sub);
                        
                        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
                        zp.ProductCode__c = 'DELCHG';
                        database.insert(zp);
                        
                        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
                        prp.zqu__ZProduct__c = zp.Id;
                        prp.zqu__Deleted__c = false;
                        prp.Name = 'Landed Delivery Charge';
                        database.insert(prp);
                        
                        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
                        job.Batch_Run_Date__c = date.today()+5;
                        database.insert(job);
                        
                        test.startTest();
                            BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId);
                        test.stopTest();
            }
            static testMethod void testBatchCOADeliveryCharge5(){
                        Delivery_Charge_Type__c adType = new Delivery_Charge_Type__c();
                        adType.Name = 'H';
                        adType.Default_Delivery_Charge_Type__c = 'H';
                        database.insert(adType);
                        
                        List<Other__c> otherList = new List<Other__c>{
                            new Other__c(Name='DTL', Value__c='23:59'),
                            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge'),
                            new Other__c(Name='HDB DELIVERY CHARGE', Value__c='HDB Delivery Charge'),
                            new Other__c(Name='APT DELIVERY CHARGE', Value__c='Apt Delivery Charge')
                        };
                        database.insert(otherList);
                        
                        Map<ID, Set<String>> mapNewContactToSub = new Map<ID, Set<String>>();
                        Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Building_Name__c = 'Ebloc2';
                        insert postal;
                        
                        Country__c country = TestDataFactory.createCountry(1)[0]; 
                        country.Country_Name__c = 'SINGAPORE'; 
                        insert country;
                        
                        Address__c ad = TestDataFactory.createAddress(1)[0];
                        ad.Address_Type__c = 'H';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad);
                        
                        Address__c ad2 = TestDataFactory.createAddress(1)[0];
                        ad2.Address_Type__c = 'P';
                        ad.Postal_Code__c = postal.id;
                        ad.Country__c = country.id;
                        database.insert(ad2);
                        
                      /*  List<Contact> cons = TestDataFactory.createContact(3);
                        for(Contact con : cons){
                            con.Address__c =  ad2.Id;
                        }
                        database.insert(cons);
                        
                        cons[1].Address__c = ad.Id;
                        database.update(cons);
                        */
                        
                       /* Contact con = new Contact();
                        con.Address__C = ad.id;
                        con.Office_Number__c = '5685689';
                        con.LastName = 'Lastname';
                        database.insert(con);*/
                        
                        List<Contact> con2 = TestDataFactory.createContactRecType(2, 'Customer Contact');
                        con2[0].Address__c = ad2.id;
                        con2[0].Office_Number__c = '5685689';
                        
                        con2[1].Address__c = ad.id;
                        con2[1].Office_Number__c = '5685689';
                        database.insert(con2);
                        
                        
                      //  for(Contact con: cons){
                            mapNewContactToSub.put(con2[1].Id, new Set<String>{ad.Id});
                            mapDelZuoraIdToOldAddressId.put(con2[0].Address__c, ad2.Id);
                     //   }
                        
                        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                        billAcc.Zuora__Account__c = acc.Id;
                        database.insert(billAcc);
                        
                        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                        sub.Zuora__Zuora_Id__c = ad.Id;
                        sub.Zuora__Status__c = 'Active';
                        sub.Subscription_Type__c = 'Delivery';
                        sub.Billing_Type__c = 'Recurring Prepaid';
                        sub.Zuora__CustomerAccount__c = billAcc.Id;
                        sub.Delivery_Charge_Type_1__c = 'H';
                        sub.Delivery_Charge_Type__c = 'H';
                        database.insert(sub);
                        
                        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
                        zp.ProductCode__c = 'DELCHG';
                        database.insert(zp);
                        
                        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
                        prp.zqu__ZProduct__c = zp.Id;
                        prp.zqu__Deleted__c = false;
                        prp.Name = 'Landed Delivery Charge';
                        database.insert(prp);
                        
                        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
                        job.Batch_Run_Date__c = date.today()+5;
                        database.insert(job);
                        
                        test.startTest();
                            BatchCOADeliveryCharge batch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId);
                        test.stopTest();
            }
}