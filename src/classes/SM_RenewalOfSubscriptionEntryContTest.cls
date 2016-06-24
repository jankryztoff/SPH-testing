@isTest
public class SM_RenewalOfSubscriptionEntryContTest {


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
      //controller.aCust='TEST';
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

// previous version below by Errol yatar

// @isTest(seeAllData=true)
// public class SM_RenewalOfSubscriptionEntryContTest {
//     static Account acc;
//     static Singpost_Address__c postal;
//     static Address__c address;
//     static List<Contact> con;
//     static List<Package__c> pkg;
//     static List<Order__c> orderRec;
//     static Case testCase;
//     static List<Zuora__CustomerAccount__c> zcaList;
//     static List<Zuora__Subscription__c> zSubs;
//     static Zuora__Refund__c refund;
//     static List<Zuora__PaymentMethod__c> zpmList;
//     static List<Zuora__Subscription__c> testSubscription;
//     static PageReference pageRef;
//     static String accId;
//     static String conId;
//     static String recConId;
//     static Package__c packageObject;
//     static List<Promotion__c> promotion;
//     static Gift__c gift;
//     static Promotion_Gift__c pg;
//     static List<zqu__ZProduct__c> zProduct;
//     static List<Package_Item__c> pItems;
//     static List<Product_Family__c> productFamily;
//     static List<zqu__ProductRatePlan__c> prdRatePlans;
//     static List<Order_Line_Item__c> oli;
//     static Order_Line_Item__c tempOLI;
//     static Asia1__c tmpAsia1;
    
//     /**
//     * @name: prepareTestData
//     * @author : Recuerdo Bregente
//     * @description : Prepares the test data objects.
//     * @date: 07/20/2015
//     */ 
//     static void prepareTestData(String caseSub, String productType, String subPeriod, String packageType){
//             defaultCustomSetting();
//             pageRef = Page.SM_RenewalOfSubscriptionEntry;
            
//             testSubscription = [ SELECT Id, Main_Package_1__c, Zuora__Account__c, Main_Package__c,
//                                 Zuora__CustomerAccount__r.Billing_Type__c, Zuora__CustomerAccount__c, Billing_Type__c,
//                                 Zuora__CustomerAccount__r.Zuora__Account__c, Contact__c, Contact__r.AccountId,
//                                 Recipient_Contact__c, Vendor_1__c, Zuora__SubscriptionEndDate__c
//                                 FROM Zuora__Subscription__c
//                                 WHERE Zuora__Account__c != NULL
//                                 AND Zuora__Status__c = 'Active'
//                                 AND Subscription_Type_1__c != 'Delivery'
//                                 AND Main_Package_1__c != ''
//                                 AND Billing_Type__c = 'Recurring Prepaid'
//                                 AND Main_Package_1__r.Package_Type__c = :packageType
//                                 LIMIT 1];
            
//             if(testSubscription.size() == 0) {
//                 acc = new Account();
//                 acc.Name = 'Test Account';
//                 acc.RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber');
//                 insert acc;
//                 accId = acc.Id;
            
//                 postal = new Singpost_Address__c();
//                 postal = TestDataFactory.createSingpostAddress(1)[0];
//                 insert postal;
            
//                 address = new Address__c();
//                 address = TestDataFactory.createAddress(1)[0];
//                 address.Postal_Code__c = postal.Id;
//                 insert address;
            
//                 con = TestDataFactory.createContact(2);
//                 con[0].Phone = '1234567';
//                 con[0].LastName ='Dumangas';
//                 con[0].FirstName = 'Ana';
//                 con[0].AccountId = acc.Id;
//                 con[1].Phone = '1234567';
//                 con[1].AccountId = acc.Id;
//                 con[1].Recipient_Indicator__c = true;
//                 con[1].LastName ='Dumangas';
//                 con[1].FirstName = 'Ana';
//                 insert con;
                
//                 conId = con[0].Id;
//                 recConId = con[1].Id;
                   
//                 pkg = TestDataFactory.createPackage(1);
//                 pkg[0].Subscription_Period__c = '15'; 
//                 pkg[0].Package_Type__c = packageType;
//                 pkg[0].Billing_Type__c = 'Recurring Prepaid';
//                 insert pkg;    
            
//                 zcaList = TestDataFactory.createBillingAccount(1);
//                 zcaList[0].Name = 'Zuora Customer Account';
//                 zcaList[0].Zuora__Account__c = acc.Id;
//                 zcaList[0].Zuora__Credit_Balance__c = 1;
//                 zcaList[0].Refund_Amount__c = 100;
//                 zcaList[0].Zuora__AutoPay__c =false;
//                 zcaList[0].Zuora__Balance__c = 1;
//                 zcaList[0].Payment_Mode__c = 'Cash';
//                 zcaList[0].Other_PaymentMethod__c= 'Cash';
//                 zcaList[0].Zuora__PaymentMethodType__c = 'Cash'; 
//                 zcalist[0].Zuora__External_Id__c = '22544AA';  
//                 zcalist[0].Zuora__Zuora_Id__c = '0124';  
//                 zcalist[0].Billing_Type__c = 'Recurring Prepaid';
//                 insert zcaList;
            
//                 //START : D-1929 3/2/2015 added to create Default Payment Method
//                 zpmList = TestDataFactory.createPaymentMethod(1);
//                 zpmList[0].Name = 'Zuora Customer Account';
//                 zpmList[0].Zuora__Type__c = 'Cash';
//                 zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
//                 insert zpmList;  
//                 //End: D-1929 3/2/2015 added to create Default Payment Method
            
//                 zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
//                 update zcaList;
            
//                 //create billing account      
//                 testSubscription =  TestDataFactory.createSubscription(1);
//                 testSubscription[0].Subscriber_Contact__c = con[0].id;  
//                 testSubscription[0].Main_Package__c = pkg[0].id;
//                 testSubscription[0].Zuora__Account__c = acc.id;
//                 testSubscription[0].Order_Number__c = null;
//                 testSubscription[0].Zuora__CustomerAccount__c = zcaList[0].Id;
//                 testSubscription[0].Billing_Type__c = 'Recurring Prepaid';
//                 testSubscription[0].Legacy_Create_Date__c = 'a';
//                 testSubscription[0].Legacy_Create_By__c = 'a';
//                 testSubscription[0].Legacy_Update_By__c = 'a';
//                 testSubscription[0].Legacy_Subscription_ID__c = 'a';
//                 testSubscription[0].Legacy_Update_Date__c = 'a';
//                 testSubscription[0].Number_of_Copies__c = 100;
//                 testSubscription[0].Number_of_Copies1__c = '100';
//                 testSubscription[0].Zuora__Status__c = 'Active';
//                 testSubscription[0].Subscription_Type_1__c = 'Publication';
//                 testSubscription[0].Subscription_Type__c = 'Publication';
//                 testSubscription[0].Contact__c = con[0].id;
//                 testSubscription[0].Delivery_Charge_Type__c = 'H';
//                 testSubscription[0].Recipient_Contact__c = recConId;
//                 testSubscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(20);
//                 insert testSubscription;
//             }
                                
//             System.assertEquals(1, testSubscription.size());
            
//             testCase = new Case();
//             testCase.AccountId = testSubscription[0].Zuora__Account__c;
//             testCase.Origin = 'Phone';
//             testCase.Priority = 'Medium';
//             testCase.Status = 'New';
//             testCase.Payment_Mode__c = 'Cash';
//             testCase.Amount_To_Refund__c = 100;
//             testCase.Action_Type__c = 'Amend';    
//             testCase.RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.CASERETENTION);
//             if(caseSub != null){
//                 testCase.Subscription_Name__c = testSubscription[0].Id;
//             }
           
//             insert testCase;
            
//             packageObject = [SELECT Id, Package_Type__c FROM Package__c WHERE
//                                     Id = :testSubscription[0].Main_Package_1__c OR
//                                     Id =: testSubscription[0].Main_Package__c];
            
//             packageObject.Subscription_Period__c = subPeriod;
//             update packageObject;
            
//             Zuora__CustomerAccount__c billingAccount = [SELECT Id, Zuora__Account__c, Billing_Type__c
//                                                         FROM Zuora__CustomerAccount__c
//                                                         WHERE Id = :testSubscription[0].Zuora__CustomerAccount__c];
//             accId = billingAccount.Zuora__Account__c;
//             conId = testSubscription[0].Contact__c;
//             recConId = testSubscription[0].Recipient_Contact__c;
            
            
//             zProduct = [SELECT Id FROM zqu__ZProduct__c WHERE ProductSubType__c = :productType];
        
//             If(zProduct.size() == 0) {
//                 //Create zProduct
//                 zProduct = TestDataFactory.createZProduct(1);
//                 zProduct[0].ProductSubType__c = productType;
//                 zProduct[0].ProductPlatform__c = 'Print';
//                 zProduct[0].name='BORJ';
//                 zProduct[0].zqu__SKU__c = 'TESTES121';
//                 zProduct[0].ProductCode__c = 'QWERTY';
//                 zProduct[0].ProductFamily__c = 'asdasd';
//                 insert zProduct;
//             }
        
//             prdRatePlans = [Select Id FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__c =: zProduct[0].Id LIMIT 1];
        
//             if(prdRatePlans.size() == 0) {
//                 //Create Product Rate Plan
//                 prdRatePlans = TestDataFactory.createProductRatePlan(1);
//                 prdRatePlans[0].zqu__ZProduct__c = zProduct[0].Id;
//                 insert prdRatePlans;
//             }
            
//             List<zqu__ProductRatePlan__c> discountRatePlan = [SELECT Id FROM zqu__ProductRatePlan__c WHERE RatePlanType__c = 'Discount' AND zqu__ZProduct__c =: zProduct[0].Id LIMIT 1];
            
//             if(discountRatePlan.size() == 0) {
//                 discountRatePlan = TestDataFactory.createProductRatePlan(1);
//                 discountRatePlan[0].zqu__ZProduct__c = zProduct[0].Id;
//                 discountRatePlan[0].RatePlanType__c = 'Discount';
//                 insert discountRatePlan;
//             }
//             prdRatePlans.addAll(discountRatePlan);
            
//             prdRatePlans[0].BillingPeriod__c = packageObject.Subscription_Period__c;
//             prdRatePlans[1].BillingPeriod__c = packageObject.Subscription_Period__c;
            
//             update prdRatePlans;
        
//         List<Package_Item__c> toDeleteItem = [SELECT Id FROM Package_Item__c WHERE Package__c = :packageObject.id];
        
//         if(toDeleteItem.size() > 0) {
//             delete toDeleteItem;
//         }
        
//         productFamily = new List<Product_Family__c>();
//         productFamily.add(new Product_Family__c());
//         productFamily[0].Product_Family__c = 'UNID0001';
//         productFamily[0].Product_Family_Name__c = 'Name 001';
        
//         productFamily.add(new Product_Family__c());
//         productFamily[1].Product_Family__c = 'UNID0002';
//         productFamily[1].Product_Family_Name__c = 'Name 002';
        
//         insert productFamily;
        
//         String packageItemType = packageType + ' Product';
//         if(packageType == 'Add on') {
//             packageItemType = 'Base Product';
//         }
        
//         pItems = [SELECT Id FROM Package_Item__c WHERE Package__c = : packageObject.Id AND RecordType.Name = 'Base Product' LIMIT 1];
        
//         if(pItems.size() == 0) {
//             //Create Package Item
//             pItems = TestDataFactory.createPackageItem(1, packageItemType);
//             pItems[0].Package__c = packageObject.Id;
//             pItems[0].Duration_in_months__c = '1';
//             pItems[0].Effective_Start_Month__c = '1';
//             pItems[0].Product_Rate_Plan__c = prdRatePlans[0].Id;
//             insert pItems;
//         }
//         pItems[0].Product_Family__c = productFamily[0].Id;
        
//         if(packageType == 'Add on') {
//             List<Package_Item__c> discountPackItems = [SELECT Id FROM Package_Item__c WHERE Package__c = : packageObject.Id AND RecordType.Name = 'Discount' LIMIT 1];
        
//             if(discountPackItems.size() == 0) {
//                 discountPackItems = TestDataFactory.createPackageItem(1, 'Discount');
//                 discountPackItems[0].Package__c = packageObject.Id;
//                 discountPackItems[0].Duration_in_months__c = '1';
//                 discountPackItems[0].Effective_Start_Month__c = '1';
//                 discountPackItems[0].Product_Rate_Plan__c = prdRatePlans[1].Id;
//                 insert discountPackItems;
//             }
//             discountPackItems[0].Product_Family__c = productFamily[1].Id;
//             pItems.addAll(discountPackItems);
//         }
        
//         update pItems;
        
//         if('Bundle' == packageType){
//             Package_Item__c currentPackageItems = TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];
//             currentPackageItems.Package__c = packageObject.id;
//             currentPackageItems.Duration_in_months__c = '2';
//             currentPackageItems.Product_Rate_Plan__c = prdRatePlans[1].id;
//             insert currentPackageItems;
//         }
        
//         promotion = TestDataFactory.createPromotion(1);
//         promotion[0].Contract_Period__c = '2';
//         promotion[0].Effective_Start_Date__c = date.Today();
//         promotion[0].Effective_End_Date__c = date.Today()+7;
//         promotion[0].Promotion_Code__c = '10054';
//         insert promotion;
        
//         orderRec = [SELECT Id, Recipient_Contact__c, Recipient_Contact__r.Phone, Recipient_Contact__r.HomePhone__c, Recipient_Contact__r.Mobile_Number__c,
//                     Billing_Account__c, Account__c, Informed_Customer__c, Subscriber_Charge__c, Recipient_Contact__r.Address__r.Address_Type__c
//                     FROM Order__c WHERE Account__c =:accId AND Recipient_Contact__c = :recConId];
              
//         if(orderRec.size() == 0) {
//             orderRec = TestDataFactory.createOrder(1);
//             orderRec[0].Account__c = accId;
//             orderRec[0].Informed_Customer__c = TRUE;
//             orderRec[0].Recipient_Contact__c = recConId;
//             orderRec[0].Subscriber_Charge__c = 15;
//             orderRec[0].Billing_Account__c = testSubscription[0].Zuora__CustomerAccount__c;
//             orderRec[0].Billing_Type__c = testSubscription[0].Zuora__CustomerAccount__r.Billing_Type__c;
//             insert orderRec;
//         }
//         oli = [SELECT Id FROM Order_Line_Item__c WHERE Main_Package_ID__c =:packageObject.id AND Order__c = :orderRec[0].id];
        
//         if(oli.size() == 0) {
//             oli = TestDataFactory.createOrderLineItem(1);
//             oli[0].Earliest_Start_Date__c = testSubscription[0].Zuora__SubscriptionEndDate__c;
//             oli[0].Start_Date__c =  testSubscription[0].Zuora__SubscriptionEndDate__c;
//             oli[0].End_Date__c = testSubscription[0].Zuora__SubscriptionEndDate__c;
//             oli[0].Fee_Waiver__c = TRUE;
//             oli[0].Order__c = orderRec[0].id;
//             oli[0].Main_Package_ID__c = packageObject.id;
//             oli[0].Main_Package_Period__c = 1;
//             oli[0].Qty__c = 1;
//             oli[0].Term_Length__c = 1;
//             oli[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
//             oli[0].Main_Package_Type__c = 'Base';
//             oli[0].Main_Package_Frequency__c = 'Default';
//             oli[0].Delivered_By__c = 'None';
//             //oli[0].Addon_Package__c = packageObject.id;
//             oli[0].Promotion_ID__c = promotion[0].id;
//             oli[0].Term_is_discussed__c = TRUE;
//             oli[0].Is_Digital__c = TRUE;
//             oli[0].Delivered_By__c = 'Mailing Agent';
//             oli[0].New_Contract_Period__c = 1;
//             insert oli;
//         }
        
//         tempOLI = new Order_Line_Item__c();
//         tempOLI = oli[0];
        
//         gift = TestDataFactory.createGift(1)[0];
//         gift.Gift_Type__c = 'Premium';
//         gift.Gift_Code__c  = '1233333';
//         gift.One_Time_Charge__c = 100;
//         insert gift;
        
//         pg =  new Promotion_Gift__c(
//         Gift_Inventory__c = 1000,
//         Gift_Issued__c = 200,
//         Gift_Redeemed__c = 0,
//         Gift__c = gift.id,
//         Redemption_Start_Date__c = date.Today()+4,
//         Redemption_End_Date__c = date.Today()+7,
//         Promotion__c = promotion[0].id);
//         insert pg;
        
//         List<zqu__Quote__c> zqQ = TestDataFactory.createQuote(1);
//         zqQ[0].Vendor_Credit__c = 0;
//         zqQ[0].zqu__Account__c = accId;
//         zqQ[0].Payment_Mode__c = 'Test';
//         zqQ[0].Delivery_Charge_Type__c = 'S';
//         zqQ[0].Subscriber_Charge__c = 0;
//         zqQ[0].Other_PaymentMethod__c = 'Recurring Prepaid';
//         zqQ[0].zqu__BillToContact__c = conId;
//         zqQ[0].Main_Package__c = packageObject.id;
//         zqQ[0].Order__c = orderRec[0].Id;
//         zqQ[0].Order_Line_Item_Number__c = oli[0].Id;
//         zqQ[0].Order_Line_Item_Number_1__c = oli[0].Id;
//         zqQ[0].Subscription_Type__c = 'Delivery';
//         zqQ[0].Delivery_Charge_Type__c = 'S';
//         insert zqQ;
            
//         Order_Line_Item_Gift__c olig = new Order_Line_Item_Gift__c(
//         Order_Line_Item__c = oli[0].id,
//         Promotion_Gift__c = pg.id);
//         insert olig;
        
//         Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
//         //SAF.Flag_Code__c = 'TEST';
//         SAF.Flag_Description__c = 'TESTx';
//         insert SAF;
        
//         Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
//         PAF.Package__c = packageObject.Id;
//         PAF.No_of_Concurrent_Users__c = 2;
//         PAF.Package_Service_Access_Flag__c = SAF.Id;
//         insert PAF;
        
//         //create Asia1__c
//         tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
//         tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
//         tmpAsia1.Display_Name__c = 'Test';
//         tmpAsia1.Email__c = 'test@email.com' ;
//         tmpAsia1.Password__c = 'aBcD3Fg';
//         tmpAsia1.Contact__c = conId;
//         insert tmpAsia1;
        
//         List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        
//         asiaSubList[0].Asia1__c = tmpAsia1.Id;
//         asiaSubList[0].Subscription__c = testSubscription[0].Id;
//         asiaSubList[0].Status__c = 'Enabled';
//         asiaSubList[0].Order_Line_Item__c = oli[0].Id;
//         asiaSubList[0].Service_Access_Flag__c = SAF.Id;
//         insert asiaSublist;
        
//     }
    
//     /**
//     * @name: prepareSearchTestData
//     * @author : Recuerdo Bregente
//     * @description : Prepares the test data objects for search.
//     * @date: 07/20/2015
//     */ 
//     static void prepareSearchTestData(Integer packageCount, Integer promotionCount){
//         pkg = TestDataFactory.createPackage(packageCount);
//         for(Integer i = 0; i < pkg.size(); i++) {
//             pkg[i].Billing_Type__c = 'Recurring Prepaid';
//             pkg[i].Package_Type__c = 'Add on';
//             pkg[i].Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
//         }
//         insert pkg;
        
//         zProduct = [SELECT Id FROM zqu__ZProduct__c WHERE ProductSubType__c = 'Magazine'];
        
//         If(zProduct.size() == 0) {
//             //Create zProduct
//             zProduct = TestDataFactory.createZProduct(1);
//             zProduct[0].ProductSubType__c = 'Magazine';
//             zProduct[0].ProductPlatform__c = 'Print';
//             insert zProduct;
//         }
        
//         prdRatePlans = [Select Id FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__c =: zProduct[0].Id AND RatePlanType__c != 'Discount' LIMIT 1];
        
//         if(prdRatePlans.size() == 0) {
//             //Create Product Rate Plan
//             prdRatePlans = TestDataFactory.createProductRatePlan(1);
//             prdRatePlans[0].zqu__ZProduct__c = zProduct[0].Id;
//             insert prdRatePlans;
//         }
        
//         List<zqu__ProductRatePlan__c> discountRatePlan = [SELECT Id FROM zqu__ProductRatePlan__c WHERE RatePlanType__c = 'Discount' AND zqu__ZProduct__c =: zProduct[0].Id LIMIT 1];
        
//         if(discountRatePlan.size() == 0) {
//             discountRatePlan = TestDataFactory.createProductRatePlan(1);
//             discountRatePlan[0].zqu__ZProduct__c = zProduct[0].Id;
//             discountRatePlan[0].RatePlanType__c = 'Discount';
//             insert discountRatePlan;
//         }
        
//         prdRatePlans.addAll(discountRatePlan);
        
//         prdRatePlans[0].BillingPeriod__c = pkg[0].Subscription_Period__c;
//         prdRatePlans[1].BillingPeriod__c = pkg[0].Subscription_Period__c;
        
//         update prdRatePlans;
        
//         productFamily = new List<Product_Family__c>();
//         productFamily.add(new Product_Family__c());
//         productFamily[0].Product_Family__c = 'UNID0001';
//         productFamily[0].Product_Family_Name__c = 'Name 001';
        
//         productFamily.add(new Product_Family__c());
//         productFamily[1].Product_Family__c = 'UNID0002';
//         productFamily[1].Product_Family_Name__c = 'Name 002';
        
//         insert productFamily;
        
//         pItems = [SELECT Id FROM Package_Item__c WHERE Package__c = : pkg[0].Id AND RecordType.Name = 'Base Product' LIMIT 1];
        
//         if(pItems.size() == 0) {
//             //Create Package Item
//             pItems = TestDataFactory.createPackageItem(1, 'Base Product');
//             pItems[0].Package__c = pkg[0].Id;
//             pItems[0].Duration_in_months__c = '1';
//             pItems[0].Effective_Start_Month__c = '1';
//             pItems[0].Product_Rate_Plan__c = prdRatePlans[0].Id;
//             insert pItems;
//         }
//         pItems[0].Product_Family__c = productFamily[0].Id;
        
//         List<Package_Item__c> discountPackItems = [SELECT Id FROM Package_Item__c WHERE Package__c = : pkg[0].Id AND RecordType.Name = 'Discount' LIMIT 1];
        
//         if(discountPackItems.size() == 0) {
//             discountPackItems = TestDataFactory.createPackageItem(1, 'Discount');
//             discountPackItems[0].Package__c = pkg[0].Id;
//             discountPackItems[0].Duration_in_months__c = '1';
//             discountPackItems[0].Effective_Start_Month__c = '1';
//             discountPackItems[0].Product_Rate_Plan__c = prdRatePlans[1].Id;
//             insert discountPackItems;
//         }
//         discountPackItems[0].Product_Family__c = productFamily[1].Id;
//         pItems.addAll(discountPackItems);
        
//         update pItems;
        
//         promotion = TestDataFactory.createPromotion(promotionCount);
//         for(Integer i = 0; i < promotion.size(); i++) {
//             //promotion[i].Billing_Type__c = 'Recurring Prepaid';
//             promotion[i].Contract_Period__c = '12';
//         }
//         insert promotion;
//     }
    
//     /**
//     * @name: testExecuteSearchWithInvalidSearchType
//     * @author : Recuerdo Bregente
//     * @description : Tests executeSearch method with search type is invalid
//     * @date: 07/21/2015
//     */
//     static testMethod void testExecuteSearchWithInvalidSearchType(){
//         try
//         {
//             prepareSearchTestData(1,1);
//         }catch(exception e) {
//             system.debug(':::ERROR ' + e);
//         }
               
//         try{
//             Test.startTest();
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
//             controller.searchFrom = '-1';
//             controller.searchBillingType = '-1';
//             controller.searchText = '-1';
            
//             controller.executeSearch();
            
//             System.assert(controller.packageResultList.size() == 0);
//           System.assert(controller.packageResultList.size() == 0);
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }

