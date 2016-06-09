/**
 * Class Name: SP_DeliveryChargesBatch_SelectAccsTest
 * @author: Christian Coquilla
 * Date: 4/13/2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test Class for SP_DeliveryChargesBatch_SelectAccs
 */
 
 @isTest(seeAllData = True)
public class SP_DeliveryChargesBatch_SelectAccsTest {
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    static testmethod void test01(){
    
     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     insert acc;
     
     set<String> AccntSet = new set<string>();
     AccntSet.add('acc.Id');
     
     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
     billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
     billAcc.Zuora__Account__c = acc.Id;
     billAcc.Zuora__AccountNumber__c = '123';
     database.insert(billAcc);
    
     Address__c address = TestDataFactory.createAddress(1)[0];
     database.insert(address);
    
     Contact con = TestDataFactory.createContact(1)[0];
     con.AccountId = acc.id;
     con.Address__c = address.Id;
     //con.Billing_Indicator__c = True;
     con.Recipient_Indicator__c = true;
     database.insert(con);
 
     Package__c pack = TestDataFactory.createPackage(1)[0];
     database.insert(pack);
    
     Order__c orderRec = TestDataFactory.createOrder(1)[0];
     orderRec.Account__c = acc.Id;
     orderRec.Informed_Customer__c = TRUE;
     orderRec.Recipient_Contact__c = con.Id;
     database.insert(orderRec);
    
    /*Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
    cas.Order__c = orderRec.Id;
    database.insert(cas);*/
    
     List<Temp_Stop__c> temp = TestDataFactory.createTempStop(1);
     temp[0].Restart_Date__c = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
     temp[0].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
     temp[0].Qty__c = 3;
     temp[0].Cancelled__c  = false;
    
     /*temp[1].Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31);
     temp[1].Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 1, 1);
     temp[1].Qty__c = 3;
     temp[1].Cancelled__c  = false;*/
     database.insert(temp);
    
     system.assertEquals(null, temp[0].Temp_Stop_Status__c);

     zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
     zProduct.ProductSubType__c = 'Newspaper';
     zProduct.ProductPlatform__c = 'Print';
     database.insert(zProduct);
        
     zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
     prdRatePlan.zqu__ZProduct__c = zProduct.Id;
     database.insert(prdRatePlan);
        
     zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
     prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
     database.insert(prpc);
        
     List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
     for (Package_Item__c pItem : pItems) {
     pItem.Package__c = pack.Id;
     pItem.Product_Rate_Plan__c = prdRatePlan.Id;
     }
     database.insert(pItems);     
     
     List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
     subRecs[0].Zuora__Account__c = acc.Id;
     subRecs[0].Name = 'TestName';
     subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
     subRecs[0].Order_Number_1__c = orderRec.Id;
     subRecs[0].Order_Number__c = orderRec.Id;
     subRecs[0].Term_Length__c = 0;
     subRecs[0].Term_Length1__c = '0';
     subRecs[0].Main_Package_1__c = pack.id;
     subRecs[0].Main_Package__c = pack.Id;
     subRecs[0].Zuora__SubscriptionStartDate__c = Date.Today();
     subRecs[0].Zuora__SubscriptionEndDate__c = date.Today()+1;
     subRecs[0].Recipient_Contact__c = con.Id;
     subRecs[0].Recipient_Contact_1__c = con.Id;
     subRecs[0].Zuora__Status__c = 'Active';
     subRecs[0].Frequency_1__c = 'Default';
     subRecs[0].Frequency__c = 'Default';
     subRecs[0].Subscription_Type_1__c = 'Publication';
     subRecs[0].Subscription_Type__c = 'Publication';
     
     subRecs[1].Zuora__Account__c = acc.Id;
     subRecs[1].Name = 'TestName';
     subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
     subRecs[1].Order_Number_1__c = orderRec.Id;
     subRecs[1].Order_Number__c = orderRec.Id;
     subRecs[1].Term_Length__c = 0;
     subRecs[1].Term_Length1__c = '0';
     subRecs[1].Main_Package_1__c = pack.id;
     subRecs[1].Main_Package__c = pack.Id;
     subRecs[1].Zuora__SubscriptionStartDate__c = Date.Today();
     subRecs[1].Zuora__SubscriptionEndDate__c = date.Today()+1;
     subRecs[1].Recipient_Contact__c = con.Id;
     subRecs[1].Recipient_Contact_1__c = con.Id;
     subRecs[1].Zuora__Status__c = 'Active';
     subRecs[1].Frequency_1__c = 'Default';
     subRecs[1].Frequency__c = 'Default';
     subRecs[1].Subscription_Type_1__c = 'Delivery';
     subRecs[1].Subscription_Type__c = 'Delivery';
     database.insert(subRecs);
     
     List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 
     Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
     subTemp.Temp_Stop__c = temp[0].Id;
     subTemp.Subscription__c = subRecs[0].Id;
     database.insert(subTemp);
     
    Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
    subTemp2.Temp_Stop__c = temp[0].Id;
    subTemp2.Subscription__c = subRecs[1].Id;
    database.insert(subTemp2);
    
    subtempstopList.add(subTemp);
    subtempstopList.add(subTemp2);    
     
      list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Subscription__c, Subscription__r.Recipient_Contact__r.Address__c,
      Subscription__r.Zuora__CustomerAccount__c, Subscription__r.Subscription_Type_1__c, Temp_Stop__c, Temp_Stop__r.Restart_Date__c,
      Subscription__r.Recipient_Contact_1__c, Subscription__r.Recipient_Contact__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Status__c 
      FROM Subscription_Temp_Stop__c WHERE Id =: subTemp.Id]; 
      
