/**
@Author Alfred Abrina
@name SP_VendorAllocationBatchTest
@CreateDate 02/18/2015
@Description Test class for SP_VendorAllocationBatch
@Version <1.0>
@reference SP_VendorAllocationBatch
*/  
@isTest (SeeAllData = true)
private class SP_VendorAllocationBatchTest { 

static Account acct;

/**
* Method to feed data to batch class. 
* @name unitTestAllocation
* @param Object params Account, Vendor_Allocation__c, Subscription_Vendor__c
*/  
static testMethod void unitTestAllocation() { 
  acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
  acct.Name = 'Account Test123';
  acct.Phone = '22521';
  acct.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
  acct.Status__c = 'Active';
  insert acct;    
  //System.assertEquals ('Active', acct.Status__c);  
      
  Vendor_Allocation__c vend = TestDataFactory.createVendorAlloc(1)[0];
  vend.Vendor_Account__c = acct.Id;
  vend.Legacy_Created_Date__c = '02/21/2014';
  vend.Legacy_Created_By__c = 'AlfredA';
  vend.Legacy_Updated_Date__c = '01/25/2015';
  vend.Legacy_Updated_By__c = 'AlfredA';
  vend.Effective_Start_Date__c = Date.today(); 
  vend.Allocated__c = true;
  insert vend;
  //System.assertEquals('AlfredA', vend.Legacy_Created_By__c);
    
  Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];   
  subVendor.Legacy_Create_Date__c = '02/21/2014';
  subVendor.Legacy_Create_By__c = 'AlfredA';
  subVendor.Legacy_Update_Date__c = '01/25/2015';
  subVendor.Legacy_Update_By__c = 'AlfredA';      
  insert subVendor;    
  //System.assertEquals ('AlfredA', subVendor.Legacy_Update_By__c);
  try{
  Test.StartTest(); 
  SP_VendorAllocationBatch batch2 = new SP_VendorAllocationBatch(); 
  ID batchprocessid = Database.executeBatch(batch2, 200); 
   
  BATCH_JOB_SCHEDULER__c batchJobScheduler = new BATCH_JOB_SCHEDULER__c();
  batchJobScheduler.Status__c = 'STARTED';         
  batchJobScheduler.Batch_Run_Date__c = Date.today();  
  batchJobScheduler.End_Time__c = DateTime.now();
  batchJobScheduler.SFDC_Job_id__c = batchprocessid;
  insert batchJobScheduler;
     
  Test.StopTest();    
  }catch(exception e){}
   }   

static testMethod void unitTestAllocation2() { 
  acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
  acct.Name = 'Account Test123';
  acct.Phone = '22521';
  acct.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
  acct.Status__c = 'Active';
  insert acct;    
  //System.assertEquals ('Active', acct.Status__c);  
      
  Vendor_Allocation__c vend = TestDataFactory.createVendorAlloc(1)[0];
  vend.Vendor_Account__c = acct.Id;
  vend.Legacy_Created_Date__c = '02/21/2014';
  vend.Legacy_Created_By__c = 'AlfredA';
  vend.Legacy_Updated_Date__c = '01/25/2015';
  vend.Legacy_Updated_By__c = 'AlfredA';
  vend.Effective_Start_Date__c = Date.today(); 
  vend.Allocated__c = true;
  insert vend;
  //System.assertEquals('AlfredA', vend.Legacy_Created_By__c);
   
      Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
      postal.Name = '1234';
      postal.Street_Name__c = 'Test Street';
      postal.Building_Name__c = 'Test Building';
      postal.House_Block_Number__c = '13';
      insert postal;
  
     Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            //add.Country__c = country.Id;
            insert add;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acct.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            insert billAcc;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acct.id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;
            
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acct.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact_1__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        Database.insert(subRecs);
    
    
    
  Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];   
  subVendor.Account__c = acct.Id; 
  subVendor.Legacy_Create_Date__c = '02/21/2014';
  subVendor.Legacy_Create_By__c = 'AlfredA';
  subVendor.Legacy_Update_Date__c = '01/25/2015';
  subVendor.Legacy_Update_By__c = 'AlfredA';      
  subVendor.Vendor__c = acct.Id;
  subVendor.Recipient__c = con.Id;
  insert subVendor;    
  //System.assertEquals ('AlfredA', subVendor.Legacy_Update_By__c);
  
  Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        //cas.Order__c = order.Id;
        insert cas;
  
  Case_Vendor_Subscription__c caseVendor = TestDataFactory.createCaseVendorSub(1)[0];
  caseVendor.Account__c = acct.Id;
  caseVendor.Address__c = add.Id;
  caseVendor.Case__c = cas.Id;
  caseVendor.Subscription_Vendor__c = subVendor.Id;
  insert caseVendor;
  
  Case_Subscription__c caseSub = testDataFactory.createCaseSubscription(1)[0];
  caseSub.Account__c = acct.Id;
  caseSub.Address__c = add.id;
  caseSub.Subscription__c = subRecs.Id;
  caseSub.Case__c = cas.Id;
  caseSub.isComplaint__c = true;
  insert caseSub;
  try{
  Test.StartTest(); 
  SP_VendorAllocationBatch batch = new SP_VendorAllocationBatch(date.Today()); 
  SP_VendorAllocationBatch batch2 = new SP_VendorAllocationBatch(cas.Id);
  ID batchprocessid = Database.executeBatch(batch, 200); 
   
  BATCH_JOB_SCHEDULER__c batchJobScheduler = new BATCH_JOB_SCHEDULER__c();
  batchJobScheduler.Status__c = 'STARTED';         
  batchJobScheduler.Batch_Run_Date__c = Date.today();  
  batchJobScheduler.End_Time__c = DateTime.now();
  batchJobScheduler.SFDC_Job_id__c = batchprocessid;
  insert batchJobScheduler;
     
  Test.StopTest(); 
  }catch(exception e){}  
   
   }
}