/*
 * Class Name: UpdateZuoraArmsInfoTest
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * Project/Requirement: 
 * @description: to test UpdateZuoraArmsInfo 

class


 */

@isTest (Seealldata = TRUE)
private class  UpdateZuoraArmsInfoTest2{

    /**
    *  To test UpdateZuoraArmsInfo
    *  @name testUpdateZuoraArmsInfo
    *  @param none
    *  @return none
    *  @throws na
    */       
    static testMethod void testUpdateZuoraArmsInfo(){
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
            

        System.runAs(u) {
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.Email__c = 'test@email.com';
            acc.Attention_To_Care_Of_Indicator__c = 'C';
            insert acc;
            
            Zuora__CustomerAccount__c zacc = TestDataFactory.createBillingAccount(1)[0];
            zacc.Zuora__Account__c = acc.id;
            zacc.Name = 'Test Account'; 
            zacc.ARMS_Account_Number__c = '0033367899';
            zacc.AGD_Unit__c = 'BRICK'; 
            zacc.Attention_To_Care_Of_Indicator__c = 'C';
            zacc.Attention_To_Care_Of_Name__c = 'Test'; 
            zacc.Attention_To_Care_Of_Salutation__c = 'MR';
            insert zacc;   
        
            Case c = TestDataFactory.createcase(1, 'Bypass Credit Card')[0];
            c.AccountId = acc.id; 
            c.Billing_Account_Name__c = zacc.id;
            //RecordTypeId = ConstantsSLB.getKeyId('Case_Bypass Credit Card'),
            c.Generate_Arms_Invoice__c = TRUE; 
            c.Stop_Charging_Credit_Card__c = TRUE;
            c.Charging_Date__c = date.today().addDays(60);
            insert c;   
        
            PageReference pageRef = Page.Send_ARMSNo_to_Zuora;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('retURL', '');            
            ApexPages.currentPage().getParameters().put('zid', zacc.id); 
            ApexPages.currentPage().getParameters().put('cid', c.id); 
           
            try{
                test.setMock(WebServiceMock.class, new zApiTest());
                Test.startTest();
                UpdateZuoraArmsInfo ubnClass = new UpdateZuoraArmsInfo();
                ubnClass.paymentMethodId = 'test';
                ubnClass.c = 'test';
                ubnClass.paymentMethod = 'test';
                String response = ubnClass.getResponse();
                System.assertEquals(response, null);
                
                ubnClass.updateZuoraAccount();
                Test.stopTest();
            }catch(Exception e){}
            
        
        }
    }
}