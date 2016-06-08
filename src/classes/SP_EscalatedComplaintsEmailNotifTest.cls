/**
* Class Name: SP_EscalatedComplaintsEmailNotification
* @author: <April veloso>
* Date: <04/07/2016>
* Requirement/Project Name: <SPH>
*/

@isTest 
    private class SP_EscalatedComplaintsEmailNotifTest {
        static testMethod void test_SP_EscalatedComplaintsEmailNotification() {
                       
            Other__c other = new Other__c();
               other.Name = 'DTL';
               other.Value__c = '23:59';
               insert(other); 
               
              Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
                cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
                cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
                cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Sun_Start_Time__c = System.Now();
                cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
                cirPlannerSchedule.Name = 'CIR Plan Schedule';
                insert cirPlannerSchedule;
            
            
            User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    //UserRoleID = [SELECT USerRoleID from User where UserRoleId !=null LIMIT 1].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
            
                    System.RunAs(u){
            
                            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                            database.insert(acc);
                            
                            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                            postal.Name = 'Singapore';
                            postal.Street_Name__c = 'Street';
                            postal.Building_Name__c = 'building';
                            database.insert(postal);
                            
                            Country__c country = TestDataFactory.createCountry(1)[0];
                            country.Country_Name__c = 'country';
                            database.insert(country);
                            
                            Recordtype rectype = [SELECT Id, DeveloperName FROM Recordtype where sObjectType = 'Address__c' and Name = 'Local' LIMIT 1];
                            
                            Address__c add = TestDataFactory.createAddress(1)[0];
                            add.recordTypeId = rectype.id;
                            add.Block_House_Number__c = '10';
                            add.Postal_Code__c = postal.Id;
                            add.Level_Number__c = '12';
                            add.Unit_Number__c = '2B';
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
                            
                            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                            subRecs.Zuora__CustomerAccount__c = billAcc.Id;
                            subRecs.Zuora__SubscriptionStartDate__c = date.today();
                            subRecs.Term_Length1__c = '1.1';
                            subRecs.Recipient_Contact__c = con.id;
                            database.insert(subRecs);
                            
                            List<Case> caseList = TestDataFactory.createCase(1,'Complaint - Newspaper');
                            caseList[0].IsEscalated = True;
                            Database.insert(caseList);
                            
                            
                            Case_Subscription__c caseSubscription = new Case_Subscription__c ();
                            caseSubscription.Subscription__c = subRecs.id;
                            caseSubscription.Case__c = caseList[0].id;
                            database.insert(caseSubscription);
                            
                            Test.startTest();
                                          
                                SP_EscalatedComplaintsEmailNotification newTest = new SP_EscalatedComplaintsEmailNotification();   
                                newTest.emailVendorEscalatedComplaints(caseList);    
                            Test.stopTest();
            }
        }
}