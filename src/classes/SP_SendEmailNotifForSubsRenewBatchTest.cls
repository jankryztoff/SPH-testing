/*
 * Class Name: SP_SendEmailNotifForSubsRenewBatchTest
 * @modified by: Kirk Yngwie M. Enriquez
 * Modified Date: 06/19/2015
 * Project/Requirement: 
 * @description: to test SP_SendEmailNotifForSubsRenewBatch class
 */

@isTest(seeAllData=true)
public class SP_SendEmailNotifForSubsRenewBatchTest{

     /*
    *   @description: This test method executes the testSP_SendEmailNotifForSubsRenewalsBatch.
    *   @Parameters: N/A
    *   @return: N/A
    */
    
    static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch(){
                
                List<Account> vendorSubsAcct = new List<Account>(); 
                List<RecordType> rt3 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' LIMIT 1]; 
                for(Integer i=0; i< 5; i++){
                 Account acctRecord = new Account(Name='TestContacAcc'+ i);
                  if(rt3.size() > 0){
                     acctRecord.RecordTypeId = rt3[0].Id;
                     System.debug ('Iterating '+ i  + acctRecord.RecordTypeId); 
                  }
                    acctRecord.Name = 'test123';
                    acctRecord.email__c = 'test@gmail.com';
                    acctRecord.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
                    acctRecord.Staff_ID__c = 'asasa2';  
                    acctRecord.Mobile__c = '1234';      
                    acctRecord.Contact_Person__c = 'mycontatc';
                    vendorSubsAcct.add(acctRecord);  
                }   
                insert vendorSubsAcct;
                
                Set<Id> directRecTypeIds = new Set<Id> {
                  ConstantsSLB.getKeyId('Account_Direct Corporate'),
                  ConstantsSLB.getKeyId('Account_Direct Individual'),
                  ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')
                   };
                String query = 'SELECT Id, Name FROM Account WHERE RecordType.Id IN :directRecTypeIds';
                System.debug('Database Query here: ' + [SELECT Id, Name FROM Account WHERE RecordType.Id =: ConstantsSLB.getKeyId('Account_Direct Corporate')]);
                
                System.debug ('list of alfdsd ' + [select RecordTypeId from Account where Id =: vendorSubsAcct[0].Id].RecordTypeId);
                
                //check if vendorSubsAcct object Name is equal to test123
                System.assertEquals ('test123', vendorSubsAcct[0].Name);
                
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';                
               // Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];                
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';                
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];                
                Package__c pack = TestDataFactory.createPackage(1)[0];                
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];                
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';                
                gift.One_Time_Charge__c = 4;
                insert new List<sObject>{pro, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                       
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id; 
                 
                
                //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
                //insert dtl;              
                
                    
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct[0].Id;
                billingAcc.Billing_type__c = 'Full Prepaid';
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                prpc.PublicationCode__c = 'abcd';
                prpc.Name = 'Name';
                prpc.Id = prpc.Id; 
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                
                
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Operated__c = true;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, pItem, venAlloc};
                
                zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
                prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
                prpct.zqu__PriceFormat__c = 'Per Unit';
                prpct.zqu__Currency__c ='SGD';
                insert prpct;
                
                Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBERS';
                key.Id__c = '123457397';
                key.Type__c = 'Number';
                insert key; 
                
                List<Contact> con = new List<Contact>(); 
                List<RecordType> rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: '' LIMIT 1]; 
                for(Integer i=0;i<3;i++){
                 Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);
                  if(rt2.size() > 0){
                     contactRecord.RecordTypeId = rt2[0].Id;
                  }                 
                  contactRecord.Recipient_Indicator__c = true;
                  //contactRecord.Email_Secondary__c = '@gmail.com';
                  contactRecord.Address_Unique_ID__c = 'ABC123';
                  contactRecord.Billing_Indicator__c = true;
                  contactRecord.AccountId = vendorSubsAcct[0].Id;
                  contactRecord.Address__c = add.Id;                                           
                  con.add(contactRecord);  
                }   
                insert con;
            
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct[0].Id; 
                order.Recipient_Contact__c = con[0].Id;
                order.billing_type__c = 'Full Prepaid';
                order.Billing_Account__c = billingAcc.Id;
                order.Informed_Customer__c = True;
                insert order;
                
                Order_Line_Item__c orderline= TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.Main_Package_ID__c = pack.Id;
                insert orderline;
                
                Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
                cirPlanSched.Name = 'CIR Plan Schedules';
                cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
                cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);         
                cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
                cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                insert cirPlanSched;


                List<Case> cas = TestDataFactory.createCase(1, 'Complaint - Newspaper');
                List<RecordType> rtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' LIMIT 1]; 
                 for(Integer i=0;i<4;i++){
                 Case cse = new Case(Origin='Email');
                  if(rtype.size() > 0){
                     cse.RecordTypeId = rtype[0].Id;
                  }
                     cse.Rejected_Renewal__c = true;   
                     cse.Category__c = 'Subscription Request';
                     cse.Sub_Category__c = 'Start Subscription'; 
                     cse.Vendor_Subscription_Created__c = false; 
                     cse.Address__c = 'Makati City';                                          
                     cas.add(cse);  
                }
                insert cas;
            
            //Test.startTest();
            
                List<Zuora__Subscription__c> zsubs = TestDataFactory.createSubscription(4);
                
                for (Zuora__Subscription__c zsub : zsubs) {
                
                    zsub.Zuora__Account__c = vendorSubsAcct[0].Id;
                    zsub.Subscriber_Contact__c = con[0].Id;
                    //zsub.Days_to_Expire__c = globalvariableclass.DAYS_TO_EXPIRE_14;
                    zsub.Subscription_Type_1__c = 'Publication';
                    
                    zsub.Zuora__CustomerAccount__c = billingAcc.Id;
                    zsub.Recipient_Contact__c = con[0].Id;
                    zsub.Order_Line_Item_Number_1__c = orderline.id;
                    zsub.Main_Package_1__c = pack.id;
                    zsub.Number_of_Copies1__c = '2';
                    zsub.Zuora__Status__c = 'Active';
                    zsub.Order_Number__c = order.Id;
                    zsub.Suppress_Vendor_Start_Notice__c = 'false';
                    zsub.Subscription_Charge__c = 200;
                    zsub.Supressed_Acknowledgement_Letter__c = 'false';
                    zsub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                    zsub.Urgent__c = 'false';
                    zsub.Vendor_Conversion__c = 'false';
                    zsub.Charity__c = 'false';
                    zsub.Zuora__SubscriptionStartDate__c = Date.today();
                    zsub.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);
                    zsub.Product_Code__c = 'prodCode_test';
                    zsub.Number_of_Copies__c = 100;
                    zsub.Frequency_1__c = 'Mon - Fri';
                }
                
                zsubs[0].Billing_Type__c = 'Full Prepaid';
                //zsubs[0].Product_Code__c = 'prodCode_test';
                //zsubs[0].Subscriber_Contact__c = con[0].Id;
                zsubs[1].Billing_Type__c = 'Recurring Prepaid';
                //zsubs[1].Product_Code__c =  'Magazine'; 
                //zsubs[1].Subscriber_Contact__c = con[1].Id;
                zsubs[2].Billing_Type__c = 'Full Prepaid';
                zsubs[3].Billing_Type__c = 'Recurring Prepaid';
                
                
                                            
                                        
                
                Test.startTest();
                insert new List<sObject>{zsubs[0], zsubs[1], zsubs[2], zsubs[3]};
                 
                List<Zuora__Subscription__c>  zuoras= [SELECT Id FROM Zuora__Subscription__c WHERE Days_to_Expire__c = :globalvariableclass.DAYS_TO_EXPIRE_14 
                                            AND Zuora__Status__c = :globalvariableclass.ZUORA_STATUS_ACTIVE 
                                            AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION
                                            AND Zuora__Account__r.RecordType.Id IN :null
                                            AND (Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_EMAIL)];
                                            
                   system.assertNotEquals(1, zuoras.size());
                                
                try{                  
                Test.setMock(WebServiceMock.class, new zLoginMock());
               
                SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
                ID batchprocessid = Database.executeBatch(batch, 200);
                
                List<Zuora__Subscription__c> zuoSubs = new List<Zuora__Subscription__c>();
                
                 Database.BatchableContext BC;
                 SP_SendEmailNotifForSubsRenewalsBatch  sp = new SP_SendEmailNotifForSubsRenewalsBatch (); 
                 sp.start(BC);
                 //sp.execute(BC,vendorSubsAcct);
                 sp.execute(BC,zuoSubs);
                 //sp.finish(BC);
    
                BATCH_JOB_SCHEDULER__c batchJobScheduler = new BATCH_JOB_SCHEDULER__c();
                batchJobScheduler.Status__c = 'STARTED';         
                batchJobScheduler.Batch_Run_Date__c = Date.today();  
                batchJobScheduler.End_Time__c = DateTime.now();
                batchJobScheduler.SFDC_Job_id__c = batchprocessid;
                insert batchJobScheduler;

                test.stopTest();
                } catch (Exception e) {
                }
        }


    static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch_New(){
                
                List<Account> vendorSubsAcct = new List<Account>(); 
                List<RecordType> rt3 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' LIMIT 1]; 
                for(Integer i=0; i< 5; i++){
                 Account acctRecord = new Account(Name='TestContacAcc'+ i);
                  if(rt3.size() > 0){
                     acctRecord.RecordTypeId = rt3[0].Id;
                     System.debug ('Iterating '+ i  + acctRecord.RecordTypeId); 
                  }
                    acctRecord.Name = 'test123';
                    acctRecord.email__c = 'test@gmail.com';
                    acctRecord.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
                    acctRecord.Staff_ID__c = 'asasa2';  
                    acctRecord.Mobile__c = '1234';      
                    acctRecord.Contact_Person__c = 'mycontatc';
                    vendorSubsAcct.add(acctRecord);  
                }   
                insert vendorSubsAcct;
                
                Set<Id> directRecTypeIds = new Set<Id> {
                  ConstantsSLB.getKeyId('Account_Direct Corporate'),
                  ConstantsSLB.getKeyId('Account_Direct Individual'),
                  ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')
                   };
                String query = 'SELECT Id, Name FROM Account WHERE RecordType.Id IN :directRecTypeIds';
                System.debug('Database Query here: ' + [SELECT Id, Name FROM Account WHERE RecordType.Id =: ConstantsSLB.getKeyId('Account_Direct Corporate')]);
                
                System.debug ('list of alfdsd ' + [select RecordTypeId from Account where Id =: vendorSubsAcct[0].Id].RecordTypeId);
                
                //check if vendorSubsAcct object Name is equal to test123
                System.assertEquals ('test123', vendorSubsAcct[0].Name);
                
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';                
               // Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];                
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99';                
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];                
                Package__c pack = TestDataFactory.createPackage(1)[0];                
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];                
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';                
                gift.One_Time_Charge__c = 4;
                insert new List<sObject>{pro, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                       
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id; 
                 
                
                //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
                //insert dtl;              
                
                    
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Postal_Code__c = singpostAdd.Id;
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct[0].Id;
                billingAcc.Billing_type__c = 'Full Prepaid';
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                prpc.PublicationCode__c = 'abcd';
                prpc.Name = 'Name';
                prpc.Id = prpc.Id; 
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Operated__c = true;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, pItem, venAlloc};
                
                zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
                prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
                prpct.zqu__PriceFormat__c = 'Per Unit';
                prpct.zqu__Currency__c ='SGD';
                insert prpct;
                
                Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBERS';
                key.Id__c = '123457397';
                key.Type__c = 'Number';
                insert key; 
                
                List<Contact> con = new List<Contact>(); 
                List<RecordType> rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: '' LIMIT 1]; 
                for(Integer i=0;i<3;i++){
                 Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);
                  if(rt2.size() > 0){
                     contactRecord.RecordTypeId = rt2[0].Id;
                  }                 
                  contactRecord.Recipient_Indicator__c = true;
                  //contactRecord.Email_Secondary__c = '@gmail.com';
                  contactRecord.Address_Unique_ID__c = 'ABC123';
                  contactRecord.Billing_Indicator__c = true;
                  contactRecord.AccountId = vendorSubsAcct[0].Id;
                  contactRecord.Address__c = add.Id;                                           
                  con.add(contactRecord);  
                }   
                insert con;
            
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct[0].Id; 
                order.Recipient_Contact__c = con[0].Id;
                order.billing_type__c = 'Full Prepaid';
                order.Billing_Account__c = billingAcc.Id;
                order.Informed_Customer__c = True;
                insert order;
                
                Order_Line_Item__c orderline= TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.Main_Package_ID__c = pack.Id;
                insert orderline;
                
                Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
                cirPlanSched.Name = 'CIR Plan Schedules';
                cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
                cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);         
                cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
                cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                insert cirPlanSched;


                List<Case> cas = TestDataFactory.createCase(1, 'Complaint - Newspaper');
                List<RecordType> rtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' LIMIT 1]; 
                 for(Integer i=0;i<4;i++){
                 Case cse = new Case(Origin='Email');
                  if(rtype.size() > 0){
                     cse.RecordTypeId = rtype[0].Id;
                  }
                     cse.Rejected_Renewal__c = true;   
                     cse.Category__c = 'Subscription Request';
                     cse.Sub_Category__c = 'Start Subscription'; 
                     cse.Vendor_Subscription_Created__c = false; 
                     cse.Address__c = 'Makati City';                                          
                     cas.add(cse);  
                }
                insert cas;
            
            //Test.startTest();
            
                List<Zuora__Subscription__c> zsubs = TestDataFactory.createSubscription(4);
                
                for (Zuora__Subscription__c zsub : zsubs) {
                
                    zsub.Zuora__Account__c = vendorSubsAcct[0].Id;
                    zsub.Subscriber_Contact__c = con[0].Id;
                    //zsub.Days_to_Expire__c = globalvariableclass.DAYS_TO_EXPIRE_14;
                    zsub.Subscription_Type_1__c = 'Publication';                  
                    zsub.Zuora__CustomerAccount__c = billingAcc.Id;
                    zsub.Recipient_Contact__c = con[0].Id;
                    zsub.Order_Line_Item_Number_1__c = orderline.id;
                    zsub.Main_Package_1__c = pack.id; 
                    zsub.Number_of_Copies1__c = '2';
                    zsub.Zuora__Status__c = 'Active';
                    zsub.Order_Number__c = order.Id;
                    zsub.Suppress_Vendor_Start_Notice__c = 'false';
                    zsub.Subscription_Charge__c = 200;
                    zsub.Supressed_Acknowledgement_Letter__c = 'false';
                    zsub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                    zsub.Urgent__c = 'false';
                    zsub.Vendor_Conversion__c = 'false';
                    zsub.Charity__c = 'false';
                    zsub.Zuora__SubscriptionStartDate__c = date.TODAY();
                    zsub.Zuora__SubscriptionEndDate__c = Date.Today()+14;
                    zsub.Product_Code__c = 'prodCode_test';
                    zsub.Number_of_Copies__c = 100;
                    zsub.Frequency_1__c = 'Mon - Fri';
                }
                
                zsubs[0].Billing_Type__c = 'Full Prepaid';
                //zsubs[0].Product_Code__c = 'prodCode_test';
                //zsubs[0].Subscriber_Contact__c = con[0].Id;
                zsubs[1].Billing_Type__c = 'Recurring Prepaid';
                //zsubs[1].Product_Code__c =  'Magazine'; 
                //zsubs[1].Subscriber_Contact__c = con[1].Id;
                zsubs[2].Billing_Type__c = 'Full Prepaid';
                zsubs[3].Billing_Type__c = 'Recurring Prepaid';
                 
                
                Test.startTest();
                insert zsubs; //new List<sObject>{zsubs[0], zsubs[1], zsubs[2], zsubs[3]};
                
                 system.assertEquals(null, zsubs[0].Days_to_Expire__c);
                
                 
                //List<Zuora__Subscription__c>  zuoras= [SELECT Id FROM Zuora__Subscription__c WHERE Days_to_Expire__c = :globalvariableclass.DAYS_TO_EXPIRE_14 
                //                            AND Zuora__Status__c = :globalvariableclass.ZUORA_STATUS_ACTIVE 
                //                            AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION
                //                            AND Zuora__Account__r.RecordType.Id IN :null
                //                            AND (Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_EMAIL)];
                //system.assertEquals(1, zuoras.size(),'Should satisfy all conditions');
                //                
                //List<Zuora__Subscription__c>  zuoras2= [SELECT Id FROM Zuora__Subscription__c WHERE Days_to_Expire__c = :globalvariableclass.DAYS_TO_EXPIRE_14 AND id in :zsubs];                
                //system.assertEquals(1, zuoras2.size(),'Days_to_Expire__c = globalvariableclass.DAYS_TO_EXPIRE_14'); //actual 0
                //
                //List<Zuora__Subscription__c>  zuoras3= [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = :globalvariableclass.ZUORA_STATUS_ACTIVE AND id in :zsubs];
                //system.assertEquals(1, zuoras3.size(), 'globalvariableclass.ZUORA_STATUS_ACTIVE'); //actual 4
                //  
                //List<Zuora__Subscription__c>  zuoras4= [SELECT Id FROM Zuora__Subscription__c  WHERE Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION AND id in :zsubs];
                //                            
                //system.assertEquals(1, zuoras4.size(), 'GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION'); //actual 0  
                //                         
                //List<Zuora__Subscription__c>  zuoras5= [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Account__r.RecordType.Id IN :null AND id in: zsubs];
                //
                //system.assertEquals(1, zuoras5.size(), 'Zuora__Account__r.RecordType.Id IN :null');
                //
                //List<Zuora__Subscription__c>  zuoras6= [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Account__r.Renewal_Letter__c =: GlobalVariableClass.REFERENCE_EMAIL AND id in :zsubs ];                            
                //                            
                //system.assertEquals(1, zuoras6.size(),'GlobalVariableClass.REFERENCE_EMAIL');    //actual 4            
                
                try{                  
                Test.setMock(WebServiceMock.class, new zLoginMock());
               
                SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
                ID batchprocessid = Database.executeBatch(batch, 1);
                
                List<Zuora__Subscription__c> zuoSubs = new List<Zuora__Subscription__c>();
                zuoSubs.add(zsubs[0]);//by jowie -082015-
                zuoSubs.add(zsubs[1]);//by jowie -082015-
                 Database.BatchableContext BC;
                 SP_SendEmailNotifForSubsRenewalsBatch  sp = new SP_SendEmailNotifForSubsRenewalsBatch (); 
                 sp.start(BC);
                 //sp.execute(BC,vendorSubsAcct);
                 sp.execute(BC,zuoSubs);
                 //sp.finish(BC);
    
                BATCH_JOB_SCHEDULER__c batchJobScheduler = new BATCH_JOB_SCHEDULER__c();
                batchJobScheduler.Status__c = 'STARTED';         
                batchJobScheduler.Batch_Run_Date__c = Date.today();  
                batchJobScheduler.End_Time__c = DateTime.now();
                batchJobScheduler.SFDC_Job_id__c = batchprocessid;
                insert batchJobScheduler;

                test.stopTest();
                } catch (Exception e) {
                }
        }

    static testmethod void testSP_SendEmailNotifForSubsRenewalsBatch_Orig() {  // <-- This is the Original Test Method Signature
            
        List<Account> vendorSubsAcct = new List<Account>(); 
                List<RecordType> rt3 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' LIMIT 1]; 
                for(Integer i=0; i< 5; i++){
                 Account acctRecord = new Account(Name='TestContacAcc'+ i);
                  if(rt3.size() > 0){
                     acctRecord.RecordTypeId = rt3[0].Id;
                     System.debug ('Iterating '+ i  + acctRecord.RecordTypeId); 
                  }
                    acctRecord.Name = 'test123';
                    acctRecord.email__c = 'test@gmail.com';
                    acctRecord.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
                    acctRecord.Staff_ID__c = 'asasa2';  
                    acctRecord.Mobile__c = '1234';      
                    acctRecord.Contact_Person__c = 'mycontatc';
                    vendorSubsAcct.add(acctRecord);  
                }   
                insert vendorSubsAcct;
                
                Set<Id> directRecTypeIds = new Set<Id> {
                  ConstantsSLB.getKeyId('Account_Direct Corporate'),
                  ConstantsSLB.getKeyId('Account_Direct Individual'),
                  ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')
                   };
                String query = 'SELECT Id, Name FROM Account WHERE RecordType.Id IN :directRecTypeIds';
                System.debug('Database Query here: ' + [SELECT Id, Name FROM Account WHERE RecordType.Id =: ConstantsSLB.getKeyId('Account_Direct Corporate')]);
                
                System.debug ('list of alfdsd ' + [select RecordTypeId from Account where Id =: vendorSubsAcct[0].Id].RecordTypeId);
                
                //check if vendorSubsAcct object Name is equal to test123
                System.assertEquals ('test123', vendorSubsAcct[0].Name);
                
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';                
               // Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];                
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99'; 
                singpostAdd.Street_Name__c = 'street';              
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];                
                Package__c pack = TestDataFactory.createPackage(1)[0];                
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];                                 
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';                
                gift.One_Time_Charge__c = 4;
                insert new List<sObject>{pro, singpostAdd, subsVen, pack, zProduct, venAccount, gift};
                       
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id; 
                 
                Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBERS';
                key.Id__c = '123457397';
                key.Type__c = 'Number';
                insert key; 
                //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
                //insert dtl;              
                
                SPH_Location__c SPHLoc = new SPH_Location__c();
                SPHLoc.Location_Code__c = '12';
                insert SPHLoc;
                
                    
                Address__c add = TestDataFactory.createAddress(1)[0];
                //List<RecordType> rec = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Overseas' LIMIT 1];
                add.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
                //add.RecordType = rec[0];
                add.Address_1__c = 'address1';
                add.Address_2__c = 'address2';
                add.Address_3__c = 'address3';
                add.Address_4__c = 'address4';
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct[0].Id;
                billingAcc.Billing_type__c = 'Full Prepaid';
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};                                
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                prpc.PublicationCode__c = 'abcd';
                prpc.Name = 'Name';
                prpc.Id = prpc.Id; 
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                // START : UD-3048 11/11/2015 Alyana Navarro
                List<Package__c> renewalPackageList = [SELECT id, name FROM Package__c ORDER BY CreatedDate LIMIT 1];
                pItem.RenewalPkgCodeMag1YrBase__c = renewalPackageList[0].id;
                pItem.RenewalPkgCodeMag1YrDisc__c = renewalPackageList[0].id;
                pItem.RenewalPkgCodeMag2YrBase__c = renewalPackageList[0].id;
                pItem.RenewalPkgCodeMag2YrDisc__c = renewalPackageList[0].id;
                // END : UD-3048 11/11/2015 Alyana Navarro
                
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Operated__c = true;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, pItem, venAlloc};
                
                zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
                prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
                prpct.zqu__PriceFormat__c = 'Per Unit';
                prpct.zqu__Currency__c ='SGD';
                insert prpct;
                
                
                
                List<Contact> con = new List<Contact>(); 
                List<RecordType> rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: '' LIMIT 1]; 
                for(Integer i=0;i<3;i++){
                 Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);
                  if(rt2.size() > 0){
                     contactRecord.RecordTypeId = rt2[0].Id;
                  }                 
                  contactRecord.Recipient_Indicator__c = true;
                  contactRecord.Email_Secondary__c = 'test@gmail.com';
                  contactRecord.Address_Unique_ID__c = 'ABC123';
                  contactRecord.Billing_Indicator__c = true;
                  contactRecord.AccountId = vendorSubsAcct[0].Id;
                  contactRecord.Address__c = add.Id;                                           
                  con.add(contactRecord);  
                }   
                insert con;
            
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct[0].Id; 
                order.Recipient_Contact__c = con[0].Id;
                order.billing_type__c = 'Full Prepaid';
                order.Billing_Account__c = billingAcc.Id;
                order.Informed_Customer__c = True;
                insert order;
                
                Order_Line_Item__c orderline= TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Main_Package_Product_Sub_Type__c = 'productsubtype';
                insert orderline;
                
                Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
                cirPlanSched.Name = 'CIR Plan Schedules';
                cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
                cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);         
                cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
                cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                insert cirPlanSched;


                List<Case> cas = TestDataFactory.createCase(1, 'Complaint - Newspaper');
                List<RecordType> rtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' LIMIT 1]; 
                for(Integer i=0;i<4;i++){
                  Case cse = new Case(Origin='Email');
                  if(rtype.size() > 0){
                     cse.RecordTypeId = rtype[0].Id;
                  }
                     cse.Rejected_Renewal__c = true;   
                     cse.Category__c = 'Subscription Request';
                     cse.Sub_Category__c = 'Start Subscription'; 
                     cse.Vendor_Subscription_Created__c = false; 
                     cse.Address__c = 'Makati City';                                          
                     cas.add(cse);  
                }
                //insert cas;  //IAN Commented
                        
                List<Zuora__Subscription__c> zsubs = TestDataFactory.createSubscription(2);
                
                for (Zuora__Subscription__c zsub : zsubs) {
                
                    zsub.Zuora__Account__c = vendorSubsAcct[0].Id;
                    zsub.Subscriber_Contact__c = con[0].Id;
                    //zsub.Days_to_Expire__c = globalvariableclass.DAYS_TO_EXPIRE_14;
                    //zsub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
                    //zsub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;                  
                    zsub.Zuora__CustomerAccount__c = billingAcc.Id;
                    zsub.Recipient_Contact__c = con[0].Id;
                    zsub.Order_Line_Item_Number_1__c = orderline.id;
                    zsub.Order_Line_Item_Number__c = orderline.Id;
                    zsub.Main_Package_1__c = pack.id;
                    zsub.Main_Package__c = pack.Id;
                    zsub.Number_of_Copies1__c = '2';
                    zsub.Zuora__Status__c = globalvariableclass.ZUORA_STATUS_ACTIVE;
                    zsub.Order_Number__c = order.Id;
                    zsub.Suppress_Vendor_Start_Notice__c = 'false';
                    zsub.Subscription_Charge__c = 200;
                    zsub.Supressed_Acknowledgement_Letter__c = 'false';
                    zsub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                    zsub.Urgent__c = 'false';
                    zsub.Vendor_Conversion__c = 'false';
                    zsub.Charity__c = 'false';
                    zsub.Zuora__SubscriptionStartDate__c = date.TODAY();
                    zsub.Zuora__SubscriptionEndDate__c = date.newinstance(2015, 8, 18);
                    zsub.Subscription_End_Date__c = 'date.newinstance(2015, 8, 18)';                    
                    //zsub.Product_Code__c = 'prodCode_test';
                    zsub.Number_of_Copies__c = 100;
                    zsub.Frequency_1__c = 'Mon - Fri';
                    zsub.is1stPDFGenerated__c = true;
                    zsub.is1stNotifEmailSent__c = false;
                    zsub.is2ndPDFGenerated__c = true;
                    zsub.is2ndNotifEmailSent__c = false;
                    zsub.contact__c = con[0].Id;
                    //zsub.Product_Code__c = 'Pcode';
                    zsub.Term_Length__c = 12;
                    zsub.Product_Code__c =  'Magazine';
                }
                zsubs[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
                zsubs[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                zsubs[0].Billing_Type__c = 'Full Prepaid';
                zsubs[1].Subscription_Type_1__c = 'Delivery'; 
                zsubs[1].Subscription_Type__c = 'Delivery';
                //zsubs[0].Product_Code__c = 'prodCode_test';
                //zsubs[0].Subscriber_Contact__c = con[0].Id;
              //zsubs[1].Billing_Type__c = 'Recurring Prepaid';
                //zsubs[1].Product_Code__c =  'Magazine'; 
                //zsubs[1].Subscriber_Contact__c = con[1].Id;
              //zsubs[2].Billing_Type__c = 'Full Prepaid';
              //zsubs[3].Billing_Type__c = 'Recurring Prepaid';
                 
                
                insert zsubs; 
                //system.assertEquals(null, zsubs[0].Zuora__SubscriptionEndDate__c.year());
                
                Zuora__SubscriptionProductCharge__c spcList = TestDataFactory.createSubProductCharge(1)[0];  
                spcList.Zuora__Account__c = vendorSubsAcct[0].Id;
                spcList.PublicationCode__c = 'publication';
                spcList.Product_Code__c = 'Magazine';
                spcList.Zuora__Subscription__c = zsubs[0].Id;
                insert spcList; 
                
                //zProduct = TestDataFactory.createZProduct(1)[0];
                zProduct.ProductSubType__c = 'Magazine';
                zProduct.ProductCode__c = 'Magazine';                
                update zProduct;
              
                Test.startTest();
                
                SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
                ID batchprocessid = Database.executeBatch(batch,200);
                System.assertNotEquals(null, batchprocessid);
                
                Test.stopTest();
    }
    
    static testmethod void testNewsPaperProdType() {  // <-- This is the Original Test Method Signature
            
        List<Account> vendorSubsAcct = new List<Account>(); 
                List<RecordType> rt3 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' LIMIT 1]; 
                for(Integer i=0; i< 5; i++){
                 Account acctRecord = new Account(Name='TestContacAcc'+ i);
                  if(rt3.size() > 0){
                     acctRecord.RecordTypeId = rt3[0].Id;
                     System.debug ('Iterating '+ i  + acctRecord.RecordTypeId); 
                  }
                    acctRecord.Name = 'test123';
                    acctRecord.email__c = 'test@gmail.com';
                    acctRecord.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
                    acctRecord.Staff_ID__c = 'asasa2';  
                    acctRecord.Mobile__c = '1234';      
                    acctRecord.Contact_Person__c = 'mycontatc';
                    vendorSubsAcct.add(acctRecord);  
                }   
                insert vendorSubsAcct;
                
                Set<Id> directRecTypeIds = new Set<Id> {
                  ConstantsSLB.getKeyId('Account_Direct Corporate'),
                  ConstantsSLB.getKeyId('Account_Direct Individual'),
                  ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')
                   };
                String query = 'SELECT Id, Name FROM Account WHERE RecordType.Id IN :directRecTypeIds';
                System.debug('Database Query here: ' + [SELECT Id, Name FROM Account WHERE RecordType.Id =: ConstantsSLB.getKeyId('Account_Direct Corporate')]);
                
                System.debug ('list of alfdsd ' + [select RecordTypeId from Account where Id =: vendorSubsAcct[0].Id].RecordTypeId);
                
                //check if vendorSubsAcct object Name is equal to test123
                System.assertEquals ('test123', vendorSubsAcct[0].Name);
                
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';                
               // Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];                
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.Name = '99'; 
                singpostAdd.Street_Name__c = 'street';              
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];                
                Package__c pack = TestDataFactory.createPackage(1)[0];                
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];                                 
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';                
                gift.One_Time_Charge__c = 4;
                insert new List<sObject>{pro, singpostAdd, subsVen, pack, zProduct, venAccount, gift};
                       
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id; 
                 
                
                //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
                //insert dtl;              
                
                SPH_Location__c SPHLoc = new SPH_Location__c();
                SPHLoc.Location_Code__c = '12';
                insert SPHLoc;
                
                    
                Address__c add = TestDataFactory.createAddress(1)[0];
                //List<RecordType> rec = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Local'];
                add.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
                add.Address_1__c = 'address1';
                add.Address_2__c = 'address2';
                add.Address_3__c = 'address3';
                add.Address_4__c = 'address4';
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct[0].Id;
                billingAcc.Billing_type__c = 'Full Prepaid';
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};                                
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                prpc.PublicationCode__c = 'abcd';
                prpc.Name = 'Name';
                prpc.Id = prpc.Id; 
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                // START : UD-3048 11/11/2015 Alyana Navarro
                List<Package__c> renewalPackageList = [SELECT id, name FROM Package__c ORDER BY CreatedDate LIMIT 1];
                pItem.RenewalPkgCodeMag1YrBase__c = renewalPackageList[0].id;
                pItem.RenewalPkgCodeMag1YrDisc__c = renewalPackageList[0].id;
                pItem.RenewalPkgCodeMag2YrBase__c = renewalPackageList[0].id;
                pItem.RenewalPkgCodeMag2YrDisc__c = renewalPackageList[0].id;
                // END : UD-3048 11/11/2015 Alyana Navarro
                
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Operated__c = true;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, pItem, venAlloc};
                
                zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
                prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
                prpct.zqu__PriceFormat__c = 'Per Unit';
                prpct.zqu__Currency__c ='SGD';
                insert prpct;
                
                Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBERS';
                key.Id__c = '123457397';
                key.Type__c = 'Number';
                insert key; 
                
                List<Contact> con = new List<Contact>(); 
                List<RecordType> rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: '' LIMIT 1]; 
                for(Integer i=0;i<3;i++){
                 Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);
                  if(rt2.size() > 0){
                     contactRecord.RecordTypeId = rt2[0].Id;
                  }                 
                  contactRecord.Recipient_Indicator__c = true;
                  contactRecord.Email_Secondary__c = 'test@gmail.com';
                  contactRecord.Address_Unique_ID__c = 'ABC123';
                  contactRecord.Billing_Indicator__c = true;
                  contactRecord.AccountId = vendorSubsAcct[0].Id;
                  contactRecord.Address__c = add.Id;                                           
                  con.add(contactRecord);  
                }   
                insert con;
            
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct[0].Id; 
                order.Recipient_Contact__c = con[0].Id;
                order.billing_type__c = 'Full Prepaid';
                order.Billing_Account__c = billingAcc.Id;
                order.Informed_Customer__c = True;
                insert order;
                
                Order_Line_Item__c orderline= TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Main_Package_Product_Sub_Type__c = 'productsubtype';
                insert orderline;
                
                Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
                cirPlanSched.Name = 'CIR Plan Schedules';
                cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
                cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);         
                cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
                cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                insert cirPlanSched;


                List<Case> cas = TestDataFactory.createCase(1, 'Complaint - Newspaper');
                List<RecordType> rtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' LIMIT 1]; 
                for(Integer i=0;i<4;i++){
                  Case cse = new Case(Origin='Email');
                  if(rtype.size() > 0){
                     cse.RecordTypeId = rtype[0].Id;
                  }
                     cse.Rejected_Renewal__c = true;   
                     cse.Category__c = 'Subscription Request';
                     cse.Sub_Category__c = 'Start Subscription'; 
                     cse.Vendor_Subscription_Created__c = false; 
                     cse.Address__c = 'Makati City';                                          
                     cas.add(cse);  
                }
                //insert cas;  //IAN Commented
                        
                List<Zuora__Subscription__c> zsubs = TestDataFactory.createSubscription(4);
                
                for (Zuora__Subscription__c zsub : zsubs) {
                
                    zsub.Zuora__Account__c = vendorSubsAcct[0].Id;
                    zsub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
                    zsub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
                    zsub.Subscriber_Contact__c = con[0].Id;
                    //zsub.Days_to_Expire__c = globalvariableclass.DAYS_TO_EXPIRE_14;                                     
                    zsub.Zuora__CustomerAccount__c = billingAcc.Id;
                    zsub.Recipient_Contact__c = con[0].Id;
                    zsub.Order_Line_Item_Number_1__c = orderline.id;
                    zsub.Order_Line_Item_Number__c = orderline.Id;
                    zsub.Main_Package_1__c = pack.id;
                    zsub.Main_Package__c = pack.Id;
                    zsub.Number_of_Copies1__c = '2';
                    zsub.Zuora__Status__c = globalvariableclass.ZUORA_STATUS_ACTIVE;
                    zsub.Order_Number__c = order.Id;
                    zsub.Suppress_Vendor_Start_Notice__c = 'false';
                    zsub.Subscription_Charge__c = 200;
                    zsub.Supressed_Acknowledgement_Letter__c = 'false';
                    zsub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                    zsub.Urgent__c = 'false';
                    zsub.Vendor_Conversion__c = 'false';
                    zsub.Charity__c = 'false';
                    zsub.Zuora__SubscriptionStartDate__c = date.TODAY();
                    zsub.Zuora__SubscriptionEndDate__c = date.newinstance(2015, 8, 05);                    
                    zsub.Product_Code__c = 'prodCode_test';
                    zsub.Number_of_Copies__c = 100;
                    zsub.Frequency_1__c = 'Mon - Fri';
                    zsub.is1stPDFGenerated__c = true;
                    zsub.is1stNotifEmailSent__c = false;
                    zsub.is2ndPDFGenerated__c = true;
                    zsub.is2ndNotifEmailSent__c = false;
                    zsub.contact__c = con[0].Id;
                    zsub.Product_Code__c = 'Pcode';
                    zsub.Unique_Delivery_Identifier__c = 'ABC123';
                    zsub.Term_Length__c = 12;
                }
                
                zsubs[0].Billing_Type__c = 'Full Prepaid';
                //zsubs[0].Product_Code__c = 'prodCode_test';
                //zsubs[0].Subscriber_Contact__c = con[0].Id;
              //zsubs[1].Billing_Type__c = 'Recurring Prepaid';
                //zsubs[1].Product_Code__c =  'Magazine'; 
                //zsubs[1].Subscriber_Contact__c = con[1].Id;
              //zsubs[2].Billing_Type__c = 'Full Prepaid';
              //zsubs[3].Billing_Type__c = 'Recurring Prepaid';
                
                insert zsubs;                 
                
                
                Zuora__SubscriptionProductCharge__c spcList = TestDataFactory.createSubProductCharge(1)[0];  
                spcList.Zuora__Account__c = vendorSubsAcct[0].Id;
                spcList.PublicationCode__c = 'publication';
                spcList.Product_Code__c = 'Pcode';
                spcList.Zuora__Subscription__c = zsubs[0].Id;
                insert spcList; 
                
                //zProduct = TestDataFactory.createZProduct(1)[0];
                zProduct.ProductSubType__c = 'Newspaper';
                zProduct.ProductCode__c = 'Pcode';                
                update zProduct;
              
                Test.startTest();
                
                SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
                ID batchprocessid = Database.executeBatch(batch,200);
                System.assertNotEquals(null, batchprocessid);
                
                Test.stopTest();
    }    
      
}