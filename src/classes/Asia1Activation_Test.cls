/**
 * Class Name: <Asia1Activation_Test>
 * @author: <C.V.Manawatao>
 * Date: <28/01/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for Asia1Activation>
*/


@isTest (Seealldata = TRUE)
public class Asia1Activation_Test {

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
        
        Asia1Activation aoa = new Asia1Activation();
        aoa.thisAsia1 = a1;
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
        insert a1;
        Test.startTest();
        
        Asia1Activation aoa = new Asia1Activation();
        aoa.thisAsia1 = a1;
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockFailTest());
        aoa.verifyAccount();
        Test.stopTest();
    }//end of unitTest1
    
}