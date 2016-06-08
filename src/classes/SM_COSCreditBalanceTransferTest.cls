@isTest(SeeAllData=true)
private class SM_COSCreditBalanceTransferTest{
    static testMethod void testSM_COSCreditBalanceTransfer(){
        String error = '';
        
        List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;
        
        //Mailing Agent
        List<Account> accList2 = TestDataFactory.createAccount(1, 'Mailing Agent');
        accList2[0].NRIC__c = 'T1232567R';
        insert accList2;

        list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
        postal[1].Name = 'SPostal';
        postal[1].House_Block_Number__c = 'TEST';
        postal[1].Address_Type__c = 'A';
        insert postal;
        
        list<Address__c> addressRec = TestDataFactory.createAddress(2);
        addressRec[0].Address_Type__c='P';
        addressRec[0].Postal_Code__c = postal[0].Id;
        addressRec[1].Address_Type__c = 'A';
        addressRec[1].Postal_Code__c = postal[1].Id;
        addressRec[1].Block_House_Number__c ='TEST';
        addressRec[1].Level_Number__c ='xx';
        addressRec[1].Unit_Number__c = 'yy';
        insert addressRec;

        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec[0].Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conlist[0].Recipient_Number__c = 299999993;
        conlist[0].Recipient_Number_Show__c = '299999993';
        //system.assertequals(conList , null);
        insert conList;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        packageList[0].Frequency_Identifier__c = '1';
        insert packageList;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].id;
        billAcc.Zuora__Zuora_Id__c = '2c92c0f953078a560153126214ff1e9d';
        database.insert(billAcc);
        
        //subscription 1  
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        zuoSubList[0].Frequency_1__c = 'Default';
        zuoSubList[0].Frequency__c = 'Default';
        insert zuoSubList;
    
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = accList[0].id;
        
        database.insert(ord);
        

        
        Map<Id, String> mapName = new Map<Id, String>();
        mapName.put(ord.Id, billAcc.Zuora__Zuora_Id__c);
        
        //system.assertequals(mapName, null);
        try{
            test.setMock(WebServiceMock.class, new zApiTest());
            test.startTest();
                SM_COSCreditBalanceTransfer.processBalanceTransfer(mapName);
            test.StopTest();
        }
        catch(Exception e){
      }
    }
}