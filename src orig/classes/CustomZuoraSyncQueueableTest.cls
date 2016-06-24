@isTest(SeeAllData=True)

private class CustomZuoraSyncQueueableTest{
    static testMethod void testCustomZuoraSyncQueueable(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
        database.insert(billAcc);
    
        List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(200);
        for(Zuora__Subscription__c sub : subList){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Contract_End_Date__c = String.valueOf(date.today()+60);
            sub.Recipient_Contact_1__c = con.Id;
            sub.Recipient_Contact__c = con.Id;
            sub.Other_PaymentMethod__c = 'Invoice';
            sub.Payment_Method__c = 'Full';
            sub.Payment_Mode__c = 'Credit Card';
            sub.Promotion_Contract_Period__c = '30';
            sub.Payment_Type__c = 'Postpaid';
            sub.Subscriber_Contact__c = con.Id;
            sub.Subscriber_Contact_1__c = con.Id;
            sub.Term_Length1__c = '30';
            sub.Vendor_Credit__c = '500';
            sub.Zuora__ContractAcceptanceDate__c = date.today()+2;
            sub.Zuora__ContractEffectiveDate__c = date.today()+10;
            //sub.Zuora__External_Id__c = 'abcdef789123456zzz';
            sub.Zuora__InitialTerm__c = '123';
            sub.Zuora__InvoiceOwner__c = billAcc.Id;
            sub.Zuora__NextChargeDate__c = date.today()+50;
            sub.Zuora__NextRenewalDate__c = date.today()+90;
            sub.Zuora__OriginalCreatedDate__c = date.today();
            sub.Zuora__RenewalTerm__c = '1234';
            sub.Zuora__ServiceActivationDate__c = date.today();
            sub.Zuora__Status__c = 'New';
            sub.Zuora__MRR__c = 100;
            sub.Zuora__TCV__c = 100;
            sub.Zuora__TermStartDate__c = date.today()+1;
            sub.Zuora__TermEndDate__c = date.today()+30;
            sub.Zuora__TermSettingType__c = 'TERMED';
            sub.Zuora__Notes__c = 'notes';
            sub.Delivery_Charge_Type__c = 'H';
            sub.Vendor__c = Acc.Id;
        }
        database.insert(subList);
       
        test.startTest();
        
            CustomZuoraSyncQueueable custQ = new CustomZuoraSyncQueueable();
            custQ.lstNewVersions = subList;
            /*QueueableContext context;
            custQ.execute(context);*/
            System.enqueueJob(custQ);

        test.stopTest();
    }
}