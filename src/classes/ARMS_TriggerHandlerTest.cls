@isTest (Seealldata = TRUE)
public class ARMS_TriggerHandlerTest{
    
static testMethod void TestInsertUpdateBillingAcc(){

List<Zuora__CustomerAccount__c> accInsert = new List<Zuora__CustomerAccount__c>();
List<Zuora__CustomerAccount__c> accUpdate = new List<Zuora__CustomerAccount__c>();
List<Zuora__CustomerAccount__c> accDelete = new List<Zuora__CustomerAccount__c>();
Set<ID> accIDs = new Set<ID>();
Set<ID> idForUpdate = new Set<ID>();
List<Account> accountref = new List<Account>();
List<Account> accountnew = new List<Account>();

Integer i = 0;

for(i=0; i<3;i++){
    Account acc = new Account();
    acc.Name = 'Test Account'+i;
    //acc.RecordTypeID = '012N00000008ic6';
    
    accountref.add(acc);
    }
    
 //accountref = TestDataFactory.createAccount(3, 'Direct Corporate'); 
   
   
system.debug('---->accountref'+accountref);

insert accountref;
            
for(i=0;i<3;i++){
    Zuora__CustomerAccount__c a = new Zuora__CustomerAccount__c();
    a.Name = 'Test Billing Account'+i;
    a.Zuora__Account__c = accountref[i].id;
    idForUpdate.add(accountref[i].id);
    accInsert.add(a);
}

insert accInsert;

// Update the Billing Accounts created above
//test data

i=0;

for(Zuora__CustomerAccount__c a : [select id, Zuora__Account__c from Zuora__CustomerAccount__c where id IN :accInsert]){
    
    a.ARMS_ID__c = 'Test123'+i;
    a.ARMS_Account_Number__c = '1234567'+i;
    a.ARMS_Account_Type__c = 'A'+i;
    a.Credit_Limit_Internal__c = 12345+i;
    a.Credit_Limit_External__c = 98765+i;
    a.Approved_Debt_Exposure_Amount__c = 123456+i;
    a.ARMS_Debt_Management__c = 'NORM'; 
    a.Business_Sector__c = 'TestBS'+i;
    a.SOA_Grouping__c = 'T'+i;
    a.Zuora__BillToAddress1__c = 'This is a test address update for Billing AccountThis is a test address update for Billing Account'+i;
    a.Zuora__BillToAddress2__c = 'This is a test address update for Billing AccountThis is a test address update for Billing Account'+i;
    accUpdate.add(a);
    i++;
}
ARMS_TriggerHandler.isSkipUpdate = false;
update accUpdate;

for(Zuora__CustomerAccount__c a : [select id, Zuora__Account__c from Zuora__CustomerAccount__c where id IN :accInsert]){
    accDelete.add(a); 
}
delete(accDelete);
}
}