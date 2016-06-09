/**
 * Class Name: <EmailMessageTriggerHandlerTest>
 * @author: <FrancisMartinBenzon>
 * Date: <7/24/2014>
 * Requirement/Project Name: <SPH>
 */

@isTest (SeeAllData = TRUE)
public class EmailMessageTriggerHandlerTest { 
    
    static testMethod void testEmailRecordDeleteError(){
        Id profileID = (Id) ConstantsSLB.getKeyId('Profile_Standard User');
        User u = new User(
            Alias = 'standt',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profileID, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='shasda@testorg.com'
        );

        Case ca;
        EmailMessage ems;
        Account acct;

        System.runAs(u) { 

            acct = new Account();
            acct.Name = 'Testing Contact Trigger';
            acct.Airline_Indicator__c = TRUE;
            insert acct;    

            ca = new Case();            
            ca.AccountId = acct.Id;
            ca.Status = 'New';
            ca.Origin = 'Email';  
            insert ca;

                      
            ems =  new EmailMEssage();
            ems.FromAddress = UserInfo.getUserEmail();
            ems.FromName =  UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            ems.Incoming = true;
            ems.ToAddress = 'francis.m.b.benzon@c-se.sandbox.salesforce.com';
            ems.Subject = 'Test email';
            ems.TextBody = 'Hello';
            ems.ParentId = ca.Id;
            insert ems;
            
            Test.startTest();           
            try {
                delete ems; 
            }
            catch(DmlException e){    
                System.assert(e.getMessage().contains('Email record cannot be deleted!'));
            }
            Test.stopTest();  
        } 
    }
    
    static testMethod void testOutOfOfficeEmailError(){
        Id profileID = (Id) ConstantsSLB.getKeyId('Profile_Standard User');
        User u = new User(
            Alias = 'standt',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profileID, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='shalala@leki.com'
        );

        Case ca;
        EmailMessage ems;
        Account acct;

        System.runAs(u) { 

            acct = new Account();
            acct.Name = 'Testing Contact Trigger';
            acct.Airline_Indicator__c = TRUE;
            insert acct;    

            ca = new Case();            
            ca.AccountId = acct.Id;
            ca.Status = 'New';
            ca.Origin = 'Email';  
            insert ca;

                      
            ems =  new EmailMEssage();
            ems.FromAddress = 'standarduser@gmail.com';
            ems.Incoming = true;
            ems.ToAddress = 'francis.m.b.benzon@c-se.sandbox.salesforce.com';
            ems.Subject = 'ooo';
            ems.TextBody = 'Hello';
            ems.ParentId = ca.Id;
            
            try{
            insert ems;
            }
            
            catch(DmlException e){          
                 //System.assert(e.getMessage().contains('Out of office email cant be added to email records.'));
                
            }
        }
    }                   
}