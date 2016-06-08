/**
 * Class Name: SP_MidMonthStartProrationBatch_S_test
 * @author: April Veloso
 * Date: 4/7/2016
 * Requirement/Project Name: Singapore Press Holdings
 * @ test class for SP_MidMonthStartProrationBatch_Select
 */


@isTest(Seealldata=true)
public class SP_MidMonthStartProrationBatch_S_test {
     static testMethod void test_BT_AB_ARM068DX_ExportCreditAdjustment(){   
                
                Date_Configuration__c dateConfig = new Date_Configuration__c();
                dateConfig.Name = 'date';
                dateConfig.Date__c = date.today()+60;
                database.insert(dateConfig);
                
                Date referenceDate = UsageHelper.getUsageReferenceDate();
                Date firstDayOfNextMonth = referenceDate.addMonths(1).toStartofMonth();
                Date lastDayOfNextMonth = referenceDate.addMonths(2).toStartofMonth().addDays(-1); 
                
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
                
                list<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
                subRecs[0].Zuora__CustomerAccount__c = billAcc.Id;
                subRecs[0].Zuora__SubscriptionStartDate__c = date.today();
                subRecs[0].Term_Length1__c = '1.1';
                subRecs[0].Billing_Type__c = 'Recurring Prepaid';
                
                subRecs[1].Zuora__CustomerAccount__c = billAcc.Id;
                subRecs[1].Zuora__SubscriptionStartDate__c = date.today()-15;
                subRecs[1].Zuora__SubscriptionEndDate__c = date.today()+30;
                subRecs[1].Term_Length__c = 1;
                subRecs[1].Term_Length1__c = '1';
                subRecs[1].Billing_Type__c = 'Recurring Prepaid';
                subrecs[1].Zuora__Status__c = 'Active';
               
                subRecs[2].Zuora__CustomerAccount__c = billAcc.Id;
                subRecs[2].Zuora__SubscriptionStartDate__c = date.today()-30;
                subRecs[2].Zuora__SubscriptionEndDate__c = date.today();
                subRecs[2].Term_Length__c = 1;
                subRecs[2].Term_Length1__c = '1';
                subRecs[2].Billing_Type__c = 'Recurring Postpaid'; 
                subRecs[2].Zuora__TermSettingType__c = 'Evergreen';
                
                subRecs[3].Zuora__CustomerAccount__c = billAcc.Id;
                subRecs[3].Zuora__SubscriptionStartDate__c = date.today();
                subRecs[3].Zuora__SubscriptionEndDate__c = date.today()-30;
                subRecs[3].Term_Length__c = 1;
                subRecs[3].Term_Length1__c = '1';
                subRecs[3].Billing_Type__c = 'Recurring Prepaid';
                subrecs[3].Zuora__Status__c = 'Active';
               
                database.insert(subRecs);    
               //System.assertEquals(referenceDate , date.today());
               //System.assertEquals(subRecs[1].Zuora__SubscriptionStartDate__c , date.today());
               //System.assertEquals(subRecs[2].Zuora__SubscriptionEndDate__c, date.today());
               // System.assertEquals(firstDayOfNextMonth, date.today()); 
               
                               
                List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = Testdatafactory.createSubscriptionProductCharge(3);
                zSubProdCharge[0].Zuora__Type__c = 'Usage';
                zSubProdCharge[0].Zuora__Subscription__c = subRecs[0].id;
                zSubProdCharge[0].PublicationCode__c = '1234';
                
                zSubProdCharge[1].Zuora__Type__c = 'Usage';
                zSubProdCharge[1].Zuora__Subscription__c = subRecs[1].id;
                zSubProdCharge[1].PublicationCode__c = '1235';
                
                zSubProdCharge[2].Zuora__Type__c = 'Usage';
                zSubProdCharge[2].Zuora__Subscription__c = subRecs[2].id;
                zSubProdCharge[2].PublicationCode__c = '1236';
                database.insert(zSubProdCharge);
                
                              
                Set<String> accountNumberSet = new Set<String>();
                accountNumberSet.add(''+acc.id);
                Database.BatchableContext BC;
                
                      
                test.startTest();
                    SP_MidMonthStartProrationBatch_Select batch = new SP_MidMonthStartProrationBatch_Select(accountNumberSet);
                    ID batchprocessid = Database.executeBatch(batch, 200);
                    batch.execute(BC,subRecs);
                test.stopTest(); 
    }
}