//     }
    
//     /**
//     * @name: testExecuteSearchPackage
//     * @author : Recuerdo Bregente
//     * @description : Tests executeSearch method with package type
//     * @date: 07/21/2015
//     */
//     static testMethod void testExecuteSearchPackage(){
//         try
//         {
//             prepareSearchTestData(1,1);
//         }catch(exception e) {
//             system.debug(':::ERROR ' + e);
//         }
               
//         try{
//             Test.startTest();
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
//             controller.searchFrom = 'Package';
//             controller.searchBillingType = 'Recurring Prepaid';
//             controller.searchText = 'Test';
            
//             controller.selectedPackageId = pkg[0].Id;
//             controller.executeSearch();
            
            
//             try
//             {
//                 delete pkg;
//                 delete promotion;
//                 delete productFamily;
//             }catch(exception e) {
//                 system.debug(':::ERROR ' + e);
//             }
       
//             //prepareSearchTestData(100,1);            
//             controller.executeSearch();
            
//             //System.assert(controller.packageResultList.size() >= 1);
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }

//     }
    
//     /**
//     * @name: testExecuteSearchPromotionMore100
//     * @author : Recuerdo Bregente
//     * @description : Tests executeSearch method with promotion type with more than 100 records.
//     * @date: 07/21/2015
//     */
//     static testMethod void testExecuteSearchPromotionMore100(){
//         try
//         {
//             prepareSearchTestData(1,100);
//         }catch(exception e) {
//             system.debug(':::ERROR ' + e);
//         }
       
        
//         try{
//             Test.startTest();
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
//             controller.searchFrom = 'Promotion';
//             controller.searchBillingType = 'Recurring Prepaid';
//             controller.searchText = 'Test';
//             controller.executeSearch();
            
