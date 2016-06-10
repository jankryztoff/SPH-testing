/**
    * Class Name: <DigitalComplaintItemsExtensionTest2>
    * @author: Kirk Yngwie Enriquez
    * Date: <7/2/2015>
    * Requirement/Project Name: <SPH>
    * @description<Test Class for DigitalComplaintItemsExtension>
    * Last Modified By: Ana Fe Dumangas
    * Last Modified On: 10/20/15
*/

@isTest (seeAllData= True)
private class DigitalComplaintItemsExtensionTest2{
    
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
           
           System.runAs(u){
           
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
                packageList[0].Package_Type__c = 'Base Product';                                  
                packageList[1].Billing_Type__c = 'Full Prepaid';
                insert packageList;                            
                                
                //create Billing Account Records
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = accList[0].Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
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
                orderList[0].Billing_Account__c = billAcc.id;
                orderList[0].Informed_Customer__c = TRUE;
                orderList[0].Recipient_Contact__c = conList[0].Id;
                orderList[0].Billing_Type__c = 'Full Prepaid';
                orderList[0].Subscriber_Charge__c = 10.00;
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
                /*zuoSubList = TestDataFactory.createSubscription(1);
                zuoSubList[0].Name = 'Zuora Name';
                zuoSubList[0].Main_Package__c = packageList[0].Id;
                zuoSubList[0].Main_Package_1__c = String.valueOf(packageList[0].Id);
                zuoSubList[0].Recipient_Contact__c = conList[0].Id; //last name   
                zuoSubList[0].Recipient_Contact_1__c = conList[0].Id;        
                zuoSubList[0].Zuora__Account__c = accList[1].Id;
                zuoSubList[0].Subscriber_Contact__c = conList[0].Id;        
                zuoSubList[0].Order_Line_Item_Number__c = String.ValueOf(oliList[0].Id);
                zuoSubList[0].Order_Line_Item_Number_1__c = oliList[0].Id;    
                zuoSubList[0].Order_Number__c = String.ValueOf(orderList[0].Id);
                zuoSubList[0].Order_Number_1__c = orderList[0].Id;
                zuoSubList[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
                zuoSubList[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                zuoSubList[0].Zuora__Status__c = 'Active';
                zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'false';
                zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'false';
                zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zuoSubList[0].Urgent__c = 'false';
                zuoSubList[0].Vendor_Conversion__c = 'false';
                zuoSubList[0].Charity__c = 'false';
                zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
                zuoSubList[0].Subscription_Type__c = 'Publication';
                zuoSubList[0].Subscription_Type_1__c = 'Publication';
                insert zuoSubList; */     
                
                
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
                //zSubs.add(Subs);
                insert zuoSubList;
               
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
                
                //insert Case Records
                Case cs = TestDataFactory.createCase(1, 'Enquiry')[0];
                //Case cas = new Case();
                cs.Order__c = orderList[0].Id;
                cs.AccountID = accList[0].Id;       
                cs.SuppliedEmail = 'sampleemail@email.com'; 
                cs.ContactId = conList[0].id;
                cs.Sub_Category__c = 'Change/Reset Password';
                cs.Subscription_Name__c = zuoSubList[0].id;
                cs.Sub_Category__c = 'Service Flag Not Updated';
                //cas.RecordTypeID = '012N00000008kI8';
                insert cs;       
                
                Digital_Complaint_Items__c dci2 = new Digital_Complaint_Items__c();
                dci2.Case_No__c = cs.Id; 
                dci2.SPH_Online_User_Id__c = 'TEstxxxx';
                dci2.Asia1__c = tmpAsia1DEL.Id;
                dci2.First_Name__c = 'master';
                dci2.Last_Name__c = 'test';
                dci2.Email__c = 'testxxxx@email.com';
                dci2.New_Password__c = 'aBcdE3gf';
                dci2.Account_Lookup_Field__c = accList[0].id;
                insert dci2;
           
                Test.startTest();
                PageReference pageRef = Page.DigitalComplaintItemsPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId', cs.Id);                
                ApexPages.standardController controller = new ApexPages.standardController(dci2);
                
                DigitalComplaintItemsExtension createDigitalComplaintItemsExtension = new DigitalComplaintItemsExtension(controller);
                createDigitalComplaintItemsExtension.asia1SelectedExistingId = tmpAsia1DEL.id;
                createDigitalComplaintItemsExtension.addAsia1ExistingAccount();
                createDigitalComplaintItemsExtension.addAsia1NewAccount();
                createDigitalComplaintItemsExtension.validateNewAsia1Account();
                
                createDigitalComplaintItemsExtension.asia1.User_ID_LDAP_ID__c = 'Sample User ID';
                createDigitalComplaintItemsExtension.asia1.Display_Name__c = 'Sample Display Name';
                createDigitalComplaintItemsExtension.validateNewAsia1Account();
                
                createDigitalComplaintItemsExtension.asia1IdToBeRemoved = tmpAsia1DEL.id;
                createDigitalComplaintItemsExtension.removeAsia1Subscription();
                
                List<Package_Access_Flag__c> retPaf = createDigitalComplaintItemsExtension.retrieveServiceFlags(packageList[0].Id);
                List<SelectOption> retSelOp = createDigitalComplaintItemsExtension.getAsia1ExistingAccounts();
                
                String retVal = createDigitalComplaintItemsExtension.getEnabledAsia1();
                createDigitalComplaintItemsExtension.populateDisableServiceFields();
                
                PageReference retRef = createDigitalComplaintItemsExtension.SaveMe();
                
                Test.stopTest();
           } 
    }
   
   
}