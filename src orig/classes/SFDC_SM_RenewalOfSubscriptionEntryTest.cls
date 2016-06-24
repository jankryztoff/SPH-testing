@isTest
public class SFDC_SM_RenewalOfSubscriptionEntryTest{


    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createCharge();
        insert CustomSettingsDataFactory.createChargeType();
        insert CustomSettingsDataFactory.createZuora_HPM_Settings();
        insert CustomSettingsDataFactory.createError_Messages();
        insert CustomSettingsDataFactory.createARMSInterface();
        insert CustomSettingsDataFactory.createBillingBatch();
    }
    
  static Account acc;
  static Singpost_Address__c postal;
    static Address__c address;
    static List<Contact> con;
    static List<Package__c> pkg;
    static List<Order__c> orderRec;
  static Case testCase;
  static List<Zuora__CustomerAccount__c> zcaList;
  static List<Zuora__PaymentMethod__c> zpmList;
    static List<Zuora__Subscription__c> testSubscription;

    static List<Order_Line_Item__c> oli;
    static Asia1__c tmpAsia1;
    static List<Package_Item__c> pItems;
    final id accountId = ApexPages.currentPage().getParameters().get('accountId');

    static void prepareTestData(String caseSubName){
      ///////////////////////////////////////////////////////////////
    // Creation of Test Data
    acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber');
        insert acc;

        postal = new Singpost_Address__c();
        postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
    
        address = new Address__c();
        address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = postal.Id;
        insert address;

        con = TestDataFactory.createContact(2);
        con[0].Phone = '1234567';
        con[0].LastName ='Dumangas';
        con[0].FirstName = 'Ana';
        con[0].AccountId = acc.Id;
        con[1].Phone = '1234567';
        con[1].AccountId = acc.Id;
        con[1].Recipient_Indicator__c = true;
        con[1].LastName ='Dumangas';
        con[1].FirstName = 'Ana';
        insert con;

        pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15'; 
        pkg[0].Package_Type__c = 'Base'; //packageType;
        pkg[0].Billing_Type__c = 'Recurring Prepaid';
        pkg[0].Subscription_Period__c = '12'; //subPeriod;
        insert pkg;    

        zcaList = TestDataFactory.createBillingAccount(1);
        zcaList[0].Name = 'Zuora Customer Account';
        zcaList[0].Zuora__Account__c = acc.Id;
        zcaList[0].Zuora__Credit_Balance__c = 1;
        zcaList[0].Refund_Amount__c = 100;
        zcaList[0].Zuora__AutoPay__c =false;
        zcaList[0].Zuora__Balance__c = 1;
        zcaList[0].Payment_Mode__c = 'Cash';
        zcaList[0].Other_PaymentMethod__c= 'Cash';
        zcaList[0].Zuora__PaymentMethodType__c = 'Cash'; 
        zcalist[0].Zuora__External_Id__c = '22544AA';  
        zcalist[0].Zuora__Zuora_Id__c = '0124';  
        zcalist[0].Billing_Type__c = 'Recurring Prepaid';
        insert zcaList;
    
        //START : D-1929 3/2/2015 added to create Default Payment Method
        zpmList = TestDataFactory.createPaymentMethod(1);
        zpmList[0].Name = 'Zuora Customer Account';
        zpmList[0].Zuora__Type__c = 'Cash';
        zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
        insert zpmList;  
        //End: D-1929 3/2/2015 added to create Default Payment Method
    
        zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
        update zcaList;
        
        /*List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
        //orderLineItemList[0].Addon_Package__c = pkg[0].id;
        insert orderLineItemList;*/
        
        orderRec = TestDataFactory.createOrder(1);
        orderRec[0].Account__c = acc.id;
        orderRec[0].Informed_Customer__c = TRUE;
        orderRec[0].Recipient_Contact__c = con[1].Id;
        orderRec[0].Subscriber_Charge__c = 15;
        orderRec[0].Billing_Account__c = zcaList[0].Id;
        orderRec[0].Billing_Type__c = 'Recurring Prepaid';
        insert orderRec;

        oli = TestDataFactory.createOrderLineItem(2);
        oli[0].Earliest_Start_Date__c = Date.today();
        oli[0].Start_Date__c =  Date.today().addDays(1);
        oli[0].End_Date__c = Date.today().addDays(20);
        oli[0].Fee_Waiver__c = TRUE;
        oli[0].Order__c = orderRec[0].id;
        oli[0].Main_Package_ID__c = pkg[0].id;
        oli[0].Main_Package_Period__c = 1;
        oli[0].Qty__c = 1;
        oli[0].Term_Length__c = 1;
        oli[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
        oli[0].Main_Package_Type__c = 'Base';
        oli[0].Main_Package_Frequency__c = 'Default';
        oli[0].Delivered_By__c = 'None';
        oli[0].Term_is_discussed__c = TRUE;
        oli[0].Is_Digital__c = TRUE;
        oli[0].Delivered_By__c = 'Mailing Agent';
        oli[0].New_Contract_Period__c = 1;
        oli[0].Main_Package_Sub_Type__c = 'Termed';
        
        oli[1].Earliest_Start_Date__c = Date.today();
        oli[1].Start_Date__c =  Date.today().addDays(1);
        oli[1].End_Date__c = Date.today().addDays(20);
        oli[1].Fee_Waiver__c = TRUE;
        oli[1].Order__c = orderRec[0].id;
        oli[1].Main_Package_ID__c = pkg[0].id;
        oli[1].Main_Package_Period__c = 1;
        oli[1].Qty__c = 1;
        oli[1].Term_Length__c = 1;
        oli[1].Main_Package_Billing_Type__c = 'Recurring Prepaid';
        oli[1].Main_Package_Type__c = 'Base';
        oli[1].Main_Package_Frequency__c = 'Default';
        oli[1].Delivered_By__c = 'None';
        oli[1].Term_is_discussed__c = TRUE;
        oli[1].Is_Digital__c = TRUE;
        oli[1].Delivered_By__c = 'Mailing Agent';
        oli[1].New_Contract_Period__c = 1;
        oli[1].Main_Package_Sub_Type__c = 'Termed';
        insert oli;
        
        List<Promotion__c> promoList = TestDataFactory.createPromotion(1);
        promoList[0].Contract_Period__c = '12';
        insert promoList;
        
        testSubscription =  TestDataFactory.createSubscription(2);
        testSubscription[0].Subscriber_Contact__c = con[0].id;
        testSubscription[0].Main_Package__c = pkg[0].id;
        testSubscription[0].Main_Package_1__c = pkg[0].id;
        testSubscription[0].Zuora__Account__c = acc.id;
        testSubscription[0].Order_Number__c = null;
        testSubscription[0].Zuora__CustomerAccount__c = zcaList[0].Id;
        testSubscription[0].Billing_Type__c = 'Recurring Prepaid';
        testSubscription[0].Legacy_Create_Date__c = 'a';
        testSubscription[0].Legacy_Create_By__c = 'a';
        testSubscription[0].Legacy_Update_By__c = 'a';
        testSubscription[0].Legacy_Subscription_ID__c = 'a';
        testSubscription[0].Legacy_Update_Date__c = 'a';
        testSubscription[0].Number_of_Copies__c = 100;
        testSubscription[0].Number_of_Copies1__c = '100';
        testSubscription[0].Zuora__Status__c = 'Active';
        testSubscription[0].Subscription_Type_1__c = 'Publication';
        testSubscription[0].Subscription_Type__c = 'Publication';
        testSubscription[0].Contact__c = con[0].id;
        testSubscription[0].Delivery_Charge_Type__c = 'H';
        testSubscription[0].Recipient_Contact__c = con[1].Id; //recConId;
        testSubscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(20);
        testSubscription[0].Zuora__Version__c = 1;
        testSubscription[0].Zuora__TermSettingType__c = 'TERMED';
        testSubscription[0].Term_Length__c = 12;
        testSubscription[0].Term_Length1__c = '12';
        //testSubscription[0].Order_Number_1__c = orderRec[0].Id;
        testSubscription[0].Order_Line_Item_Number_1__c = oli[0].Id;
        
        testSubscription[1].Subscriber_Contact__c = con[0].id;
        testSubscription[1].Main_Package__c = pkg[0].id;
        testSubscription[1].Main_Package_1__c = pkg[0].id;
        testSubscription[1].Zuora__Account__c = acc.id;
        testSubscription[1].Order_Number__c = null;
        testSubscription[1].Zuora__CustomerAccount__c = zcaList[0].Id;
        testSubscription[1].Billing_Type__c = 'Recurring Prepaid';
        testSubscription[1].Legacy_Create_Date__c = 'a';
        testSubscription[1].Legacy_Create_By__c = 'a';
        testSubscription[1].Legacy_Update_By__c = 'a';
        testSubscription[1].Legacy_Subscription_ID__c = 'a';
        testSubscription[1].Legacy_Update_Date__c = 'a';
        testSubscription[1].Number_of_Copies__c = 100;
        testSubscription[1].Number_of_Copies1__c = '100';
        testSubscription[1].Zuora__Status__c = 'Active';
        testSubscription[1].Subscription_Type_1__c = 'Publication';
        testSubscription[1].Subscription_Type__c = 'Publication';
        testSubscription[1].Contact__c = con[0].id;
        testSubscription[1].Delivery_Charge_Type__c = 'H';
        testSubscription[1].Recipient_Contact__c = con[1].Id;
        testSubscription[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(20);
        testSubscription[1].Zuora__Version__c = 1;
        testSubscription[1].Zuora__TermSettingType__c = 'TERMED';
        testSubscription[1].Term_Length__c = 12;
        testSubscription[1].Term_Length1__c = '12';
        system.debug('>>>CHA promoList[0].Id ' + promoList[0].Id);
        testSubscription[1].Promotion_1__c = promoList[0].Id;
        testSubscription[1].Order_Line_Item_Number_1__c = oli[1].Id;
        insert testSubscription;
    
    testCase = new Case();
    testCase.AccountId = testSubscription[0].Zuora__Account__c;
    testCase.Origin = 'Phone';
    testCase.Priority = 'Medium';
    testCase.Status = 'New';
    testCase.Payment_Mode__c = 'Cash';
    testCase.Amount_To_Refund__c = 100;
    testCase.Action_Type__c = 'Amend';    
    testCase.RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.CASERETENTION);
    if(caseSubName != null){
      testCase.Subscription_Name__c = testSubscription[0].Id;
    }
    insert testCase;


    ////////////////////
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        //prdRatePlan.RatePlanType__c = 'Discount';
        insert prdRatePlan;
        
        //zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        //prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        //insert prpc;
        
        pItems = TestDataFactory.createPackageItem(2, 'Base Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = pkg[0].id;
            pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            //pItem.RecordTypeId = constantsSLB.getKeyID('Package Item_Discount');
        } //RecordType.Name = 'Discount' && Product_Rate_Plan__r.RatePlanType__c != 'Discount'
        insert pItems;

        //create Asia1__c
        tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = con[0].Id;
        insert tmpAsia1;
    ////////////////////
    }


    //BEGIN WITH CASE ID PROVIDED
  static testMethod void myUnitTest1(){
    // This test class will satisfied all the IF statement
    PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
    prepareTestData('');
    Test.startTest();
      pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
      pageRef.getParameters().put( 'caseId', testCase.Id );
      pageRef.getParameters().put('def_parent_id', testCase.Id);

      system.Test.setCurrentPage( pageRef );
      SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
      controller.retrieveActiveSubscriptions();

      //controller.save();

      controller.continueSave();

      controller.asia1SelectedExistingId = tmpAsia1.id;
      controller.addAsia1ExistingAccount();
      
      controller.searchText = 'Mail';
      controller.searchFrom = 'Package';
      controller.searchBillingType = 'Full Prepaid';
      controller.executeSearch();

      controller.searchFrom = 'Promotion';
      controller.executeSearch();

      controller.searchFrom = 'Test';
      controller.executeSearch();


      controller.addAsia1NewAccount();
      controller.removeAsia1Subscription();
      controller.getAsia1ExistingAccounts();
      controller.getDeliveryChargeTypes();

      controller.retrieveSource();
      controller.creditCardType  = 'American Express';
      controller.retrieveSource();
      controller.getSource();

      //END of billing payment functionality
      SM_RenewalOfSubscriptionEntryController.armsWrapper awCus = new SM_RenewalOfSubscriptionEntryController.armsWrapper();
      controller.searchCusName(); //< --- with web service
      controller.searchAccName(); //< --- with web service
      //controller.armsCusWrapList = new List<SM_RenewalOfSubscriptionEntryController.armsWrapper>{awCus};
      awCus.arNum = '1';
      awCus.arName = '1';        
      awCus.arPOC = '1';         
      awCus.arAddress = '1';         
      awCus.arPostcode = '1';        
      awCus.arStatus = '1';      
      awCus.arBusProf = '1';         
      awCus.arDate = '1';        
      awCus.isTick = True;       
      awCus.arAccNum = '1';      
      awCus.arType = '1';        
      awCus.arCredTerm= '1';         
      awCus.arCredTermRef = '1';         
      awCus.arDebtMgmt = '1';        
      awCus.arCompCode = '1';        
      awCus.arCreateDate = '1';      
      awCus.arBLInd = '1';       
      awCus.BLClrCd = '1';       
      awCus.BLRsn = '1';         
      awCus.IdTyp = '1';         
      awCus.IdN = '1';       
      awCus.PpCntryC = '1';      
      awCus.CrRskRtg = '1';      
      awCus.CrLmtInt = '1';      
      awCus.CrLmtExt = '1';      
      awCus.CityM = '1';         
      awCus.Cntry = '1';         
      awCus.PoBoxN = '1';        
      awCus.AttnI = '1';         
      awCus.StfI = '1';      
      awCus.GstOOSI = '1';       
      awCus.UpdId = '1';         
      awCus.UpdDte = '1';        
      awCus.UpdTme = '1';        
      awCus.arAddress1 = '1';        
      awCus.arAddress2 = '1';        
      awCus.arAddress3 = '1';        
      awCus.arAddress4 = '1';    
      controller.armsCusWrapList = new List<SM_RenewalOfSubscriptionEntryController.armsWrapper>{awCus};
        
      controller.getBillAccName();
      controller.addPopAcc();
      controller.closePopup();
      controller.cancelSearch();
      
      SM_RenewalOfSubscriptionEntryController.armsWrapper awCus2 = new SM_RenewalOfSubscriptionEntryController.armsWrapper();
      controller.searchCusName(); //< --- with web service
      controller.searchAccName(); //< --- with web service
      //controller.armsCusWrapList = new List<SM_RenewalOfSubscriptionEntryController.armsWrapper>{awCus};
      awCus2.arNum = '1';
      awCus2.arName = '1';        
      awCus2.arPOC = '1';         
      awCus2.arAddress = '1';         
      awCus2.arPostcode = '1';        
      awCus2.arStatus = '1';      
      awCus2.arBusProf = '1';         
      awCus2.arDate = '1';        
      awCus2.isTick = True;       
      awCus2.arAccNum = '1';      
      awCus2.arType = '1';        
      awCus2.arCredTerm= '1';         
      awCus2.arCredTermRef = '1';         
      awCus2.arDebtMgmt = '1';        
      awCus2.arCompCode = '1';        
      awCus2.arCreateDate = '1';      
      awCus2.arBLInd = '1';       
      awCus2.BLClrCd = '1';       
      awCus2.BLRsn = '1';         
      awCus2.IdTyp = '1';         
      awCus2.IdN = '1';       
      awCus2.PpCntryC = '1';      
      awCus2.CrRskRtg = '1';      
      awCus2.CrLmtInt = '1';      
      awCus2.CrLmtExt = '1';      
      awCus2.CityM = '1';         
      awCus2.Cntry = '1';         
      awCus2.PoBoxN = '1';        
      awCus2.AttnI = '1';         
      awCus2.StfI = '1';      
      awCus2.GstOOSI = '1';       
      awCus2.UpdId = '1';         
      awCus2.UpdDte = '1';        
      awCus2.UpdTme = '1';        
      awCus2.arAddress1 = '1';        
      awCus2.arAddress2 = '1';        
      awCus2.arAddress3 = '1';        
      awCus2.arAddress4 = '1';    
      controller.armsCusWrapList = new List<SM_RenewalOfSubscriptionEntryController.armsWrapper>{awCus, awCus2};
      controller.addPopAcc();
      
      controller.clearPaymentMethod();
      controller.cancel();
      controller.calculateCharges2();
      controller.clearOtherPaymentMethod();

    Test.stopTest();

  }

  static testMethod void myUnitTest2(){
    // This test method will not provide CASE.Subscription_Name__c
    PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
    prepareTestData(null);

    Test.startTest();
      pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
      pageRef.getParameters().put( 'caseId', testCase.Id );

      system.Test.setCurrentPage( pageRef );
      SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
      controller.retrieveActiveSubscriptions();

    Test.stopTest();

  }
  //END WITH CASE ID PROVIDED

  //BEGIN WITHOUT CASE ID PROVIDED
  static testMethod void myUnitTest3(){
    // This test method will not provide CASE
    PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
    prepareTestData(null);

    orderRec[0].Delivery_Charge_Type__c = 'N';
    update orderRec[0];
    
    Test.startTest();
      pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
      //pageRef.getParameters().put( 'caseId', testCase.Id );

      system.Test.setCurrentPage( pageRef );
      SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
      controller.retrieveActiveSubscriptions();
      controller.selectedDeliveryChargeType = 'S';
      controller.calculateCharges();
      
      orderRec[0].Delivery_Charge_Type__c = 'S';
      update orderRec[0];
      controller.selectedDeliveryChargeType = 'N';
      controller.calculateCharges();
      
      controller.selectedDeliveryChargeType = '9';
      controller.calculateCharges();
      
      controller.selectedDeliveryChargeType = 'H';
      controller.calculateCharges();
      
    Test.stopTest();

  }

  static testMethod void myUnitTest4(){
    // This test method will provide subscriptionId
    PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
    prepareTestData(null);

    Test.startTest();
      pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
      pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );

      system.Test.setCurrentPage( pageRef );
      SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
      controller.retrieveActiveSubscriptions();

    Test.stopTest();

  }
  //END WITHOUT CASE ID PROVIDED

  static testMethod void myUnitTest5(){
        // This test method will invoke the normal save() method
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        prepareTestData(null);

  
        Test.startTest();
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'caseId', testCase.Id );

            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.retrieveActiveSubscriptions();
            system.debug('kulot : ' + controller.thisOrder);
            Error_Messages__c msg =new Error_Messages__c(Name='Temp Stop Qty',Message__c='test only',Apex_Class_Trigger_Name__c='Test error');
            insert msg;

            if (controller.thisOrder <> null) {
                controller.selectedSubscriptionId = testSubscription[0].Id;
                controller.save();
            }

        Test.stopTest();

    }

    static testMethod void myUnitTest6(){
        // This test method will invoke the save() method and force the data to covered the if condition.
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        prepareTestData(null);

  
        Test.startTest();
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'def_parent_id', testCase.Id  );

            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.retrieveActiveSubscriptions();
            system.debug('kulot : ' + controller.thisOrder);
            List<Error_Messages__c> listMsg = new List<Error_Messages__c>();
            Error_Messages__c msg =new Error_Messages__c(Name='Temp Stop Qty',Message__c='test only',Apex_Class_Trigger_Name__c='Test error');
            listMsg.add(msg);
            Error_Messages__c msg1 =new Error_Messages__c(Name='Insufficient Amount',Message__c='test only',Apex_Class_Trigger_Name__c='Test error');
            listMsg.add(msg1);
            insert listMsg;
            

            if (controller.thisOrder <> null) {
                controller.selectedSubscriptionId = testSubscription[0].Id;
                controller.thisOrder.Payment_Mode__c = 'Credit Card';
                controller.thisOrder.Payment_Method_ID__c = null;
                controller.billingAccountOption = 'createNew';
                controller.save();

                controller.thisOrder.Payment_Mode__c = 'Check';
                controller.dueToSPH = 1;
                controller.save();

                controller.billingAccountOption = 'createNew';
                controller.thisOrder.Payment_Mode__c = 'Other';
                controller.thisOrder.Other_Payment_Mode__c = 'Invoice';
                controller.searchCustTick = false;
                controller.thisOrder.Create_ARMS_Customer_Account__c = false;
                controller.thisOrder.Business_Profile__c = 'NONE';
                controller.thisOrder.Debt_Management_Treatment__c = 'NONE';
                controller.save();

                controller.searchCustTick = true; // reset to avoid entering the previous If statement
                controller.accNum = '1';
                controller.accTextName = 'pi';
                controller.searchAcctTick = false;
                controller.thisOrder.Create_ARMS_Customer_Account__c  = false;
                controller.thisOrder.Business_Profile__c = 'NONE';
                controller.thisOrder.Debt_Management_Treatment__c = 'NONE';
                controller.save();

                controller.thisOrder.Business_Profile__c = ''; // reset to avoid entering the previous If statement
                controller.thisOrder.Create_ARMS_Customer_Account__c = false;
                controller.searchCustTick = false;
                controller.accNum = null;
                controller.accTextName = null;
                controller.save();

                controller.thisOrder.Create_ARMS_Customer_Account__c = true; // reset to avoid entering the previous If statement
                controller.thisOrder.Business_Profile__c = 'NONE';
                controller.thisOrder.Payment_Mode__c = 'Other';
                controller.thisOrder.Other_Payment_Mode__c = 'Invoice';
                controller.save();

                controller.thisOrder.Payment_Mode__c = 'Other';
                controller.thisOrder.Other_Payment_Mode__c = '';
                controller.save();

                controller.thisOrder.Payment_Mode__c = ''; // reset to avoid entering the previous If statement
                controller.thisOrder.Create_ARMS_Customer_Account__c = true;
                controller.thisOrder.Create_ARMS_Account_Only__c = true;
                controller.save();

                controller.thisOrder.Customer_Name__c = 'pi';
                controller.thisOrder.Customer_No__c = '1';
                controller.save();

                controller.thisOrder.Customer_No__c = null; // reset to avoid entering the previous If statement
                controller.thisOrder.Customer_Name__c = null; // reset to avoid entering the previous If statement
                controller.thisOrder.ARMS_Account_Number__c = '11234';
                controller.thisOrder.Debt_Management_Treatment__c = 'pi';
                controller.save();

                controller.thisOrder.ARMS_Account_Number__c = null; // reset to avoid entering the previous If statement
                controller.orderLineItem.Term_Length__c = 0;
                controller.orderLineItem.Main_Package_Sub_Type__c = 'Termed';
                controller.save();

                controller.orderLineItem.Term_Length__c = 1; // reset to avoid entering the previous If statement
                controller.orderLineItem.New_Contract_Period__c = 0;
                controller.save();

                /* 
                THIS IS INVALID PROMOTION ID

                controller.orderLineItem.New_Contract_Period__c = 1;
                controller.orderLineItem.Term_is_discussed__c = false;
                controller.orderLineItem.Promotion_ID__c = 'pi';
                system.debug('1a============================');
                controller.save();
                system.debug('2a============================');

                Make data for line 1013 IF statement.
                */


                // JUST CALL INITIALIZE THE UNSED VARIABLE
                controller.totalSubscriptionPrice = 0.00;
                controller.selSubName = '';
                controller.orderLineItemIdToBeRemoved = '';
                controller.selectedOrderLineItem = '';
                controller.selectedPromotionId = '';
                controller.selPackId = '';
                controller.isRemoveEligibilityRuleSearchFilter = true;
                controller.searchErrorMsg = '';
                controller.searchPackageMsg = '';
                controller.selectedPackageName = '';
                controller.isReInitializedItem = TRUE;
                controller.searchPromotionMsg = '';
                //controller.promotionGifts = new list<GiftWrapper>();
                controller.isPromotionSelected = TRUE;
                controller.asia1ErrorMsg = '';
                controller.acquisitionType = '';
                controller.deliveryChargeType = '';
                controller.glCode = '';
                controller.isSponsored = TRUE;
                controller.fullPaymentMonthlyDeliveryCharge = 0.00;
                controller.amountPaid = 0.00;
                controller.isNewsPaper = TRUE;
                controller.defaultSelectedSubscriptionId = '';
                controller.charityField = TRUE;
                controller.withNonCharityOli = TRUE;

            }

        Test.stopTest();

    }
    
     static testMethod void NewRenewalSubsTest01(){
      
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        prepareTestData(null);

        Promotion_Gift__c PromoGift = TestDataFactory.createPromotionGift(1)[0];
        insert PromoGift;   
        
       
        Test.startTest();
            pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
            pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
            pageRef.getParameters().put( 'def_parent_id', testCase.Id  );

            system.Test.setCurrentPage( pageRef );
            SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
            controller.retrieveActiveSubscriptions();
            system.debug('kulot : ' + controller.thisOrder);
            List<Error_Messages__c> listMsg = new List<Error_Messages__c>();
            Error_Messages__c msg =new Error_Messages__c(Name='Temp Stop Qty',Message__c='test only',Apex_Class_Trigger_Name__c='Test error');
            listMsg.add(msg);
            Error_Messages__c msg1 =new Error_Messages__c(Name='Insufficient Amount',Message__c='test only',Apex_Class_Trigger_Name__c='Test error');
            listMsg.add(msg1);
            insert listMsg;
            

            if (controller.thisOrder <> null) {
                controller.selectedSubscriptionId = testSubscription[0].Id;
                controller.thisOrder.Payment_Mode__c = 'Credit Card';
                controller.thisOrder.Payment_Method_ID__c = null;
                controller.billingAccountOption = 'createNew';
                controller.save();

                controller.thisOrder.Payment_Mode__c = 'Check';
                controller.dueToSPH = 1;
                controller.save();

                controller.billingAccountOption = 'createNew';
                controller.thisOrder.Payment_Mode__c = 'Other';
                controller.thisOrder.Other_Payment_Mode__c = 'Invoice';
                controller.searchCustTick = false;
                controller.thisOrder.Create_ARMS_Customer_Account__c = false;
                controller.thisOrder.Business_Profile__c = 'NONE';
                controller.thisOrder.Debt_Management_Treatment__c = 'NONE';
                controller.save();

                controller.searchCustTick = true; // reset to avoid entering the previous If statement
                controller.accNum = '1';
                controller.accTextName = 'pi';
                controller.searchAcctTick = false;
                controller.thisOrder.Create_ARMS_Customer_Account__c  = false;
                controller.thisOrder.Business_Profile__c = 'NONE';
                controller.thisOrder.Debt_Management_Treatment__c = 'NONE';
                controller.save();

                controller.thisOrder.Business_Profile__c = ''; // reset to avoid entering the previous If statement
                controller.thisOrder.Create_ARMS_Customer_Account__c = false;
                controller.searchCustTick = false;
                controller.accNum = null;
                controller.accTextName = null;
                controller.save();

                controller.thisOrder.Create_ARMS_Customer_Account__c = true; // reset to avoid entering the previous If statement
                controller.thisOrder.Business_Profile__c = 'NONE';
                controller.thisOrder.Payment_Mode__c = 'Other';
                controller.thisOrder.Other_Payment_Mode__c = 'Invoice';
                controller.save();

                controller.thisOrder.Payment_Mode__c = 'Other';
                controller.thisOrder.Other_Payment_Mode__c = '';
                controller.save();

                controller.thisOrder.Payment_Mode__c = ''; // reset to avoid entering the previous If statement
                controller.thisOrder.Create_ARMS_Customer_Account__c = true;
                controller.thisOrder.Create_ARMS_Account_Only__c = true;
                controller.save();

                controller.thisOrder.Customer_Name__c = 'pi';
                controller.thisOrder.Customer_No__c = '1';
                controller.save();

                controller.thisOrder.Customer_No__c = null; // reset to avoid entering the previous If statement
                controller.thisOrder.Customer_Name__c = null; // reset to avoid entering the previous If statement
                controller.thisOrder.ARMS_Account_Number__c = '11234';
                controller.thisOrder.Debt_Management_Treatment__c = 'pi';
                controller.save();

                controller.thisOrder.ARMS_Account_Number__c = null; // reset to avoid entering the previous If statement
                controller.orderLineItem.Term_Length__c = 0;
                controller.orderLineItem.Main_Package_Sub_Type__c = 'Termed';
                controller.save();

                controller.orderLineItem.Term_Length__c = 1; // reset to avoid entering the previous If statement
                controller.orderLineItem.New_Contract_Period__c = 0;
                controller.save();

                /* 
                THIS IS INVALID PROMOTION ID

                controller.orderLineItem.New_Contract_Period__c = 1;
                controller.orderLineItem.Term_is_discussed__c = false;
                controller.orderLineItem.Promotion_ID__c = 'pi';
                system.debug('1a============================');
                controller.save();
                system.debug('2a============================');

                Make data for line 1013 IF statement.
                */


                // JUST CALL INITIALIZE THE UNSED VARIABLE
                controller.totalSubscriptionPrice = 0.00;
                controller.selSubName = '';
                controller.orderLineItemIdToBeRemoved = '';
                controller.selectedOrderLineItem = '';
                controller.selectedPromotionId = '';
                controller.selPackId = '';
                controller.isRemoveEligibilityRuleSearchFilter = true;
                controller.searchErrorMsg = '';
                controller.searchPackageMsg = '';
                controller.selectedPackageName = '';
                controller.isReInitializedItem = TRUE;
                controller.searchPromotionMsg = '';
                controller.isPromotionSelected = TRUE;
                controller.asia1ErrorMsg = '';
                controller.acquisitionType = '';
                controller.deliveryChargeType = '';
                controller.glCode = '';
                controller.isSponsored = TRUE;
                controller.fullPaymentMonthlyDeliveryCharge = 0.00;
                controller.amountPaid = 0.00;
                controller.isNewsPaper = TRUE;
                controller.defaultSelectedSubscriptionId = '';
                controller.charityField = TRUE;
                controller.withNonCharityOli = TRUE;
            
            Boolean newbool = true; 
            
            SM_RenewalOfSubscriptionEntryController.GiftWrapper smRenewSubs_gw = new SM_RenewalOfSubscriptionEntryController.GiftWrapper();
            smRenewSubs_gw.selectGift = newbool; 
            smRenewSubs_gw.promotionGift = PromoGift;
           
            List<SM_RenewalOfSubscriptionEntryController.GiftWrapper> smRenewSubs_gwList = new List<SM_RenewalOfSubscriptionEntryController.GiftWrapper>();
            smRenewSubs_gwList.add(smRenewSubs_gw);
            
            controller.promotionGifts = smRenewSubs_gwList;
            // controller.populatePromotionGifts();
            controller.populateAddOn();
            controller.revertOldValues();
            controller.getBillingAccountOptions();
            
        orderRec[0].Payment_Mode__c = 'Cash';
        orderRec[0].Base_Subscription__c = testSubscription[0].id;
        orderRec[0].Status__c = 'Draft';
        update orderRec;
        
        controller.thisOrder = orderRec[0];
              controller.addOrderLineItem();
            }

        Test.stopTest();

    }

    static testMethod void testRenewal07(){
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        prepareTestData(null);
        
        Test.startTest();
        
        pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
        pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
        pageRef.getParameters().put( 'caseId', testCase.Id );

        system.Test.setCurrentPage( pageRef );
        SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
        controller.retrieveActiveSubscriptions();
        
        Error_Messages__c msg =new Error_Messages__c(Name='Temp Stop Qty',Message__c='test only',Apex_Class_Trigger_Name__c='Test error');
        insert msg;
        
        system.debug('testRenewal07 controller.thisOrder : ' + controller.thisOrder);
        if (controller.thisOrder <> null) {
            controller.selectedSubscriptionId = testSubscription[0].Id;
            controller.save();
        }
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTest8(){
    // This test method will not provide CASE
    PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
    prepareTestData(null);
    
    //create Product Publication
    Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
    
    Test.startTest();
      pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
      //pageRef.getParameters().put( 'caseId', testCase.Id );

      system.Test.setCurrentPage( pageRef );
      SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
      controller.retrieveActiveSubscriptions();
      controller.testCoveragePatch();

      
    Test.stopTest();

    }
    /*
    static testMethod void myUnitTest9(){
    // This test method will not provide CASE
    PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
    prepareTestData(null);
    
    //testARMS
    
    Test.startTest();
        pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
        //pageRef.getParameters().put( 'caseId', testCase.Id );

        system.Test.setCurrentPage( pageRef );
        SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
        controller.retrieveActiveSubscriptions();
        
        //prepare searchCus data
        controller.aCust = 'test Cus Name';

        controller.searchCusName();
    
        //prepare searchAcc data

        //controller.searchAccName();
    Test.stopTest();

    }
    **/
}