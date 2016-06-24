@isTest (SeeAllData=true)

private class UpdateBillingAccountNameTest {


    /*
    *  @name <testupdateBillingAccountPaymentInfo_01>
    *  @description - test method to call updateZuoraGoodWillCall() and getResponse()
    *  @param <void>>
    *  @return <none> - 
    *  @throws exception-<none>
    */

    /*static testmethod void testupdateZuoraBillingAccount(){    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Prepaid';
        insert billAcc;
        
        //create zpi instances
        Zuora.zApi zApiInstance = new Zuora.zApi();
        //List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
        Zuora.zObject rec = new Zuora.zObject('Account');        
        Zuora.zApi.SaveResult result = new Zuora.zApi.SaveResult();

        //create test data
        string testgoodwillvalue = 'goodwill';
        string testbillingAccountId = String.valueOf(billAcc.Id);
        string testresponse = 'response';
        string testreturnUrl = 'url';  
        
        //start test
        try{
            //test.setMock(WebServiceMock.class, new zApiTest());
              
            test.startTest();
                UpdateBillingAccountName upg = new UpdateBillingAccountName();
                UpdateBillingAccountName.updateZuoraBillingAccount(testgoodwillvalue, testbillingAccountId);
                upg.getResponse();
            test.stopTest();
        }catch(Exception e){
            system.debug('\n\n Error = '+e.getMessage());
        } 
    }*/

    /*static testmethod void testupdateZuoraBillingAccount2(){           
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
                
        //create test data
        string testgoodwillvalue;
        string testbillingAccountId;
        string testresponse;
        string testreturnUrl;  
       
        //start test
        try{
            //test.setMock(WebServiceMock.class, new zApiTest());
            test.startTest();
                UpdateBillingAccountName upg = new UpdateBillingAccountName();
                UpdateBillingAccountName.updateZuoraBillingAccount(testgoodwillvalue, testbillingAccountId);
                upg.getResponse();
            test.stopTest();
        }catch(Exception e){
            system.debug('\n\n Error = '+e.getMessage());
        } 
    }*/

    static testmethod void testupdateZuoraBillingAccountFail(){    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Zuora_Id__c = 'z12314';
        insert billAcc;

        //Billing_Batch__c billBatch = new Billing_Batch__c();
        //billBatch.Name = 'Full';
        //billBatch.Batch__c = '13';
        //billBatch.Next_Batch_Number__c = 14;
        //insert billBatch;

        //List<Billing_Batch__c> billBatchList = new List<Billing_Batch__c>();

        //for(Integer i=0;i<10;i++){
        //    Billing_Batch__c billBatch = new Billing_Batch__c(Name = 'Name '+i, Batch__c = '0 '+i, Next_Batch_Number__c = 0+i);
        //    billBatchList.add(billBatch);
        //}

        //insert billBatchList;

        Billing_Batch__c billingBatch = new Billing_Batch__c();
		billingBatch.Next_Batch_Number__c = 14;
		billingBatch.Batch__c = '13,14,15';
		billingBatch.Name = 'Postpaid';
        insert billingBatch;

        //create test data
        string testgoodwillvalue = 'goodwill';
        string testbillingAccountId = String.valueOf(billAcc.Id);
        string testresponse = 'response';
        string testreturnUrl = 'url';  
        
        //start test
        test.startTest();
            try{
                UpdateBillingAccountName upg = new UpdateBillingAccountName();
                upg.getResponse();

                UpdateBillingAccountName.updateZuoraBillingAccount(testgoodwillvalue, testbillingAccountId);
                UpdateBillingAccountName.isTrue = false;
            }catch(Exception e){
                System.debug('\n\n\n Error Message = '+e.getMessage());
            }
        test.stopTest();
    }

    static testmethod void testupdateZuoraBillingAccountSuccess(){              
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Zuora_Id__c = 'z12314';
        insert billAcc;

        //Billing_Batch__c billBatch = new Billing_Batch__c();
        //billBatch.Name = 'Full';
        //billBatch.Batch__c = '13';
        //billBatch.Next_Batch_Number__c = 15;
        //insert billBatch;

        //List<Billing_Batch__c> billBatchList = new List<Billing_Batch__c>();

        //for(Integer i=0;i<10;i++){
        //    Billing_Batch__c billBatch = new Billing_Batch__c(Name = 'Name '+i, Batch__c = '0 '+i, Next_Batch_Number__c = 0+i);
        //    billBatchList.add(billBatch);
        //}

        //insert billBatchList;

        Billing_Batch__c billingBatch = new Billing_Batch__c();
		billingBatch.Next_Batch_Number__c = 14;
		billingBatch.Batch__c = '13,14,15';
		billingBatch.Name = 'Postpaid';
        insert billingBatch;
                
        //create test data
        string testgoodwillvalue = 'goodwill';
        string testbillingAccountId = String.valueOf(billAcc.Id);
        string testresponse = 'response';
        string testreturnUrl = 'url';  
        
        //start test
        test.startTest();
            try{
                UpdateBillingAccountName upg = new UpdateBillingAccountName();
                upg.getResponse();

                UpdateBillingAccountName.updateZuoraBillingAccount(testgoodwillvalue, testbillingAccountId);
            }catch(Exception e){
                System.debug('\n\n\n Error Message = '+e.getMessage());
            }
        test.stopTest();
    }
}