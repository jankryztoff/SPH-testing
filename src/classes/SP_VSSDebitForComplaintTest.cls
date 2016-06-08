/**
  * Class Name: SP_VSSDebitForComplaintTest
  * @author: Accenture IDC - Nilesh
  * Date: 10 Feb 

2015


  * Requirement/Project Name: SPH Project
  * @description Test Class for SP_VSSDebitForComplaint
  * 
  */
@isTest(seeAllData = FALSE)
    public class SP_VSSDebitForComplaintTest {

    static testmethod void unitTest1() { 
    
            Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;
            /*
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '123457397';
            key.Type__c = 'Number';
            insert key;
            */
            
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            acct.AccountNumber= '011223344';
            acct.Vendor_Group__c = 'T';
            acct.Vendor_Code__c = 'Test';
            insert acct;
          
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: 'Customer Contact' LIMIT 1];
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
                
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
                       
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.RecordTypeId = rt.Id;
            con.Address__c = address.id;
            insert con;
            
            con.Recipient_Indicator__c = true;
            update con;
        
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acct.Id;
            billAcc.Zuora__Credit_Balance__c = 50000.00;
            billAcc.Billing_Type__c= 'Full Prepaid';
            database.insert(billAcc);
               
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acct.Id;
            order.Recipient_Contact__c = con.Id;
            order.Informed_Customer__c = True;
            order.Subscriber_Charge__c = 15;
            insert order;
        
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            list<string> configuredDtlDate = ConstantsSLB.getOther('DTL').split(':');
            
            Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Name = 'Test';
            subRec.Zuora__Account__c = acct.Id;
            subRec.Order_Number__c = order.Id;
            subRec.Subscriber_Contact__c = con.Id;
            subRec.Recipient_Contact__c = con.Id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            // subRec.Vendor__c = 'test123';
            //subRec.Vendor_1__c = acct.Id;
            //subRec.Order_Line_Item_Number__c = orderline.Id;
            subRec.Billing_Type__c = 'Full Prepaid';
            subRec.Zuora__CustomerAccount__c = billAcc.Id;
            subRec.Number_of_Copies__c=100;
            subRec.Number_of_Copies1__c =  '100';
            subRec.Qty__c = 20;
            subRec.Vendor__c = 'test';
            subRec.Vendor_1__c = acct.Id;
            subRec.Subscription_Type__c = 'Publication';
            insert subRec;
            
            //Cir_Planner_Schedule__c cirPlanner = TestDataFactory.createCir_Planner_Schedule();
            Cir_Planner_Schedule__c cirPlanner = new Cir_Planner_Schedule__c(); //  Cir_Planner_Schedule__c.getInstance('CIR Plan Schedule');
            cirPlanner.Name = 'CIR Plan Schedule';
            cirPlanner.Mon_Fri_End_Time__c = DateTime.newInstance(2015, 8, 3, 8, 6, 16);
            cirPlanner.Mon_Fri_Start_Time__c = DateTime.newInstance(2015, 8, 3, 6, 6, 16);
            cirPlanner.Sat_PH_End_Time__c = DateTime.newInstance(2015, 8, 8, 8, 6, 16); 
            cirPlanner.Sat_PH_Start_Time__c = DateTime.newInstance(2015, 8, 8, 6, 6, 16); 
            cirPlanner.Sun_End_Time__c = DateTime.newInstance(2015, 8, 9, 8, 6, 16); 
            cirPlanner.Sun_Start_Time__c = DateTime.newInstance(2015, 8, 9, 8, 6, 16);
            insert cirPlanner;
              
              
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Publication_Code__c = 'CD01';
            insert pub;
              
            Recordtype recType = [SELECT ID, Name FROM Recordtype WHERE sObjectType = 'Case' AND Name = 'Complaint - Newspaper' LIMIT 1];
          
            List<Case> caseList = TestDataFactory.createCase(1, 'Complaint - Newspaper');
            caseList[0].Account__c = acct.Id;
            caseList[0].Courier_Fee__c= 10.5;
            caseList[0].Paper_Fee__c = 2.5;
            caseList[0].Subscription_Name__c = subRec.Id;
            caseList[0].Vendor_Chargeable_Courier__c = TRUE;
            caseList[0].Vendor_Chargeable_Paper__c = TRUE;
            caseList[0].Recordtypeid=  recType.id;
            caseList[0].Status = 'Closed';
            //caseList[0].ClosedDate = date.Today()+1;
            //caseList[0].RecordType.DeveloperName = 'Complaint_Newspaper';
            insert caseList;
            
            List<Case> sampleC = [SELECT id FROM Case Where Courier_Fee__c = 10.5];
            System.assertNotEquals(null, sampleC.size());
            
            
            List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(1);
            caseSub[0].Account__c = acct.id;
            caseSub[0].Subscription__c = subRec.Id;
            caseSub[0].Case__c = caseList[0].id;
            caseSub[0].Address__c = address.id;
            caseSub[0].isComplaint__c = true;
            insert caseSub;
            
            List<BT_CO_VSS_CreditDebit__c> vssCreditDebit = TestDataFactory.createBT_CO_VSS_CreditDebit(1);
            insert vssCreditDebit;
            
            Case_Vendor_Fee__c caseVendor = new Case_Vendor_Fee__c();
            caseVendor.Case__c = caseList[0].id;
            caseVendor.Copies__c =  10;
            caseVendor.Paper_Fee__c = 5.50;
            caseVendor.Publication__c = pub[0].id;
            caseVendor.Subscription__c = subRec.Id;
            insert caseVendor;
            
                       
            Test.startTest();
             
            SP_VSSDebitForComplaint batch = new SP_VSSDebitForComplaint();
            database.executeBatch(batch,200);
            
            try
            {
                Database.BatchableContext BC;
                batch.execute(BC, caseList);
            } catch(exception e) {
                system.debug(':::ERROR ' + e);
           }
            
            
            SP_VSSDebitForComplaint batch2 = new SP_VSSDebitForComplaint(2, 1);
            
            Test.stopTest();
    }
}