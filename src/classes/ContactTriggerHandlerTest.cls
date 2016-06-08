@isTest (SeeAllData = TRUE)
public class ContactTriggerHandlerTest {
    /**
     * Class Name: <ContactTriggerHandlerTest>
     * @author: <FrancisMartinBenzon, MarkJhustinPinoy>
     * Date: <7/15/2014>
     * Requirement/Project Name: <SPH>
     * @description<Test Class for ContactTriggerHandler, handles bulk insert and update, handles validations>
     */
    
    //This method runs a user to create a contact record. In the process of contact creation related Objects records are also created.
    //Account, Address, SingPost Address are also created.
    
    static testMethod void testSingleInsertUpdateLocal(){
        
        User u = new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
        Account acct;
        Address__c add;
        Contact cont;
        SingPost_Address__c singPostAdd;

        System.runAs(u) {                                                
          
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            /**singPostAdd = new SingPost_Address__c();
            singPostAdd.Building_Name__c='building';
            singPostAdd.Address_Type__c='S';
            singPostAdd.Street_Name__c='Street';
            singPostAdd.Number_of_Units__c=1;
            singPostAdd.House_Block_Number__c = '1';
            
            insert singPostAdd;*/
            
            //Id RecordTypeId = (Id) ConstantsSLB.getKeyId('Address_Airline');
            add = new Address__c();
            add.Name = 'McKinley B Trigger Test';
            add.Postal_Code__c = postal.Id ;
            add.Address_Unique_Id__c = 'testing';
            add.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
            
            insert add;           
            add = [SELECT Address_Unique_ID__c FROM Address__c WHERE Id = : add.Id]; 
            
            acct = new Account();
            acct.Name = 'Account Test';
            acct.Airline_Indicator__c = TRUE;
            insert acct;    
            
            cont = new Contact();
            cont.Lastname = 'Benzon';
            cont.AccountId = acct.Id;
            cont.Address__c = add.Id;
            cont.Billing_Indicator__c = FALSE;
            cont.Email__c = 'abc@gmail.com';
            cont.NRIC__c = 'S1234567X';
            cont.HomePhone__c = '222-111-333';
            
            insert cont;    
            update cont;
            
            cont = [SELECT Address_Unique_ID__c FROM Contact WHERE Id = : cont.Id];
            System.assertEquals(cont.Address_Unique_ID__c , add.Address_Unique_ID__c);
        }
    }    
    
