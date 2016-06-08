/*
 * Class Name: UpdateZuoraArmsInfoTest
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * Project/Requirement: 
 * @description: to test UpdateZuoraArmsInfo class
 */

@isTest
private class  UpdateZuoraArmsInfoTest{

    static User createUser() {
        UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
                       EmailEncodingKey='UTF-8', LastName='Testing123', 
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                       ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
                       UserName='testDeploymentUser@sph.com', Title='Testing123');
        insert usr;

        return usr;
    }

    /**
    *  To test UpdateZuoraArmsInfo
    *  @name testUpdateZuoraArmsInfo
    *  @param none
    *  @return none
    *  @throws na
    */    
    @isTest (SeeAllData = true)   
    static void testUpdateZuoraArmsInfo(){
        User usr = createUser();
            
        System.runAs(usr) {

            //Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
            //cir.Name = 'CIR Plan Schedule';
            //cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
            //cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
            //cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            //cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
            //cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            //cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            //database.insert(cir);
            
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