      list<Subscription_Temp_Stop__c> listtemp2 = [SELECT Id, Subscription__c, Subscription__r.Recipient_Contact__r.Address__c,
      Subscription__r.Zuora__CustomerAccount__c, Subscription__r.Subscription_Type_1__c, Temp_Stop__c, Temp_Stop__r.Restart_Date__c,
      Subscription__r.Recipient_Contact_1__c, Subscription__r.Recipient_Contact__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Status__c 
      FROM Subscription_Temp_Stop__c WHERE Id =: subTemp2.Id];  
    
    Test.startTest();
            Database.BatchableContext bc;            
            SP_DeliveryChargesBatch_SelectAccs batch = new SP_DeliveryChargesBatch_SelectAccs(AccntSet);
            //String batchId = Database.executeBatch(batch);
            id batchID = database.executeBatch(batch, 200);
            batch.execute(bc, listtemp);
            batch.execute(bc, listtemp2);
            batch.createUsage(1, subRecs[0]);
            //String schedBatchId = System.scheduleBatch(delCharge, 'testJob', 1);
            //Database.BatchableContext BC;
            //delCharge.finish(BC);
            
            /*BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchId;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;*/
            Test.stopTest();
   
    }
    static testmethod void test02(){
    
     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     insert acc;
     
     set<String> AccntSet = new set<string>();
     AccntSet.add('acc.Id');
     
     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
     billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
     billAcc.Zuora__Account__c = acc.Id;
     billAcc.Zuora__AccountNumber__c = '123';
     database.insert(billAcc);
    
     Address__c address = TestDataFactory.createAddress(1)[0];
     database.insert(address);
    
     Contact con = TestDataFactory.createContact(1)[0];
     con.AccountId = acc.id;
     con.Address__c = address.Id;
     //con.Billing_Indicator__c = True;
     con.Recipient_Indicator__c = true;
     database.insert(con);
     
     Contact con1 = TestDataFactory.createContact(1)[0];
     con1.AccountId = acc.id;
     con1.Address__c = address.Id;
     //con.Billing_Indicator__c = True;
     con1.Recipient_Indicator__c = true;
     database.insert(con1);     
     
     
            
    
     Package__c pack = TestDataFactory.createPackage(1)[0];
     database.insert(pack);
    
     Order__c orderRec = TestDataFactory.createOrder(1)[0];
     orderRec.Account__c = acc.Id;
     orderRec.Informed_Customer__c = TRUE;
     orderRec.Recipient_Contact__c = con.Id;
     database.insert(orderRec);
    
    /*Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
    cas.Order__c = orderRec.Id;
    database.insert(cas);*/
    
     List<Temp_Stop__c> temp = TestDataFactory.createTempStop(1);
     temp[0].Restart_Date__c = referenceDate.addMonths(3).toStartofMonth().addDays(-1);
     temp[0].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
     temp[0].Qty__c = 3;
     temp[0].Cancelled__c  = false;
    
     /*temp[1].Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31);
     temp[1].Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 1, 1);
     temp[1].Qty__c = 3;
     temp[1].Cancelled__c  = false;*/
     database.insert(temp);
    
     system.assertEquals(null, temp[0].Temp_Stop_Status__c);

     zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
     zProduct.ProductSubType__c = 'Newspaper';
     zProduct.ProductPlatform__c = 'Print';
     database.insert(zProduct);
        
     zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
     prdRatePlan.zqu__ZProduct__c = zProduct.Id;
     database.insert(prdRatePlan);
        
     zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
     prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
     database.insert(prpc);
        
     List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
     for (Package_Item__c pItem : pItems) {
     pItem.Package__c = pack.Id;
     pItem.Product_Rate_Plan__c = prdRatePlan.Id;
     }
     database.insert(pItems);     
     
     List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
     subRecs[0].Zuora__Account__c = acc.Id;
     subRecs[0].Name = 'TestName';
     subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
     subRecs[0].Order_Number_1__c = orderRec.Id;
     subRecs[0].Order_Number__c = orderRec.Id;
     subRecs[0].Term_Length__c = 0;
     subRecs[0].Term_Length1__c = '0';
     subRecs[0].Main_Package_1__c = pack.id;
     subRecs[0].Main_Package__c = pack.Id;
     subRecs[0].Zuora__SubscriptionStartDate__c = Date.Today();
     subRecs[0].Zuora__SubscriptionEndDate__c = date.Today()+1;
     subRecs[0].Recipient_Contact__c = con.Id;
     subRecs[0].Recipient_Contact_1__c = con.Id;
     subRecs[0].Zuora__Status__c = 'Active';
     subRecs[0].Frequency_1__c = 'Default';
     subRecs[0].Frequency__c = 'Default';
     subRecs[0].Subscription_Type_1__c = 'Publication';
     subRecs[0].Subscription_Type__c = 'Publication';
     
     subRecs[1].Zuora__Account__c = acc.Id;
     subRecs[1].Name = 'TestName';
     subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
     subRecs[1].Order_Number_1__c = orderRec.Id;
     subRecs[1].Order_Number__c = orderRec.Id;
     subRecs[1].Term_Length__c = 0;
     subRecs[1].Term_Length1__c = '0';
     subRecs[1].Main_Package_1__c = pack.id;
     subRecs[1].Main_Package__c = pack.Id;
     subRecs[1].Zuora__SubscriptionStartDate__c = Date.Today();
     subRecs[1].Zuora__SubscriptionEndDate__c = date.Today()+1;
     subRecs[1].Recipient_Contact__c = con1.Id;
     subRecs[1].Recipient_Contact_1__c = con1.Id;
     subRecs[1].Zuora__Status__c = 'Active';
     subRecs[1].Frequency_1__c = 'Default';
     subRecs[1].Frequency__c = 'Default';
     subRecs[1].Subscription_Type_1__c = 'Delivery';
     subRecs[1].Subscription_Type__c = 'Delivery';
     database.insert(subRecs);
     
     List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 
     Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
     subTemp.Temp_Stop__c = temp[0].Id;
     subTemp.Subscription__c = subRecs[0].Id;
     database.insert(subTemp);
     
    Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
    subTemp2.Temp_Stop__c = temp[0].Id;
    subTemp2.Subscription__c = subRecs[1].Id;
    database.insert(subTemp2);
    
    subtempstopList.add(subTemp);
    subtempstopList.add(subTemp2);    
     
      list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Subscription__c, Subscription__r.Recipient_Contact__r.Address__c,
      Subscription__r.Zuora__CustomerAccount__c, Subscription__r.Subscription_Type_1__c, Temp_Stop__c, Temp_Stop__r.Restart_Date__c,
      Subscription__r.Recipient_Contact_1__c, Subscription__r.Recipient_Contact__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Status__c 
      FROM Subscription_Temp_Stop__c WHERE Id =: subTemp.Id]; 
      
      list<Subscription_Temp_Stop__c> listtemp2 = [SELECT Id, Subscription__c, Subscription__r.Recipient_Contact__r.Address__c,
      Subscription__r.Zuora__CustomerAccount__c, Subscription__r.Subscription_Type_1__c, Temp_Stop__c, Temp_Stop__r.Restart_Date__c,
      Subscription__r.Recipient_Contact_1__c, Subscription__r.Recipient_Contact__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Status__c 
      FROM Subscription_Temp_Stop__c WHERE Id =: subTemp2.Id];  
    
    Test.startTest();
            Database.BatchableContext bc;            
            SP_DeliveryChargesBatch_SelectAccs batch = new SP_DeliveryChargesBatch_SelectAccs(AccntSet);
            //String batchId = Database.executeBatch(batch);
            id batchID = database.executeBatch(batch, 200);
            batch.execute(bc, listtemp);
            //batch.execute(bc, listtemp2);
            batch.createUsage(1, subRecs[0]);
            //String schedBatchId = System.scheduleBatch(delCharge, 'testJob', 1);
            //Database.BatchableContext BC;
            //delCharge.finish(BC);
            
            /*BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchId;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;*/
            Test.stopTest();
   
    }
    
    static testmethod void test03(){
    
     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     insert acc;
     
     set<String> AccntSet = new set<string>();
     AccntSet.add('acc.Id');
     
     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
     billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
     billAcc.Zuora__Account__c = acc.Id;
     billAcc.Zuora__AccountNumber__c = '123';
     database.insert(billAcc);
    
     Address__c address = TestDataFactory.createAddress(1)[0];
     database.insert(address);
    
     Contact con = TestDataFactory.createContact(1)[0];
     con.AccountId = acc.id;
     con.Address__c = address.Id;
     //con.Billing_Indicator__c = True;
     con.Recipient_Indicator__c = true;
     database.insert(con);
     
     Contact con1 = TestDataFactory.createContact(1)[0];
     con1.AccountId = acc.id;
     con1.Address__c = address.Id;
     //con.Billing_Indicator__c = True;
     con1.Recipient_Indicator__c = true;
     database.insert(con1);     
     
     
            
    
     Package__c pack = TestDataFactory.createPackage(1)[0];
     database.insert(pack);
    
     Order__c orderRec = TestDataFactory.createOrder(1)[0];
     orderRec.Account__c = acc.Id;
     orderRec.Informed_Customer__c = TRUE;
     orderRec.Recipient_Contact__c = con.Id;
     database.insert(orderRec);
    
    /*Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
    cas.Order__c = orderRec.Id;
    database.insert(cas);*/
    
     List<Temp_Stop__c> temp = TestDataFactory.createTempStop(1);
     temp[0].Restart_Date__c = referenceDate.addMonths(2).toStartofMonth().addDays(-1);
     temp[0].Temp_Stop_Date__c = referenceDate.toStartOfMonth();
     temp[0].Qty__c = 3;
     temp[0].Cancelled__c  = false;
    
     /*temp[1].Restart_Date__c = date.newInstance(referenceDate.year(), 12, 31);
     temp[1].Temp_Stop_Date__c = date.newInstance(referenceDate.year()-1, 1, 1);
     temp[1].Qty__c = 3;
     temp[1].Cancelled__c  = false;*/
     database.insert(temp);
    
     system.assertEquals(null, temp[0].Temp_Stop_Status__c);

     zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
     zProduct.ProductSubType__c = 'Newspaper';
     zProduct.ProductPlatform__c = 'Print';
     database.insert(zProduct);
        
     zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
     prdRatePlan.zqu__ZProduct__c = zProduct.Id;
     database.insert(prdRatePlan);
        
     zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
     prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
     database.insert(prpc);
        
     List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
     for (Package_Item__c pItem : pItems) {
     pItem.Package__c = pack.Id;
     pItem.Product_Rate_Plan__c = prdRatePlan.Id;
     }
     database.insert(pItems);     
     
     List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
     subRecs[0].Zuora__Account__c = acc.Id;
     subRecs[0].Name = 'TestName';
     subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
     subRecs[0].Order_Number_1__c = orderRec.Id;
     subRecs[0].Order_Number__c = orderRec.Id;
     subRecs[0].Term_Length__c = 0;
     subRecs[0].Term_Length1__c = '0';
     subRecs[0].Main_Package_1__c = pack.id;
     subRecs[0].Main_Package__c = pack.Id;
     subRecs[0].Zuora__SubscriptionStartDate__c = Date.Today();
     subRecs[0].Zuora__SubscriptionEndDate__c = date.Today()+1;
     subRecs[0].Recipient_Contact__c = con.Id;
     subRecs[0].Recipient_Contact_1__c = con.Id;
     subRecs[0].Zuora__Status__c = 'Active';
     subRecs[0].Frequency_1__c = 'Default';
     subRecs[0].Frequency__c = 'Default';
     subRecs[0].Subscription_Type_1__c = 'Publication';
     subRecs[0].Subscription_Type__c = 'Publication';
     
     subRecs[1].Zuora__Account__c = acc.Id;
     subRecs[1].Name = 'TestName';
     subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
     subRecs[1].Order_Number_1__c = orderRec.Id;
     subRecs[1].Order_Number__c = orderRec.Id;
     subRecs[1].Term_Length__c = 0;
     subRecs[1].Term_Length1__c = '0';
     subRecs[1].Main_Package_1__c = pack.id;
     subRecs[1].Main_Package__c = pack.Id;
     subRecs[1].Zuora__SubscriptionStartDate__c = Date.Today();
     subRecs[1].Zuora__SubscriptionEndDate__c = date.Today()+1;
     subRecs[1].Recipient_Contact__c = con1.Id;
     subRecs[1].Recipient_Contact_1__c = con1.Id;
     subRecs[1].Zuora__Status__c = 'Active';
     subRecs[1].Frequency_1__c = 'Default';
     subRecs[1].Frequency__c = 'Default';
     subRecs[1].Subscription_Type_1__c = 'Delivery';
     subRecs[1].Subscription_Type__c = 'Delivery';
     database.insert(subRecs);
     
     List<Subscription_Temp_Stop__c> subtempstopList = new List<Subscription_Temp_Stop__c>(); 
     Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
     subTemp.Temp_Stop__c = temp[0].Id;
     subTemp.Subscription__c = subRecs[0].Id;
     database.insert(subTemp);
     
    Subscription_Temp_Stop__c subTemp2 = new Subscription_Temp_Stop__c();
    subTemp2.Temp_Stop__c = temp[0].Id;
    subTemp2.Subscription__c = subRecs[1].Id;
    database.insert(subTemp2);
    
    subtempstopList.add(subTemp);
    subtempstopList.add(subTemp2);    
     
      list<Subscription_Temp_Stop__c> listtemp = [SELECT Id, Subscription__c, Subscription__r.Recipient_Contact__r.Address__c,
      Subscription__r.Zuora__CustomerAccount__c, Subscription__r.Subscription_Type_1__c, Temp_Stop__c, Temp_Stop__r.Restart_Date__c,
      Subscription__r.Recipient_Contact_1__c, Subscription__r.Recipient_Contact__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Status__c 
      FROM Subscription_Temp_Stop__c WHERE Id =: subTemp.Id]; 
      
      list<Subscription_Temp_Stop__c> listtemp2 = [SELECT Id, Subscription__c, Subscription__r.Recipient_Contact__r.Address__c,
      Subscription__r.Zuora__CustomerAccount__c, Subscription__r.Subscription_Type_1__c, Temp_Stop__c, Temp_Stop__r.Restart_Date__c,
      Subscription__r.Recipient_Contact_1__c, Subscription__r.Recipient_Contact__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Status__c 
      FROM Subscription_Temp_Stop__c WHERE Id =: subTemp2.Id];  
    
    Test.startTest();
            Database.BatchableContext bc;            
            SP_DeliveryChargesBatch_SelectAccs batch = new SP_DeliveryChargesBatch_SelectAccs(AccntSet);
            //String batchId = Database.executeBatch(batch);
            id batchID = database.executeBatch(batch, 200);
            batch.execute(bc, listtemp);
            //batch.execute(bc, listtemp2);
            batch.createUsage(1, subRecs[0]);
            //String schedBatchId = System.scheduleBatch(delCharge, 'testJob', 1);
            //Database.BatchableContext BC;
            //delCharge.finish(BC);
            
            /*BATCH_JOB_SCHEDULER__c batchJobSched = new BATCH_JOB_SCHEDULER__c();
            batchJobSched.SFDC_Job_id__c = batchId;
            batchJobSched.Batch_Run_Date__c = System.today();
            insert batchJobSched;*/
            Test.stopTest();
   
    }
    
    
  }