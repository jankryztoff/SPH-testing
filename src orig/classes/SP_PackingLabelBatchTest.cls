/**
 * Class Name: SP_PackingLabelBatchTest
 * @author: Abolac, Jason A.
 * Date: April 07, 2016
 * @description: Test Class for SP_PackingLabelBatch
**/

@isTest (seeAllData= false)

    private class SP_PackingLabelBatchTest{
        static testMethod void testSP_PackingLabelBatchTest(){
            
            User testUser = new User(
                Alias='stndrd',
                Email='standarduser@test.com',
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = [Select Id From Profile Where Name = 'CSO Admin' LIMIT 1].Id,
                TimeZoneSidKey='America/Los_Angeles',
                //START: Test Class Update Added by Kristine Balaoing 04/29/2016
                UserName='standardSP01KC24@test.com'
                //END: Test Class Update Added by Kristine Balaoing 04/29/2016
            );
            System.runAs(testUser) {
            
                Date monthStart = Date.today();
                Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
                Date monthEnd = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);
                
                Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
                insert dtl; 

                Cir_Planner_Schedule__c cirPlanner = new Cir_Planner_Schedule__c( Name='CIR Plan Schedule', 
                Mon_Fri_End_Time__c=DateTime.newInstanceGMT(2014, 08, 19, 22, 00, 00),
                Mon_Fri_Start_Time__c=DateTime.newInstanceGMT(2014, 08, 19, 01, 00, 00),
                Sat_PH_End_Time__c=DateTime.newInstanceGMT(2014, 08, 18, 17, 00, 00),
                Sat_PH_Start_Time__c=DateTime.newInstanceGMT(2014, 08, 18, 08, 00, 00),
                Sun_End_Time__c=DateTime.newInstanceGMT(2014, 08, 18, 17, 00, 00),
                Sun_Start_Time__c= DateTime.newInstanceGMT(2014, 08, 18, 10, 00, 00));
                insert cirPlanner;
                //system.assertequals(cirPlanner, null);
                
                List<Account> accList = TestDataFactory.createAccount(3, 'Direct Individual');
                accList[0].NRIC__c = 'T1234567R';
                insert accList;
                
                //Mailing Agent
                List<Account> accList2 = TestDataFactory.createAccount(1, 'Mailing Agent');
                accList2[0].NRIC__c = 'T1232567R';
                insert accList2;
                
                //Vendor Account
                List<Account> accList3 = TestDataFactory.createAccount(1, 'Vendor');
                accList2[0].NRIC__c = 'T1632567R';
                insert accList3;
                
                list<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
                postal[1].Name = 'SPostal';
                postal[1].House_Block_Number__c = 'TEST';
                postal[1].Address_Type__c = 'A';
                insert postal;
                
                List<Package__c> packageList = TestDataFactory.createPackage(2);
                packageList[0].Package_Type__c = 'Base Product';                                  
                packageList[0].Billing_Type__c = 'Full Prepaid';
                packageList[0].Frequency_Identifier__c = '1';
                insert packageList;   
                
                list<Address__c> addressRec = TestDataFactory.createAddress(2);
                addressRec[0].Address_Type__c='P';
                addressRec[0].Postal_Code__c = postal[0].Id;
                addressRec[1].Address_Type__c = 'A';
                addressRec[1].Postal_Code__c = postal[1].Id;
                addressRec[1].Block_House_Number__c ='TEST';
                addressRec[1].Level_Number__c ='xx';
                addressRec[1].Unit_Number__c = 'yy';
                insert addressRec;
                
                //START PD-0104 12-May-2016 Added by Raviteja - Insert the NEXT_RECIPIENT_NUMBER custom setting
                Key_Id__c cs = new Key_Id__c();
                cs.Name='NEXT_RECIPIENT_NUMBER';
                cs.Id__c = '30465246';
                insert cs;
                //END PD-0104 12-May-2016 Added by Raviteja
                 
                List<Contact> conList = TestDataFactory.createContact(1);
                conList[0].AccountId = accList[0].Id;
                conList[0].Address__c = addressRec[0].Id;
                conList[0].Recipient_Indicator__c = true;
                conList[0].LastName = 'Last Name';
                conList[0].Billing_Indicator__c = TRUE; 
                conList[0].FirstName = 'First Name';
                conList[0].Phone = '1234567';
                conList[0].Mobile_Number__c = '09155568874'; 
                conList[0].Mobile_Number_2__c = '09112234567';
                conlist[0].Recipient_Number__c = 299999993;
                conlist[0].Recipient_Number_Show__c = '299999993';
                //system.assertequals(conList , null);
                insert conList;
                
                       
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = accList[0].Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__Credit_Balance__c = 1;
                insert billAcc;
                  
                //subscription 1  
                List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
                zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
                zuoSubList[0].Recipient_Contact__c= conList[0].Id;
                zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
                //zuoSubList[0].Vendor__c = accList[0].Id;
                zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
                zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
                zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
                zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
                zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
                zuoSubList[0].Main_Package__c = packageList[0].Id;
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Zuora__Account__c = accList[0].id;
                zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
                zuoSubList[0].Delivered_By__c = 'Mailing Agent';
                zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
                zuoSubList[0].Term_Length__c = 1;
                zuoSubList[0].Term_Length1__c = '1';
                zuoSubList[0].Vendor_1__c = accList2[0].Id;
                zuoSubList[0].Product_Code__c = 'STSU';
                zuoSubList[0].Frequency_1__c = 'Default';
                zuoSubList[0].Frequency__c = 'Default';
                insert zuoSubList;

                //subscription 2
                List <Zuora__Subscription__c> zuoSubList1 = TestDataFactory.createSubscription(1);
                zuoSubList1[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
                zuoSubList1[0].Recipient_Contact__c= conList[0].Id;
                zuoSubList1[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
                //zuoSubList[0].Vendor__c = accList[0].Id;
                zuoSubList1[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
                zuoSubList1[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
                zuoSubList1[0].Zuora__SubscriptionStartDate__c = date.today()-10;
                zuoSubList1[0].Zuora__SubscriptionEndDate__c = date.today()+10;
                zuoSubList1[0].Subscription_End_Date__c = string.valueof(date.today()+10);
                zuoSubList1[0].Main_Package__c = packageList[0].Id;
                zuoSubList1[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList1[0].Zuora__Account__c = accList[0].id;
                zuoSubList1[0].Subscriber_Contact__c= conList[0].Id;
                zuoSubList1[0].Delivered_By__c = 'Mailing Agent';
                zuoSubList1[0].Delivered_By_1__c = 'Mailing Agent';
                zuoSubList1[0].Term_Length__c = 1;
                zuoSubList1[0].Term_Length1__c = '1';
                zuoSubList1[0].Vendor_1__c = accList2[0].Id;
                zuoSubList1[0].Product_Code__c = 'STSU';
                zuoSubList1[0].Frequency_1__c = 'Default';
                zuoSubList1[0].Frequency__c = 'Default';
                insert zuoSubList1;
                
                //subscription 3
                List <Zuora__Subscription__c> zuoSubList2 = TestDataFactory.createSubscription(1);
                zuoSubList2[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
                zuoSubList2[0].Recipient_Contact__c= conList[0].Id;
                zuoSubList2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
                //zuoSubList[0].Vendor__c = accList[0].Id;
                zuoSubList2[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
                zuoSubList2[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
                zuoSubList2[0].Zuora__SubscriptionStartDate__c = date.today()-10;
                zuoSubList2[0].Zuora__SubscriptionEndDate__c = date.today()+10;
                zuoSubList2[0].Subscription_End_Date__c = string.valueof(date.today()+10);
                zuoSubList2[0].Main_Package__c = packageList[0].Id;
                zuoSubList2[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList2[0].Zuora__Account__c = accList[0].id;
                zuoSubList2[0].Subscriber_Contact__c= conList[0].Id;
                zuoSubList2[0].Delivered_By__c = 'Mailing Agent';
                zuoSubList2[0].Delivered_By_1__c = 'Mailing Agent';
                zuoSubList2[0].Term_Length__c = 1;
                zuoSubList2[0].Term_Length1__c = '1';
                zuoSubList2[0].Vendor_1__c = accList2[0].Id;
                zuoSubList2[0].Product_Code__c = 'STSU';
                zuoSubList2[0].Frequency_1__c = 'Default';
                zuoSubList2[0].Frequency__c = 'Default';
                insert zuoSubList2;
                
                list<zqu__ZProduct__c> zProd = TestDataFactory.createZProduct(2);
                zProd[0].ProductCode__c = 'STSU';
                zProd[1].ProductCode__c = 'STSU';
                insert zProd;
                
                list<Publication__c> pubCode = TestDataFactory.createPublication(2);
                pubCode[0].Platform_Type__c = 'Print';
                pubCode[0].Publication_Next_Start_Date__c = Date.today()-5;
                pubCode[0].Frequency_Code__c = 'D';
                pubCode[0].Published_Days__c = 'YYYYYYY';
                pubCode[1].Platform_Type__c = 'Print';
                pubCode[1].Publication_Next_Start_Date__c = Date.today()-5;
                pubCode[1].Frequency_Code__c = 'W';
                pubCode[1].Published_Days__c = 'YYYYYYY';
                insert pubCode;
        
                List<Product_Publication__c> proPub = TestDataFactory.createProductPublication(2);
                proPub[0].Publication_Code__c = pubCode[0].id;
                proPub[0].ZProduct__c = zProd[0].id;
                proPub[1].Publication_Code__c = pubCode[1].id;
                proPub[1].ZProduct__c = zProd[1].id;
                insert proPub;


                //publication daily issue 1
                List<Publication_Daily_Issue_Data__c> pubDailyIssue = new List<Publication_Daily_Issue_Data__c>();
                Publication_Daily_Issue_Data__c pubDaily = new Publication_Daily_Issue_Data__c();
                pubDaily.Publication__c = pubCode[0].id;
                pubDaily.Publication_Code__c = 'STSU';
                pubDaily.Consolidation_Date__c = Date.today();
                pubDaily.Order_Closed_Indicator__c = 'Y';
                pubDaily.Publication_Issue_Date__c = Date.today()+14;       
                pubDailyIssue.add(pubDaily);
                //publication daily issue 2
                Publication_Daily_Issue_Data__c pubDaily1 = new Publication_Daily_Issue_Data__c();
                pubDaily1.Publication__c = pubCode[1].id;
                pubDaily1.Publication_Code__c = 'STSU';
                pubDaily1.Consolidation_Date__c = Date.today();
                pubDaily1.Order_Closed_Indicator__c = 'Y';
                pubDaily1.Publication_Issue_Date__c = Date.today()+14;       
                pubDailyIssue.add(pubDaily1);
                insert pubDailyIssue;
                
                //nonpub day1
                List<Non_Publication_Day__c> nonPubDay = new List<Non_Publication_Day__c>();
                Non_Publication_Day__c nonPub = new Non_Publication_Day__c();
                nonPub.Publication__c = pubCode[0].id;
                nonPub.Publication_Code__c = 'STSU';
                nonPub.Non_Publication_Date__c = Date.today()+1;
                nonPubDay.add(nonPub);
                //nonpub day 2
                List<Non_Publication_Day__c> nonPubDay1 = new List<Non_Publication_Day__c>();
                Non_Publication_Day__c nonPub1 = new Non_Publication_Day__c();
                nonPub1.Publication__c = pubCode[1].id;
                nonPub1.Publication_Code__c = 'STSU';
                nonPub1.Non_Publication_Date__c = Date.today()+1;
                nonPubDay.add(nonPub1);
                insert nonPubDay;           
                
                List<Public_Holiday__c> publicHoliday = new List<Public_Holiday__c>();
                Public_Holiday__c pubHol = new Public_Holiday__c();
                pubHol.Holiday_Date__c = Date.today()+3;
                publicHoliday.add(pubHol);
                insert publicHoliday;
                
                //Case 1
                List<Case> changeAddress = new List<Case>();
                Case changeAdd = new Case();
                changeAdd.AccountId = accList[0].Id;
                changeAdd.Effective_Date__c = Date.today()+1;
                changeAdd.Contact_To_Update__c = conList[0].Id;
                changeAdd.Status = GlobalVariableClass.STATUS_CLOSED;
                changeAdd.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
                changeAdd.Subscription_Name__c = zuoSubList1[0].id;
                changeAdd.Vendor__c = accList3[0].Id;
                changeAdd.Within_Circulation_Planning_Schedule__c = false;
                changeAddress.add(changeAdd);
                //Case 2
                Case changeAdd1 = new Case();
                changeAdd1.AccountId = accList[0].Id;
                changeAdd1.Effective_Date__c = Date.today()+1;
                changeAdd1.Contact_To_Update__c = conList[0].Id;
                changeAdd1.Status = GlobalVariableClass.STATUS_CLOSED;
                changeAdd1.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
                changeAdd1.Subscription_Name__c = zuoSubList2[0].id;
                changeAdd1.Within_Circulation_Planning_Schedule__c = false;
                changeAddress.add(changeAdd1);
                insert changeAddress;
                
                //Case Sub1
                List<Case_Subscription__c> caseSubscription = new List<Case_Subscription__c>();
                Case_Subscription__c caseSub = new Case_Subscription__c();
                caseSub.Case__c = changeAddress[0].Id;
                caseSub.Account__c = accList[0].Id;
                caseSub.Subscription__c = zuoSubList1[0].id;
                caseSub.isComplaint__c = false;
                caseSubscription.add(caseSub);
                //Case Sub2
                Case_Subscription__c caseSub1 = new Case_Subscription__c();
                caseSub1.Case__c = changeAddress[1].Id;
                caseSub1.Account__c = accList[0].Id;
                caseSub1.Subscription__c = zuoSubList2[0].id;
                caseSub1.isComplaint__c = false;
                caseSubscription.add(caseSub1);
                insert caseSubscription;
            
                
                //Address Assignment
                list<Address_Assignment__c> addressAssign = new list<Address_Assignment__c>();
                Address_Assignment__c addAssign = new Address_Assignment__c();
                addAssign.Case__c = changeAddress[1].id;
                addAssign.Vendor__c = accList3[0].Id;
                addAssign.Effective_Date__c = Date.today();
                addAssign.Contact__c = conlist[0].id;
                addAssign.Address__c = addressRec[1].id;
                addressAssign.add(addAssign);
                insert addressAssign;
                
                
                List<CMIS_POP_Packing_label_Batch__c> cmisPopPackingLabel = new List<CMIS_POP_Packing_label_Batch__c>();
                CMIS_POP_Packing_label_Batch__c cmisPopPack = new CMIS_POP_Packing_label_Batch__c();        
                cmisPopPack.Publication_Code__c = 'STSU';
                cmisPopPack.Publication_Issue_Date__c = Date.today();
                cmisPopPack.Mailing_Agent__c = 'MLAGN';
                cmisPopPack.Subscription__c = zuoSubList[0].id;
                cmisPopPack.Total_Direct_Subscriptions__c = 1;
                cmisPopPack.Total_Local_Freelist_Copies__c = 0;
                cmisPopPack.Total_Local_Subscription_Copies__c = 2;
                cmisPopPack.Total_Overseas_Freelist_Copies__c = 0;
                cmisPopPack.Total_Overseas_Subscription_Copies__c = 0;
                cmisPopPack.Total_Sponsored_Copies__c = 0;
                cmisPopPack.Vendor_Group__c = 'V';
                cmisPopPack.Batch_Run_Date__c = Date.today();
                cmisPopPackingLabel.add(cmisPopPack);
                insert cmisPopPackingLabel;
                Test.setCreatedDate(cmisPopPackingLabel[0].id, Datetime.now().AddDays(-1));
                
                List<Temp_Stop__c> tempStopRec = new List<Temp_Stop__c>();
                Temp_Stop__c tempStop = new Temp_Stop__c();
                tempStop.Cancelled__c = false;
                tempStop.Restart_Date__c = Date.Today()+1;
                tempStop.Temp_Stop_Qty__c = 2 ;
                tempStop.Qty__c = 4 ;
                tempStop.Temp_Stop_Date__c = Date.today()-1;
                tempStopRec.add(tempStop);
                Temp_Stop__c tempStop1 = new Temp_Stop__c();
                tempStop1.Cancelled__c = false;
                tempStop1.Restart_Date__c = Date.Today()+1;
                tempStop1.Temp_Stop_Qty__c = 2 ;
                tempStop1.Qty__c = 4 ;
                tempStop1.Temp_Stop_Date__c = Date.today()-1;
                tempStopRec.add(tempStop1);
                insert tempStopRec;
                
                List<Subscription_Temp_Stop__c> subscriptionTempStop = new List<Subscription_Temp_Stop__c>();
                Subscription_Temp_Stop__c subTempStop = new Subscription_Temp_Stop__c();
                subTempStop.Subscription__c = zuoSubList[0].id;
                subTempStop.Temp_Stop__c = tempStopRec[0].id;
                subscriptionTempStop.add(subTempStop);
                Subscription_Temp_Stop__c subTempStop1 = new Subscription_Temp_Stop__c();
                subTempStop1.Subscription__c = zuoSubList[0].id;
                subTempStop1.Temp_Stop__c = tempStopRec[1].id;
                subscriptionTempStop.add(subTempStop1);
                insert subscriptionTempStop;
                
                
                /*
                Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = accList[0].Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList[0].Id;
                orderRec.Billing_Contact__c = conList[0].Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.Base_Subscription__c = zuoSubList[0].id; 
                insert orderRec;
                */
                
                Test.startTest();
                //system.assertequals(zuoSubList , null);
                SP_PackingLabelBatch batch = new SP_PackingLabelBatch();
                Database.executeBatch(batch, 200); 
                Test.stopTest();
            }
        }

    }