//             System.assertEquals(null, controller.packageResultList);
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }

//     }
    
//     /**
//     * @name: testExecuteSearchPromotion
//     * @author : Recuerdo Bregente
//     * @description : Tests executeSearch method with promotion type
//     * @date: 07/21/2015
//     */
//     static testMethod void testExecuteSearchPromotion(){
//         try
//         {
//             prepareTestData('', 'Magazine', '12', 'Add on');
//         }catch(exception e) {
//             system.debug(':::ERROR ' + e);
//         }
               
//         try{
//             Test.startTest();
//             pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
//             pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
//             pageRef.getParameters().put( 'caseId', testCase.Id );
        
//             system.Test.setCurrentPage( pageRef );
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
//             /*
//             controller.retrieveActiveSubscriptions();
//             controller.subscriptionId = testSubscription[0].Id;
//             controller.thisOrder = new Order__c();
//             controller.thisOrder.Account__c = testSubscription[0].Zuora__Account__c;
//             controller.thisOrder.Credit_Balance__c = 12;
//             controller.thisOrder.Delivery_Charge__c = 1;
//             insert controller.thisOrder;
//             controller.thisOrder.Delivery_Charge_Type__c = 'H';
//             testSubscription[0].Zuora__SubscriptionEndDate__c = Date.today();
//             insert testSubscription;
//             controller.populateSubscriptionDetail(); */
//             controller.selectedPackageId = packageObject.Id;
//             controller.searchFrom = 'Promotion';
//             controller.searchBillingType = 'Recurring Prepaid';
//             controller.searchText = 'Test';
//             controller.executeSearch();
            
