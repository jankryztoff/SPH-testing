/**********************************************************************/
/* Class Name:  SP_MidMonthNonCreditProBatchTest
/* Author: Marie Kristine Munda 
/* Description: A test class for SP_MidMonthNonCreditProrationBatchClass
/* Date created: 02/26/2014//e
/**********************************************************************/

@isTest(seeAllData = TRUE)

private class SP_MidMonthNonCreditProBatchTest{
/******************************************/
/*Description:
/******************************************/
 static testMethod void test(){
 
        /****************************** Test Data Creation ****************************/
    /*   Insert code statements that inserts Data                                 */
    /*   needed by Base Class.                                                    */
    /*****************************************************************************/
     
     //Create a new user with Standard User Profile   
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='GMT',
            UserName='standard@test.com'
        );  
        
        System.runAs(testUser) {

     // Create Account 
     Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.NRIC__c = 'T1234567R';
     insert acc; 

        
    //Create an Address record
     List<Address__c> addressList = TestDataFactory.createAddress(1);
    
    //Create contact con
    Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = addressList[0].Id;
        con.Recipient_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    insert con;
    
    //Create Billing Account
    Zuora__CustomerAccount__c ba = TestDataFactory.createBillingAccount(1)[0];
        ba.Zuora__Account__c = acc.Id;
    insert  ba;
    
    //Create Package
     Package__c pack = new Package__c();
        pack.Package_Type__c = 'Base';
        pack.Name = 'TestPackageName';
        pack.Subscription_Type__c = 'Termed';
        pack.Channel_Direct__c = true;
        pack.Channel_E_shop_overseas__c = true;
        pack.Channel_E_shop_private__c = true;
        pack.Channel_E_shop_public__c = true;
        pack.Subscription_Period__c = '35';
        pack.Package_Code__c = 'SamplePackageCode';
        pack.Effective_Start_Date__c = date.Today();
        pack.Effective_End_Date__c = date.Today() + 30;
    insert pack;
    System.assertEquals(pack.Name, 'TestPackageName');
    
    //Create Order
     Order__c order= TestDataFactory.createOrder(1)[0];   
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
    insert order;
    
    
    //Create External Payment
    External_Payment__c e = TestDataFactory.createExternalPayment(1)[0];
            e.Account_Name__c =  acc.Id;
            e.Payment_Method__c ='Credit Card';
            e.Transaction_Status__c = 'F';
            e.Transaction_Type__c = 'R';
            e.Transaction_Date__c = date.today();
            e.Billing_Account__c =ba.Id;
            e.Billing_Contact_email__c ='standard@test.com';

    //Create Publication
      Publication__c pub = TestDataFactory.createPublication(1)[0];
          pub.Publication_Type__c ='M';
          pub.Published_Days__c ='4';
          pub.Publication_Code__c ='AAAA';
          
      insert pub;
         
    
   //Create subscrption Sub
    Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__Account__c = acc.Id;
        sub.Subscriber_Contact__c = con.Id;
        sub.Recipient_Contact__c = con.Id;
        sub.Main_Package_1__c = pack.id;
        sub.Zuora__Status__c = 'Active';
        sub.Zuora__CustomerAccount__c = ba.Id;
        sub.Order_Number__c = order.Id;
        sub.Suppress_Vendor_Start_Notice__c = 'false';
        sub.Supressed_Acknowledgement_Letter__c = 'false';
        sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Urgent__c = 'false';
        sub.Vendor_Conversion__c = 'false';
        sub.Charity__c = 'false';
        sub.Subscription_Type__c = 'Publication';
    insert sub;
         System.assertEquals(sub.Subscription_Type__c , 'Publication');
    
     //Create Subscription Charges
        Zuora__SubscriptionProductCharge__c subchar = TestDataFactory.createSubProductCharge(1)[0];
            subchar.Zuora__Zuora_Id__c = sub.id;
            subchar.Product_Code__c ='Sample Product Code';
            subchar.PublicationCode__c ='Publication Code';
            subchar.Zuora__Subscription__c = sub.id;
         insert subchar;   
        
        Test.startTest();
        
        SP_MidMonthNonCreditProrationBatch batch = new SP_MidMonthNonCreditProrationBatch();
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        Test.stopTest(); 
        
        
        }//End of System.runAs  
    }//End of test method
}//end of SP_MidMonthNonCreditProBatchTest class