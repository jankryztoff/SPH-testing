@isTest 
private class UpdateParticularsTest{
    
        @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createMASS_CONFIG();
        insert CustomSettingsDataFactory.createError_Messages();
    }
    
    public class ChangeofParametersRequest{
        String nric;
        String passport;
        String homePhone;
        String mobilePhone;
        String officePhone;
        String email;
        String secondarymail;
        String name;
        String salutation;
        String contactID;
        String billingIndicator;
        String recipientIndicator;
    }
    
    static testmethod void testUpdateParticulars1(){
        
        // This prepares the data needed for testing the data
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
            
        Account acct;
        Address__c add;
        Country__c cntry;
        Order__c ord;
        Contact cont;
 
        System.runAs(u){
              
            Test.startTest();
              
                acct = new Account();
                acct.Name = 'Account Test';
                acct.Airline_Indicator__c = TRUE;
                Database.insert(acct);      
              
                //start... added by jjzs apr072016
                cntry = new Country__c();
                    cntry.Account__c = acct.Id;
                Database.insert(cntry); 
                //stop... added by jjzs apr072016
                
                add = new Address__c();
                    add.Name = 'McKinley B Trigger Test';
                    //add.Postal_Code__c = postal.Id ;
                    add.Address_Unique_Id__c = 'testing';
                    add.Country__c = cntry.Id; //added by jjzs apr072016
                    add.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');                        
                Database.insert(add);   
                
                cont = new Contact();
                    cont.Lastname = 'Benzon';
                    cont.AccountId = acct.Id;
                    cont.Address__c = add.Id;
                    cont.Billing_Indicator__c = FALSE;
                    cont.Email__c = 'abc@gmail.com';
                    cont.NRIC__c = 'S1234567X';
                    cont.HomePhone__c = '222-111-333';           
                Database.insert(cont); 
                
                add = [SELECT Address_Unique_ID__c FROM Address__c WHERE Id = : add.Id];  
                cont = [SELECT Address_Unique_ID__c FROM Contact WHERE Id = : cont.Id];
                System.assertEquals(cont.Address_Unique_ID__c , add.Address_Unique_ID__c);
                
                UpdateParticulars uptClass = new UpdateParticulars();
                String response = uptClass.getResponse();
                System.assertEquals(response, null);    
                
            Test.stopTest();
    }
    }

    static testmethod void testWrongUpdateParticulars() {
        
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
        
           
        Account acct;
        Address__c add;
        Contact cont;
        Country__c cntry;
        
        System.runAs(u){
        
            Test.startTest();
              
                acct = new Account();
                    acct.Name = 'Account Test';
                    acct.Airline_Indicator__c = TRUE;
                Database.insert(acct);    
              
                //start... added by jjzs apr072016
                cntry = new Country__c();
                    cntry.Account__c = acct.Id;
                Database.insert(cntry); 
                //stop... added by jjzs apr072016
        
                add = new Address__c();
                    add.Name = 'McKinley B Trigger Test';
                    add.Address_Unique_Id__c = 'testing';
                    add.Country__c = cntry.Id; //added by jjzs apr072016
                    add.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');   
              Database.insert(add);

                cont = new Contact();
                    cont.Lastname = 'Benzon';
                    cont.AccountId = acct.Id;
                    cont.Address__c = add.Id;
                    cont.Billing_Indicator__c = FALSE;
                    cont.Email__c = 'abc@gmail.com';
                    cont.NRIC__c = 'S1234567X';
                  cont.HomePhone__c = '222-111-333';
                Database.insert(cont);
            
         // cont = [SELECT Address_Unique_ID__c FROM Contact WHERE Id = : cont.Id];
         // System.assertEquals(cont.Address_Unique_ID__c , add.Address_Unique_ID__c);
            
         // UpdateParticulars uptClass = new UpdateParticulars();
        //  String response = uptClass.getResponse();
        //  System.assertEquals(response, null);    
               
          Test.stopTest();
        
            
        }            
        
    }
    
    static testMethod void testUpdateParticulars(){
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'Postal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'S1234567D';
        acc.Passport__c = 'P11111';
        acc.Telephone_Residence__c = '122-1222';
        acc.Handphone_Number__c = '222111111';
        acc.Office_Number__c = '11244444';
        acc.Email__c = 'sample@sample.com';
        acc.Email_Secondary__c = 'sample2@sample.com';
        acc.Name = 'Account Name';
        insert acc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Billing_Indicator__c = true;
        con.Address__c = addressRec.Id;
        con.FirstName = 'John';
        con.LastName = 'Doe';
        con.NRIC__c = acc.NRIC__c;
        con.Passport__c = 'P11111';
        con.HomePhone__c = '122-1222';
        con.Mobile_Number__c = '222111111';
        con.Office_Number__c = '11244444';
        con.Email__c = 'sample@sample.com';
        con.Email_Secondary__c = 'sample2@sample.com';
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Salutation = 'Mr';
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.FirstName = 'John';
        con1.LastName = 'Doe';
        con1.NRIC__c = acc.NRIC__c;
        con1.Passport__c = 'P11111';
        con1.HomePhone__c = '122-1222';
        con1.Mobile_Number__c = '222111111';
        con1.Office_Number__c = '11244444';
        con1.Email__c = 'sample@sample.com';
        con1.Email_Secondary__c = 'sample2@sample.com';
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        con1.Salutation = 'Mr';
        insert con1;

        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Billing_Contact__c = con.id;
        order.Other_Payment_Mode__c = 'Invoice';
        order.Status__c = 'Close';
        order.Customer_No__c = '1234567890';    
        order.Account__c = acc.id;
        insert order;
        
        Integer counter = 0;
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
        for(Zuora__CustomerAccount__c bill:billAcc){
            bill.Zuora__Account__c = acc.Id;
            bill.Billing_Contact__c = con.id;
            bill.Zuora__External_Id__c = '123456789012345';
            bill.ARMS_ID__c = '1234567890';
            bill.Other_PaymentMethod__c = 'Invoice';
            bill.Zuora__BillToId__c = '0321654987';
            if(counter==1){
                bill.Zuora__External_Id__c = '1234567890123451';
            }
            counter++;
        }
        insert billAcc; 
        
        Test.startTest();
        EshopChageofParameters.accName = [Select Account_Auto_Number__c From Account Where id=:acc.id].Account_Auto_Number__c;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EshopChangeofParametersService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        ChangeofParametersRequest eshReq = new ChangeofParametersRequest();
        eshReq.nric = acc.NRIC__c;
        eshReq.passport = acc.Passport__c;
        eshReq.homephone = acc.Handphone_Number__c;
        eshReq.mobilePhone = acc.Handphone_Number__c;
        eshReq.officePhone = acc.Office_number__c;
        eshReq.email = acc.Email__c;
        eshReq.secondarymail = acc.Email_Secondary__c;
        eshReq.Name = acc.Name;
        eshReq.Salutation = con.Salutation;    
        eshReq.contactId = con.Id;
        eshReq.billingIndicator = 'N';
        eshReq.recipientIndicator = 'Y';
        
        EshopChageofParameters.ChangeofParametersRequest esh = new EshopChageofParameters.ChangeofParametersRequest();
        String jsonStr = JSON.serialize(eshReq);
        esh = (EshopChageofParameters.ChangeofParametersRequest)JSON.deserialize(jsonStr, EshopChageofParameters.ChangeofParametersRequest.class);
        EshopChageofParameters.ChangeofParametersResponse response = EshopChageofParameters.UpdateCustomerDetails(esh); 
        Test.stopTest();
        System.assertNotEquals(null, response);    
    }

}