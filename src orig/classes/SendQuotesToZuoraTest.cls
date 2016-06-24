/**
 * Class Name: SendQuotesToZuoraTest
 * @author: April Veloso
 * Date: 4/8/2016
 * Requirement/Project Name: Singapore Press Holdings
 * @ test class for SendQuotesToZuora
 * 
 */


@isTest(Seealldata=true)
public class SendQuotesToZuoraTest {
        static testMethod void test_SendQuotesToZuoraTest(){
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                database.insert(acc);
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Street_Name__c = 'Street';
                postal.Building_Name__c = 'building';
                database.insert(postal);
                
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Country_Name__c = 'country';
                database.insert(country);
                
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Block_House_Number__c = '10';
                add.Postal_Code__c = postal.Id;
                add.Level_Number__c = '12';
                add.Unit_Number__c = '12';
                add.Country__c = country.Id;
                database.insert(add);
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = add.Id;
                con.AccountId = acc.Id;
                con.Recipient_Indicator__c = true;
                database.insert(con);
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                database.insert(billAcc);
                
                List<Id> listId = new List<id>{acc.id};
                 
                Test.startTest();        
                    SendQuotesToZuora newZuora = new SendQuotesToZuora();
                    newZuora.SendQuotesToZuora();
                    newZuora.RecievedData(listId, acc.id, billAcc.id, true);
                test.stopTest();
        }
}