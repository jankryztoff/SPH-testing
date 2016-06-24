/**********************************************************************/
/* Class Name:  UpdateBatchNumberTest
/* @author: Marie Kristine Munda 
/* Description: A test class for UpdateBatchNumber
/* Date Last Modified: 02/02/2014
/**********************************************************************/
 
@isTest(seeAllData = true)        
private class UpdateBatchNumberTest{

        
        /****************************** ******************************/
        /*This method is to test queryBillingAccount method in the base case
        /*Oject Account, Order, SingPost are Package, Case, PRomotion, Contact created
        /**************************************************************/
    
     /*@testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createPlannerSched();
        //insert CustomSettingsDataFactory.createOther(); 
    }*/  
    
  static testMethod void testBatchNumberUpdate(){
        /****************************** Test Data Creation ******************************/
        /*   Insert code statements that inserts Data                                   */
        /*   needed by Base Class.                                                      */
        /********************************************************************************/
        
    //Create a new user with Standard User Profile
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
            );
        

        //The test will run as the user created.
        System.runAs(u) {
        
        //Create Account
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c='abc@email.com', Mobile__c='123456');
            insert acc;
            
            Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Account');
            
            insert zacc;    
            
            Case c = new Case(AccountId = acc.id, Billing_Account_Name__c = zacc.id, RecordTypeId = ConstantsSLB.getKeyId('Case_Bypass Credit Card'), Stop_Charging_Credit_Card__c = TRUE, Generate_Arms_Invoice__c=true,
                Charging_Date__c=date.today()+50, Status = 'Closed');
            insert c;        
        
            PageReference pageRef = Page.Send_BatchNo_to_Zuora;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('retURL', '');            
            ApexPages.currentPage().getParameters().put('cid', c.id); 
           
            UpdateBatchNumber ubnClass = new UpdateBatchNumber();
            String response = ubnClass.getResponse();
            System.assertEquals(response, null);
            
            //ubnClass.queryBillingAccount();
            
            zacc.Other_PaymentMethod__c = 'Invoice';
            zacc.Payment_Mode__c = 'Other';
            zacc.ARMS_Business_Profile__c = 'NORM';
            zacc.ARMS_Debt_Management__c = 'NORM';
            update zacc;
            
            UpdateBatchNumber ubnClass2 = new UpdateBatchNumber();
            ubnClass2.queryBillingAccount();
           // System.assertEquals(response, 'success');
        }//End of System.runAs
    }//End of testBatchNumberUpdate method
    
    static testMethod void testBatchNumberUpdate2(){
        /****************************** Test Data Creation ******************************/
        /*   Insert code statements that inserts Data                                   */
        /*   needed by Base Class.                                                      */
        /********************************************************************************/
        
    //Create a new user with Standard User Profile

        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
            );
        

        //The test will run as the user created.
        System.runAs(u) {
        
        //Create Account
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c='abc@email.com', Mobile__c='123456');
            insert acc;
            
            Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Account');
            
            insert zacc;    
            
            Case c = new Case(AccountId = acc.id, Billing_Account_Name__c = zacc.id, RecordTypeId = ConstantsSLB.getKeyId('Case_Bypass Credit Card'), Stop_Charging_Credit_Card__c = TRUE, Generate_Arms_Invoice__c=true,
                Charging_Date__c=date.today()+50, Status = 'Closed');
            insert c;        
        
            PageReference pageRef = Page.Send_BatchNo_to_Zuora;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('retURL', '');            
            ApexPages.currentPage().getParameters().put('cid', c.id); 
           
            UpdateBatchNumber ubnClass = new UpdateBatchNumber();
            String response = ubnClass.getResponse();
            System.assertEquals(response, null);
            
            ubnClass.queryBillingAccount();
            
           // System.assertEquals(response, 'success');
        }//End of System.runAs
    }//End of testBatchNumberUpdate method
    
   
    /************************************/
    /*This method is to test Batch Number Update
    /*Oject Account, Order, SingPost are Pacckage, Case, Billing Account, Contact created.
    /************************************/  

  static testMethod void testBatchNumberUpdateCatch(){
    
    //Create a new user with Standard User Profile

       User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
            );
        

        //The test will run as the user created.
        System.runAs(u) {
        
        //Create Account
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            //new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c='abc@email.com', Mobile__c='123456');
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Country_Name__c = 'SINGAPORE'; 
            insert country;
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
            address.Block_House_Number__c =  'TEST';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = country.id;
    
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__C = true;
            insert con;
            
            Zuora__CustomerAccount__c zacc = TestDataFactory.createBillingAccount(1)[0];
            //new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Account', Old_Batch_Number__c = '1236589', Payment_Mode__c = 'CreditCard');
            zacc.Zuora__Account__c = acc.id;
            zacc.Billing_Contact__c = con.id;
            zacc.Zuora__Batch__c = '1236589';
            zacc.Old_Batch_Number__c = '1236589';
            zacc.Payment_Mode__c = 'CreditCard';
            zacc.ARMS_Debt_Management__c = 'NORM';
            zacc.ARMS_Business_Profile__c = 'NORM';
            insert zacc;  
            
            Case c = new Case();
            c.RecordTypeId = ConstantsSLB.getKeyId('Case_Bypass Credit Card');
            c.AccountId = acc.id;
            c.Account__c = acc.id;
            c.Billing_Account_Name__c = zacc.id;
            c.Stop_Charging_Credit_Card__c = FALSE;
            c.Start_Charging_Credit_Card__c = TRUE;
            c.Charge_Status__c = 'Charge';
            c.Status = 'Closed';
            insert c;        
            System.assertnotEquals(null, c);
        
            //List<Zuora__CustomerAccount__c>  var = [SELECT id from Zuora__CustomerAccount__c WHERE Zuora__Account__c =: c.Billing_Account_Name__r.Zuora__Account__c ];
            /*  AND Old_Batch_Number__c != null AND Payment_Mode__c = 'CreditCard' */
            //System.assertNotEquals(0, var.size());  
            //System.assertnotEquals(null, zacc[0].Zuora__Account__c);                          
            //System.assertnotEquals(null, var[0].Zuora__Account__c);
            //System.assertnotEquals(null, c.Billing_Account_Name__r.Zuora__Account__c);
            //System.assertnotEquals(null, c.Billing_Account_Name__c);
            
           // System.assertEquals(zacc.Zuora__Account__c, c.Billing_Account_Name__r.Zuora__Account__c);
            
            
            PageReference pageRef = Page.Send_BatchNo_to_Zuora;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('retURL', '');            
            ApexPages.currentPage().getParameters().put('cid', c.id); 
          
           
            UpdateBatchNumber ubnClass = new UpdateBatchNumber();
            String response = ubnClass.getResponse();
            System.assertEquals(response, null);
            
            //ubnClass.queryBillingAccount();
      /*      
            zacc.Other_PaymentMethod__c = 'Invoice';
            zacc.Payment_Mode__c = 'Other';
            zacc.ARMS_Business_Profile__c = 'NORM';
            zacc.ARMS_Debt_Management__c = 'NORM';
            update zacc;*/
            
            string cId = ''+ c.id;
            UpdateBatchNumber ubnClass2 = new UpdateBatchNumber();
            ubnClass2.queryBillingAccount();
            ubnClass2.queryBillingAccount(cId);
          
        }//End of System run as
    }//End of testBatchNumberUpdateCatch
}// End of UpdateBatchNumberTest