//             System.assertEquals(null, controller.packageResultList);
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }

//     }
    
//     /**
//     * @name: testHelperMethods
//     * @author : Recuerdo Bregente
//     * @description : Tests other helper methods
//     * @date: 07/21/2015
//     */
//     static testMethod void testHelperMethods(){
//         prepareTestData('', 'Magazine', '12', 'Add on');
//         try{
//             Test.startTest();
//             pageRef.getParameters().put( 'subscriptionId', testSubscription[0].Id );
//             pageRef.getParameters().put( 'accountId', testSubscription[0].Zuora__Account__c );
//             pageRef.getParameters().put( 'caseId', testCase.Id );
        
//             system.Test.setCurrentPage( pageRef );
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.retrieveActiveSubscriptions();
//             try
//             {
//                 SM_RenewalOfSubscriptionEntryController.retrieveRelatedPackages(String.valueOf(promotion[0].Id), 'Recurring Prepaid', String.valueOf(packageObject.Id));
//             }catch(exception e) {
//                 system.debug(':::ERROR ' + e);
//             }
            
//             controller.selectedAddOnPackage = packageObject.Id;
//             controller.orderLineItem = tempOLI;
//             System.debug(tempOLI);
//             controller.populateAddOn(); 
//             controller.selectedPromotionId = promotion[0].Id;
//             controller.populatePromotionGifts();
//             System.assertEquals(null, controller.packageResultList);
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
    
