/**
* Class Name: SP_RenewalReminderMapperTest
* @author: Rom Edison Reyes
* Date: 4/13/2016
* Requirement/Project Name: <SPH>
* @description Test Class for SP_RenewalReminderMapper
*/
@isTest(seeAllData = true)
public class SP_RenewalReminderMapperTest{

  static testmethod void testAll(){  
    Integer records = 1;
    Integer count = 0;
    
    List<Zone__c> zoneList = TestDataFactory.createZone(1);
    count = 0;
    for (Zone__c obj : zoneList) {
        obj.Name = ''+count;
        count++;
    }
    insert zoneList;
    
    //Country
    List<Country__c> countryList = TestDataFactory.createCountry(1);
    count = 0;
    for (Country__c obj : countryList) {
        obj.Zone__c = zoneList[count].id;
        count++;
    }
    insert countryList;
    
    //City
    List<City__c> cityList = TestDataFactory.createCity(1);
    count = 0;
    for (City__c obj : cityList) {
        //Country - Country
        obj.Country__c = countryList[count].id;
        obj.Flight_Number_1__c = 'Flight Number 1 '+ count;
        count++;
    }
    insert cityList;
    
    //Singpost Address
    List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(1);
    insert singpostAddressList;
    
    //Address
    List<Address__c> addressList1 = TestDataFactory.createAddress(1);
    addressList1[0].Address_Type__c= 'H';
    addressList1[0].Postal_Code__c = singpostAddressList[0].Id;
    addressList1[0].Country__c = countryList[0].Id;
    insert addressList1;
    
    List<Account> accountList1 = TestDataFactory.createAccount(1, 'Direct Individual');
    count = 0;
    for (Account obj : accountList1) {
        obj.Singpost_Address__c = singpostAddressList[0].id;
        count++;
    }
    insert accountList1;
    
    List<Contact> contactList1 = TestDataFactory.createContact(1);
    for (Contact obj : contactList1) {
        obj.AccountId = accountList1[0].Id;
        obj.City_Code__c = cityList[0].id;          
        obj.Recipient_Indicator__c = true;
        obj.Billing_Indicator__c = true;
        obj.Address__c = addressList1[0].Id;
        obj.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        obj.FirstName = 'FName';
        obj.LastName = 'LName';
        obj.Passport__c = 'Passport Test';
        obj.HomePhone__c = '123 456';
        obj.Mobile_Number__c = '123456';
        obj.Email = 'test@test.com';
        count++;
    }   
    insert contactList1; 
    
    //Product
    zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0]; //try to loop with many product sub type
    zProduct.ProductPlatform__c = 'Print';
    zProduct.ProductSubType__c = 'Newspaper';
    zProduct.ProductCode__c = 'STSU';
    insert zProduct;
    
    Zuora__Product__c prod = TestDataFactory.createProduct(1)[0];
    insert prod;
    
    //Product Rate Plan
    zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
    prdRatePlan.zqu__ZProduct__c = zProduct.Id;
    prdRatePlan.SubscriptionFrequency__c = '2';
    prdRatePlan.RatePlanType__c = 'Bill Plan';
    insert prdRatePlan;
    
    //Pubs
    List<Publication__c> publicationList1 = TestDataFactory.createPublication(1);
    count = 0;
    for (Publication__c publication : publicationList1 ) {
    publication.Product_Family__c = 'PrFam';
    publication.Published_Days__c = 'YYYYYYY';
    publication.Publication_Type__c = 'N';
    publication.Publication_Code__c = 'CODE';
    publication.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
    publication.Earliest_Start_Date__c = date.today().addDays(1);
    count++;
    }
    insert publicationList1;
    
    //Product Publication
    List<Product_Publication__c> prodPubList1 = TestDataFactory.createProductPublication(1);
    count = 0;
    for(Product_Publication__c prodPub : prodPubList1 ){
        prodPub.Product_Code__c = prod.Id;
        prodPub.Publication_Code__c = publicationList1[0].Id;
        prodPub.ZProduct__c = zProduct.Id;
        count++;
    }
    insert prodPubList1;
    
    //Billing Account
    List<Zuora__CustomerAccount__c> zuoraCustomerAccountList1 = TestDataFactory.createBillingAccount(records);
    count = 0;
    for (Zuora__CustomerAccount__c obj : zuoraCustomerAccountList1) {
        obj.Billing_Contact__c = contactList1[count].id;          
        obj.Zuora__Account__c = accountList1[count].id;         
        obj.Zuora__Credit_Balance__c = 100;          
        obj.Billing_Type__c = 'Recurring Prepaid';
        obj.Zuora__DefaultPaymentMethod__c = 'Other';
        obj.Other_PaymentMethod__c  = 'External Parties';
        obj.Zuora__Zuora_Id__c  = 'ZID'+ count; 
        count++;
    }
    insert zuoraCustomerAccountList1;
    
    //Package
    List<Package__c> packageList1 = TestDataFactory.createPackage(records);
    packageList1[0].Package_Code__c = 'packsample';
    packageList1[0].Subscription_Type__c = 'Evergreen';
    packageList1[0].Package_Sub_Type__c = 'Single';
    packageList1[0].Subscription_Period__c = '12';
    packageList1[0].Billing_Type__c = 'Recurring Prepaid';
    insert packageList1;
    
