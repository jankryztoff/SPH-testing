/*April Veloso
  10/19/2015
  Test class for BulkQuoteHandler
*/

@isTest (seeAllData = True)
public with sharing class BulkQuoteHandlerTest{

    static testmethod void test1(){
                  
                 /*  Other__c other = new Other__c();
                   other.Name = 'Zero Charge Amount';
                   other.Value__c = 'Zero Charge Amount';
                   database.insert(other);
                     
                   Key_Id__c key = new Key_Id__c();
                    key.Name = 'NEXT_RECIPIENT_NUMBER';
                    key.Id__c = '30012551';
                    insert(key); 
                 */  
                                                       
                    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    acc.RecordTypeId = [SELECT Id from RecordType WHERE sObjectType = 'Account' and Name ='Direct corporate'].id;
                    insert acc;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
                    Country__c country = TestDataFactory.createCountry(1)[0]; 
                    country.Country_Name__c = 'SINGAPORE'; 
                    insert country;
                    
                    
                    List<Address__c> address = TestDataFactory.createAddress(2);
                    Recordtype recType = [SELECT Id, Name from RecordType Where Name = 'Internal'];
                    address[0].RecordtypeId = recType.id;
                    address[0].Block_House_Number__c =  'TEST';
                    address[0].Postal_Code__c = postal.id;
                    address[0].Level_Number__c = '17';
                    address[0].Unit_Number__c = 'Unit 5';
                    address[0].Country__c = country.id;
                    
                    Recordtype recType2 = [SELECT Id, Name from RecordType Where Name = 'Local'];
                    address[1].RecordtypeId = recType2.id;
                    address[1].Block_House_Number__c =  'TEST';
                    address[1].Postal_Code__c = postal.id;
                    address[1].Level_Number__c = '17';
                    address[1].Unit_Number__c = 'Unit 5';
                    address[1].Country__c = country.id;
                                      
                    database.insert(address);
                    System.debug('ANDREI:' + address[0].Recordtype.Name);
                    
                    
                    List<Contact> con = TestDataFactory.createContact(2);
                    con[0].AccountId = acc.Id;
                    con[0].Address__c = address[0].id;
                    con[0].Recipient_Indicator__c = true;
                    con[0].RecordTypeId = [SELECT Id From RecordType WHERE sObjectType = 'Contact' and Name ='Customer Contact'].id;
                    
                    con[1].AccountId = acc.Id;
                    con[1].Address__c = address[1].id;
                    con[1].Recipient_Indicator__c = true;
                    con[1].RecordTypeId = [SELECT Id From RecordType WHERE sObjectType = 'Contact' and Name ='Customer Contact'].id;
                    
                    database.insert(con);
                    
                     
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    //billAccountList [0].id = zInv.id;
                    billAccountList[0].Zuora__Account__c = acc.id; 
                    billAccountList[0].Billing_Contact__c = con[0].id;
                    billAccountList[0].ARMS_Account_Number__c = '027101021';
                    billAccountList[0].Other_PaymentMethod__c ='Invoice';
                    billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                    billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                    billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                    billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                    billAccountList[0].Zuora__DefaultPaymentMethod__c ='Credit Card';
                    insert billAccountList;
                 
                  // if(billingAcctId_billingAcctObj.get(sub_billingAcctId.get(sub)).Zuora__DefaultPaymentMethod__c != GlobalVariableClass.CREDITCARD
                    
                    List<Order__c> order = TestDataFactory.createOrder(2);
                    order[0].Account__c = acc.Id;
                    order[0].Informed_Customer__c = TRUE;
                    order[0].Recipient_Contact__c = con[0].Id;
                    order[0].Subscriber_Charge__c = 100.00;
                    order[0].Order_Type__c = 'Change of Subscription';
                    
                    order[1].Account__c = acc.Id;
                    order[1].Informed_Customer__c = TRUE;
                    order[1].Recipient_Contact__c = con[1].Id;
                    order[1].Subscriber_Charge__c = 100.00;
                    order[1].Order_Type__c = 'Change of Subscription';
                    database.insert(order);
                    
                    List<Package__c> packList = TestdataFactory.createPackage(2);
                    packList[0].Package_Type__c ='Add On';
                    packList[0].Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    packList[0].Billing_Type__c = 'Full Prepaid';
                  
                    packList[1].Package_Type__c ='Add On';
                    packList[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    packList[1].Billing_Type__c = 'Full Prepaid';
                    database.insert(packList);
                    
                   /*04/05 Package__c pack = TestdataFactory.createPackage(1)[0];
                    pack.Package_Type__c ='Add On';
                    pack.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    pack.Billing_Type__c = 'Full Prepaid';
                    database.insert(pack);*/
                    
            /*APRIL        List<Package__c> pack = TestdataFactory.createPackage(2);
                    pack[0].Package_Type__c ='Add On';
                    pack[0].Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    pack[0].Billing_Type__c = 'Full Prepaid';
                    
                    pack[1].Package_Type__c ='Base';
                    pack[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
                    pack[1].Billing_Type__c = 'Full Prepaid';
                    database.insert(pack);
             APRIL*/       
                    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                    orderline.Order__C = order[0].id;
                    orderline.Start_Date__c = date.today()+1;
                    orderline.Main_Package_ID__c = packList[0].id;
                    orderline.Delivered_By__c = 'Vendor';
                    orderline.Direct_Sub_Delivery_Method__c = 'Vendor';
                    orderline.Addon_Package__c = packList[1].id;
                    orderline.Main_Package_Product_Family__c = 'Default';
                    orderline.Main_Package_Billing_Type__c ='Full Prepaid';
                    database.insert(orderline);
                    
                    Subscription_Vendor__c subVen = new Subscription_Vendor__c();
                    database.insert(subVen);
                    
                    
                    Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                    zSub.Zuora__Account__c = acc.id;
                    zSUb.Zuora__CustomerAccount__c = billAccountList[0].id;
                    zSub.Vendor_Subscription_To_Convert_1__c =subVen.id;
                    zSub.Vendor_Subscription_To_Convert__c =subVen.id;
                    zSub.Sponsor_1__c = false;
                    zSub.Order_Number_1__c = order[0].id;
                    zSub.Zuora__Zuora_Id__c = 'AXY01KLM';
                    database.insert(zSub);
                    
                    order[0].Base_Subscription__c=zSub.id;
                    order[1].Base_Subscription__c=zSub.id;
                    database.update(order);
                    
                    zqu__ZProduct__c  zquProduct = TestdataFactory.createZProduct(1)[0];
                    zquProduct.ProductCode__c = 'POSCHG';
                    zquProduct.ProductType__c =' Charges';
                    zquProduct.ProductSubType__c =' Charges';
                    database.insert(zquProduct);
                    
                                                 
                    zqu__ProductRatePlan__c zquProdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                    zquProdRatePlan.RatePlanCode__c = 'CHGPOS';
                    zquProdRatePlan.zqu__Deleted__c = false;
                    zquProdRatePlan.zqu__ZProduct__c = zquProduct.id;
                   // zquProdRatePlan.Name = 'Zero Charge Amount';                   
                    database.insert(zquProdRatePlan);
                    
                  /*  zqu__ProductRatePlanCharge__c zquProdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
                    zquProdRatePlanCharge.zqu__ProductRatePlan__c = zquProdRatePlan.id;
                    zquProdRatePlanCharge.zqu__Deleted__c = false;
                    database.insert(zquProdRatePlanCharge);
                  */  
                     
                    //system.assertEquals(zquProdRatePlan[1].Name, 'Zero Charge Amount');
              /*APRIL      Package_Item__c packItem = TestdataFactory.createPackageItem(1, 'Bundle Discount')[0];
                    packItem.Package__c= pack[1].id;
                    insert packItem;
              APRIL*/
  
                    set<id> setID = new set<id>();
                    setID.add(order[0].Id);
                    setID.add(order[1].Id);

                    String origin = 'Cebu';
      
          test.startTest();
      
            BulkQuoteHandler bulkh = new BulkQuoteHandler();
            bulkh.bulkQuoteCreation(setID , origin);
          test.stopTest();
    }
}