//     /**
//     * @name: testSearchCusName
//     * @author : Recuerdo Bregente
//     * @description : Tests searchCusName method.
//     * @date: 07/21/2015
//     */
//     static testMethod void testSearchCusName(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchCompleteData('0','0'));
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchCusName();
            
//             System.assertEquals(controller.errorMsg, '');
//             controller.armsCusWrapList[0].isTick = true;
//             controller.addPopAcc();
            
//             controller.armsCusWrapList.add(controller.armsCusWrapList[0]);
//             controller.addPopAcc();
            
//             controller.closePopup();
//             controller.cancelSearch();
//             controller.continueSave();
            
//             controller.armsCusWrapList[0].arBLInd = 'arBLInd';
//             System.assertEquals('arBLInd',controller.armsCusWrapList[0].arBLInd);    
//             controller.armsCusWrapList[0].BLClrCd = 'BLClrCd'; 
//             System.assertEquals('BLClrCd',controller.armsCusWrapList[0].BLClrCd);      
//             controller.armsCusWrapList[0].BLRsn = 'BLRsn'; 
//             System.assertEquals('BLRsn',controller.armsCusWrapList[0].BLRsn);        
//             controller.armsCusWrapList[0].IdTyp = 'IdTyp';  
//             System.assertEquals('IdTyp',controller.armsCusWrapList[0].IdTyp);      
//             controller.armsCusWrapList[0].IdN = 'IdN';     
//             System.assertEquals('IdN',controller.armsCusWrapList[0].IdN); 
//             controller.armsCusWrapList[0].PpCntryC = 'PpCntryC'; 
//             System.assertEquals('PpCntryC',controller.armsCusWrapList[0].PpCntryC);    
//             controller.armsCusWrapList[0].CrRskRtg = 'CrRskRtg';   
//             System.assertEquals('CrRskRtg',controller.armsCusWrapList[0].CrRskRtg);   
//             controller.armsCusWrapList[0].CrLmtInt = 'CrLmtInt';   
//             System.assertEquals('CrLmtInt',controller.armsCusWrapList[0].CrLmtInt);   
//             controller.armsCusWrapList[0].CrLmtExt = 'CrLmtExt';  
//             System.assertEquals('CrLmtExt',controller.armsCusWrapList[0].CrLmtExt);   
//             controller.armsCusWrapList[0].CityM = 'CityM';    
//             System.assertEquals('CityM',controller.armsCusWrapList[0].CityM);     
//             controller.armsCusWrapList[0].Cntry = 'Cntry';     
//             System.assertEquals('Cntry',controller.armsCusWrapList[0].Cntry);   
//             controller.armsCusWrapList[0].PoBoxN = 'PoBoxN';  
//             System.assertEquals('PoBoxN',controller.armsCusWrapList[0].PoBoxN);      
//             controller.armsCusWrapList[0].AttnI = 'AttnI';   
//             System.assertEquals('AttnI',controller.armsCusWrapList[0].AttnI);      
//             controller.armsCusWrapList[0].StfI = 'StfI';     
//             System.assertEquals('StfI',controller.armsCusWrapList[0].StfI); 
//             controller.armsCusWrapList[0].GstOOSI = 'GstOOSI'; 
//             System.assertEquals('GstOOSI',controller.armsCusWrapList[0].GstOOSI);    
//             controller.armsCusWrapList[0].UpdId = 'UpdId';      
//             System.assertEquals('UpdId',controller.armsCusWrapList[0].UpdId);   
//             controller.armsCusWrapList[0].UpdDte = 'UpdDte';  
//             System.assertEquals('UpdDte',controller.armsCusWrapList[0].UpdDte);     
//             controller.armsCusWrapList[0].UpdTme = 'UpdTme';
//             System.assertEquals('UpdTme',controller.armsCusWrapList[0].UpdTme);
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
    
