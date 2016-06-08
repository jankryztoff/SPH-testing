/**
 * Class Name: <Asia1ActivationTest>
 * @author: <C.V.Manawatao>
 * Date: <28/01/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for Asia1Activation>
*/


@isTest (Seealldata = TRUE)
public class Asia1ActivationTest {

    static testmethod void unitTest1(){
        
        
        Asia1__c a1 = new Asia1__c();
        a1.User_ID_LDAP_ID__c = 'userId27';
        a1.Status__c = 'Pending Creation';
        a1.Id_Already_Active__c = false;
        a1.Enabled__c = false;
        a1.Password__c = '13456722';
        a1.Display_Name__c = 'userId27';
        a1.email__c = 'userId27@sample.com';
        insert a1;
        Test.startTest();
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(a1);
        Asia1Activation aoa;
        aoa = new Asia1Activation (stdController);
        //Arvin 4/14/2015 below constructor is not defined, stdcontroller was created
        //Asia1Activation aoa = new Asia1Activation();
        // aoa.thisAsia1 = a1;
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
        aoa.verifyAccount();
        Test.stopTest();
    }//end of unitTest1
    static testmethod void unitTest2(){
        Asia1__c a1 = new Asia1__c();
        a1.User_ID_LDAP_ID__c = 'userId27';
        a1.Status__c = 'Pending Creation';
        a1.Id_Already_Active__c = false;
        a1.Enabled__c = false;
        a1.Password__c = '13456722';
        a1.Display_Name__c = 'userId27';
        a1.email__c = 'userId27@sample.com';
        a1.Base_Date_Expiration__c = date.today()-5;
        a1.Is_Link_Expired_Used__c = true;
        insert a1;
        Test.startTest();
        
       
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(a1);
        Asia1Activation aoa;
        aoa = new Asia1Activation (stdController);
       //Arvin 4/14/2015 below constructor is not defined, stdcontroller was created
       //Asia1Activation aoa = new Asia1Activation();
       //aoa.thisAsia1 = a1;
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockFailTest());
        aoa.verifyAccount();
        aoa.isExpired = false;
        Test.stopTest();
    }//end of unitTest2
    
    static testmethod void unitTest3(){
        
        
        Asia1__c a1 = new Asia1__c();
        a1.User_ID_LDAP_ID__c = 'userId27';
        a1.Status__c = 'Pending Creation';
        a1.Id_Already_Active__c = false;
        a1.Enabled__c = true;
        a1.Password__c = '13456722';
        a1.Display_Name__c = 'userId27';
        a1.email__c = 'userId27@sample.com';
        insert a1;
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(a1);
        Asia1Activation aoa;
        aoa = new Asia1Activation (stdController);
        
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
        aoa.verifyAccount();
        Test.stopTest();
    }//end of unitTest3
    
    static testmethod void unitTest4(){
        
        
        Asia1__c a1 = new Asia1__c();
        a1.User_ID_LDAP_ID__c = 'userId27';
        a1.Status__c = 'Error Creation';
        a1.Id_Already_Active__c = false;
        a1.Enabled__c = true;
        a1.Password__c = '13456722';
        a1.Display_Name__c = 'userId27';
        a1.email__c = 'userId27@sample.com';
        insert a1;
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(a1);
        Asia1Activation aoa;
        aoa = new Asia1Activation (stdController);
        
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
        aoa.verifyAccount();
        Test.stopTest();
    }//end of unitTest4
    
}