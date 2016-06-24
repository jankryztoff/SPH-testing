/**
* Class Name: <ChangeOfPaymentController>
* @author: <valgacad>
* Date: <9/18/2014>
* Requirement/Project Name: <CRSM Project>
* @description<Test Class for ChangeOfPaymentController>
*/

@isTest (Seealldata = TRUE)
private class ChangeOfPaymentControllerTest3{

///static Account acc;    
    static testMethod void ValidateChangeOfPaymentController(){

//Create a new user with Standard User Profile

        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
            );

        //The test will run as the user created.
        System.runAs(testUserCOP) {
            try {
                Test.setMock(WebServiceMock.class, new zLoginMock());
                Test.startTest();
                
                Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c = 'sample@email.com', Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Account', Zuora__Batch__c = 'Batch1', ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'GOVT';
                zacc.ARMS_Debt_Management__c = 'GOVT';
                zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id, Credit_Balance__c = decimal.valueof('20.00'), Delivery_Charge__c = decimal.valueof('3.00'), Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id, Billing_Account_Name__c = zacc.id, RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'CreditCard');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                //zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                changePayment.aCust = 'Sample Cust';
                changePayment.thisCase.Payment_Mode__c = 'CreditCard';
                //april veloso
//                changePayment.ARMS_ID = '';
                changePayment.ARMS_Return_Message = 'Sample Message';
                changePayment.ARMS_Return_Status = 'ReturnS';
                
                changePayment.getBillAccName(); 
                changePayment.searchCusName();
                changePayment.cancelSearch();
                changePayment.searchAccName();
                                 
                try{
                    changePayment.saveRecord();
                    changePayment.updateOrderAndSubscriptions('Other', 'CreditCard');
                } catch (Exception e){}
    
                //---------
                //PageReference pageRef = Page.Send_ARMSNo_to_Zuora;
                //Test.setCurrentPage(pageRef);
                
                //ApexPages.currentPage().getParameters().put('retURL', '');            
                //ApexPages.currentPage().getParameters().put('zid', zacc.id); 
                
                //START: Wenjun - 11/12/14 
                //Scenerio 1: Simulate Null Billing Type
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cash'; 
                
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                ////Scenerio 2:  Simulate Null Payment Mode
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = NULL;
                changePayment.thisBillingAccount = null;
    
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                ////Scenerio 3:  Simulate Invoice Prepaid
                /*Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__CustomerAccount__c = zacc.id, Zuora__Account__c = acc.id, Billing_Type__c = 'Recurring Prepaid');
                insert sub;*/
                
                changePayment = new ChangeOfPaymentController ();
                /*Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__Account__c = acc.id,Billing_Type__c = 'Recurring Prepaid');
                sub.Zuora__CustomerAccount__c = zacc.id;
                insert sub;*/
                
                changePayment.dummySubscription = zSub;
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Invoice';
                changePayment.thisBillingAccount = zacc;
                
                changePayment.getAcquisitionTypes();
                //changePayment.getDeliveryChargeTypes();
                changePayment.fetchBillingAccount();
                changePayment.getSource();
                changePayment.updateBillingAccountArms();
    
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                ////Scenerio 4: Simulate Credit Card Preaid
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'CreditCard';
                //changePayment.updateCreateCustomerService();
                
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                //JG Checking of Cash payment method
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cash';
                changePayment.updateCreateCustomerService();
               
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                //JG Checking of Cheque payment method
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cheque';
                changePayment.thisOrder.Check_Issuing_Bank__c = null;
                changePayment.thisOrder.Check_Amount__c = null;
                changePayment.thisOrder.Check_No__c = '';
                changePayment.thisOrder.Check_Dated__c = null;
                
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                                
                ////Scenerio 5: Simulate Credit Card Postpaid
                //sub.Billing_Type__c = 'Recurring Postpaid';
                //Update sub;
                
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'CreditCard';
                
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                ////Scenerio 6: Cancel 
                changePayment = new ChangeOfPaymentController ();
                changePayment.cancel();
                //END: Wenjun - 11/12/14
                //
               
               //START: Wenjun - 11/12/14 
                //Scenerio 1: Simulate Null Billing Type
               changePayment = new ChangeOfPaymentController ();
               changePayment.thisCase.AccountId = acc.Id;
               changePayment.thisCase.Billing_Account_Name__c = zacc.id;
               changePayment.thisCase.Payment_Mode__c = 'Cash';
    
              try{
                  changePayment.fetchBillingAccount(); 
              }
              catch(Exception e){}
              
              List<ChangeOfPaymentController.armsWrapper> armsList = new List<ChangeOfPaymentController.armsWrapper>();
              ChangeOfPaymentController.armsWrapper arms = new ChangeOfPaymentController.armsWrapper();
              arms.arName = 'Sample arName';
              arms.isTick = true;
              armsList.add(arms);
              changePayment.armsCusWrapList = armsList;
              
              changePayment.addPopAcc();
              changePayment.closePopup();
              
              Test.stopTest();
            }
            catch(Zuora.zRemoteException e){}  
        }
    }
    
    
    //jurna
    ///static Account acc;    
    static testMethod void ValidateChangeOfPaymentController2(){

//Create a new user with Standard User Profile

        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
            );

        //The test will run as the user created.
        System.runAs(testUserCOP) {
            try {
                Test.setMock(WebServiceMock.class, new zLoginMock());
                
                
                Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c = 'sample@email.com', Mobile__c = '1234567');
                /*Account acc = TestDataFactory.createAccount(1, 'Account_Direct Corporate')[0];
                acc.Email__c = 'sample@email.com';
                acc.Mobile__c = '1234567';
                acc.AccountNumber = 'AN000test1234545678912345678912'; */
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Account', Zuora__Batch__c = 'Batch1', ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'GOVT';
                zacc.ARMS_Debt_Management__c = 'GOVT';
                zacc.ARMS_ID__c = 'Sample ID';
                zacc.Zuora__Account__c = acc.id; 
                insert zacc; 
                
                Contact con = TestDataFactory.createContact(1)[0];
                insert con;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id, Credit_Balance__c = decimal.valueof('20.00'), Delivery_Charge__c = decimal.valueof('3.00'), Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                /*//jurna
                Order__c orderAcc = TestDataFactory.createOrder(1)[0];
                orderAcc.Account__c = acc.id;
                orderAcc.Credit_Balance__c = decimal.valueof('20.00');
                orderAcc.Delivery_Charge__c = decimal.valueof('3.00');
                orderAcc.Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00');
                orderAcc.Other_Payment_Mode__c = 'Invoice'; 
                orderAcc.Payment_Mode__c = 'Check';
                orderAcc.Recipient_Contact__c = con.Id; */
                insert orderAcc; 
                
                Case c = new Case(AccountId = acc.id, Billing_Account_Name__c = zacc.id, RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'CreditCard');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                //zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                changePayment.aCust = 'Sample Cust';
                changePayment.thisCase.Payment_Mode__c = 'CreditCard';
                
                changePayment.getBillAccName(); 
                changePayment.searchCusName();
                changePayment.cancelSearch();
                changePayment.searchAccName();
                 
                try{
                    changePayment.saveRecord();
                    changePayment.updateOrderAndSubscriptions('Other', 'CreditCard');
                } catch (Exception e){}
    
                //---------
                //PageReference pageRef = Page.Send_ARMSNo_to_Zuora;
                //Test.setCurrentPage(pageRef);
                
                //ApexPages.currentPage().getParameters().put('retURL', '');            
                //ApexPages.currentPage().getParameters().put('zid', zacc.id); 
                
                //START: Wenjun - 11/12/14 
                //Scenerio 1: Simulate Null Billing Type
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cash'; 
                //changePayment.thisCase.Payment_Mode__c = 'Cheque'; 
                
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                ////Scenerio 2:  Simulate Null Payment Mode
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = NULL;
                changePayment.thisBillingAccount = null;
    
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                ////Scenerio 3:  Simulate Invoice Prepaid
                /*Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__CustomerAccount__c = zacc.id, Zuora__Account__c = acc.id, Billing_Type__c = 'Recurring Prepaid');
                insert sub;*/
                
                changePayment = new ChangeOfPaymentController ();
                /*Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__Account__c = acc.id,Billing_Type__c = 'Recurring Prepaid');
                sub.Zuora__CustomerAccount__c = zacc.id;
                insert sub;*/
                
                changePayment.dummySubscription = zSub;
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Invoice';
                changePayment.thisBillingAccount = zacc;
                
                changePayment.getAcquisitionTypes();
                //changePayment.getDeliveryChargeTypes();
                changePayment.fetchBillingAccount();
                changePayment.getSource();
                changePayment.updateBillingAccountArms();
    
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                ////Scenerio 4: Simulate Credit Card Preaid
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'CreditCard';
                //changePayment.updateCreateCustomerService();
                
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                //JG Checking of Cash payment method
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cash';
                //changePayment.thisCase.Payment_Mode__c = 'Cheque';
                changePayment.updateCreateCustomerService();
               
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                //JG Checking of Cheque payment method
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cheque';
                changePayment.thisOrder.Check_Issuing_Bank__c = null;
                changePayment.thisOrder.Check_Amount__c = null;
                changePayment.thisOrder.Check_No__c = '';
                changePayment.thisOrder.Check_Dated__c = null;
                
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                                
                ////Scenerio 5: Simulate Credit Card Postpaid
                //sub.Billing_Type__c = 'Recurring Postpaid';
                //Update sub;
                
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'CreditCard';
                
                try{
                  changePayment.saveRecord(); 
                }
                catch(Exception e){}
                
                ////Scenerio 6: Cancel 
                changePayment = new ChangeOfPaymentController ();
                changePayment.cancel();
                //END: Wenjun - 11/12/14
                //
               
               //START: Wenjun - 11/12/14 
                //Scenerio 1: Simulate Null Billing Type
               Test.startTest();
               changePayment = new ChangeOfPaymentController ();
               changePayment.thisCase.AccountId = acc.Id;
               changePayment.thisCase.Billing_Account_Name__c = zacc.id;
               changePayment.thisCase.Payment_Mode__c = 'Cash';   
    
              try{
                  changePayment.fetchBillingAccount(); 
              }
              catch(Exception e){}
              
              List<ChangeOfPaymentController.armsWrapper> armsList = new List<ChangeOfPaymentController.armsWrapper>();
              ChangeOfPaymentController.armsWrapper arms = new ChangeOfPaymentController.armsWrapper();
              arms.arName = 'Sample arName';
              arms.isTick = true;
              armsList.add(arms);
              changePayment.armsCusWrapList = armsList;
              
              changePayment.addPopAcc();
              changePayment.closePopup();
              
              Test.stopTest();
            }
            catch(Zuora.zRemoteException e){}  
        }
    }

    
    //Unit Test
    static testMethod void unitTest(){

//Create a new user with Standard User Profile

        User testUserCOP = new User(
                                Alias = 'stndrd',
                                Email='standarduser@test.com', 
                                EmailEncodingKey='UTF-8',
                                LastName='Test',
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US',
                                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                                TimeZoneSidKey='America/Los_Angeles',
                                UserName='changeofpaymentcontroller@test.com');

        //The test will run as the user created.
        System.runAs(testUserCOP){
        
            try {
                Test.setMock(WebServiceMock.class, new zLoginMock());
                Test.startTest();
                
                Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c = 'sample@email.com', Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Account', Zuora__Batch__c = 'Batch1', ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'NORM';
                zacc.ARMS_Debt_Management__c = 'NORM';
                zacc.ARMS_ID__c = 'Sample ID';
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id, Credit_Balance__c = decimal.valueof('20.00'), Delivery_Charge__c = decimal.valueof('3.00'), Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'), Payment_Mode__c = 'Cheque');
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id, Billing_Account_Name__c = zacc.id, RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'Cash');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                changePayment.aCust = 'Sample Cust';
                changePayment.thisCase.Payment_Mode__c = GlobalVariableClass.CREDITCARD;
                
                //joyrem
                
                                                
                changePayment.getBillAccName(); 
                changePayment.searchCusName();
                changePayment.cancelSearch();
                changePayment.searchAccName();
                 
                try{
                    changePayment.saveRecord();
                    changePayment.updateOrderAndSubscriptions('Other', 'CreditCard');
                    changePayment.updateOrderAndSubscriptions('Check', 'CreditCard');
                    changePayment.updateCreateCustomerService();
                } catch (Exception e){}
                
                List<ChangeOfPaymentController.armsWrapper> armsList = new List<ChangeOfPaymentController.armsWrapper>();
                ChangeOfPaymentController.armsWrapper arms = new ChangeOfPaymentController.armsWrapper();
                arms.arName = 'Sample arName';
                arms.isTick = true;
                armsList.add(arms);
                
                arms = new ChangeOfPaymentController.armsWrapper();
                arms.arName = 'Sample arName2';
                arms.isTick = true;
                armsList.add(arms);
                changePayment.armsCusWrapList = armsList;
                
                changePayment.addPopAcc();
                changePayment.closePopup();
                
                //joy
                
               /* Map<String,String> inputHttpHeaders_x = new Map<String,String>();
                inputHttpHeaders_x.put('test','test');
                
                Map<String,String> outputHttpHeaders_x = new Map<String,String>();
                outputHttpHeaders_x.put('test','test');
                
                wwwSphComArWsWsdlCam.CAMSOAP AccRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();
                AccRespCAM.endpoint_x = ConstantsSLB.getARMSIntegrationSettings(GlobalVariableClass.ENDPOINTDELEGATOR);
                AccRespCAM.clientCertName_x ='test';
                AccRespCAM.clientCert_x = 'etst';
                AccRespCAM.clientCertPasswd_x = 'test';*/
                //AccRespCAM.inputHttpHeaders_x;
                //AccRespCAM.outputHttpHeaders_x;
                
                
              Test.stopTest();
            }catch(Zuora.zRemoteException e) {}  
        }
    }
    
    //sets all getters and setters by jowie
    static testmethod void setAllUncoveredAttributes(){
    
        ChangeOfPaymentController copc = new ChangeOfPaymentController();
            copc.ARMS_Return_Message = 'test';
            copc.ARMS_Return_Status = 'text';
            copc.ARMS_Total_Outstanding_Amount = 1.0;
            copc.ARMS_Update_Ind = true;
            copc.Credit_Term  = 1.0;
            copc.Credit_Limit_Internal = 1.0;
            copc.Credit_Limit_External = 1.0;
            copc.Credit_Reference = 'test';
            copc.acquisitionType = 'test';
            copc.deliveryChargeType = 'test';
            copc.billingAccountOption = 'test';
            copc.glCode = 'test';
            copc.paymentMethodId = 'test';
            copc.fullPaymentMonthlyDeliveryCharge = 1.0;
            copc.subscriberCharge = 1.0; 
            copc.vendorCredit = 1.0; 
            copc.amountPaid = 1.0; 
            copc.isSponsored = true;
            copc.dtlDate = date.Today();
      
      
        ChangeOfPaymentController.armsWrapper copc_aw = new ChangeOfPaymentController.armsWrapper();
            copc_aw.arPOC = 'test';        
            copc_aw.arAddress = 'test';        
            copc_aw.arPostcode = 'test';      
            copc_aw.arStatus = 'test';  
            copc_aw.arAccNum = 'test';     
            copc_aw.arType = 'test';       
            copc_aw.arCredTerm = 'test';        
            copc_aw.arCredTermRef = 'test';        
            copc_aw.arDebtMgmt = 'test';       
            copc_aw.arCompCode = 'test';        
            copc_aw.arCreateDate = 'test';      
            copc_aw.arBLInd = 'test';       
            copc_aw.BLClrCd = 'test';      
            copc_aw.BLRsn = 'test';      
            copc_aw.IdTyp = 'test';       
            copc_aw.IdN = 'test';  
            copc_aw.PpCntryC = 'test';
            copc_aw.CrRskRtg = 'test';      
            copc_aw.CrLmtInt = 'test';    
            copc_aw.CrLmtExt = 'test';   
            copc_aw.CityM = 'test';         
            copc_aw.Cntry = 'test';     
            copc_aw.PoBoxN = 'test';        
            copc_aw.AttnI = 'test';        
            copc_aw.StfI = 'test';  
            copc_aw.GstOOSI = 'test';       
            copc_aw.UpdId = 'test';       
            copc_aw.UpdDte = 'test';        
            copc_aw.UpdTme = 'test';     
            copc_aw.arDate = 'test';       
            copc_aw.arAddress3 = 'test';        
            copc_aw.arAddress4 = 'test'; 
    }
    
    static testMethod void testSaveRecord(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        database.insert(cas);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        //billAcc.Billing_Type__c = 'Full Prepaid';
        database.insert(billAcc);
        
        Integer count = 0;
        List<Zuora__Subscription__c>  sub = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c s:sub){
            if(count==0){
                s.Billing_Type__c = 'Credit Card Postpaid';
            }
            else{
                s.Billing_Type__c = 'Recurring Prepaid';
            }
            s.Zuora__CustomerAccount__c = billAcc.Id;
            count++;
        }
        database.insert(sub);
    
        test.startTest();
            PageReference pgR = Page.ChangeOfPaymentType;
            Test.setCurrentPage(pgR);
        
            ChangeOfPaymentController cont = new ChangeOfPaymentController();
            cont.thisCase = cas;
            cont.thisCase.Payment_Mode__c = 'Cheque';
            cont.thisOrder = ord;
            cont.thisOrder.Check_Issuing_Bank__c = 'bank';
            cont.thisOrder.Check_No__c = 'no'; 
            cont.thisOrder.Check_Dated__c = date.today();
            cont.thisOrder.Check_Amount__c = null;
            cont.thisBillingAccount = billAcc;
            cont.thisAccount = acc;
            cont.saveRecord();
            
            cont.thisBillingAccount.ARMS_Business_Profile__c = 'NONE';
            cont.thisCase.Payment_Mode__c = 'Invoice';
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'CreditCard';
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = null;
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'Credit Card';
            cont.thisCase.Billing_Account_Name__c = billAcc.Id;
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'Cheque';
            cont.saveRecord();
        test.stopTest();
    }
    
     static testMethod void testSaveRecordB(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        database.insert(cas);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        //billAcc.Billing_Type__c = 'Full Prepaid';
        database.insert(billAcc);
        
        Integer count = 0;
        List<Zuora__Subscription__c>  sub = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c s:sub){
            if(count==0){
                s.Billing_Type__c = 'Credit Card Postpaid';
            }
            else{
                s.Billing_Type__c = 'Recurring Prepaid';
            }
            s.Zuora__CustomerAccount__c = billAcc.Id;
            count++;
        }
        database.insert(sub);
    
        test.startTest();
            PageReference pgR = Page.ChangeOfPaymentType;
            Test.setCurrentPage(pgR);
        
            ChangeOfPaymentController cont = new ChangeOfPaymentController();
            cont.thisCase = cas;
            cont.thisCase.Payment_Mode__c = 'Cheque';
            cont.thisOrder = ord;
            cont.thisOrder.Check_Issuing_Bank__c = 'bank';
            cont.thisOrder.Check_No__c = 'no'; 
            //cont.thisOrder.Check_Dated__c = date.today();
            cont.thisOrder.Check_Dated__c = null;
            //cont.thisOrder.Check_Amount__c = null;
            cont.thisOrder.Check_Amount__c = null;
            cont.thisBillingAccount = billAcc;
            cont.thisAccount = acc;
            cont.saveRecord();
            
            cont.thisBillingAccount.ARMS_Business_Profile__c = 'NONE';
            cont.thisCase.Payment_Mode__c = 'Invoice';
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'CreditCard';
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = null;
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'Credit Card';
            cont.thisCase.Billing_Account_Name__c = billAcc.Id;
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'Cheque';
            cont.saveRecord();
        test.stopTest();
        }
    
    static testMethod void testSaveRecord2(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Payment_Mode__c = 'Cheque';
        database.insert(cas);
        
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        //billAcc.Billing_Type__c = 'Full Prepaid';
        database.insert(billAcc);
        
        Integer count = 0;
        List<Zuora__Subscription__c>  sub = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c s:sub){
            if(count==0){
                s.Billing_Type__c = 'Credit Card Postpaid';
            }
            else{
                s.Billing_Type__c = 'Recurring Prepaid';
            }
            s.Zuora__CustomerAccount__c = billAcc.Id;
            count++;
        }
        database.insert(sub);
    
        test.startTest();
        
            PageReference pgR = Page.ChangeOfPaymentType;
            Test.setCurrentPage(pgR);
        
            ChangeOfPaymentController cont = new ChangeOfPaymentController();
            //cont.thisCase = cas;
            cont.thisCase.Payment_Mode__c = cas.Payment_Mode__c;
            //cont.thisOrder = ord;
            //cont.thisOrder.Check_Issuing_Bank__c = 'bank';
            //cont.thisOrder.Check_No__c = 'no'; 
            //cont.thisOrder.Check_Dated__c = date.today();
            //cont.thisOrder.Check_Amount__c = null;
            //cont.thisBillingAccount = billAcc;
            //cont.thisAccount = acc;
            cont.saveRecord();
            
            /*cont.thisBillingAccount.ARMS_Business_Profile__c = 'NONE';
            cont.thisCase.Payment_Mode__c = 'Invoice';
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'CreditCard';
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = null;
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'Credit Card';
            cont.thisCase.Billing_Account_Name__c = billAcc.Id;
            cont.saveRecord();
            
            cont.thisCase.Payment_Mode__c = 'Cheque';
            cont.saveRecord();*/
        test.stopTest();
    }
    
}