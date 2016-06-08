/**
 * Class Name: BT_AB_ARM068DX_ExportCreditAdjTest
 * @author: April Veloso
 * Date: 4/7/2016
 * Requirement/Project Name: Singapore Press Holdings
 * @ test class for BT_AB_ARM068DX_ExportCreditAdjustment
 * Edited by: April Veloso <04/07/2016>
 */


@isTest(Seealldata=true)
public class BT_AB_ARM068DX_ExportCreditAdjTest {

    static testMethod void test_BT_AB_ARM068DX_ExportCreditAdjustment(){
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Generate_Account_Number__c = true;
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
        billAcc.ARMS_Account_Number__c = '765432';
        database.insert(billAcc);
        
        List<Case> cs = TestDataFactory.createCase(2,'Complaint - Digital'); 
        cs[0].Actual_Approver_Name__c = 'April';
        database.insert(cs);
        
        Credit_Adjustment__c creditAdj = new Credit_Adjustment__c();
        creditAdj.Billing_Account__c= billAcc.id;
        creditAdj.Case__c = cs[0].id;
        creditAdj.Credit_Amount__c = 10.50;
        creditAdj.Document_Date__c = date.today();
        creditAdj.Name = 'April';       
        database.insert(creditAdj);    
        
        
        test.startTest();
                 BT_AB_ARM068DX_ExportCreditAdjustment batch = new BT_AB_ARM068DX_ExportCreditAdjustment();
                 ID batchprocessid = Database.executeBatch(batch, 200);
        test.stopTest(); 
    }
}