@isTest
private class ARMS_TriggerHandlerTest3{
    static testMethod void testARMS_TriggerHandler(){
        //start custom settings
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.RecordTypeId = [SELECT id, DeveloperName from Recordtype where sObjectType = 'Address__c' and Developername = 'Local'].id; //]ConstantsSLB.getKeyId('Address_Local');
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        insert address;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Office_Number__c = '7895123';
        con.Office_Extension__c = '123';
        con.Address__c = address.id;
        database.insert(con);
        
        Zuora__CustomerAccount__c BAccount = TestDataFactory.createBillingAccount(1)[0];
        BAccount.Name = 'Test';
        BAccount.Zuora__Account__c = acc.Id; 
        BAccount.ARMS_ID__c = 'ID2536';
        BAccount.Payment_Mode__c = 'Other';
        BAccount.Other_PaymentMethod__c = 'Invoice';
        BAccount.ARMS_Debt_Management__c = 'NORM';
        BAccount.ARMS_Business_Profile__c = 'NORM';
        BAccount.Billing_Contact__c = con.id;
        database.insert(BAccount);
        
         Zuora__PaymentMethod__c payment = TestDataFactory.createPaymentMethod(1)[0];
        payment.Zuora__BillingAccount__c = BAccount.Id;
        payment.Zuora__External_Id__c = 'external1233';
        database.insert(payment);
        
        
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.AccountID = acc.Id;
        cas.Category__c = 'Subscription Request';
        cas.Sub_Category__c = 'Change of Credit Card';
        cas.Payment_Method_ID__c = 'external1233';
        database.insert(cas);
        
        List<Zuora__CustomerAccount__c> billAccList = TestDataFactory.createBillingAccount(1); 
        //for(Zuora__CustomerAccount__c ba: billAccList){
            billAccList[0].Name = 'Test';
            billAccList[0].Zuora__Account__c = acc.Id;
            billAccList[0].ARMS_Account_Required__c = false;
            billAccList[0].Billing_Contact__c = con.Id;
            billAccList[0].Zuora__Default_Payment_Method__c = payment.Id;
            billAccList[0].Payment_Mode__c = 'Other';
            billAccList[0].Other_PaymentMethod__c = 'Invoice';
            billAccList[0].Zuora__DefaultPaymentMethod__c = 'Other';
            //ba.ARMS_Business_Profile__c = 'NORM';
            //ba.ARMS_Debt_Management__c = 'NORM';
            //ba.ARMS_Customer_Number__c = '123';
            //ba.ARMS_Account_Number__c = '123';
            billAccList[0].ARMS_Business_Profile__c = 'NORM';
            billAccList[0].ARMS_Debt_Management__c = 'NORM';
            billAccList[0].ARMS_Account_Required__c = true;
            billAccList[0].ARMS_Customer_Number__c = '123';
            billAccList[0].ARMS_Account_Number__c = '123';
            billAccList[0].ARMS_Account_Type__c = 'type';
            //billAccList[0].Credit_Term__c = 30;
            billAccList[0].Zuora__BillToAddress1__c = '123456';
            billAccList[0].ARMS_ID__c  = 'ID2536';
            
           /*billAccList[1].Zuora__Account__c = acc.Id;
            billAccList[1].ARMS_Account_Required__c = false;
            billAccList[1].Billing_Contact__c = con.Id;
            billAccList[1].Zuora__Default_Payment_Method__c = payment.Id;
            billAccList[1].Payment_Mode__c = 'Other';
            billAccList[1].Other_PaymentMethod__c = 'Invoice';
            billAccList[1].Zuora__DefaultPaymentMethod__c = 'Other';
            //ba.ARMS_Business_Profile__c = 'NORM';
            //ba.ARMS_Debt_Management__c = 'NORM';
            //ba.ARMS_Customer_Number__c = '123';
            //ba.ARMS_Account_Number__c = '123';
            billAccList[1].ARMS_Business_Profile__c = 'NORM';
            billAccList[1].ARMS_Debt_Management__c = 'NORM';
            billAccList[1].ARMS_Account_Required__c = true;
            billAccList[1]a.ARMS_Customer_Number__c = '123';
            billAccList[1].ARMS_Account_Number__c = '123';
            billAccList[1].ARMS_Account_Type__c = 'type';
            //billAccList[0].Credit_Term__c = 30;
            billAccList[1].Zuora__BillToAddress1__c = '123456';
            billAccList[1].ARMS_ID__c  = 'ID2536';
            
            billAccList[2].Zuora__Account__c = acc.Id;
            billAccList[0].ARMS_Account_Required__c = false;
            billAccList[0].Billing_Contact__c = con.Id;
            billAccList[0].Zuora__Default_Payment_Method__c = payment.Id;
            billAccList[0].Payment_Mode__c = 'Other';
            billAccList[0].Other_PaymentMethod__c = 'Invoice';
            billAccList[0].Zuora__DefaultPaymentMethod__c = 'Other';
            //ba.ARMS_Business_Profile__c = 'NORM';
            //ba.ARMS_Debt_Management__c = 'NORM';
            //ba.ARMS_Customer_Number__c = '123';
            //ba.ARMS_Account_Number__c = '123';
            billAccList[0].ARMS_Business_Profile__c = 'NORM';
            billAccList[0].ARMS_Debt_Management__c = 'NORM';
            billAccList[0].ARMS_Account_Required__c = true;
            billAccList[0]a.ARMS_Customer_Number__c = '123';
            billAccList[0].ARMS_Account_Number__c = '123';
            billAccList[0].ARMS_Account_Type__c = 'type';
            //billAccList[0].Credit_Term__c = 30;
            billAccList[0].Zuora__BillToAddress1__c = '123456';
            billAccList[0].ARMS_ID__c  = 'ID2536';*/
            
       // }
        
        
        //end test data
        
            database.insert(billAccList);
            /*
            billAccList[0].ARMS_Business_Profile__c = 'NORM';
            billAccList[0].ARMS_Debt_Management__c = 'NORM';
            billAccList[0].ARMS_Account_Required__c = true;
            billAccList[0].Billing_Contact__c = con.Id;
            database.update(billAccList[0]);
            system.assertEquals(null, billAccList[0].Billing_Contact__c); 
            billAccList[0].ARMS_Customer_Number__c = '123';
            billAccList[0].ARMS_Account_Number__c = '123';
            billAccList[0].ARMS_Account_Type__c = 'type';
            //billAccList[0].Credit_Term__c = 30;
            billAccList[0].Zuora__BillToAddress1__c = '123456';
            billAccList[0].Billing_Contact__c = con.Id;            
            database.update(billAccList[0]);*/
            
            
           
            BT_CO_ARMS_CreateCustAccountFile__c bt = new BT_CO_ARMS_CreateCustAccountFile__c();
            bt.Customer_Name1__c = billAccList[0].Name;
            bt.Unique_Key__c = 'Test';
            bt.Sub_Contact_Ext__c = con.Office_Extension__c;
            database.insert(bt);
            
            Map<String, String> idToBusinessProfMap =  new Map<String, String>() ;
            idToBusinessProfMap.put(billAccList[0].ARMS_ID__c, billAccList[0].ARMS_ID__c);
            
            Map<String, String> idToDebtManagementMap = new Map<String, String>();
            idToDebtManagementMap.put(billAccList[0].ARMS_ID__c, billAccList[0].ARMS_ID__c);
			
			//START 1/28/2016 D-4368 Added by J.Sarion
			Set<Id> accountIdForARMSSet = new Set<Id>();
			accountIdForARMSSet.add(billAccList[0].Zuora__Account__c);
			//END 1/28/2016 D-4368 Added by J.Sarion
			
        test.startTest();  
           ARMS_TriggerHandler handler = new ARMS_TriggerHandler();
           Boolean var1 = handler.runBeforeInsertTrigger();
           Boolean var2 = handler.runBeforeUpdateTrigger();
           Boolean var3 = handler.runBeforeDeleteTrigger();
           Boolean var4 = handler.runAfterInsertTrigger();
           Boolean var5 = handler.runAfterUpdateTrigger();
           Boolean var6 = handler.runAfterDeleteTrigger();
		   //START 1/28/2016 D-4368 Added by J.Sarion
           ARMS_TriggerHandler.updatePaymentTerm(idToBusinessProfMap, idToDebtManagementMap, accountIdForARMSSet);
		   //END 1/28/2016 D-4368 Added by J.Sarion
           handler.relinkCustomerBatchRecord(billAccList[0]);
        test.stopTest();
    }
}