    List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
    prodfam[0].Product_Family_Name__c = 'TestNAme';
    insert prodfam;
    
    //Package Items
    Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
    pItem.Package__c = packageList1[0].Id;
    pItem.Product_Rate_Plan__c = prdRatePlan.Id;
    pItem.Duration_in_months__c = '1';
    pItem.Effective_Start_Month__c = '1';
    pItem.Product_Family__c = prodfam[0].id;
    insert pItem;
    
    //Orders for old sub
    List<Order__c> orderList1 = TestDataFactory.createOrder(1);
    count = 0;
    for (Order__c obj : orderList1) {
        obj.Account__c = accountList1[0].id;           
        obj.Billing_Account__c = zuoraCustomerAccountList1[0].id;           
        obj.isChangeOfSubEntry__c = false;           
        obj.Order_Type__c = 'Start Subscription';
        obj.Billing_Type__c = 'Recurring Prepaid';          
        obj.Status__c = 'Close';
        obj.Recipient_Contact__c = contactList1[0].id;
        obj.Billing_Contact__c = contactList1[0].id;
        obj.Payment_Mode__c = 'Credit Card';
        obj.Payment_Method_ID__c = 'zIDBillAcc';
        obj.Subscriber_Charge__c = 100;
        //obj.Delivery_Charge_Type__c
        
        count++;
    }
    insert orderList1;
    
    //OLI
    List<Order_Line_Item__c> orderLineItemList1 = TestDataFactory.createOrderLineItem(records);
    count = 0;
    for (Order_Line_Item__c obj : orderLineItemList1) {
        obj.Order__c = orderList1[count].id;
        obj.Main_Package_ID__c = packageList1[count].id;
        obj.Start_Date__c = Date.today().addDays(1);
        obj.Qty__c = 1;
        obj.Subscribed_as__c = 'New Buy';
        obj.Term_Length__c = 12; 
        obj.Main_Package_Billing_Type__c = 'Recurring Prepaid';     
        
        count++;
    }
    insert orderLineItemList1;
    
    //Subs
    List<Zuora__Subscription__c>  zuoraSubscriptionList = TestDataFactory.createSubscription(2);
    count = 0;
    for (Zuora__Subscription__c obj : zuoraSubscriptionList) {
        obj.Zuora__Account__c = accountList1[0].id;     
        obj.Zuora__CustomerAccount__c = zuoraCustomerAccountList1[0].id;
        obj.Main_Package_1__c = packageList1[0].id;          
        obj.Number_of_Copies1__c = '1';
        obj.Zuora__Status__c = Globalvariableclass.SUBSCRIPTION_STATUS_ACTIVE;
        obj.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
        obj.Zuora__SubscriptionEndDate__c = null;
        obj.Subscription_Type__c = 'Publication';
        obj.Subscription_Type_1__c = 'Publication';
        obj.Zuora__TermSettingType__c = 'EVERGREEN';
        obj.Term_Length__c = 1;
        obj.Recipient_Contact__c = contactList1[0].id;
        obj.Contact__c = contactList1[0].id;
        obj.Delivery_Charge_Type_1__c = 'H';
        obj.Order_Number_1__c = orderList1[0].Id;
        obj.Order_Line_Item_Number_1__c = orderLineItemList1[0].Id;
        obj.Number_of_Copies__c = 1; 
        obj.Zuora__Zuora_Id__c  = 'ZIDSub'+ count;  
        obj.Billing_Type__c = 'Recurring Prepaid';
        count++;
    }
    zuoraSubscriptionList[1].Subscription_Type__c = 'Delivery';
    zuoraSubscriptionList[1].Subscription_Type_1__c = 'Delivery';
    insert zuoraSubscriptionList;
    
    List<Letter_Print_Request__c> lstLPR = new List<Letter_Print_Request__c>();
    
    Letter_Print_Request__c lpr1 = new Letter_Print_Request__c();
    lpr1.Record_Id__c = zuoraSubscriptionList[1].id;
    lpr1.Name = 'LPR1';
    insert lpr1;
    
    Letter_Print_Request__c lpr2 = new Letter_Print_Request__c();
    lpr2.Record_Id__c = zuoraSubscriptionList[0].id;
    lpr2.Parent_Letter_Print_Request__c = lpr1.id;
    lpr2.Name = 'LPR2';
    insert lpr2;
    
    Letter_Print_Request__c lpr3 = new Letter_Print_Request__c();
    lpr3.Name = 'LPR3';
    insert lpr3;
    
    lstLPR.add(lpr1);
    lstLPR.add(lpr2);
    lstLPR.add(lpr3);
    
    Map<Id,Zuora__Subscription__c> subscriptionMapParam = new Map<Id,Zuora__Subscription__c>();
    subscriptionMapParam.put(zuoraSubscriptionList[0].id,zuoraSubscriptionList[0]);
    subscriptionMapParam.put(zuoraSubscriptionList[1].id,zuoraSubscriptionList[1]);
    
    
    Test.StartTest();
    SP_RenewalReminderMapper.initializeRenewalSubscriptionGroup(lstLPR,subscriptionMapParam);
    SP_RenewalReminderMapper.groupOrderLineItemsByRecipient(zuoraSubscriptionList);
    SP_RenewalReminderMapper.getSubscriptionMap(lstLPR);
    Test.StopTest();
  }
 
 
  
}