//     /**
//     * @name: testSearchCusNameWithRtnStsIsOne
//     * @author : Recuerdo Bregente
//     * @description : Tests searchCusName method with RtnSts value is one.
//     * @date: 07/21/2015
//     */
//     static testMethod void testSearchCusNameWithRtnStsIsOne(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchCompleteData('1','0'));
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchCusName();
            
//             System.assertEquals(controller.errorMsg, null);
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
    
//     /**
//     * @name: testSearchCusNameNoAccSrchResp
//     * @author : Recuerdo Bregente
//     * @description : Tests searchCusName method with no CusSrchResp for search customer request.
//     * @date: 07/21/2015
//     */
//     static testMethod void testSearchCusNameNoAccSrchResp(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchNoSrchResp());
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchCusName();
            
//             System.assertEquals(controller.errorMsg, 'Invalid response from server. Please try again later.');
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
    
//     /**
//     * @name: testSearchAccName
//     * @author : Recuerdo Bregente
//     * @description : Tests searchAccName method.
//     * @date: 07/21/2015
//     */
//     static testMethod void testSearchAccName(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchCompleteData('0','0'));
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchAccName();
            
//             System.assertEquals(controller.errorMsg, '');
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
    
//     /**
//     * @name: testSearchAccNameWithRtnStsIsOne
//     * @author : Recuerdo Bregente
//     * @description : Tests searchAccName method with response value of RtnSts is one.
//     * @date: 07/27/2015
//     */
//     static testMethod void testSearchAccNameWithRtnStsIsOne(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchCompleteData('0','1'));
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchAccName();
            
//             System.assertEquals(controller.errorMsg, ConstantsSLB.getErrorMessage('ARMS account is not existing'));
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
    
//     /**
//     * @name: testSearchAccNameWithRtnStsIsEight
//     * @author : Recuerdo Bregente
//     * @description : Tests searchAccName method with response value of RtnSts is eight.
//     * @date: 07/27/2015
//     */
//     static testMethod void testSearchAccNameWithRtnStsIsEight(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchCompleteData('0','8'));
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchAccName();
            
//             System.assertEquals(controller.errorMsg, ConstantsSLB.getErrorMessage('ARMS account too many record'));
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
        
//     }
    
//     /**
//     * @name: testSearchAccNameWithRtnStsIsTwo
//     * @author : Recuerdo Bregente
//     * @description : Tests searchAccName method with response value of RtnSts is two.
//     * @date: 07/27/2015
//     */
//     static testMethod void testSearchAccNameWithRtnStsIsTwo(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchCompleteData('0','2'));
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchAccName();
            
//             System.assertEquals(controller.errorMsg, 'Success');
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
    
//     /**
//     * @name: testSearchAccNameWithMoreThanOneAccType
//     * @author : Recuerdo Bregente
//     * @description : Tests searchAccName method with more than one account type.
//     * @date: 07/21/2015
//     */
//     static testMethod void testSearchAccNameWithMoreThanOneAccType(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchAccountMoreThanOneAccType());
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchAccName();
            
//             //System.assertEquals(controller.errorMsg, 'More than one account is retrieved with Type equal to SS.');
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
    
