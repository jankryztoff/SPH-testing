/**
    * Class Name: <DigitalComplaintItemsExtensionTest>
    * @author: <KristineCampang>
    * Date: <9/4/2014>
    * Requirement/Project Name: <SPH>
    * @description<Test Class for DigitalComplaintItemsExtension>
    * Last Modified By: Kirk Yngwie Enriquez
    * Last Modified On: 07/27/2015
    
    */
    
    //must be able to call DigitalComplaintController & DigitalComplaintItemsExtension
    
    @isTest (seeAllData= True)
    private class DigitalComplaintItemsExtensionTest{ 
        
        //test single vendor
        static testmethod void testSingleVendorSub(){
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            //  System.assertEquals('', String.valueOf(u));
            
            //The test will run as the user created.
            System.runAs(u) {  
                /************************** CREATE TEST DATA ********************************/
                List<Account> accList = new List<Account>();
                List<Contact> conList = new List<Contact>();
                List<Case> caseList = new List<Case>(); 
                List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
                List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
                List<Order__c> orderList = new List<Order__c>();
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                insert postal;
                
                //create Account Records
                accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
                accList[0].NRIC__c = 'T1234567R';
                accList[1].NRIC__c = 'T7654321R';
                accList[2].NRIC__c = 'T1234765R';
                insert accList;            
                
                //create Main Package Records
                List<Package__c> packageList = TestDataFactory.createPackage(2);
                packageList[0].Package_Type__c = 'Base Product';                                  
                packageList[1].Billing_Type__c = 'Full Prepaid';
                insert packageList;                            
                                
                //create Billing Account Records
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = accList[0].Id;
                insert billAcc;
                
                //create Address Records
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                //create Contact Records
                conList = TestDataFactory.createContact(1);
                conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList[0].AccountId = accList[0].Id;
                conList[0].Address__c = addressRec.Id;
                conList[0].Recipient_Indicator__c = true;
                conList[0].LastName = 'Last Name';
                conList[0].FirstName = 'First Name';
                conList[0].Phone = '1234567'; //not sure 
                //conList[0].HomePhone__c = '987654321'; //02-27-15 Commented out by JPO to cover else if conditions
                conList[0].Mobile_Number__c = '09155568874'; //02-27-15 Added by JPO to cover else-if conditions for lines 608-618
                conList[0].Mobile_Number_2__c = '09112234567';
                insert conList;    
                          
                //create Order Records
                orderList = TestDataFactory.createOrder(1);
                orderList[0].Account__c = accList[0].Id;
                orderList[0].Informed_Customer__c = TRUE;
                orderList[0].Recipient_Contact__c = conList[0].Id;
                orderList[0].RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Locked Record').getRecordTypeId();
                insert orderList;                
                
                //create Order Line Item Records
                oliList = TestDataFactory.createOrderLineItem(1);
                oliList[0].Main_Package_ID__c = packageList[0].Id;
                oliList[0].Start_Date__c = date.today()+1;
                oliList[0].End_Date__c = date.today().adddays(30);
                oliList[0].Order__c = orderList[0].Id;
                insert oliList[0];
                
                //create Zuora Subscription Records
                zuoSubList = TestDataFactory.createSubscription(1);
                zuoSubList[0].Name = 'Zuora Name';
                zuoSubList[0].Main_Package__c = packageList[0].Id;
                zuoSubList[0].Main_Package_1__c = String.valueOf(packageList[0].Id);
                zuoSubList[0].Recipient_Contact__c = conList[0].Id; //last name           
                zuoSubList[0].Zuora__Account__c = accList[1].Id;
                zuoSubList[0].Subscriber_Contact__c = conList[0].Id;        
                zuoSubList[0].Zuora__SubscriptionStartDate__c = date.newInstance(2014, 12, 1);
                zuoSubList[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                zuoSubList[0].Zuora__Status__c = 'Active';
                zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'false';
                zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'false';
                zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zuoSubList[0].Urgent__c = 'false';
                zuoSubList[0].Vendor_Conversion__c = 'false';
                zuoSubList[0].Charity__c = 'false';
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Number_of_Copies1__c = '10';
                zuoSubList[0].Zuora__Account__c = accList[1].id;
                zuoSubList[0].Subscription_Type_1__c = 'Publication';
                zuoSubList[0].Subscription_Type__c = 'Publication';
                zuoSubList[0].Qty__c = 100;
                insert zuoSubList;                 
                
                //insert Case Records
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderList[0].Id;
                cas.AccountID = accList[1].Id;       
                cas.SuppliedEmail = 'sampleemail@email.com'; 
                cas.ContactId = conList[0].id;
                cas.Sub_Category__c = 'Change/Reset Password';
                cas.Subscription_Name__c = zuoSubList[0].id;
                //cas.RecordTypeId = '012N00000008kI8';
                insert cas;
                
                Asia1__c tmpAsia1DEL = TestDataFactory.createAsiaOne(1)[0];
                tmpAsia1DEL.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                tmpAsia1DEL.Display_Name__c = 'JohnAsia';
                tmpAsia1DEL.Email__c = 'johndacutan2@example.com' ;
                tmpAsia1DEL.Password__c = 'aBcD3Fg';
                tmpAsia1DEL.Contact__c = conList[0].Id;
                tmpAsia1DEL.Status__c = 'Pending Creation';
                insert tmpAsia1DEL;           
                
                System.assertEquals('jadacutan2@example.com', tmpAsia1DEL.User_ID_LDAP_ID__c, 'Assertion failed'); //success                

                Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
                SAF.Name = 'TEST Name'; // ?
                //SAF.Flag_Code__c = 'TEST'; 
                SAF.Flag_Description__c = 'TESTx';
                insert SAF;                 
                           
                Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];            
                PAF.Package__c = packageList[0].Id;
                PAF.No_of_Concurrent_Users__c = 2;
                PAF.Package_Service_Access_Flag__c = SAF.Id;
                insert PAF;  
                
                Service_Access_Flag__c SAF2 = TestDataFactory.createServiceAccessFlag(1)[0];
                SAF2.Name = 'TEST Name 2'; // ?
                //SAF.Flag_Code__c = 'TEST'; 
                SAF2.Flag_Description__c = 'TESTx';
                insert SAF2;
                
                Package_Access_Flag__c PAF2 = TestDataFactory.createPackageAccessFlag(1)[0];            
                PAF2.Package__c = packageList[0].Id;
                PAF2.No_of_Concurrent_Users__c = 2;
                PAF2.Package_Service_Access_Flag__c = SAF2.Id;
                insert PAF2;   
                            
                //[JPO 02/24] Added Asia1_Subscription
                List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
                asiaSubList[0].Asia1__c = tmpAsia1DEL.Id;
                asiaSubList[0].Subscription__c = zuoSubList[0].Id;
                asiaSubList[0].Status__c = 'Enabled';
                asiaSubList[0].Order_Line_Item__c = oliList[0].Id;
                asiaSubList[0].Service_Access_Flag__c = SAF.Id;
                insert asiaSubList;            
                
                Digital_Complaint_Items__c dci2 = new Digital_Complaint_Items__c();
                dci2.Case_No__c = cas.Id; // field is not writeable
                dci2.SPH_Online_User_Id__c = 'TEstxxxx';
                dci2.Asia1__c = tmpAsia1DEL.Id;
                dci2.First_Name__c = 'master';
                dci2.Last_Name__c = 'test';
                dci2.Email__c = 'testxxxx@email.com';
                dci2.New_Password__c = 'aBcdE3gf';
                dci2.Account_Lookup_Field__c = accList[0].id;
                //insert dci2;
                
                /************************** START TEST EXECUTION ********************************/
                Test.startTest();
                PageReference pageRef = Page.DigitalComplaintItemsPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId', cas.Id);                
                ApexPages.standardController controller = new ApexPages.standardController(dci2);
                
                //test initialized components and add new Asia1 account
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);                                                
                
                //START: Testing of SaveMe() methods - John P. Ocariz [02-27-2015]
                //test with an empty asia1Obj (without any addAsia1NewAccount() method call)                
                createDigitalComplaintItemsExtension.saveMe();
                
                //test different subCatNames:                
                List<String> testSubCatNames = new List<String>();
                testSubCatNames.add('User Id Not Created/Activated');
                testSubCatNames.add('Deactivate User Id');
                testSubCatNames.add('Change/Reset Password');
                
                for(String subCatName: testSubCatNames){
                    createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                    
                    //reset Asia1__c object
                    Asia1__c tmpAsia1DEL2 = TestDataFactory.createAsiaOne(1)[0];
                    tmpAsia1DEL2.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                    tmpAsia1DEL2.Display_Name__c = 'JohnAsia';
                    tmpAsia1DEL2.Email__c = 'johndacutan2@example.com' ;
                    tmpAsia1DEL2.Password__c = 'aBcD3Fg';
                    tmpAsia1DEL2.Contact__c = conList[0].Id;
                    tmpAsia1DEL2.Status__c = 'Pending Creation';
                    createDigitalComplaintItemsExtension.asia1 = tmpAsia1DEL2;
                    
                    createDigitalComplaintItemsExtension.addAsia1NewAccount();
                    createDigitalComplaintItemsExtension.subcatName = subCatName;                    
                    createDigitalComplaintItemsExtension.SaveMe();
                    try{
                    createDigitalComplaintItemsExtension.saveandnew();
                    }catch(exception e){}
                }
                
                //test other if-else conditions, reset instance for each condition
                //01 - resetPass = TRUE
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.resetPass = TRUE;                
                createDigitalComplaintItemsExtension.SaveMe();                            
                
                //02 - deacUserId = FALSE
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.deacUserId = FALSE;                
                createDigitalComplaintItemsExtension.SaveMe();               

                //END: Testing of SaveMe() methods - John P. Ocariz [02-27-2015]
                      
                //START: test validateNewAsia1Account                
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                
                //reset Asia1c object to enter if block
                Asia1__c tmpAsia1DEL2 = TestDataFactory.createAsiaOne(1)[0];
                tmpAsia1DEL2.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                tmpAsia1DEL2.Display_Name__c = 'JohnAsia';
                tmpAsia1DEL2.Email__c = 'johndacutan2@example.com' ;
                tmpAsia1DEL2.Password__c = 'aBcD3Fg';
                tmpAsia1DEL2.Contact__c = conList[0].Id;
                tmpAsia1DEL2.Status__c = 'Pending Creation';
                createDigitalComplaintItemsExtension.asia1 = tmpAsia1DEL2;
                
                createDigitalComplaintItemsExtension.validateNewAsia1Account(); // for else block
                createDigitalComplaintItemsExtension.addAsia1NewAccount();           
                createDigitalComplaintItemsExtension.asia1SelectedExistingId = String.ValueOf(tmpAsia1DEL.Id); //null?                                             
                createDigitalComplaintItemsExtension.validateNewAsia1Account(); //JPO 02/26 - re-calling method for null asia1                
                createDigitalComplaintItemsExtension.removeAsia1Subscription();
                Test.stopTest();
                /************************** END TEST EXECUTION ********************************/
            }
        }    
        
        //test single vendor 2
        static testmethod void testSingleVendorSub2(){
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            //  System.assertEquals('', String.valueOf(u));
            
            //The test will run as the user created.
            System.runAs(u) {  
                /************************** CREATE TEST DATA ********************************/
                List<Account> accList = new List<Account>();
                List<Contact> conList = new List<Contact>();
                List<Case> caseList = new List<Case>(); 
                List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
                List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
                List<Order__c> orderList = new List<Order__c>();
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                insert postal;
                
                //create Account Records
                accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
                accList[0].NRIC__c = 'T1234567R';
                accList[1].NRIC__c = 'T7654321R';
                accList[2].NRIC__c = 'T1234765R';
                insert accList;            
                
                //create Main Package Records
                List<Package__c> packageList = TestDataFactory.createPackage(2);
                packageList[0].Package_Type__c = 'Base Product';                                  
                packageList[1].Billing_Type__c = 'Full Prepaid';
                insert packageList;                            
                                
                //create Billing Account Records
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = accList[0].Id;
                insert billAcc;
                
                //create Address Records
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                //create Contact Records
                conList = TestDataFactory.createContact(1);
                conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList[0].AccountId = accList[0].Id;
                conList[0].Address__c = addressRec.Id;
                conList[0].Recipient_Indicator__c = true;
                conList[0].LastName = 'Last Name';
                conList[0].FirstName = 'First Name';
                //conList[0].Phone = '1234567'; //not sure 
                conList[0].HomePhone__c = '987654321'; 
                //conList[0].Mobile_Number__c = '09155568874'; //02-27-15 Added by JPO to cover else-if conditions for lines 608-618
                //conList[0].Mobile_Number_2__c = '09112234567';
                insert conList;    
                          
                //create Order Records
                orderList = TestDataFactory.createOrder(1);
                orderList[0].Account__c = accList[0].Id;
                orderList[0].Informed_Customer__c = TRUE;
                orderList[0].Recipient_Contact__c = conList[0].Id;
                orderList[0].RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Locked Record').getRecordTypeId();
                insert orderList;                
                
                //create Order Line Item Records
                oliList = TestDataFactory.createOrderLineItem(1);
                oliList[0].Main_Package_ID__c = packageList[0].Id;
                oliList[0].Start_Date__c = date.today()+1;
                oliList[0].End_Date__c = date.today().adddays(30);
                oliList[0].Order__c = orderList[0].Id;
                insert oliList[0];
                
                //create Zuora Subscription Records
                zuoSubList = TestDataFactory.createSubscription(1);
                zuoSubList[0].Name = 'Zuora Name';
                zuoSubList[0].Main_Package__c = packageList[0].Id;
                zuoSubList[0].Main_Package_1__c = String.valueOf(packageList[0].Id);
                zuoSubList[0].Recipient_Contact__c = conList[0].Id; //last name           
                zuoSubList[0].Zuora__Account__c = accList[1].Id;
                zuoSubList[0].Subscriber_Contact__c = conList[0].Id;        
                zuoSubList[0].Zuora__SubscriptionStartDate__c = date.newInstance(2014, 12, 1);
                zuoSubList[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                zuoSubList[0].Zuora__Status__c = 'Active';
                zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'false';
                zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'false';
                zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zuoSubList[0].Urgent__c = 'false';
                zuoSubList[0].Vendor_Conversion__c = 'false';
                zuoSubList[0].Charity__c = 'false';
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Number_of_Copies1__c = '10';
                zuoSubList[0].Zuora__Account__c = accList[1].id;
                zuoSubList[0].Subscription_Type_1__c = 'Publication';
                zuoSubList[0].Subscription_Type__c = 'Publication';
                zuoSubList[0].Qty__c = 100;
                zuoSubList[0].Qty1__c = '100';
                insert zuoSubList;                 
                
                //insert Case Records
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderList[0].Id;
                cas.AccountID = accList[1].Id;       
                cas.SuppliedEmail = 'sampleemail@email.com'; 
                cas.ContactId = conList[0].id;
                cas.Sub_Category__c = 'Change/Reset Password';
                cas.Subscription_Name__c = zuoSubList[0].id;
                //cas.RecordTypeId = '012N00000008kI8';
                insert cas;
                
                Asia1__c tmpAsia1DEL = TestDataFactory.createAsiaOne(1)[0];
                tmpAsia1DEL.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                tmpAsia1DEL.Display_Name__c = 'JohnAsia';
                tmpAsia1DEL.Email__c = 'johndacutan2@example.com' ;
                tmpAsia1DEL.Password__c = 'aBcD3Fg';
                tmpAsia1DEL.Contact__c = conList[0].Id;
                tmpAsia1DEL.Status__c = 'Pending Creation';
                insert tmpAsia1DEL;           
                
                System.assertEquals('jadacutan2@example.com', tmpAsia1DEL.User_ID_LDAP_ID__c, 'Assertion failed'); //success                

                Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
                SAF.Name = 'TEST Name'; // ?
                //SAF.Flag_Code__c = 'TEST'; 
                SAF.Flag_Description__c = 'TESTx';
                insert SAF;                 
                           
                Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];            
                PAF.Package__c = packageList[0].Id;
                PAF.No_of_Concurrent_Users__c = 2;
                PAF.Package_Service_Access_Flag__c = SAF.Id;
                insert PAF;              
                
                                
                //[JPO 02/24] Added Asia1_Subscription
                List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
                asiaSubList[0].Asia1__c = tmpAsia1DEL.Id;
                asiaSubList[0].Subscription__c = zuoSubList[0].Id;
                asiaSubList[0].Status__c = 'Enabled';
                asiaSubList[0].Order_Line_Item__c = oliList[0].Id;
                asiaSubList[0].Service_Access_Flag__c = SAF.Id;
                insert asiaSubList;            
                
                Digital_Complaint_Items__c dci2 = new Digital_Complaint_Items__c();
                dci2.Case_No__c = cas.Id; // field is not writeable
                dci2.SPH_Online_User_Id__c = 'TEstxxxx';
                dci2.Asia1__c = tmpAsia1DEL.Id;
                dci2.First_Name__c = 'master';
                dci2.Last_Name__c = 'test';
                dci2.Email__c = 'testxxxx@email.com';
                dci2.New_Password__c = 'aBcdE3gf';
                dci2.Account_Lookup_Field__c = accList[0].id;
                //insert dci2;
                
                /************************** START TEST EXECUTION ********************************/
                Test.startTest();
                PageReference pageRef = Page.DigitalComplaintItemsPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId', cas.Id);                
                ApexPages.standardController controller = new ApexPages.standardController(dci2);
                
                //test initialized components and add new Asia1 account
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);                                                
                
                //START: Testing of SaveMe() methods - John P. Ocariz [02-27-2015]
                //test with an empty asia1Obj (without any addAsia1NewAccount() method call)                
                createDigitalComplaintItemsExtension.saveMe();
                
                //test different subCatNames:                
                List<String> testSubCatNames = new List<String>();
                testSubCatNames.add('User Id Not Created/Activated');
                testSubCatNames.add('Deactivate User Id');
                testSubCatNames.add('Change/Reset Password');
                
                for(String subCatName: testSubCatNames){
                    createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                    
                    //reset Asia1__c object
                    Asia1__c tmpAsia1DEL2 = TestDataFactory.createAsiaOne(1)[0];
                    tmpAsia1DEL2.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                    tmpAsia1DEL2.Display_Name__c = 'JohnAsia';
                    tmpAsia1DEL2.Email__c = 'johndacutan2@example.com' ;
                    tmpAsia1DEL2.Password__c = 'aBcD3Fg';
                    tmpAsia1DEL2.Contact__c = conList[0].Id;
                    tmpAsia1DEL2.Status__c = 'Pending Creation';
                    createDigitalComplaintItemsExtension.asia1 = tmpAsia1DEL2;
                    
                    createDigitalComplaintItemsExtension.addAsia1NewAccount();
                    try{
                    createDigitalComplaintItemsExtension.subcatName = subCatName;                    
                    createDigitalComplaintItemsExtension.SaveMe();
                    createDigitalComplaintItemsExtension.saveandnew();
                    }catch(exception e){}
                }
                
                //test other if-else conditions, reset instance for each condition
                //01 - resetPass = TRUE
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.resetPass = TRUE;                
                createDigitalComplaintItemsExtension.SaveMe();                            
                
                //02 - deacUserId = FALSE
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.deacUserId = FALSE;                
                createDigitalComplaintItemsExtension.SaveMe();               

                //END: Testing of SaveMe() methods - John P. Ocariz [02-27-2015]
                      
                //START: test validateNewAsia1Account                
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                
                //reset Asia1c object to enter if block
                Asia1__c tmpAsia1DEL2 = TestDataFactory.createAsiaOne(1)[0];
                tmpAsia1DEL2.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                tmpAsia1DEL2.Display_Name__c = 'JohnAsia';
                tmpAsia1DEL2.Email__c = 'johndacutan2@example.com' ;
                tmpAsia1DEL2.Password__c = 'aBcD3Fg';
                tmpAsia1DEL2.Contact__c = conList[0].Id;
                tmpAsia1DEL2.Status__c = 'Pending Creation';
                createDigitalComplaintItemsExtension.asia1 = tmpAsia1DEL2;
                
                createDigitalComplaintItemsExtension.validateNewAsia1Account(); // for else block
                createDigitalComplaintItemsExtension.addAsia1NewAccount();           
                createDigitalComplaintItemsExtension.asia1SelectedExistingId = String.ValueOf(tmpAsia1DEL.Id); //null?                                             
                createDigitalComplaintItemsExtension.validateNewAsia1Account(); //JPO 02/26 - re-calling method for null asia1                
                createDigitalComplaintItemsExtension.removeAsia1Subscription();
                Test.stopTest();
                /************************** END TEST EXECUTION ********************************/
            }
        }      
        //END testmethod testSingleVendorSub2
        
        //test single vendor 3
        static testmethod void testSingleVendorSub3(){
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            //  System.assertEquals('', String.valueOf(u));
            
            //The test will run as the user created.
            System.runAs(u) {  
                /************************** CREATE TEST DATA ********************************/
                List<Account> accList = new List<Account>();
                List<Contact> conList = new List<Contact>();
                List<Case> caseList = new List<Case>(); 
                List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
                List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
                List<Order__c> orderList = new List<Order__c>();
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                insert postal;
                
                //create Account Records
                accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
                accList[0].NRIC__c = 'T1234567R';
                accList[1].NRIC__c = 'T7654321R';
                accList[2].NRIC__c = 'T1234765R';
                insert accList;            
                
                //create Main Package Records
                List<Package__c> packageList = TestDataFactory.createPackage(2);
                packageList[0].Package_Type__c = 'Base Product';                                  
                packageList[1].Billing_Type__c = 'Full Prepaid';
                insert packageList;                            
                                
                //create Billing Account Records
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = accList[0].Id;
                insert billAcc;
                
                //create Address Records
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                //create Contact Records
                conList = TestDataFactory.createContact(1);
                conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList[0].AccountId = accList[0].Id;
                conList[0].Address__c = addressRec.Id;
                conList[0].Recipient_Indicator__c = true;
                conList[0].LastName = 'Last Name';
                conList[0].FirstName = 'First Name';
                conList[0].Phone = '1234567'; 
                insert conList;    
                          
                //create Order Records
                orderList = TestDataFactory.createOrder(1);
                orderList[0].Account__c = accList[0].Id;
                orderList[0].Informed_Customer__c = TRUE;
                orderList[0].Recipient_Contact__c = conList[0].Id;
                orderList[0].RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Locked Record').getRecordTypeId();
                insert orderList;                
                
                //create Order Line Item Records
                oliList = TestDataFactory.createOrderLineItem(1);
                oliList[0].Main_Package_ID__c = packageList[0].Id;
                oliList[0].Start_Date__c = date.today()+1;
                oliList[0].End_Date__c = date.today().adddays(30);
                oliList[0].Order__c = orderList[0].Id;
                insert oliList[0];
                
                //create Zuora Subscription Records
                zuoSubList = TestDataFactory.createSubscription(1);
                zuoSubList[0].Name = 'Zuora Name';
                zuoSubList[0].Main_Package__c = packageList[0].Id;
                zuoSubList[0].Main_Package_1__c = String.valueOf(packageList[0].Id);
                zuoSubList[0].Recipient_Contact__c = conList[0].Id; //last name           
                zuoSubList[0].Zuora__Account__c = accList[1].Id;
                zuoSubList[0].Subscriber_Contact__c = conList[0].Id;        
                zuoSubList[0].Zuora__SubscriptionStartDate__c = date.newInstance(2014, 12, 1);
                zuoSubList[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                zuoSubList[0].Zuora__Status__c = 'Active';
                zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'false';
                zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'false';
                zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zuoSubList[0].Urgent__c = 'false';
                zuoSubList[0].Vendor_Conversion__c = 'false';
                zuoSubList[0].Charity__c = 'false';
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Number_of_Copies1__c = '10';
                zuoSubList[0].Zuora__Account__c = accList[1].id;
                zuoSubList[0].Subscription_Type_1__c = 'Publication';
                zuoSubList[0].Subscription_Type__c = 'Publication';
                zuoSubList[0].Qty__c = 100;
                zuoSubList[0].Qty1__c = '100';
                insert zuoSubList;                 
                
                //insert Case Records
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderList[0].Id;
                cas.AccountID = accList[1].Id;       
                cas.SuppliedEmail = 'sampleemail@email.com'; 
                cas.ContactId = conList[0].id;
                cas.Sub_Category__c = 'Change/Reset Password';
                cas.Subscription_Name__c = zuoSubList[0].id;
                //cas.RecordTypeId = '012N00000008kI8';
                insert cas;
                
                Asia1__c tmpAsia1DEL = TestDataFactory.createAsiaOne(1)[0];
                tmpAsia1DEL.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                tmpAsia1DEL.Display_Name__c = 'JohnAsia';
                tmpAsia1DEL.Email__c = 'johndacutan2@example.com' ;
                tmpAsia1DEL.Password__c = 'aBcD3Fg';
                tmpAsia1DEL.Contact__c = conList[0].Id;
                tmpAsia1DEL.Status__c = 'Pending Creation';
                insert tmpAsia1DEL;           
                
                System.assertEquals('jadacutan2@example.com', tmpAsia1DEL.User_ID_LDAP_ID__c, 'Assertion failed'); //success                

                Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
                SAF.Name = 'TEST Name'; // ?
                //SAF.Flag_Code__c = 'TEST'; 
                SAF.Flag_Description__c = 'TESTx';
                insert SAF;                 
                           
                Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];            
                PAF.Package__c = packageList[0].Id;
                PAF.No_of_Concurrent_Users__c = 2;
                PAF.Package_Service_Access_Flag__c = SAF.Id;
                insert PAF;              
                
                                
                //[JPO 02/24] Added Asia1_Subscription
                List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
                asiaSubList[0].Asia1__c = tmpAsia1DEL.Id;
                asiaSubList[0].Subscription__c = zuoSubList[0].Id;
                asiaSubList[0].Status__c = 'Enabled';
                asiaSubList[0].Order_Line_Item__c = oliList[0].Id;
                asiaSubList[0].Service_Access_Flag__c = SAF.Id;
                insert asiaSubList;            
                
                Digital_Complaint_Items__c dci2 = new Digital_Complaint_Items__c();
                dci2.Case_No__c = cas.Id; // field is not writeable
                dci2.SPH_Online_User_Id__c = 'TEstxxxx';
                dci2.Asia1__c = tmpAsia1DEL.Id;
                dci2.First_Name__c = 'master';
                dci2.Last_Name__c = 'test';
                dci2.Email__c = 'testxxxx@email.com';
                dci2.New_Password__c = 'aBcdE3gf';
                dci2.Account_Lookup_Field__c = accList[0].id;
                //insert dci2;
                
                /************************** START TEST EXECUTION ********************************/
                Test.startTest();
                PageReference pageRef = Page.DigitalComplaintItemsPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId', cas.Id);                
                ApexPages.standardController controller = new ApexPages.standardController(dci2);
                
                //test initialized components and add new Asia1 account
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);                                                
                
                //START: Testing of SaveMe() methods - John P. Ocariz [02-27-2015]
                //test with an empty asia1Obj (without any addAsia1NewAccount() method call)                
                createDigitalComplaintItemsExtension.saveMe();
                
                //test different subCatNames:                
                List<String> testSubCatNames = new List<String>();
                testSubCatNames.add('User Id Not Created/Activated');
                testSubCatNames.add('Deactivate User Id');
                testSubCatNames.add('Change/Reset Password');
                
                for(String subCatName: testSubCatNames){
                    createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                    
                    //reset Asia1__c object
                    Asia1__c tmpAsia1DEL2 = TestDataFactory.createAsiaOne(1)[0];
                    tmpAsia1DEL2.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                    tmpAsia1DEL2.Display_Name__c = 'JohnAsia';
                    tmpAsia1DEL2.Email__c = 'johndacutan2@example.com' ;
                    tmpAsia1DEL2.Password__c = 'aBcD3Fg';
                    tmpAsia1DEL2.Contact__c = conList[0].Id;
                    tmpAsia1DEL2.Status__c = 'Pending Creation';
                    createDigitalComplaintItemsExtension.asia1 = tmpAsia1DEL2;
                    
                    createDigitalComplaintItemsExtension.addAsia1NewAccount();
                    try{
                    createDigitalComplaintItemsExtension.subcatName = subCatName;                    
                    createDigitalComplaintItemsExtension.SaveMe();
                    createDigitalComplaintItemsExtension.saveandnew();
                    }catch(exception e){}
                }
                
                //test other if-else conditions, reset instance for each condition
                //01 - resetPass = TRUE
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.resetPass = TRUE;                
                createDigitalComplaintItemsExtension.SaveMe();                            
                
                //02 - deacUserId = FALSE
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.deacUserId = FALSE;                
                createDigitalComplaintItemsExtension.SaveMe();    
                createDigitalComplaintItemsExtension.retrieveUserDetails();            

                //END: Testing of SaveMe() methods - John P. Ocariz [02-27-2015]
                      
                //START: test validateNewAsia1Account                
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                
                //reset Asia1c object to enter if block
                Asia1__c tmpAsia1DEL2 = TestDataFactory.createAsiaOne(1)[0];
                tmpAsia1DEL2.User_ID_LDAP_ID__c = 'jadacutan2@example.com';
                tmpAsia1DEL2.Display_Name__c = 'JohnAsia';
                tmpAsia1DEL2.Email__c = 'johndacutan2@example.com' ;
                tmpAsia1DEL2.Password__c = 'aBcD3Fg';
                tmpAsia1DEL2.Contact__c = conList[0].Id;
                tmpAsia1DEL2.Status__c = 'Pending Creation';
                createDigitalComplaintItemsExtension.asia1 = tmpAsia1DEL2;
                
                createDigitalComplaintItemsExtension.validateNewAsia1Account(); // for else block
                createDigitalComplaintItemsExtension.addAsia1NewAccount();           
                createDigitalComplaintItemsExtension.asia1SelectedExistingId = String.ValueOf(tmpAsia1DEL.Id); //null?                                             
                createDigitalComplaintItemsExtension.validateNewAsia1Account(); //JPO 02/26 - re-calling method for null asia1                
                createDigitalComplaintItemsExtension.removeAsia1Subscription();
                
                /*conList[0].Phone = null;
                conList[0].Mobile_Number_2__c = '123456';
                update conList[0];
                DigitalComplaintItemsExtension cont = new DigitalComplaintItemsExtension(controller);
                cont.SaveMe(); */
                Test.stopTest();
                /************************** END TEST EXECUTION ********************************/
            }
        }      
        //END testmethod testSingleVendorSub3
        
        static testMethod void testAsia1Account(){
            
            //Create a new user with Standard User Profile
            
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            //  System.assertEquals('', String.valueOf(u));
            
            //The test will run as the user created.
            System.runAs(u) {            
                
                List<Account> accList = new List<Account>();
                List<Contact> conList = new List<Contact>();
                List<Case> caseList = new List<Case>(); 
                //List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
                List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
                List<Order__c> orderList = new List<Order__c>();
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                insert postal;
                
                //create Account Records
                accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
                accList[0].NRIC__c = 'T1234567R';
                accList[1].NRIC__c = 'T7654321R';
                accList[2].NRIC__c = 'T1234765R';
                insert accList;
                
                //create Main Package Records
                List<Package__c> packageList = TestDataFactory.createPackage(2);
                insert packageList[0];
                
                //List<Package__c> packageList = TestDataFactory.createPackage(1);
                packageList[1].Billing_Type__c = 'Full Prepaid';
                insert packageList[1];
                
                
                //create Billing Account Records
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = accList[0].Id;
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                
                //create Address Records
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                //create Contact Records
                conList = TestDataFactory.createContact(1);
                conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList[0].AccountId = accList[0].Id;
                conList[0].Address__c = addressRec.Id;
                conList[0].Recipient_Indicator__c = true;
                insert conList;
                
                //create Order Records
                orderList = TestDataFactory.createOrder(1);
                orderList[0].Account__c = accList[0].Id;
                orderList[0].Informed_Customer__c = TRUE;
                orderList[0].Recipient_Contact__c = conList[0].Id;
                orderList[0].RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Locked Record').getRecordTypeId();
                insert orderList ; 
                
                //insert Case Records
                List<Case> casList = TestDataFactory.createCase(2, 'Complaint - Magazine');
                casList[0].AccountId = accList[0].Id;
                casList[0].ContactId = conList[0].Id;
                casList[0].Order__c = orderList[0].Id;
                casList[0].Sub_Category__c = 'Change/Reset Password';
                
                casList[1].AccountId = accList[1].Id;
                casList[1].ContactId = conList[0].Id;
                casList[1].Order__c = orderList[0].Id;
                casList[1].Sub_Category__c = 'User Id Not Created/Activated';
                insert casList;           
                
                //create Order Line Item Records
                oliList = TestDataFactory.createOrderLineItem(1);
                oliList[0].Main_Package_ID__c = packageList[0].Id;
                oliList[0].Start_Date__c = date.today()+1;
                oliList[0].End_Date__c = date.today().adddays(30);
                oliList[0].Order__c = orderList[0].Id;
               // insert new List<sObject>{cas, oliList[0]};
                 insert oliList;   
                
                 List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
                //Zuora__Subscription__c Subs = new Zuora__Subscription__c();
                zuoSubList[0].Zuora__Account__c = accList[0].id;
                zuoSubList[0].Name= 'CS0000000110';
                zuoSubList[0].Number_of_Copies__c= 10;
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Next_Earliest_Start_Date__c= date.today();
                zuoSubList[0].Unique_Address_Id__c= 'asdasdasd';
                zuoSubList[0].Year_to_Date_Temp_Stop_Days__c= 2;
                zuoSubList[0].Previous_Year_Temp_Stop_Days__c= 2;
                zuoSubList[0].Legacy_Create_Date__c='2014-08-07';
                zuoSubList[0].Legacy_Create_By__c='test';
                zuoSubList[0].Legacy_Update_Date__c='test';
                zuoSubList[0].Legacy_Update_By__c='test';
                zuoSubList[0].Legacy_Subscription_ID__c='test';
                zuoSubList[0].Cheque_details__c='test';
                zuoSubList[0].DTL__c='test';
                zuoSubList[0].Paypal_Payment_Profile_Id__c='test';
                zuoSubList[0].Pub_Tag__c='test';
                zuoSubList[0].Subscribe_As__c='test';
                zuoSubList[0].Zuora__SubscriptionEndDate__c= null;
                zuoSubList[0].Subscription_Grace_Period_End_Date__c= 'test';
                zuoSubList[0].Gift_ID__c= 'test';
                zuoSubList[0].Redeem_Date__c= 'test';
                zuoSubList[0].Gift_ID_2__c= 'test';
                zuoSubList[0].Redeem_Date_2__c= 'test';
                zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
                zuoSubList[0].Recipient_Contact__c= conList[0].Id;
                zuoSubList[0].Subscription_Charge__c= 223.0;
                zuoSubList[0].Term_Length__c= 2;
                zuoSubList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
                zuoSubList[0].Main_Package__c = packageList[0].Id;
                zuoSubList[0].Main_Package_1__c = packageList[0].Id;
                zuoSubList[0].Billing_Type__c = 'Recurring Prepaid';
                zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
                zuoSubList[0].Subscription_Type_1__c = 'Publication';
                zuoSubList[0].Subscription_Type__c = 'Publication';
                zuoSubList[0].Qty__c = 100;
                //zSubs.add(Subs);
                insert zuoSubList;   
                
                            
                //[JPO 02/17] Added update on case record for subscription_name field
                casList[0].Subscription_Name__c = zuoSubList[0].id;
                update casList;
                
                //create Asia1__c
                Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
                tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
                tmpAsia1.Display_Name__c = 'Test';
                tmpAsia1.Email__c = 'testxxxx@email.com' ;
                tmpAsia1.Password__c = 'aBcD3Fg';
                tmpAsia1.Contact__c = conList[0].Id;
                insert tmpAsia1;     
                //asia1.User_ID_LDAP_ID__c != null && asia1.Display_Name__c != null
               
                zqu__ZProduct__c zPro = TestDataFactory.createZProduct(1)[0];
                zPro.ProductPlatform__c = 'Online';
                insert zPro;
                
                zqu__ZUnitOfMeasure__c UOM = TestDataFactory.createZUnitOfMeasure(1)[0];
                insert UOM;
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zPro.Id;
                prdRatePlan.BillingType__c = 'Full Prepaid';
                prdRatePlan.SubscriptionFrequency__c = '1';
                insert prdRatePlan;
                
                zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
                prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
                prdRatePlanCharge.zqu__ZUnitOfMeasure__c = UOM.Id;
                insert prdRatePlanCharge;            
                
                Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
                //SAF.Flag_Code__c = 'TEST';
                SAF.Flag_Description__c = 'TESTx';
                insert SAF;            
                
                List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
                asiaSubList[0].Asia1__c = tmpAsia1.Id;
                asiaSubList[0].Subscription__c = zuoSubList[0].Id;
                asiaSubList[0].Status__c = 'Enabled';
                asiaSubList[0].Order_Line_Item__c = oliList[0].Id;
                asiaSubList[0].Service_Access_Flag__c = SAF.Id;
                insert asiaSubList;            
                
                Digital_Complaint_Items__c dci2 = new Digital_Complaint_Items__c();
                dci2.Case_No__c = casList[0].Id; // field is not writeable
                dci2.SPH_Online_User_Id__c = 'TEstxxxx';
                dci2.Asia1__c = tmpAsia1.Id;
                dci2.First_Name__c = 'master';
                dci2.Last_Name__c = 'test';
                dci2.Email__c = 'testxxxx@email.com';
                dci2.New_Password__c = 'aBcdE3gf';
                dci2.Account_Lookup_Field__c = accList[0].id;
                //insert dci2;
                
                            
                Test.startTest();
                PageReference pageRef = Page.DigitalComplaintItemsPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId', casList[0].Id);
                ApexPages.standardController controller = new ApexPages.standardController(dci2);            
                
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);                 
                        
                
                //ADDED by JpOcariz 2/11/2015
                //********** TEST: asiaObj != null' ******************                   
                PageReference testsaveMe_01 = createDigitalComplaintItemsExtension.saveMe();   
                PageReference testsaveandnew_01 = createDigitalComplaintItemsExtension.saveandnew(); 
                
                //********** TEST: subCatName == 'Change/Reset Password' ******************
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension2 = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension2.subcatName = 'Change/Reset Password';        
                PageReference testsaveMe_03 = createDigitalComplaintItemsExtension.SaveMe();
                PageReference testsaveandnew_03 = createDigitalComplaintItemsExtension.saveandnew(); 
                
                //sub test: resetPass = TRUE
                //createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension2.resetPass = TRUE;                
                PageReference testsaveMe_02 = createDigitalComplaintItemsExtension.SaveMe();
                PageReference testsaveandnew_02 = createDigitalComplaintItemsExtension.saveandnew(); 
                
                //********** TEST: subCatName == 'Deactivate User Id')' ******************
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension3 = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.subcatName = 'Deactivate User Id';
                try{
                PageReference testsaveMe_04 = createDigitalComplaintItemsExtension.SaveMe();  
                PageReference testsaveandnew_04 = createDigitalComplaintItemsExtension.saveandnew(); 
                }catch(exception e){}
                //********** TEST: subCatName == 'User Id Not Created/Activated') ******************
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension4 = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.subcatName = 'User Id Not Created/Activated';
                
                PageReference testsaveMe_05 = createDigitalComplaintItemsExtension.SaveMe();
                PageReference testsaveandnew_05 = createDigitalComplaintItemsExtension.saveandnew(); 
                
                //sub-test: if deacUserId = FALSE
                //createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.deacUserId = FALSE;
                
                PageReference testSaveMe_06 = createDigitalComplaintItemsExtension.SaveMe();
                PageReference testsaveandnew_06 = createDigitalComplaintItemsExtension.saveandnew();             
                
                //*******************END TESTING FOR SaveMe() ******************
                //                         
                
                PageReference testCancel = createDigitalComplaintItemsExtension.cancel();           
                createDigitalComplaintItemsExtension.getEnabledAsia1();
                createDigitalComplaintItemsExtension.validateNewAsia1Account();
                createDigitalComplaintItemsExtension.addAsia1NewAccount();
                
                createDigitalComplaintItemsExtension.asia1 = tmpAsia1;
                createDigitalComplaintItemsExtension.Validate();
                
                
                //*********TEST Validate() Condition: validUserName = FALSE *************
                
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.asiaUsername = null;
                createDigitalComplaintItemsExtension.asiaDisplayName = null;
                createDigitalComplaintItemsExtension.Validate();
    
                //*********TEST Validate() Condition: Asia1 = null *************
                createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                delete tmpAsia1;
                createDigitalComplaintItemsExtension.Validate();
                //END
                
                createDigitalComplaintItemsExtension.populateDisableServiceFields();
                createDigitalComplaintItemsExtension.removeAsia1Subscription();
                createDigitalComplaintItemsExtension.getAsia1ExistingAccounts();            
                
                //createDigitalComplaintItemsExtension.createAsia1Subscription(asiaSubList); //PRIVATE METHOD
                createDigitalComplaintItemsExtension.retrieveServiceFlags(packageList[0].Id);
                Test.stopTest();      
            }//END System.runAs(u)
        }//END testmethod testAsia1Account
        
        /*static testMethod void testAsia1ExistingAccount(){
            
            //Create a new user with Standard User Profile
            
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            //  System.assertEquals('', String.valueOf(u));
            
            //The test will run as the user created.
            System.runAs(u) {
                
                
                List<Account> accList = new List<Account>();
                List<Contact> conList = new List<Contact>();
                List<Case> caseList = new List<Case>(); 
                List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
                List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
                List<Order__c> orderList = new List<Order__c>();
              
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                insert postal;
                
                //create Account Records
                accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
                accList[0].NRIC__c = 'T1234567R';
                accList[1].NRIC__c = 'T7654321R';
                accList[2].NRIC__c = 'T1234765R';
                insert accList;
                
                //create Main Package Records
                List<Package__c> packageList = TestDataFactory.createPackage(1);
                packageList[0].Package_Type__c = 'Bundled';
                packageList[0].Billing_Type__c = 'Full Prepaid';
                packageList[0].Subscription_Period__c = '18';
                insert packageList[0];
                
                
                //create Billing Account Records
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = accList[0].Id;
                insert billAcc;
                
                //create Address Records
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                //create Contact Records
                conList = TestDataFactory.createContact(1);
                conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList[0].AccountId = accList[0].Id;
                conList[0].Address__c = addressRec.Id;
                conList[0].Recipient_Indicator__c = true;
                insert conList;
                
                //create Order Records
                orderList = TestDataFactory.createOrder(1);
                orderList[0].Account__c = accList[0].Id;
                orderList[0].Informed_Customer__c = TRUE;
                orderList[0].Recipient_Contact__c = conList[0].Id;
                orderList[0].RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Locked Record').getRecordTypeId();
                insert orderList ; 
                
                //insert Case Records
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderList[0].Id;
                cas.Sub_Category__c = 'Change/Reset Password';            
                insert cas;
                
                //create Order Line Item Records
                oliList = TestDataFactory.createOrderLineItem(1);
                oliList[0].Main_Package_ID__c = packageList[0].Id;
                oliList[0].Start_Date__c = date.today()+1;
                oliList[0].End_Date__c = date.today().adddays(30);
                oliList[0].Order__c = orderList[0].Id;
                //insert new List<sObject>{cas, oliList[0]};
                insert oliList;
                    
                    //create Zuora Subscription Records
                zuoSubList = TestDataFactory.createSubscription(1);
                zuoSubList[0].Zuora__Account__c = accList[1].Id;
                //zuoSubList[0].Account__c = acc.id; //[JPO 02/23] Added to meet filter critera
                zuoSubList[0].Subscriber_Contact__c = conList[0].Id;
                zuoSubList[0].Recipient_Contact__c = conList[0].Id;
                zuoSubList[0].Main_Package_1__c = packageList[0].Id;
                //zuoSubList[0].Order_Line_Item_Number__c = orderList[0].Id;    
                //zuoSubList[0].Order_Number__c = orderList[0].Id;
                zuoSubList[0].Zuora__SubscriptionStartDate__c = date.newInstance(2014, 12, 1);
                zuoSubList[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                zuoSubList[0].Zuora__Status__c = 'Active';
                zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'false';
                zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'false';
                zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zuoSubList[0].Urgent__c = 'false';
                zuoSubList[0].Vendor_Conversion__c = 'false';
                zuoSubList[0].Charity__c = 'false';
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Number_of_Copies1__c = '10';
                zuoSubList[0].Subscription_Type_1__c = 'Publication';
                zuoSubList[0].Subscription_Type__c = 'Publication';
                zuoSubList[0].Qty__c = 100;
                insert zuoSubList;
                
                //[JPO 02/17] Added to update case record with subscription_name
                cas.Subscription_Name__c = zuoSubList[0].id;
                cas.Account__c = accList[1].id;
                cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND Name ='Complaint - Newspaper'].Id;
                //(Subscription Name: Account IDEQUALSCase: Account Name ID) OR
                //(Subscription Name: Account IDEQUALSCase: Account Name ID)
    
                update cas;
                
                //create Case Records
                caseList = TestDataFactory.createCase(1, 'Start Subscription');
                caseList[0].Account = accList[0];
                caseList[0].Contact = conList[0];
                insert caseList;
                
                create Asia1__c
                Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
                tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
                tmpAsia1.Display_Name__c = 'Test';
                tmpAsia1.Email__c = 'test@email.com' ;
                tmpAsia1.Password__c = 'aBcD3Fg';
                tmpAsia1.Contact__c = conList[0].Id;
                insert tmpAsia1;
                
    
                Asia1__c tmpAsia1 = new Asia1__c();
                tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
                tmpAsia1.Display_Name__c = 'Test';
                tmpAsia1.Email__c = 'test@email.com' ;
                tmpAsia1.Password__c = 'aBcD3Fg';
                tmpAsia1.Contact__c = conList[0].Id;
                tmpAsia1.Status__c = 'Pending Creation';
                insert tmpAsia1;
                
                Product_Family__c pFam = new Product_Family__c(Product_Family__c = 'TEST');
                
                zqu__ZProduct__c zPro = TestDataFactory.createZProduct(1)[0];
                zPro.ProductPlatform__c = 'Online';
                zPro.ProductFamily__c = pFam.id;
                insert zPro;
                
                zqu__ZUnitOfMeasure__c UOM = TestDataFactory.createZUnitOfMeasure(1)[0];
                insert UOM;
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zPro.Id;
                insert prdRatePlan;
                
                            
                //insert pFam; //duplicate
                
                Package_Item__c pItemBase = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
                pItemBase.Package__c = packageList[0].Id;
                pItemBase.Product_Rate_Plan__c = prdRatePlan.Id;
                pItemBase.Duration_in_months__c = '3';
                pItemBase.Effective_Start_Month__c = '3';
                pItemBase.Product_Family__c = pFam.Id;
                insert new List<sObject>{pItemBase};
                    
                zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
                prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
                //prdRatePlanCharge.zqu__ProductRatePlan__c = 
                prdRatePlanCharge.zqu__ZUnitOfMeasure__c = UOM.Id;
                //prdRatePlanCharge.zqu__ProductRatePlan__c = zPro
                insert prdRatePlanCharge;
                
                Package_Item__c pItem = new Package_Item__c(); //TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                pItem.Package__c = packageList[0].Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Base_Package_Item__c = pItemBase.Id;
                pItem.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Package_Item__c' AND Name='Bundle Discount'].Id;
                
                Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
                //SAF.Flag_Code__c = 'TEST';
                SAF.Flag_Description__c = 'TESTx';
                insert SAF;
                
                Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
                PAF.Package__c = packageList[0].Id;
                PAF.No_of_Concurrent_Users__c = 2;
                PAF.Package_Service_Access_Flag__c = SAF.Id;
                insert PAF;
                
     
                Digital_Complaint_Items__c dci2 = new Digital_Complaint_Items__c();
                dci2.Case_No__c = cas.Id; // field is not writeable
                dci2.SPH_Online_User_Id__c = 'TEstxxxx';
                dci2.Asia1__c = tmpAsia1.Id;
                dci2.First_Name__c = 'master';
                dci2.Last_Name__c = 'test';
                dci2.Email__c = 'testxxxx@email.com';
                dci2.New_Password__c = 'aBcdE3gf';
                dci2.Account_Lookup_Field__c = accList[0].id;
                //insert dci2;
                
                Test.startTest();
                PageReference pageRef = Page.DigitalComplaintItemsPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId', cas.Id);
                ApexPages.standardController controller = new ApexPages.standardController(dci2);
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);                      
                    
                PageReference testsaveMe_01 = createDigitalComplaintItemsExtension.saveMe();   
                
                createDigitalComplaintItemsExtension.asia1SelectedExistingId = String.valueOf(tmpAsia1.Id);
                createDigitalComplaintItemsExtension.addAsia1ExistingAccount();            
                createDigitalComplaintItemsExtension.getAsia1ExistingAccounts();         
                createDigitalComplaintItemsExtension.retrieveServiceFlags(packageList[0].Id);
                createDigitalComplaintItemsExtension.retrieveUserDetails();            
                           
                Test.stopTest();
                
                 System.assertEquals(cas.Id, ApexPages.currentPage().getParameters().put('caseId', cas.Id), 'Assertion Message here.');
                
            }//END System.runAs(u)
        }//END testmethod testAsia1ExistingAccount 
        */
        
        static testMethod void testAsia1ExistingAccount2(){
            
            //Create a new user with Standard User Profile
            
            User u = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            //  System.assertEquals('', String.valueOf(u));
            
            //The test will run as the user created.
            System.runAs(u) {
                
                
                List<Account> accList = new List<Account>();
                List<Contact> conList = new List<Contact>();
                List<Case> caseList = new List<Case>(); 
                List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
                List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
                List<Order__c> orderList = new List<Order__c>();
              
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                insert postal;
                
                //create Account Records
                accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
                accList[0].NRIC__c = 'T1234567R';
                accList[1].NRIC__c = 'T7654321R';
                accList[2].NRIC__c = 'T1234765R';
                insert accList;
                
                //create Main Package Records
                List<Package__c> packageList = TestDataFactory.createPackage(1);
                packageList[0].Package_Type__c = 'Bundled';
                packageList[0].Billing_Type__c = 'Full Prepaid';
                packageList[0].Subscription_Period__c = '18';
                insert packageList[0];
                
                
                //create Billing Account Records
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = accList[0].Id;
                insert billAcc;
                
                //create Address Records
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
                
                //create Contact Records
                conList = TestDataFactory.createContact(1);
                conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList[0].AccountId = accList[0].Id;
                conList[0].Address__c = addressRec.Id;
                conList[0].Recipient_Indicator__c = true;
                insert conList;
                
                //create Order Records
                orderList = TestDataFactory.createOrder(1);
                orderList[0].Account__c = accList[0].Id;
                orderList[0].Informed_Customer__c = TRUE;
                orderList[0].Recipient_Contact__c = conList[0].Id;
                orderList[0].RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Locked Record').getRecordTypeId();
                insert orderList ; 
                
                //create Order Line Item Records
                oliList = TestDataFactory.createOrderLineItem(1);
                oliList[0].Main_Package_ID__c = packageList[0].Id;
                oliList[0].Start_Date__c = date.today()+1;
                oliList[0].End_Date__c = date.today().adddays(30);
                oliList[0].Order__c = orderList[0].Id;
                //insert new List<sObject>{cas, oliList[0]};
                insert oliList;
                    
                    //create Zuora Subscription Records
                zuoSubList = TestDataFactory.createSubscription(1);
                zuoSubList[0].Zuora__Account__c = accList[1].Id;
                //zuoSubList[0].Account__c = acc.id; //[JPO 02/23] Added to meet filter critera
                zuoSubList[0].Subscriber_Contact__c = conList[0].Id;
                zuoSubList[0].Recipient_Contact__c = conList[0].Id;
                zuoSubList[0].Main_Package_1__c = packageList[0].Id;
                //zuoSubList[0].Order_Line_Item_Number__c = orderList[0].Id;    
                //zuoSubList[0].Order_Number__c = orderList[0].Id;
                zuoSubList[0].Zuora__SubscriptionStartDate__c = date.newInstance(2014, 12, 1);
                zuoSubList[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                zuoSubList[0].Zuora__Status__c = 'Active';
                zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'false';
                zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'false';
                zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zuoSubList[0].Urgent__c = 'false';
                zuoSubList[0].Vendor_Conversion__c = 'false';
                zuoSubList[0].Charity__c = 'false';
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Number_of_Copies1__c = '10';
                zuoSubList[0].Subscription_Type_1__c = 'Publication';
                zuoSubList[0].Subscription_Type__c = 'Publication';
                zuoSubList[0].Qty__c = 100;
                zuoSubList[0].Qty1__c = '100';
                insert zuoSubList;
                
                //insert Case Records
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderList[0].Id;
                cas.Sub_Category__c = 'Change/Reset Password';
                cas.Subscription_Name__c = zuoSubList[0].id;
                cas.Account__c = accList[1].id;            
                insert cas;
                
                //create Case Records
                caseList = TestDataFactory.createCase(1, 'Start Subscription');
                caseList[0].Account = accList[0];
                caseList[0].Contact = conList[0];
                insert caseList;
    
                Asia1__c tmpAsia1 = new Asia1__c();
                tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
                tmpAsia1.Display_Name__c = 'Test';
                tmpAsia1.Email__c = 'test@email.com' ;
                tmpAsia1.Password__c = 'aBcD3Fg';
                tmpAsia1.Contact__c = conList[0].Id;
                tmpAsia1.Status__c = 'Pending Creation';
                insert tmpAsia1;
                
                Product_Family__c pFam = new Product_Family__c(Product_Family__c = 'TEST');
                
                zqu__ZProduct__c zPro = TestDataFactory.createZProduct(1)[0];
                zPro.ProductPlatform__c = 'Online';
                zPro.ProductFamily__c = pFam.id;
                insert zPro;
                
                zqu__ZUnitOfMeasure__c UOM = TestDataFactory.createZUnitOfMeasure(1)[0];
                insert UOM;
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zPro.Id;
                insert prdRatePlan;
                
                            
                //insert pFam; //duplicate
                
                Package_Item__c pItemBase = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
                pItemBase.Package__c = packageList[0].Id;
                pItemBase.Product_Rate_Plan__c = prdRatePlan.Id;
                pItemBase.Duration_in_months__c = '3';
                pItemBase.Effective_Start_Month__c = '3';
                pItemBase.Product_Family__c = pFam.Id;
                insert new List<sObject>{pItemBase};
                    
                zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
                prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
                //prdRatePlanCharge.zqu__ProductRatePlan__c = 
                prdRatePlanCharge.zqu__ZUnitOfMeasure__c = UOM.Id;
                //prdRatePlanCharge.zqu__ProductRatePlan__c = zPro
                insert prdRatePlanCharge;
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                pItem.Package__c = packageList[0].Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Base_Package_Item__c = pItemBase.Id;
                
                Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
                //SAF.Flag_Code__c = 'TEST';
                SAF.Flag_Description__c = 'TESTx';
                insert SAF;
                
                Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
                PAF.Package__c = packageList[0].Id;
                PAF.No_of_Concurrent_Users__c = 2;
                PAF.Package_Service_Access_Flag__c = SAF.Id;
                insert PAF;
                
     
                Digital_Complaint_Items__c dci2 = new Digital_Complaint_Items__c();
                dci2.Case_No__c = cas.Id; // field is not writeable
                dci2.SPH_Online_User_Id__c = 'TEstxxxx';
                dci2.Asia1__c = tmpAsia1.Id;
                dci2.First_Name__c = 'master';
                dci2.Last_Name__c = 'test';
                dci2.Email__c = 'testxxxx@email.com';
                dci2.New_Password__c = 'aBcdE3gf';
                dci2.Account_Lookup_Field__c = accList[0].id;
                //insert dci2;
                
                Test.startTest();
                PageReference pageRef = Page.DigitalComplaintItemsPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId', cas.Id);
                ApexPages.standardController controller = new ApexPages.standardController(dci2);
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);                      
                    
                PageReference testsaveMe_01 = createDigitalComplaintItemsExtension.saveMe();   
                
                createDigitalComplaintItemsExtension.asia1SelectedExistingId = String.valueOf(tmpAsia1.Id);
                createDigitalComplaintItemsExtension.addAsia1ExistingAccount();   
                createDigitalComplaintItemsExtension.addAsia1NewAccount();         
                //createDigitalComplaintItemsExtension.getAsia1ExistingAccounts();         
                //createDigitalComplaintItemsExtension.retrieveServiceFlags(packageList[0].Id);
                //createDigitalComplaintItemsExtension.retrieveUserDetails();            
                           
                Test.stopTest();
                
                //System.assertEquals(cas.Id, ApexPages.currentPage().getParameters().put('caseId', cas.Id), 'Assertion Message here.');
                
            }//END System.runAs(u)
        }//END testmethod testAsia1ExistingAccount2
        
        static testMethod void test01(){
            //start test data
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            database.insert(con);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            database.insert(billAcc);
            
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
            subRecs.Zuora__CustomerAccount__c = billAcc.Id;
            subRecs.Name = 'Name';
            subRecs.Zuora__Account__c = acc.Id;
            //subRecs.Subscription_Type_1__c = 'Publication';
            subRecs.Subscription_Type__c = 'Publication';
            database.insert(subRecs);
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Sub_Category__c = 'Service Flag Not Updated';
            cas.Subscription_Name__c = subRecs.Id;
            cas.AccountId = acc.Id;
            cas.ContactId = con.Id;
            database.insert(cas);
            
            Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
            asia1.Display_Name__c = 'sample@email.com';
            asia1.User_ID_LDAP_ID__c = 'sample@email.com';
            asia1.Password__c = 'password123';
            asia1.Contact__c = con.Id;
            database.insert(asia1);
            
            Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
            asia1Sub.Asia1__c = asia1.Id;
            asia1Sub.Subscription__c = subRecs.Id;
            database.insert(asia1Sub);
            
            Asia1_Subscription__c asia1Sub2 = TestDataFactory.createAsiaOneSubscription(1)[0];
            asia1Sub2.Asia1__c = asia1.Id;
            asia1Sub2.Subscription__c = subRecs.Id;
            database.insert(asia1Sub2);
            
            Digital_Complaint_Items__c dci = TestDataFactory.createDigitalComplaintItem(1, 'Create User')[0];
            dci.Case_No__c = cas.Id;
            dci.Asia1__c  = asia1.Id;
            dci.Account_Lookup_Field__c = acc.Id;
            //database.insert(dci);
            //end test data
        
            test.startTest();
                PageReference pageRef = Page.DigitalComplaintItemsPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId', cas.Id);
                
                ApexPages.standardController controller = new ApexPages.standardController(dci);
                
                DigitalComplaintItemsExtension contExt = new DigitalComplaintItemsExtension(controller); 
                
                cas.Sub_Category__c = 'Change/Reset Password';
                database.update(cas);
                DigitalComplaintItemsExtension contExt2 = new DigitalComplaintItemsExtension(controller);
                contExt2.thisSelectedAsia1 = asia1.Id;
                contExt2.SaveMe();
                contExt2.saveandnew();
                contExt2.retrieveUserDetails();
                
                dci.Asia1__c  = null;
                ApexPages.standardController controller2 = new ApexPages.standardController(dci);
                DigitalComplaintItemsExtension contExt4 = new DigitalComplaintItemsExtension(controller2);
                contExt4.retrieveUserDetails();
                contExt4.removeAsia1Subscription();
                
                contExt4.status = '';
                contExt4.deactivate = true;
                contExt4.force = true;
                contExt4.sphOnlineUserId = '';
                contExt4.asia1sub = null;
                contExt4.isAsia1Individual = true;
                contExt4.isAsia1Existing = true;
                contExt4.asia1CreationMode = '';
                contExt4.selectedAsia1 = null;
                contExt4.selectedAsia1Creation = '';
                contExt4.selectedPackageId= '';
                
                cas.Sub_Category__c = 'Change/Reset Password';
                database.update(cas);
                DigitalComplaintItemsExtension contExt5 = new DigitalComplaintItemsExtension(controller);
                contExt5.getAsia1ExistingAccounts();
            test.stopTest();
        }
        
    }//END DigitalComplaintItemsExtensionTest