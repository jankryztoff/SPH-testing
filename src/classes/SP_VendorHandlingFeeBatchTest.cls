@isTest(seeAllData=false)

private class SP_VendorHandlingFeeBatchTest{

    static testMethod void testSP_VendorHandlingFeeBatch(){
    
    Map<String, Decimal> vendorHandlingFeeMap = new Map<String, Decimal>();
    Map<String, Vendor_Monthly_Data__c> vendorNumberToMonthlyDataMap = new Map<String, Vendor_Monthly_Data__c>();
    Decimal commissionValue;
    Decimal paginationValue;
    Decimal insertionValue;
    Decimal handlingFee;
     
    
    //insert test data
    Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
    acct.Vendor_Group__c = 'V';
    acct.AccountNumber = '30017077';
    insert acct;
    
            
        
    Publication__c pub = new Publication__c(
        Name = 'Sample Publication',
        Publication_Code__c = 'PUB8',
        Published_Days__c = 'NNNNNNY',
        Publication_Type__c = '2'   
    );
    insert pub;
   
    Vendor_POP_Batch__c vPOPBatch = new Vendor_POP_Batch__c(
        Publication_Code__c = 'ST',
        Publication_Issue_Date__c = date.today(),
        Vendor_Group__c = 'V',
        Vendor_Number__c = acct.AccountNumber,
        Total_Direct_Subscriptions__c = 100,
        Total_Sponsored_Copies__c = 20,
        Total_Local_Freelist_Copies__c = 20,
        Total_Local_Subscription_Copies__c = 20,
        Total_Overseas_Freelist_Copies__c = 20,
        Total_Overseas_Subscription_Copies__c = 20
    );
    insert vPOPBatch;
    
    Publication_Daily_Issue_Data__c pubDailyIssueData = new Publication_Daily_Issue_Data__c(
        Name = 'Sample Pub Daily Issue Data',
        Publication_Code__c = vPOPBatch.Publication_Code__c, //'PUB4'
        Publication_Issue_Date__c = vPOPBatch.Publication_Issue_Date__c, //Date.today()
        Consolidation_Date__c = Date.today(),
        Order_Closed_Indicator__c = 'Y',
        Publication__c = pub.Id,
        Pagination__c = 6   
    );
    insert pubDailyIssueData;
    
    Vendor_Inserts__c vendorInserts = new Vendor_Inserts__c(
        Name = 'Sample Vendor Insert',
        Publication_Code__c = vPOPBatch.Publication_Code__c, //'PUB4'
        Publication_Issue_Date__c = vPOPBatch.Publication_Issue_Date__c, //Date.today()
        Vendor_Group__c = 'V',
        Number_of_Inserts__c = 6,
        Insert_Value__c = 10,
        Vendor_Number__c = acct.AccountNumber,//'2',
        Publication__c = pub.Id
    );
    insert vendorInserts;
      
    Vendor_Monthly_Data__c vMonthlyData = new Vendor_Monthly_Data__c(
        Amount_Before_GST__c = 50,
        GST_Amount__c = 53,
        Vendor_Number__c = vPOPBatch.Vendor_Number__c
    );
    insert vMonthlyData;
    

        
    Database.executebatch(new SP_VendorHandlingFeeBatch());
    
    }//END testMethod testSP_VendorHandlingFeeBatch
}//END SP_VendorHandlingFeeBatchTest