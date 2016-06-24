/*April Veloso
   10/19/2015
   Test class for PreviousYearTotalTempStopBatch
*/

@isTest (Seealldata = False)
private class PreviousYearTotalTempStopBatchTest {
    // This prepares the data needed for testing the data
    static testmethod void unitTest1(){
      
         Other__c other = new Other__c();
           other.Name = 'DTL';
           other.Value__c = '23:59';
           insert(other); 
 
         /*Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);*/ 
        
         User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
            
                    System.runAs(u){
         
            List<Account> accList = new List<Account>();
         
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            //addressRec.Postal_Code__c = postal.Id;
            addressRec.Address_Unique_ID__c = 'Ad123';
            insert addressRec;
            
            accList = TestDataFactory.createAccount(1, 'Direct Individual');
            accList[0].NRIC__c = 'T1234567R';
            insert accList; 
         
           
            Contact con = TestDataFactory.createContact(1)[0];
            con.Recipient_Indicator__c = TRUE;
            con.AccountId = accList[0].id;
            con.Address__c = addressRec.Id;
            database.insert(con);
            
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[0].ARMS_Account_Number__c = '027101021';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
            billAccountList[0].Payment_Mode__c = 'CREDITCARD';
            billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Other';

            database.insert(billAccountList);
            
            Cir_Planner_Schedule__c cps = new Cir_Planner_Schedule__c();
               cps.Mon_Fri_Start_Time__c = DateTime.newInstance(2015,07,9,08,00,0);
                cps.Sat_PH_Start_Time__c = DateTime.newInstance(2015,07,09,08,00,0);
                cps.Sun_Start_Time__c = DateTime.newInstance(2015,07,09,17,00,0);
                cps.Mon_Fri_End_Time__c = DateTime.newInstance(2015,07,19,22,00,0);
                cps.Sat_PH_End_Time__c = DateTime.newInstance(2015,07,18,17,00,0);
                cps.Sun_End_Time__c = DateTime.newInstance(2015,07,18,17,00,0); 
            cps.Name = 'CIR Plan Schedule';
            insert cps;
        
            
            Case cas = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
            //cas.Account__c = accList[0].id;
            insert cas;
     
    
            //Insert 
            //Subscription_Vendor__c sv = new Subscription_Vendor__c();
            //sv = TestDataFactory.createSubscriptionVendor(1)[0]; 
            
            //lSV.add(sv);
            //Insert lSV;
             Package__c pack = TestDataFactory.createPackage(1)[0];
                    pack.Package_Type__c = 'Base Product';
                    insert pack;
         
                 Zuora__Subscription__c zs = TestDataFactory.createSubscription(1)[0];
            zs.Name = 'Zuora1';
            //zs.Zuora__CustomerAccount__c = ba.Id;
            //zs.Zuora__Account__c = accList[0].id;
            //zs.Order_Line_Item_Number__c = oli.Id;
            //zs.Order_Number__c = o.Id;
            zs.Suppress_Vendor_Start_Notice__c = 'false';
            zs.Supressed_Acknowledgement_Letter__c = 'false';
            zs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zs.Urgent__c = 'false';
            zs.Vendor_Conversion__c = 'false';
            zs.Charity__c = 'false';
            zs.Zuora__SubscriptionStartDate__c = date.Today();
            zs.Zuora__SubscriptionEndDate__c = date.Today().addDays(30);
            zs.Subscription_Type_1__c = 'Publication';
            zs.Zuora__Status__c = 'Cancel';
            //zs.Main_Package_1__c = lPck[0].Id;
            zs.Ph_d__c = true;
            zs.Ph_e__c = false;
            zs.Year_to_Date_Temp_Stop_Days__c = 3;
            zs.Previous_Year_Temp_Stop_Days__c = 3;       
            zs.Zuora__Zuora_Id__c = '1123';
            zs.Subscriber_Contact__c = con.Id;
            zs.Recipient_Contact__c = con.Id;
            zs.Billing_Type__c = 'Full Prepaid';
            zs.Subscription_Type__c = 'Publication';  
            zs.Term_Length__c = 1;
            zs.Term_Length1__c = '1';
            zs.Main_Package_1__c = pack.id;
            zs.Main_Package__c = pack.id;   
            zs.Zuora__CustomerAccount__c = billAccountList[0].Id;  
            Insert zs;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
                    order.Account__c = accList[0].Id;
                    order.Informed_Customer__c = TRUE;
                    order.Recipient_Contact__c = con.Id;
                    order.Subscriber_Charge__c = 100.00;
                    order.Base_Subscription__c = zS.id;
                    order.Status__c = 'Void';
                    //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                    order.Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                    order.Urgent_Stop__c = true;
                    order.isWaive__c = true;
                    insert order;
                    
                    Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(2)[0];                   
                    orderLineItem.Order__c = order.id;
                    orderLineItem.Start_Date__c = zs.Zuora__SubscriptionEndDate__c.addDays(1);
                    orderLineItem.Main_Package_ID__c = pack.id;
                    orderLineItem.amount_to_refund__c = 100.00;
                    orderLineItem.Subscription__c = zs.id;
                    orderLineItem.fee_override__c = false;
                    orderLineItem.admin_charge__c = 2.00;
                    
                    database.insert(orderLineItem);
            //Publication__c pub = TestDataFactory.createPublication(1)[0];
            //pub.Published_Days__c = 'YYYYYYY';
            //pub.Publication_Type__c = 'N';
            //pub.Product_Category__c = 'Print';
            //pub.Publication_Code__c = '1234';
            //pub.Earliest_Start_Date__c = date.today();
            //pub.Platform_Type__c = 'Print';
            
            //insert pub;
            
            Temp_Stop__c TS = new Temp_Stop__c();
            TS.Case__c = cas.Id;
            //TS.Order__c = o.Id;
            TS.Temp_Stop_Date__c = date.today()+2;
            TS.Restart_Date__c = date.today()+5;
            insert TS;
               
            Subscription_Temp_Stop__c STS = new Subscription_Temp_Stop__c();
            STS.Subscription__c = zs.Id;
            STS.Temp_Stop__c = TS.Id;
            insert STS; 
         
            List<Subscription_Vendor__c> subVendor = TestdataFactory.createSubscriptionVendor(1);
            database.insert(subVendor);
            
            List<Vendor_Temp_Stop__c> vendorTempStop = TestDataFactory.createVendorTempStop (1);
            vendorTempStop[0].Subscription_Vendor__c = subVendor[0].id;
            vendorTempStop[0].Temp_Stop__c = TS.id;
            database.insert(vendorTempStop);
            
           
        
        //Subscription_Temp_Stop__c ss =  new Subscription_Temp_Stop__c ();
        //insert ss;
    
        Test.StartTest();
        PreviousYearTotalTempStopBatch batch = new PreviousYearTotalTempStopBatch();
        ID batchprocessid = Database.executeBatch(batch,201);
        Test.StopTest();
    }//end of unitTest1
  
  }
    
}