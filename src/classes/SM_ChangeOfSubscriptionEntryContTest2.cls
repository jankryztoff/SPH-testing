/**
 * Class Name: SM_ChangeOfSubscriptionEntryContTest2
 * @author: <Ana Fe Dumangas>
 * Date: <10/16/15>
 * Requirement/Project Name: <SPH>
 * @description: Test Class for SM_ChangeOfSubscriptionEntryController
 */ 
 @isTest
 private class SM_ChangeOfSubscriptionEntryContTest2{
     static testMethod void testSM_ChangeOfSubscriptionEntryController(){
         Integer counter;
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
     
         //start test data
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         database.insert(order);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Start_Date__c = date.today()+1;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.New_Contract_Period__c = 30;
         orderline.Promotion_ID__c = prom.Id;
         orderline.Subscribed_as__c = 'Misc Change';
         orderline.Is_Digital__c = true;
         database.insert(orderline);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Publication_Code__c = '01';
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
         database.insert(pub);
         
         List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
         for(zqu__ProductRatePlanCharge__c pr:prpc){
             pr.zqu__ProductRatePlan__c = prdRatePlan.Id;
         }
         database.insert(prpc);
         
         Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
         prodPub.ZProduct__c = zProduct.Id;
         prodPub.Publication_Code__c = pub.Id;
         database.insert(prodPub);
         
         Eligibility_Rule__c elig = TestDataFactory.createEligibilityRule(1)[0];
         elig.Action__c = 'Change';
         elig.Customer_Status__c = 'Existing Customer';
         elig.Contract_Status__c = 'With Contract';
         elig.Contract_Subscription_Rule__c = 'Contract End Date';
         elig.Condition__c = '>';
         database.insert(elig);
         
         Promotion_Eligibility_Rule__c promElig = TestDataFactory.createPromEligibilityRule(1)[0];
         promElig.Promotion__c = prom.Id;
         promElig.Package_List__c = '01';
         promElig.Eligibility_Rule__c = elig.Id;
         promElig.Date__c = date.today()+2;
         promElig.Current_Platform__c = 'Print';
         database.insert(promElig);    
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.Id;
         database.insert(promPack);
         
         Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
         spc.Zuora__Subscription__c = subList[0].Id;
         spc.Zuora__RatePlanName__c = 'Name';
         spc.Zuora__ProductSKU__c = 'SKU01';
         database.insert(spc);
         
         Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
         asia1.Display_Name__c = 'displayName123';
         asia1.User_ID_LDAP_ID__c = 'displayName123@email.com';
         asia1.Password__c = 'password123';
         asia1.Status__c = 'Created';
         database.insert(asia1);
         
         zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
         quote.Order_Line_Item_Number_1__c = orderline.Id;
         quote.Subscription_Type__c = 'Delivery';
         quote.Delivery_Charge_Type__c = 'S';
         database.insert(quote);
         
         Promotion_Gift__c gift = TestDataFactory.createPromotionGift(1)[0];
         gift.Promotion__c = prom.Id;
         database.insert(gift);
         //end test data
     
         test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             cont.asia1SelectedExistingId = asia1.Id;
             cont.orderLineItem = orderline;
             
             cont.getEarliestStart(pack.Id); 
             cont.retrieveActiveSubscriptions();
             cont.save();
             //cont.executeSearch();
             cont.cancel();
             cont.refreshSubscriberCharge();
             SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(prom.Id, 'Full Prepaid', acc.Id, 'Change', 'true', subList[0].Id);
             cont.addAsia1ExistingAccount();
             cont.addAsia1NewAccount();
             cont.removeAsia1Subscription();
         test.stopTest();
     }
     
     static testMethod void testSM_ChangeOfSubscriptionEntryController2(){
         Integer counter;
     
         //start custom settings
         List<Other__c> other = new List<Other__c>{new Other__c(Name = 'DTL', Value__c = '23:59'),
             new Other__c(Name = 'ARMS_SysId', Value__c = 'SS'),
             new Other__c(Name = 'ARMS_userID', Value__c = 'arcrcl01'),
             new Other__c(Name = 'ARMS_password', Value__c = 'arms1234')};
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         List<Error_Messages__c> error = new List<Error_Messages__c>{new Error_Messages__c(Name = 'Terms And Condition',       
         Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.', 
         Message__c = 'Tems and Condition must be accepted.'),
         new Error_Messages__c(Name = 'No Billing Account',
         Description__c = 'When saving as draft without billing account.',
         Message__c = 'Please provide billing details.')};
         database.insert(error);
         
         Delivery_Charge_Type__c devCharge = new Delivery_Charge_Type__c();
         devCharge.Name = 'S';
         devCharge.Default_Delivery_Charge_Type__c = 'L';
         database.insert(devCharge);
         
         Zuora_HPM_Settings__c zuoraSetting = new Zuora_HPM_Settings__c();
         zuoraSetting.Name = 'Default';
         zuoraSetting.Api_Security_Key__c = 'MeO04F_bJxynYVB4sQ9b1DDTZGPNXNLyDoq_rwO3Tfs=';
         zuoraSetting.Id__c = '2c92c0f84475d4670144904b96a00076';
         zuoraSetting.Tenant_Id__c = '12212';
         zuoraSetting.Zuora_URL__c = 'apisandbox.zuora.com';
         database.insert(zuoraSetting);
         //end custom settings
     
         //start test data
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Delivery_Charge_Type_1__c = 'H';
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'New';
         order.Delivery_Charge_Type__c = 'H';
         order.Recipient_Contact__c = con.Id;
         //order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         order.Payment_Mode__c = 'Other';
         order.Other_Payment_Mode__c = 'Invoice';
         database.insert(order);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Start_Date__c = date.today()+1;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.New_Contract_Period__c = 30;
         orderline.Promotion_ID__c = prom.Id;
         database.insert(orderline);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Publication_Code__c = '01';
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
         database.insert(pub);
         
         List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
         for(zqu__ProductRatePlanCharge__c pr:prpc){
             pr.zqu__ProductRatePlan__c = prdRatePlan.Id;
         }
         database.insert(prpc);
         
         Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
         prodPub.ZProduct__c = zProduct.Id;
         prodPub.Publication_Code__c = pub.Id;
         database.insert(prodPub);
         
         Eligibility_Rule__c elig = TestDataFactory.createEligibilityRule(1)[0];
         elig.Action__c = 'Change';
         elig.Customer_Status__c = 'Existing Customer';
         elig.Contract_Status__c = 'With Contract';
         elig.Contract_Subscription_Rule__c = 'Contract End Date';
         elig.Condition__c = '>';
         database.insert(elig);
         
         Promotion_Eligibility_Rule__c promElig = TestDataFactory.createPromEligibilityRule(1)[0];
         promElig.Promotion__c = prom.Id;
         promElig.Package_List__c = '01';
         promElig.Eligibility_Rule__c = elig.Id;
         promElig.Date__c = date.today()+2;
         promElig.Current_Platform__c = 'Print';
         database.insert(promElig);    
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.Id;
         database.insert(promPack);
         
         Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
         spc.Zuora__Subscription__c = subList[0].Id;
         spc.Zuora__RatePlanName__c = 'Name';
         spc.Zuora__ProductSKU__c = 'SKU01';
         database.insert(spc);
         
         Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
         asia1.Display_Name__c = 'displayName123';
         asia1.User_ID_LDAP_ID__c = 'displayName123';
         asia1.Password__c = 'password123';
         database.insert(asia1);
         //end test data
     
         test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             cont.orderLineItem = orderline;
             cont.selectedAddOnPackage = pack.Id;
             cont.populateAddOn();
             
             List<SM_SubscriptionHelper.Asia1Wrapper> asia1WrapperList = new List<SM_SubscriptionHelper.Asia1Wrapper>();
             SM_SubscriptionHelper.Asia1Wrapper asia1Wrapper = new SM_SubscriptionHelper.Asia1Wrapper();
             asia1Wrapper.asia1Id = asia1.Id;
             asia1WrapperList.add(asia1Wrapper);
             
             cont.asia1Subscriptions = asia1WrapperList;
             cont.getAsia1ExistingAccounts();
             
             cont.selectedOrderLineItem = '';
             cont.selectedchangeOfSubscriptionOptions = subList[0].Subscription_Type__c;
             cont.isReInitializedItem = true;
             cont.isExecuteSearch = true;
             cont.acquisitionType = '';
             cont.glCode = '';
             cont.dtlDate = SM_SubscriptionHelper.getDtlDate();
             cont.isSponsored = true;
             cont.fullPaymentMonthlyDeliveryCharge = 1.0;
             cont.amountPaid = 2.0;
             cont.deliveryChargeType = '';
             cont.getCOS_PACKAGE();
             cont.getCOS_QUANTITY();
             
             cont.recipientAddressType = 'S';
             cont.getDeliveryChargeTypes();
             cont.getBillingAccountOptions();
             cont.getSource();
             
             cont.thisOrder = order;
             cont.clearPaymentMethod();
             cont.clearOtherPaymentMethod();
             
             cont.aCust = 'Customer';
             cont.getBillAccName();
             
             Test.setMock(WebServiceMock.class, new ChangeSubCustomerSearchMock());
             cont.searchCusName(); 
             Test.setMock(WebServiceMock.class, new ChangeSubAccountSearchMock());
             cont.searchAccName();
             
             //List<SM_ChangeOfSubscriptionEntryController.armsWrapper> armsCWrapList = new List<SM_ChangeOfSubscriptionEntryController.armsWrapper>();
             //cont.addPopAcc();
         test.stopTest();
     }    
     
     static testMethod void testSM_ChangeOfSubscriptionEntryController3(){
         Integer counter;
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
     
         //start test data
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         order.Payment_Mode__c = 'Other';
         order.Other_Payment_Mode__c = 'Invoice';
         order.Create_ARMS_Customer_Account__c = true;
         database.insert(order);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Start_Date__c = date.today()+1;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.New_Contract_Period__c = 30;
         orderline.Promotion_ID__c = prom.Id;
         orderline.Subscribed_as__c = 'Misc Change';
         orderline.Is_Digital__c = true;
         orderline.Term_is_discussed__c = TRUE;
         database.insert(orderline);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Publication_Code__c = '01';
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
         database.insert(pub);
         
         List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
         for(zqu__ProductRatePlanCharge__c pr:prpc){
             pr.zqu__ProductRatePlan__c = prdRatePlan.Id;
         }
         database.insert(prpc);
         
         Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
         prodPub.ZProduct__c = zProduct.Id;
         prodPub.Publication_Code__c = pub.Id;
         database.insert(prodPub);
         
         Eligibility_Rule__c elig = TestDataFactory.createEligibilityRule(1)[0];
         elig.Action__c = 'Change';
         elig.Customer_Status__c = 'Existing Customer';
         elig.Contract_Status__c = 'With Contract';
         elig.Contract_Subscription_Rule__c = 'Contract End Date';
         elig.Condition__c = '>';
         database.insert(elig);
         
         Promotion_Eligibility_Rule__c promElig = TestDataFactory.createPromEligibilityRule(1)[0];
         promElig.Promotion__c = prom.Id;
         promElig.Package_List__c = '01';
         promElig.Eligibility_Rule__c = elig.Id;
         promElig.Date__c = date.today()+2;
         promElig.Current_Platform__c = 'Print';
         database.insert(promElig);    
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.Id;
         database.insert(promPack);
         
         Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
         spc.Zuora__Subscription__c = subList[0].Id;
         spc.Zuora__RatePlanName__c = 'Name';
         spc.Zuora__ProductSKU__c = 'SKU01';
         database.insert(spc);
         
         Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
         asia1.Display_Name__c = 'displayName123';
         asia1.User_ID_LDAP_ID__c = 'displayName123@email.com';
         asia1.Password__c = 'password123';
         asia1.Status__c = 'Created';
         database.insert(asia1);
         
         zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
         quote.Order_Line_Item_Number_1__c = orderline.Id;
         quote.Subscription_Type__c = 'Delivery';
         quote.Delivery_Charge_Type__c = 'S';
         database.insert(quote);
         
         Promotion_Gift__c gift = TestDataFactory.createPromotionGift(1)[0];
         gift.Promotion__c = prom.Id;
         database.insert(gift);
         //end test data
     
         test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             cont.asia1SelectedExistingId = asia1.Id;
             //cont.orderLineItem = orderline;
             
             cont.getEarliestStart(pack.Id); 
             cont.retrieveActiveSubscriptions();
             cont.billingAccountOption = 'createNew';
             cont.thisOrder = order;
             //cont.orderLineItem = orderline;
             cont.save();
             
             //cont.executeSearch();
             cont.cancel();
             cont.refreshSubscriberCharge();
             SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(prom.Id, 'Full Prepaid', acc.Id, 'Change', 'true', subList[0].Id);
             cont.addAsia1ExistingAccount();
             cont.addAsia1NewAccount();
             cont.removeAsia1Subscription();
         test.stopTest();
     }
     
     static testMethod void testSM_ChangeOfSubscriptionEntryController3b(){
         Integer counter;
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
     
         //start test data
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         order.Payment_Mode__c = 'Check';
         order.Other_Payment_Mode__c = 'Invoice';
         order.Create_ARMS_Customer_Account__c = true;
         database.insert(order);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Start_Date__c = date.today()+1;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.New_Contract_Period__c = 30;
         orderline.Promotion_ID__c = prom.Id;
         orderline.Subscribed_as__c = 'Misc Change';
         orderline.Is_Digital__c = true;
         orderline.Term_is_discussed__c = TRUE;
         database.insert(orderline);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Publication_Code__c = '01';
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
         database.insert(pub);
         
         List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
         for(zqu__ProductRatePlanCharge__c pr:prpc){
             pr.zqu__ProductRatePlan__c = prdRatePlan.Id;
         }
         database.insert(prpc);
         
         Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
         prodPub.ZProduct__c = zProduct.Id;
         prodPub.Publication_Code__c = pub.Id;
         database.insert(prodPub);
         
         Eligibility_Rule__c elig = TestDataFactory.createEligibilityRule(1)[0];
         elig.Action__c = 'Change';
         elig.Customer_Status__c = 'Existing Customer';
         elig.Contract_Status__c = 'With Contract';
         elig.Contract_Subscription_Rule__c = 'Contract End Date';
         elig.Condition__c = '>';
         database.insert(elig);
         
         Promotion_Eligibility_Rule__c promElig = TestDataFactory.createPromEligibilityRule(1)[0];
         promElig.Promotion__c = prom.Id;
         promElig.Package_List__c = '01';
         promElig.Eligibility_Rule__c = elig.Id;
         promElig.Date__c = date.today()+2;
         promElig.Current_Platform__c = 'Print';
         database.insert(promElig);    
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.Id;
         database.insert(promPack);
         
         Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
         spc.Zuora__Subscription__c = subList[0].Id;
         spc.Zuora__RatePlanName__c = 'Name';
         spc.Zuora__ProductSKU__c = 'SKU01';
         database.insert(spc);
         
         Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
         asia1.Display_Name__c = 'displayName123';
         asia1.User_ID_LDAP_ID__c = 'displayName123@email.com';
         asia1.Password__c = 'password123';
         asia1.Status__c = 'Created';
         database.insert(asia1);
         
         zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
         quote.Order_Line_Item_Number_1__c = orderline.Id;
         quote.Subscription_Type__c = 'Delivery';
         quote.Delivery_Charge_Type__c = 'S';
         database.insert(quote);
         
         Promotion_Gift__c gift = TestDataFactory.createPromotionGift(1)[0];
         gift.Promotion__c = prom.Id;
         database.insert(gift);
         //end test data
     
         test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             cont.asia1SelectedExistingId = asia1.Id;
             //cont.orderLineItem = orderline;
             
             cont.getEarliestStart(pack.Id); 
             cont.retrieveActiveSubscriptions();
             cont.billingAccountOption = 'createNew';
             cont.thisOrder = order;
             //cont.orderLineItem = orderline;
             cont.save();
             
             //cont.executeSearch();
             cont.cancel();
             cont.refreshSubscriberCharge();
             SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(prom.Id, 'Full Prepaid', acc.Id, 'Change', 'true', subList[0].Id);
             cont.addAsia1ExistingAccount();
             cont.addAsia1NewAccount();
             cont.removeAsia1Subscription();
         test.stopTest();
     }
     
     static testMethod void testSM_ChangeOfSubscriptionEntryController3c(){
         Integer counter;
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
     
         //start test data
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         order.Payment_Mode__c = 'Cash';
         order.Other_Payment_Mode__c = 'Invoice';
         order.Create_ARMS_Customer_Account__c = true;
         database.insert(order);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Start_Date__c = date.today()+1;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.New_Contract_Period__c = 30;
         orderline.Promotion_ID__c = prom.Id;
         orderline.Subscribed_as__c = 'Misc Change';
         orderline.Is_Digital__c = true;
         orderline.Term_is_discussed__c = TRUE;
         database.insert(orderline);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Publication_Code__c = '01';
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
         database.insert(pub);
         
         List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
         for(zqu__ProductRatePlanCharge__c pr:prpc){
             pr.zqu__ProductRatePlan__c = prdRatePlan.Id;
         }
         database.insert(prpc);
         
         Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
         prodPub.ZProduct__c = zProduct.Id;
         prodPub.Publication_Code__c = pub.Id;
         database.insert(prodPub);
         
         Eligibility_Rule__c elig = TestDataFactory.createEligibilityRule(1)[0];
         elig.Action__c = 'Change';
         elig.Customer_Status__c = 'Existing Customer';
         elig.Contract_Status__c = 'With Contract';
         elig.Contract_Subscription_Rule__c = 'Contract End Date';
         elig.Condition__c = '>';
         database.insert(elig);
         
         Promotion_Eligibility_Rule__c promElig = TestDataFactory.createPromEligibilityRule(1)[0];
         promElig.Promotion__c = prom.Id;
         promElig.Package_List__c = '01';
         promElig.Eligibility_Rule__c = elig.Id;
         promElig.Date__c = date.today()+2;
         promElig.Current_Platform__c = 'Print';
         database.insert(promElig);    
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.Id;
         database.insert(promPack);
         
         Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
         spc.Zuora__Subscription__c = subList[0].Id;
         spc.Zuora__RatePlanName__c = 'Name';
         spc.Zuora__ProductSKU__c = 'SKU01';
         database.insert(spc);
         
         Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
         asia1.Display_Name__c = 'displayName123';
         asia1.User_ID_LDAP_ID__c = 'displayName123@email.com';
         asia1.Password__c = 'password123';
         asia1.Status__c = 'Created';
         database.insert(asia1);
         
         zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
         quote.Order_Line_Item_Number_1__c = orderline.Id;
         quote.Subscription_Type__c = 'Delivery';
         quote.Delivery_Charge_Type__c = 'S';
         database.insert(quote);
         
         Promotion_Gift__c gift = TestDataFactory.createPromotionGift(1)[0];
         gift.Promotion__c = prom.Id;
         database.insert(gift);
         //end test data
     
         test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             cont.asia1SelectedExistingId = asia1.Id;
             //cont.orderLineItem = orderline;
             
             cont.getEarliestStart(pack.Id); 
             cont.retrieveActiveSubscriptions();
             cont.billingAccountOption = 'createNew';
             cont.thisOrder = order;
             //cont.orderLineItem = orderline;
             cont.save();
             
             //cont.executeSearch();
             cont.cancel();
             cont.refreshSubscriberCharge();
             SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(prom.Id, 'Full Prepaid', acc.Id, 'Change', 'true', subList[0].Id);
             cont.addAsia1ExistingAccount();
             cont.addAsia1NewAccount();
             cont.removeAsia1Subscription();
         test.stopTest();
     }
     
     static testMethod void NewTest001(){
         Integer counter;
         
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
     
         //start test data
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
                  
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         List<Order__c> ordList = new List<Order__c>();
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         database.insert(order);
         
         List<Case> casList1 = [SELECT CaseNumber, Status, Subscription_Name__c FROM Case WHERE RecordType.Name = 'Change of Subscription' and Subscription_Name__c =: subList[0].id];
         List<Case> caseList = new List<Case>();
         Case cas = new Case();
         cas.Account__c = acc.id;
         cas.Order__c = order.Id;
         database.insert(cas);
         caseList.add(cas);
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Start_Date__c = date.today()+1;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.New_Contract_Period__c = 30;
         orderline.Promotion_ID__c = prom.Id;
         orderline.Subscribed_as__c = 'Misc Change';
         orderline.Is_Digital__c = true;
         database.insert(orderline);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Publication_Code__c = '01';
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
         database.insert(pub);
         
         List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
         for(zqu__ProductRatePlanCharge__c pr:prpc){
             pr.zqu__ProductRatePlan__c = prdRatePlan.Id;
         }
         database.insert(prpc);
         
         Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
         prodPub.ZProduct__c = zProduct.Id;
         prodPub.Publication_Code__c = pub.Id;
         database.insert(prodPub);
         
         Eligibility_Rule__c elig = TestDataFactory.createEligibilityRule(1)[0];
         elig.Action__c = 'Change';
         elig.Customer_Status__c = 'Existing Customer';
         elig.Contract_Status__c = 'With Contract';
         elig.Contract_Subscription_Rule__c = 'Contract End Date';
         elig.Condition__c = '>';
         database.insert(elig);
         
         Promotion_Eligibility_Rule__c promElig = TestDataFactory.createPromEligibilityRule(1)[0];
         promElig.Promotion__c = prom.Id;
         promElig.Package_List__c = '01';
         promElig.Eligibility_Rule__c = elig.Id;
         promElig.Date__c = date.today()+2;
         promElig.Current_Platform__c = 'Print';
         database.insert(promElig);    
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.Id;
         database.insert(promPack);
         
         Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
         spc.Zuora__Subscription__c = subList[0].Id;
         spc.Zuora__RatePlanName__c = 'Name';
         spc.Zuora__ProductSKU__c = 'SKU01';
         database.insert(spc);
         
         Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
         asia1.Display_Name__c = 'displayName123';
         asia1.User_ID_LDAP_ID__c = 'displayName123@email.com';
         asia1.Password__c = 'password123';
         asia1.Status__c = 'Created';
         database.insert(asia1);
         
         zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
         quote.Order_Line_Item_Number_1__c = orderline.Id;
         quote.Subscription_Type__c = 'Delivery';
         quote.Delivery_Charge_Type__c = 'S';
         database.insert(quote);
         
         Promotion_Gift__c gift = TestDataFactory.createPromotionGift(1)[0];
         gift.Promotion__c = prom.Id;
         database.insert(gift);
         //end test data
     
         test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             cont.asia1SelectedExistingId = asia1.Id;
             cont.orderLineItem = orderline;
             
             cont.getEarliestStart(pack.Id); 
             cont.retrieveActiveSubscriptions();
             cont.save();
             //cont.executeSearch();
             cont.cancel();
             cont.refreshSubscriberCharge();
             SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(prom.Id, 'Full Prepaid', acc.Id, 'Change', 'true', subList[0].Id);
             cont.addAsia1ExistingAccount();
             cont.addAsia1NewAccount();
             cont.removeAsia1Subscription();
             cont.checkExistingCOA();
             try{
             cont.executeSearch();
             }catch(Exception e){
             }
             try{
             cont.searchPackage();
             }catch(Exception e){
             }
             try{
             cont.searchPromotion();
             }catch(Exception e){
             }
           
              try{
             cont.getDeliveryChargeTypes();
              }catch(Exception e){
             }
           
             cont.getBillingAccountOptions();
             cont.errorMsg = '';
             cont.displayCusErr = true;
             cont.displayAccList = true;
             cont.addAccount = true;
             cont.CBdisable = true;
             
             SM_ChangeOfSubscriptionEntryController.armsWrapper armsWrap1 = new SM_ChangeOfSubscriptionEntryController.armsWrapper();
             armsWrap1.arNum = '';
             armsWrap1.isTick = true;
             armsWrap1.arName= '';
             armsWrap1.arPOC= '';
             armsWrap1.arAddress= '';
             armsWrap1.arPostcode= '';
             armsWrap1.arStatus= '';
             armsWrap1.arBusProf= '';
             armsWrap1.arDate= '';
             armsWrap1.arAccNum= '';
             armsWrap1.arType= '';
             armsWrap1.arCredTerm= '';
             armsWrap1.arCredTermRef= '';
             armsWrap1.arDebtMgmt= '';
             armsWrap1.arCompCode= '';
             armsWrap1.arCreateDate= '';
             armsWrap1.arBLInd= '';
             armsWrap1.BLClrCd= '';
             armsWrap1.BLRsn= '';
             armsWrap1.IdTyp= '';
             armsWrap1.IdN= '';
             armsWrap1.PpCntryC= '';
             armsWrap1.CrRskRtg= '';
             armsWrap1.CrLmtInt= '';
             armsWrap1.CrLmtExt= '';
             armsWrap1.CityM= '';
             armsWrap1.Cntry= '';
             armsWrap1.PoBoxN= '';
             armsWrap1.AttnI= '';
             armsWrap1.StfI= '';
             armsWrap1.GstOOSI= '';
             armsWrap1.UpdId= '';
             armsWrap1.UpdDte= '';
             armsWrap1.UpdTme= '';
             armsWrap1.arAddress1= '';
             armsWrap1.arAddress2= '';
             armsWrap1.arAddress3= '';
             armsWrap1.arAddress4= '';
             List<SM_ChangeOfSubscriptionEntryController.armsWrapper> armsWrapList1 = new List<SM_ChangeOfSubscriptionEntryController.armsWrapper>();
             armsWrapList1.add(armsWrap1);
             cont.armsCusWrapList = armsWrapList1;
             List<SM_ChangeOfSubscriptionEntryController.armsWrapper> armsWrapList2 = new List<SM_ChangeOfSubscriptionEntryController.armsWrapper>();
             armsWrapList2.add(armsWrap1);
             cont.armsSelected = armsWrapList2;
             
             cont.addPopAcc();
             cont.closePopup();
             cont.cancelSearch();
             cont.continueSave();
            
           
         test.stopTest();
     }
     
     static testMethod void NewTest002(){
         Integer counter;
         
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
         
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
                  
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         List<Order__c> ordList = new List<Order__c>();
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         database.insert(order);
         
          test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             try{
             cont.retrieveAdminFeeAdminCharge();
             }catch(Exception e){
              System.debug(e);
             }
             
             test.stopTest();
             }
             
        static testMethod void NewTest003(){
         Integer counter;
         
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
         
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
                  
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         List<Order__c> ordList = new List<Order__c>();
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         database.insert(order);
         
          test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             try{
             cont.validateNewAsia1Account();
              }catch(Exception e){
              System.debug(e);
             }
             
             test.stopTest();
             }
             
        static testMethod void NewTest004(){
         Integer counter;
         
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
                  
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         List<Order__c> ordList = new List<Order__c>();
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         database.insert(order);
         
          test.startTest();
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', order.Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             cont.hidSubCharge = 1.0;
             cont.hidCreditCharge = 1.0;
              try{
             cont.getAsia1ExistingAccounts();
             }catch(Exception e){
             System.debug(e);
             }
             
             test.stopTest();
             }
             
       static testMethod void NewTest005(){
         Integer counter;
         
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
     
         //start custom settings
         Other__c other = new Other__c();
         other.Name = 'DTL';
         other.Value__c = '23:59';
         database.insert(other);
         
         Key_Id__c key = new Key_Id__c();
         key.Name = 'NEXT_RECIPIENT_NUMBER';
         key.Id__c = '30012551';
         database.insert(key);
         
         Integration_Settings__c integ = new Integration_Settings__c();
         integ.Name = 'Endpoint Delegator';
         integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
         database.insert(integ);
         
         Error_Messages__c error = new Error_Messages__c();
         error.Name = 'Terms And Condition';
         error.Description__c = 'Displays when creating an Order Line Item but not accepting the Terms and Condition.';
         error.Message__c = 'Tems and Condition must be accepted.';
         database.insert(error);
         //end custom settings
     
         //start test data
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         database.insert(acc);
         
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'P';
         database.insert(addressRec);
         
         Contact con = TestDataFactory.createContact(1)[0];
         con.Address__c = addressRec.Id;
         con.AccountId = acc.id;
         con.Recipient_Indicator__c = true;
         con.Email = 'displayName123@email.com';
         database.insert(con);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         pack.Billing_Type__c = 'Full Prepaid';
         pack.Package_Code__c = '01';
         database.insert(pack);
         
         zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
         zProduct.ProductPlatform__c = 'Print';
         zProduct.zqu__SKU__c = 'SKU01';
         database.insert(zProduct);
         
         zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
         prdRatePlan.zqu__ZProduct__c = zProduct.Id;
         prdRatePlan.RatePlanType__c= 'Bill Plan';
         prdRatePlan.Name = 'Name';
         database.insert(prdRatePlan);
         
         Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         pItem.Package__c = pack.id;
         pItem.Product_Rate_Plan__c = prdRatePlan.id;
         database.insert(pItem);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Promotion__c prom = TestDataFactory.createPromotion(1)[0];
         prom.Contract_Period__c = '1'; 
         database.insert(prom);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c = acc.Id;
         database.insert(ord);
         
                  
         List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(1);
         for(Zuora__Subscription__c sub:subList){
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type_1__c = 'Delivery';
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Subscription_Type__c = 'Publication';
             sub.Main_Package__c = pack.Id;
             sub.Promotion__c = prom.Id;
             sub.Qty1__c = '3';
             sub.Order_Number_1__c = ord.Id;
             sub.Contract_End_Date__c = string.valueOf(date.today()+10);
             sub.Recipient_Contact__c = con.Id;
         }
         database.insert(subList);
         
         List<Order__c> ordList = new List<Order__c>();
         Order__c order = TestDataFactory.createOrder(1)[0];
         order.Account__c = acc.Id;
         order.Subscription__c = subList[0].Id;
         order.isChangeOfSubEntry__c = true;    
         order.Order_Type1__c = 'Change of Subscription';
         order.Order_Type__c = 'Change of Subscription';
         order.Status__c = 'Draft';
         order.Recipient_Contact__c = con.Id;
         order.Payment_Mode__c = 'Credit Card';
         order.Delivery_Charge_Type__c = 'S';
         order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
         order.Billing_Account__c = billAcc.Id;
         database.insert(order);
         ordList.add(order); 
         

         
         List<Case> caseList = TestDataFactory.createCase(1, 'Change of Subscription');
         caseList[0].Account__c = acc.id;
         caseList[0].Order__c = order.Id;
         caseList[0].Subscription_Name__c = subList[0].id;
         
         
         
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
         orderline.Order__c = order.Id;
         orderline.Qty__c = 0.0;
         orderline.Start_Date__c = date.today()+1;
         orderline.Main_Package_ID__c = pack.Id;
         orderline.New_Contract_Period__c = 30;
         orderline.Promotion_ID__c = prom.Id;
         orderline.Subscribed_as__c = 'Misc Change';
         orderline.Is_Digital__c = true;
         database.insert(orderline);
         
         Publication__c pub = TestDataFactory.createPublication(1)[0];
         pub.Publication_Code__c = '01';
         pub.Earliest_Start_Date__c = date.today()+1;
         pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
         database.insert(pub);
         
         List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
         for(zqu__ProductRatePlanCharge__c pr:prpc){
             pr.zqu__ProductRatePlan__c = prdRatePlan.Id;
         }
         database.insert(prpc);
         
         Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
         prodPub.ZProduct__c = zProduct.Id;
         prodPub.Publication_Code__c = pub.Id;
         database.insert(prodPub);
         
         Eligibility_Rule__c elig = TestDataFactory.createEligibilityRule(1)[0];
         elig.Action__c = 'Change';
         elig.Customer_Status__c = 'Existing Customer';
         elig.Contract_Status__c = 'With Contract';
         elig.Contract_Subscription_Rule__c = 'Contract End Date';
         elig.Condition__c = '>';
         database.insert(elig);
         
         Promotion_Eligibility_Rule__c promElig = TestDataFactory.createPromEligibilityRule(1)[0];
         promElig.Promotion__c = prom.Id;
         promElig.Package_List__c = '01';
         promElig.Eligibility_Rule__c = elig.Id;
         promElig.Date__c = date.today()+2;
         promElig.Current_Platform__c = 'Print';
         database.insert(promElig);    
         
         Promotion_Package__c promPack = TestDataFactory.createPromotionPackage(1)[0];
         promPack.Promotion__c = prom.Id;
         promPack.Package_Name__c = pack.Id;
         database.insert(promPack);
         
         Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
         spc.Zuora__Subscription__c = subList[0].Id;
         spc.Zuora__RatePlanName__c = 'Name';
         spc.Zuora__ProductSKU__c = 'SKU01';
         database.insert(spc);
         
         Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
         asia1.Display_Name__c = 'displayName123';
         asia1.User_ID_LDAP_ID__c = 'displayName123@email.com';
         asia1.Password__c = 'password123';
         asia1.Status__c = 'Created';
         database.insert(asia1);
         
        List<Asia1_Subscription__c> tmpList = new List<Asia1_Subscription__c>();
        Asia1_Subscription__c tmp = new Asia1_Subscription__c();
        tmp.Asia1__c = asia1.id;
        tmp.Order_Line_Item__c = orderline.id;
        database.insert(tmp);
        tmpList.add(tmp); 
         
         zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
         quote.Order_Line_Item_Number_1__c = orderline.Id;
         quote.Subscription_Type__c = 'Delivery';
         quote.Delivery_Charge_Type__c = 'S';
         database.insert(quote);
         
         Promotion_Gift__c gift = TestDataFactory.createPromotionGift(1)[0];
         gift.Promotion__c = prom.Id;
         database.insert(gift);
         //end test data
     
         test.startTest();
         ordList[0].Status__c = 'New';
         database.update(ordList[0]);
         database.insert(caseList);
             PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
             Test.setCurrentPage(pRef);
             ApexPages.currentPage().getParameters().put('accountId', acc.Id);
             ApexPages.currentPage().getParameters().put('subscriptionId', subList[0].Id);
             ApexPages.currentPage().getParameters().put('id', ordList[0].Id);
             
             SM_ChangeOfSubscriptionEntryController cont = new SM_ChangeOfSubscriptionEntryController();
             cont.thisOrder = ordList[0];
             cont.retrieveRelatedSubscriptions();
             cont.cancel();
             cont.retrieveActiveSubscriptions();  
             cont.billingAccountOption = 'createNew'; 
             
             List<SM_SubscriptionHelper.Asia1Wrapper> asia1WrapperList = new List<SM_SubscriptionHelper.Asia1Wrapper>();
             SM_SubscriptionHelper.Asia1Wrapper asia1Wrapper = new SM_SubscriptionHelper.Asia1Wrapper();
             asia1Wrapper.asia1Id = asia1.Id;
             asia1WrapperList.add(asia1Wrapper);
             
             cont.asia1Subscriptions = asia1WrapperList;
             cont.isDigital = true;
             cont.asia1Sub = tmpList;
             cont.save();
         test.stopTest();
     }
 }