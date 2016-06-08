@isTest(SeeAllData=true)
public class myClass1{
    static testMethod void myTest() { 
    List<Account> accountList = new List<Account>();
    accountList = TestDataFactory.createAccount(2,'Direct Individual');
    accountList[0].email__c = 'test@test.com';
	accountList[0].Mobile__c = '1234567890';
    accountList[1].email__c = 'test@test.com';
    accountList[1].Mobile__c = '1234567890';
    List<Contact> contactList = new List<Contact>();
    insert accountList;
    system.debug(accountList);    
    
    contactList = TestDataFactory.createContactRecType(1,'Customer Contact'); 
    contactList[0].AccountId = accountList[0].Id;
    insert contactList;                        
    system.debug(contactList); 
               

    }
}