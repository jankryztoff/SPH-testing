/**
 * Class Name: BT_AB_DIR094DX_VendorPerformanceTest
 * @author: Accenture IDC (Shruti Kishore)
 * Modified by: <Johnmar Diamante>
 * Modified Date: <6/19/2015>
 * Date: 2/17/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @ test class for BT_AB_DIR094DX_VendorPerformanceInfo
 * Edited by: April Veloso <04/07/2016>
 */


@isTest(Seealldata=true)
public class BT_AB_DIR094DX_VendorPerformanceTest {

    static testMethod void unitTest1(){
           
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
            
            List<Case> cs = TestDataFactory.createCase(2,'Complaint - Digital'); 
            database.insert(cs);
            
            Publication__c pub = TestdataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'Pcod';
            database.insert(pub);
            
            Subscription_Vendor__c subVen = TestdataFactory.createSubscriptionVendor(1)[0];
            subVen.Account__c = acc.id;
            subVen.Status__c = 'ACTIVE';
            subVen.Recipient__c = con.id;
            database.insert(subVen);
            
            Subscription_Vendor_Publication__c subVenPub = Testdatafactory.createSubVendorPublication(1)[0];   
            subVenPub.Account__c = acc.id;
            subVenPub.Publication__c = pub.id;
            database.insert(subVenPub);
            
            
            Case_Vendor_Subscription__c caseVenSub = TestdataFactory.createCaseVendorSub(1)[0];
            caseVenSub.Account__c = acc.id;
            caseVenSub.Address__c = add.id;
            caseVenSub.Case__c = cs[0].id;
            caseVenSub.Subscription_Vendor__c = subVen.id;
            database.insert(caseVenSub);
            
            
            test.startTest();
            
            
                 BT_AB_DIR094DX_VendorPerformanceInfo batch = new BT_AB_DIR094DX_VendorPerformanceInfo();
                 ID batchprocessid = Database.executeBatch(batch, 200);
            test.stopTest(); 
      }
}