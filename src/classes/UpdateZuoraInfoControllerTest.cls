/**
     * Class Name: UpdateZuoraInfoControllerTest
     * @author: Percival Gacad
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Test Class for updating the ARMS No and AGD Unit in Zuora's Customer Account.
     * 
*/
@isTest (Seealldata = TRUE)
public class UpdateZuoraInfoControllerTest{

///static Account acc;    
    static testMethod void testUpdateZuoraInfo(){

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
        
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'));
            acc.Email__c = 'test@email.com'; //CLin 25April2016
            acc.Attention_To_Care_Of_Indicator__c = 'A';//CLin 25April2016
            insert acc;
            
            Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Account', ARMS_Account_Number__c = '0033367899', AGD_Unit__c = 'BRICK', Attention_To_Care_Of_Indicator__c = 'C', Attention_To_Care_Of_Name__c = 'Test', Attention_To_Care_Of_Salutation__c = 'MR');
            insert zacc;   
        
            PageReference pageRef = Page.Send_ARMSNo_to_Zuora;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('retURL', '');            
            ApexPages.currentPage().getParameters().put('zid', zacc.id); 
           
            UpdateZuoraArmsInfo ubnClass = new UpdateZuoraArmsInfo();
            String response = ubnClass.getResponse();
            System.assertEquals(response, null);
            
            ubnClass.updateZuoraAccount();
            ubnClass.updateZuoraAccount(zacc.id);
        }
    }
}