//     /**
//     * @name: testSearchAccNameNoAccSrchResp
//     * @author : Recuerdo Bregente
//     * @description : Tests searchAccName method with no AccSrchResp for search account request.
//     * @date: 07/21/2015
//     */
//     static testMethod void testSearchAccNameNoAccSrchResp(){
//         defaultCustomSetting();
        
//         try{
//             Test.startTest();
//             Test.setMock(WebServiceMock.class, new searchNoSrchResp());
//             SM_RenewalOfSubscriptionEntryController controller = new SM_RenewalOfSubscriptionEntryController();
           
//             controller.aCust = 'Ana Fe Dumangas';
//             controller.thisOrder = new Order__c();
//             controller.errorMsg = '';
//             controller.searchAccName();
            
//             System.assertEquals(controller.errorMsg, ConstantsSLB.getErrorMessage('Invalid Response'));
            
//             Test.stopTest();
//         } catch(Zuora.zRemoteException e) {
//                 System.assertNotEquals(null, e);
//         }
//     }
  
    
//      /**
//      * Class Name: searchCompleteData
//      * @author: Recuerdo Bregente
//      * Date: 07/27/2015
//      * Requirement/Project Name: Singapore Press Holdings
//      * @description Mock Class for wwwSphComArWsWsdlCam
//      */
//      class searchCompleteData implements WebServiceMock {
//       String cusRetentionStatus;
//       String accRetentionStatus;
//       public searchCompleteData(String cusRtnSts, String accRtnSts){
//           cusRetentionStatus = cusRtnSts;
//           accRetentionStatus = accRtnSts;
//       }
       
//       public void doInvoke(
//               Object stub,
//               Object request,
//               Map<String, Object> response,
//               String endpoint,
//               String soapAction,
//               String requestName,
//               String responseNS,
//               String responseName,
//               String responseType) {
//           if(requestName == 'SearchAccountRequest'){  
//               wwwSphComArWsWsdlCam.SearchAccountResponse_element responseElement = new wwwSphComArWsWsdlCam.SearchAccountResponse_element();
//               responseElement.response = new wwwSphComArWsWsdlCam.SearchAccountResponseType();
//               responseElement.response.AccSrch = new wwwSphComArWsSchemaCamSearchaccou.AccSrch_element();
//               responseElement.response.AccSrchResp = new wwwSphComArWsSchemaCamSearchaccouR.AccSrchResp_element();
//               responseElement.response.AccSrchResp.RtnSts = accRetentionStatus;
//               responseElement.response.AccSrchResp.SysId = ConstantsSLB.getOther('ARMS_SysId');
//               responseElement.response.AccSrchResp.RtnMsg = 'Success';
//               responseElement.response.AccSrchResp.L_Acc = new wwwSphComArWsSchemaCamSearchaccouR.L_AccType();
//               responseElement.response.AccSrchResp.L_Acc.Acc = new wwwSphComArWsSchemaCamSearchaccouR.AccType[]{};
//               responseElement.response.AccSrchResp.L_Acc.Acc.add(new wwwSphComArWsSchemaCamSearchaccouR.AccType());
//               responseElement.response.AccSrchResp.L_Acc.Acc[0].AccTyp = ConstantsSLB.getOther('ARMS_AccTyp');
//               response.put('response_x', responseElement);
//           } else if(requestName == 'SearchCustomerRequest'){
//               wwwSphComArWsWsdlCam.SearchCustomerResponse_element responseElement = new wwwSphComArWsWsdlCam.SearchCustomerResponse_element();
//               responseElement.response = new wwwSphComArWsWsdlCam.SearchCustomerResponseType();
//               responseElement.response.CusSrchResp = new wwwSphComArWsSchemaCamSearchcustoR.CusSrchResp_element();
//               responseElement.response.CusSrchResp.RtnSts = cusRetentionStatus;
//               responseElement.response.CusSrchResp.L_Cus = new wwwSphComArWsSchemaCamSearchcustoR.L_CusType();
//               responseElement.response.CusSrchResp.L_Cus.Cus = new wwwSphComArWsSchemaCamSearchcustoR.CusType[]{};
//               responseElement.response.CusSrchResp.L_Cus.Cus.add(new wwwSphComArWsSchemaCamSearchcustoR.CusType());
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].CusM2 = 'Ana';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].CusN = 'Dumangas';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].BlkN = 'Block 2';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].FlrN = '14th Floor';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].UntN = 'Unit 5';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].Str = 'San Agustin';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].BldgSec = 'Towers';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].CusA1 = 'Collinwood';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].CusA2 = 'Basak';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].CusA3 = 'Lapu-lapu';
//               responseElement.response.CusSrchResp.L_Cus.Cus[0].CusA4 = 'Cebu';
//               response.put('response_x', responseElement);
//           }
//       }
//     }
    
//     /**
//      * Class Name: searchAccountMoreThanOneAccType
//      * @author: Recuerdo Bregente
//      * Date: 07/27/2015
//      * Requirement/Project Name: Singapore Press Holdings
//      * @description Mock Class for wwwSphComArWsWsdlCam with more than one account type.
//      */
//      class searchAccountMoreThanOneAccType implements WebServiceMock {
//       public void doInvoke(
//               Object stub,
//               Object request,
//               Map<String, Object> response,
//               String endpoint,
//               String soapAction,
//               String requestName,
//               String responseNS,
//               String responseName,
//               String responseType) {
//           if(requestName == 'SearchAccountRequest'){           
//               wwwSphComArWsWsdlCam.SearchAccountResponse_element responseElement = new wwwSphComArWsWsdlCam.SearchAccountResponse_element();
//               responseElement.response = new wwwSphComArWsWsdlCam.SearchAccountResponseType();
//               responseElement.response.AccSrch = new wwwSphComArWsSchemaCamSearchaccou.AccSrch_element();
//               responseElement.response.AccSrchResp = new wwwSphComArWsSchemaCamSearchaccouR.AccSrchResp_element();
//               responseElement.response.AccSrchResp.RtnSts = '0';
//               responseElement.response.AccSrchResp.SysId = ConstantsSLB.getOther('ARMS_SysId');
//               responseElement.response.AccSrchResp.L_Acc = new wwwSphComArWsSchemaCamSearchaccouR.L_AccType();
//               responseElement.response.AccSrchResp.L_Acc.Acc = new wwwSphComArWsSchemaCamSearchaccouR.AccType[]{};
//               responseElement.response.AccSrchResp.L_Acc.Acc.add(new wwwSphComArWsSchemaCamSearchaccouR.AccType());
//               responseElement.response.AccSrchResp.L_Acc.Acc[0].AccTyp = ConstantsSLB.getOther('ARMS_AccTyp');
//               responseElement.response.AccSrchResp.L_Acc.Acc.add(new wwwSphComArWsSchemaCamSearchaccouR.AccType());
//               responseElement.response.AccSrchResp.L_Acc.Acc[1].AccTyp = ConstantsSLB.getOther('ARMS_AccTyp');
//               response.put('response_x', responseElement);
//           } else if(requestName == 'SearchCustomerRequest'){
//               wwwSphComArWsWsdlCam.SearchCustomerResponse_element responseElement = new wwwSphComArWsWsdlCam.SearchCustomerResponse_element();
//               responseElement.response = new wwwSphComArWsWsdlCam.SearchCustomerResponseType();
//               response.put('response_x', responseElement);
//           }
//       }
//     }
    