    static testMethod void testSingleInsertUpdateOverseas(){
    
        User u = new User(
            Alias = 'standt',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
        Account acct;
        Address__c add;
        Contact cont;
        SingPost_Address__c singPostAdd;

        System.runAs(u) {                                                
            
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            /**singPostAdd = new SingPost_Address__c();
            singPostAdd.Building_Name__c='building';
            singPostAdd.Address_Type__c='S';
            singPostAdd.Street_Name__c='Street';
            singPostAdd.Number_of_Units__c=1;
            singPostAdd.House_Block_Number__c = '1';
            
            insert singPostAdd;*/
            
            //Id RecordTypeId = (Id) ConstantsSLB.getKeyId('Address_Airline');
            add = new Address__c();
            add.Name = 'McKinley B Trigger Test';
            add.Postal_Code__c = postal.Id ;
            add.Address_Unique_Id__c = 'testing';
            add.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
            
            insert add;           
            add = [SELECT Address_Unique_ID__c FROM Address__c WHERE Id = : add.Id]; 
            
            acct = new Account();
            acct.Name = 'Account Test2';
            acct.Airline_Indicator__c = TRUE;
            insert acct;    
            
            cont = new Contact();
            cont.Lastname = 'Benzon';
            cont.AccountId = acct.Id;
            cont.Address__c = add.Id;
            cont.Billing_Indicator__c = FALSE;
            cont.Email__c = 'abc@gmail.com';
            cont.NRIC__c = 'T1732465I';
            cont.HomePhone__c = '222-111-333';
            
            insert cont;    
            update cont;
            
            cont = [SELECT Address_Unique_ID__c FROM Contact WHERE Id = : cont.Id];
            System.assertEquals(cont.Address_Unique_ID__c , add.Address_Unique_ID__c);
            
            /*acct = [SELECT Address_Unique_ID__c FROM Account WHERE Id = : acct.Id];
            System.assertEquals(acct.Address_Unique_ID__c , add.Address_Unique_ID__c);*/
        }
    }    
    
    //This is to check if trigger can handle bulk contact record creation
    static testMethod void testBulkInsertUpdate(){
        
        User u = new User(
            Alias = 'standt',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        
        Account acct;
        Address__c add;
        SingPost_Address__c singPostAdd;
        
        System.runAs(u) {
        
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal; 
                                                           
            /**singPostAdd = new SingPost_Address__c();
            singPostAdd.Building_Name__c='building';
            singPostAdd.Address_Type__c='S';
            singPostAdd.Street_Name__c='Street';
            singPostAdd.Number_of_Units__c=1;
            singPostAdd.House_Block_Number__c = '1';
            
            insert singPostAdd;*/
            
            //Id RecordTypeId = (Id) ConstantsSLB.getKeyId('Address_Airline');
            add = new Address__c();
            add.Name = 'McKinley B Trigger Test';
            add.Postal_Code__c = postal.Id ;
            add.Address_Unique_Id__c = 'testing';
            add.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
            
            insert add;
            add = [SELECT Address_Unique_ID__c FROM Address__c WHERE Id = : add.Id];
            
            acct = new Account();
            acct.Name = 'Account Test3';
            acct.Airline_Indicator__c = TRUE;
            insert acct;    
            
            System.debug('Inserting 100 contact records. Bulk validation');
        
            List<Contact> testBulkContact = new List<Contact>();
            for(integer i=0; i<100; i++){
                testBulkContact.add(
                    new Contact(
                        Lastname = 'TEST',
                        AccountId = acct.Id,
                        Address__c = add.Id,
                        Email__c = 'qweqwe@gmail.com',
                        NRIC__c = 'S7654123L',     
                        HomePhone__c = '222-111-333'
                    )
                );
            }
            insert testBulkContact;                                             
            update testBulkContact;
        }
    }
    
    static testMethod void testBillingIndicatorCOntactError(){
    
                User u = new User(
                    Alias = 'standt',
                    Email='standarduser@gmail.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Testing',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = ConstantsSLB.getKeyId('Profile_Standard User'), 
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='shasda@testorg.com'
                );
                
        Account acct;
        Contact cont;
        Contact cont2;

        System.runAs(u) {  
        
            acct = new Account();
            acct.Name = 'Account Test4';
            acct.Airline_Indicator__c = TRUE;
            
            insert acct;    
            
            cont = new Contact();
            cont.Lastname = 'Benzon';
            cont.AccountId = acct.Id;           
            cont.Billing_Indicator__c = TRUE;
            cont.Email__c = 'abc@gmail.com';
            cont.NRIC__c = 'G3637189J';
            cont.HomePhone__c = '222-111-333';
            
            insert cont;
            
            cont2 = new Contact();
            cont2.Lastname = 'asdasd';
            cont2.AccountId = acct.Id;           
            cont2.Billing_Indicator__c = TRUE;
            cont2.Email__c = 'qweasd@gmail.com';
            cont2.NRIC__c = 'G1234567M';
            cont2.HomePhone__c = '222-111-333';
            
            ContactTriggerHandler.isBeforeInsertTriggerCalled = FALSE;
            ContactTriggerHandler.isAfterInsertTriggerCalled = FALSE;
            try{
                insert cont2;           
            }
            catch(DmlException e){          
                System.assert(e.getMessage().contains('Associated Account has already a billing contact. ' + 'One billing contact per account only.'));
                
            }
            
            cont2.Billing_Indicator__c = FALSE;
            insert cont2;
        
            cont2.Billing_Indicator__c = TRUE;
    
            try{
                update cont2;       
            }
            catch(DmlException e){          
                 System.assert(e.getMessage().contains('Associated Account has already a billing contact. ' + 'One billing contact per account only.'));
            }
        }
    }

    static testMethod void testAirlineOnAccountAddressValidation() {
       
        User u = new User(
            Alias = 'standt',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='sttrgjrt@testorg.com'
        );
        
        Account acct;
        Address__c add;
        Contact cont;
        SingPost_Address__c singPostAdd;
        
        System.runAs(u) { 
        
            acct = new Account();
            acct.Name = 'Account Test5';
            acct.Airline_Indicator__c = FALSE;  
            
            insert acct;    
            
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            /**singPostAdd = new SingPost_Address__c();
            singPostAdd.Building_Name__c='building';
            singPostAdd.Address_Type__c='S';
            singPostAdd.Street_Name__c='Street';
            singPostAdd.Number_of_Units__c=1;
            singPostAdd.House_Block_Number__c = '1';
            
            insert singPostAdd;*/
            
            //Id addRecTypeId = (Id) ConstantsSLB.getKeyId('Address_Airline');
            add = new Address__c();
            add.Name = 'McKinley B Trigger Test';
            add.Postal_Code__c = postal.Id ;
            add.Address_Unique_Id__c = 'testing';
            add.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
            
            insert add;
            
            cont = new Contact();
            cont.Lastname = 'Benzon';
            cont.AccountId = acct.Id;
            cont.Address__c = add.Id;
            cont.Billing_Indicator__c = TRUE;
            cont.Email__c = 'abc@gmail.com';
            cont.NRIC__c = 'S3412675Z';
            cont.HomePhone__c = '222-111-333';
            
            try{                                
                insert cont;        
            }
            catch(DmlException e){          
                System.assert(e.getMessage().contains('Invalid Address Record Type for Airline Account'));          
            }
            
            acct.Airline_Indicator__c = TRUE;   
            update acct;
            
            ContactTriggerHandler.isBeforeInsertTriggerCalled = FALSE;
            ContactTriggerHandler.isAfterInsertTriggerCalled = FALSE;
            insert cont;    
            
            acct.Airline_Indicator__c = FALSE;  
            update acct;
            
            try{                                
                update cont;    
                
            }
            catch(DmlException e){          
                System.assert(e.getMessage().contains('Invalid Address Record Type for Airline Account'));          
            }
        }
    }       
}