//     /**
//      * Class Name: searchAccountNoSrchResp
//      * @author: Recuerdo Bregente
//      * Date: 07/27/2015
//      * Requirement/Project Name: Singapore Press Holdings
//      * @description Mock Class for wwwSphComArWsWsdlCam with no search response object.
//      */
//      class searchNoSrchResp implements WebServiceMock {
//       public void doInvoke(
//               Object stub,
//               Object request,
//               Map<String, Object> response,
//               String endpoint,
//               String soapAction,
//               String requestName,
//               String responseNS,
//               String responseName,
//               String responseType) {
//           if(requestName == 'SearchAccountRequest'){           
//               wwwSphComArWsWsdlCam.SearchAccountResponse_element responseElement = new wwwSphComArWsWsdlCam.SearchAccountResponse_element();
//               responseElement.response = new wwwSphComArWsWsdlCam.SearchAccountResponseType();
//               responseElement.response.AccSrch = new wwwSphComArWsSchemaCamSearchaccou.AccSrch_element();
//               response.put('response_x', responseElement);
//           } else if(requestName == 'SearchCustomerRequest'){
//               wwwSphComArWsWsdlCam.SearchCustomerResponse_element responseElement = new wwwSphComArWsWsdlCam.SearchCustomerResponse_element();
//               responseElement.response = new wwwSphComArWsWsdlCam.SearchCustomerResponseType();
//               response.put('response_x', responseElement);
//           }
//       }
//     }
    
//      /**
//     * @name: defaultCustomSetting
//     * @author : Recuerdo Bregente
//     * @description : Prepares custom settings.
//     * @date: 07/27/2015
//     */
//     static void defaultCustomSetting()
//     {
//         String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
//         Key_Id__c keyId;
//         Other__c otherC;
        
//         String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
//         String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
//         String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
//         List<Key_Id__c> keyList = [SELECT Name FROM Key_Id__c];
//         Set<String> keyNames = new Set<String>();
//         for(Key_Id__c keyRec : keyList) {
//             keyNames.add(keyRec.Name);
//         }
        
//         for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
//         {
//             if(!keyNames.contains(keyIdNameArray[i])) {
//                 keyId = new Key_Id__c();
//                 keyId.Name = keyIdNameArray[i];
//                 keyId.Id__c = keyIdIdcArray[i];
//                 keyId.Type__c = keyIdTypeArray[i];
//                 insert keyId;
//             }
//         }
        
//         String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
//         String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
//         List<Other__c> otherList = [SELECT Name FROM Other__c];
//         Set<String> otherNames = new Set<String>();
//         for(Other__c otherRec : otherList) {
//             otherNames.add(otherRec.Name);
//         }
        
//         for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
//         {
//             if(!otherNames.contains(orderCNameArray[i])) {
//                 otherC = new Other__c();
//                 otherC.Name = orderCNameArray[i];
//                 otherC.Value__c = orderCValueArray[i];
//                 insert otherC;
//             }
//         }
        
//         List<Cir_Planner_Schedule__c> cpcList = [SELECT Name FROM Cir_Planner_Schedule__c WHERE Name = 'CIR Plan Schedule'];
//         if(cpcList.isEmpty()) {
//             Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
//             cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
//             cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
//             cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
//             cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
//             cirPlannerSchedule.Sun_Start_Time__c = System.Now();
//             cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
//             cirPlannerSchedule.Name = 'CIR Plan Schedule';
//             insert cirPlannerSchedule;
//         }
        
//         List<BatchInterface_Settings__c> bitList = [SELECT Name FROM BatchInterface_Settings__c WHERE Name = 'Endpoint Delegator'];
//         if(bitList.isEmpty()) {
//             BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
//             batchInterfaceSetting.Name = 'Endpoint Delegator';
//             batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
//             insert batchInterfaceSetting;
//         }
        
//         String[] errorCNameArray = new String[]{'ARMS account too many record','ARMS account is not existing','ARMS Timed-out','ARMS select one Customer only','Invalid Response'};
//         String[] errorCValueArray = new String[]{'Too many account type.','ARMS account is not existing.','Timed-out. Please click Search button again.','Please select one Customer only.','Invalid response from server. Please try again later.'};
        
//         List<Error_Messages__c> errorList = [SELECT Name FROM Error_Messages__c];
//         Set<String> errorNames = new Set<String>();
//         for(Error_Messages__c errorRec : errorList) {
//             errorNames.add(errorRec.Name);
//         }
        
//         Error_Messages__c errorRec;
//         for(Integer i = 0 ; i < errorCNameArray.size(); i++ )
//         {
//              if(!errorNames.contains(errorCNameArray[i])) {
//                 errorRec = new Error_Messages__c();
//                 errorRec.Name = errorCNameArray[i];
//                 errorRec.Message__c = errorCValueArray[i];
//                 insert errorRec;
//             }
//         }
//   }
// }