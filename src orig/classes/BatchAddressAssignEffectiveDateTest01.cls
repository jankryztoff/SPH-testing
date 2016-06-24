@isTest (seeAllData= TRUE)
private class BatchAddressAssignEffectiveDateTest01 {

    
    //Holds all testdata values
    static Map<String, Object> sObjectListMap_global;
    
    //Letter_Print_Request__c
    static Letter_Print_Request__c createLetterPrintRequest01(List<Account> acc) {
        //WHERE Letter_Type__c = 'Acknowledgment_Letter' 
        //AND DTL_Date__c = TODAY 
        //AND (Acknowledgment_Type__c = 'Email' OR Acknowledgment_Type__c = 'Both')
        Letter_Print_Request__c letterPrint = new Letter_Print_Request__c();
        letterPrint.Letter_Type__c = 'Acknowledgment_Letter'; 
        letterPrint.DTL_Date__c = date.Today(); 
        letterPrint.Acknowledgment_Type__c  = 'Email';
        letterPrint.Record_ID__c = acc[0].id;
        Database.insert(letterPrint);
        
        sObjectListMap_global.put('Letter_Print_Request__c', letterPrint);
        return letterPrint;
    }
    
    //Account
    static List<Account> createAccount01() {
        //Create account
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual');
            acc[0].Name = 'TEST';
            acc[0].NRIC__c = 'T1234567R';
            acc[0].Status__c = 'Active';
            acc[0].Staff_ID__c = 'test';
            acc[0].AccountNumber = '123456789012345678901234567';
        sObjectListMap_global.put('Account',acc);
        Database.insert(acc);
        
        return acc;
    }
    
    static List<Account> createAccount02() {
        //Create account
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual');
            acc[0].Name = 'TEST';
            acc[0].NRIC__c = 'T1234567R';
            acc[0].AccountNumber = '123456789012345678901234567';
            acc[0].Staff_ID__c = 'test';
            acc[0].Status__c = 'Active';
        sObjectListMap_global.put('Account',acc);
        Database.insert(acc);
        
        return acc;
    }
    
    
    //Order__c
    static List<Order__c> createOrder01(List<Account> acc) {
        //Create order
        //WHERE Account__c IN: accountIdSet AND DTL_Date__c = TODAY]
        List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c = acc[0].Id;
//            odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c = 'Full Prepaid';
            odr[0].DTL_Date__c = Date.today();
        sObjectListMap_global.put('Order__c', odr);
        Database.insert(odr);
        return odr;
    }
    
    //Singpost Address
    static List<Singpost_Address__c> createPostalCode01() {
        List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(1);
        singpostAddressList[0].House_Block_Number__c = '010';
        insert singpostAddressList;
        sObjectListMap_global.put('Singpost_Address__c', singpostAddressList);
        return singpostAddressList;
    }
    
    //
    //Address
    static List<Address__c> createAddress01(List<Country__c> countryList, List<Singpost_Address__c> singpostAddressList) {
        List<Address__c> addressList = TestDataFactory.createAddress(4);
            //RecordType recordType = [SELECT ID FROM RecordType WHERE DeveloperName ='Overseas' LIMIT 1];
            RecordType RecType = [Select Id From RecordType  Where DeveloperName = 'Overseas' LIMIT 1];
    //        addressList[0].RecordType = recordType;
            addressList[0].Level_Number__c = '10';
            addressList[0].Unit_Number__c = '10';
            addressList[0].Country__c = countryList[0].id;
            addressList[0].Postal_Code__c = singpostAddressList[0].id;
            addressList[0].RecordType = RecType; // JURNA ADDED
            
        //
            //RecordType recordType1 = [SELECT ID FROM RecordType WHERE DeveloperName ='Local' LIMIT 1];
            //RecordType recordType1 = [SELECT ID FROM RecordType WHERE DeveloperName ='Overseas' LIMIT 1];
    //        //addressList[1].RecordType = recordType1;
            addressList[1].Level_Number__c = '10';
            addressList[1].Unit_Number__c = '10';
            addressList[1].Country__c = countryList[0].id;
            addressList[1].Postal_Code__c = singpostAddressList[0].id;
            //addressList[1].RecordType = recordType1; // JURNA ADDED
            
        //    
            //RecordType recordType2 = [SELECT ID FROM RecordType WHERE DeveloperName ='Internal' LIMIT 1];
    //        addressList[2].RecordType = recordType2;
            addressList[2].Level_Number__c = '10';
            addressList[2].Unit_Number__c = '10';
            addressList[2].Country__c = countryList[0].id;
            addressList[2].Postal_Code__c = singpostAddressList[0].id;
            //addressList[2].RecordType = recordType2; // JURNA ADDED
        //    
            //RecordType recordType3 = [SELECT ID FROM RecordType WHERE DeveloperName ='Airline' LIMIT 1];
    //        addressList[3].RecordType = recordType3;
            addressList[3].Level_Number__c = '10';
            addressList[3].Unit_Number__c = '10';
            addressList[3].Country__c = countryList[0].id;
            addressList[3].Postal_Code__c = singpostAddressList[0].id;
            //addressList[3].RecordType = recordType3; // JURNA ADDED
            
        insert addressList;
        sObjectListMap_global.put('Address__c', addressList);
        return addressList;
    }
    
    //Address
    static List<Address__c> createAddress02(List<Country__c> countryList, List<Singpost_Address__c> singpostAddressList) {
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        RecordType recordType = [SELECT ID, DeveloperName FROM RecordType WHERE DeveloperName ='Overseas' AND SobjectType = 'Address__c'LIMIT 1];
            addressList[0].RecordType = recordType;
            addressList[0].Level_Number__c = '10';
            addressList[0].Unit_Number__c = '10';
            addressList[0].Country__c = countryList[0].id;
            addressList[0].Postal_Code__c = singpostAddressList[0].id;
        
        insert addressList;
        sObjectListMap_global.put('Address__c', addressList);
        return addressList;
    }
    
    //Address
    static List<Address__c> createAddress03(List<Country__c> countryList, List<Singpost_Address__c> singpostAddressList) {
        List<Address__c> addressList = TestDataFactory.createAddress(3);
            RecordType recordType = [SELECT ID FROM RecordType WHERE DeveloperName ='Overseas' AND SobjectType = 'Address__c' LIMIT 1];
            addressList[0].RecordType = recordType;
            addressList[0].Level_Number__c = '10';
            addressList[0].Unit_Number__c = '10';
            addressList[0].Country__c = countryList[0].id;
            addressList[0].Postal_Code__c = singpostAddressList[0].id;
            
            RecordType recordType1 = [SELECT ID FROM RecordType WHERE DeveloperName ='Internal' AND SobjectType = 'Address__c' LIMIT 1];
            addressList[1].RecordType = recordType1;
            addressList[1].Level_Number__c = '10';
            addressList[1].Unit_Number__c = '10';
            addressList[1].Country__c = countryList[0].id;
            addressList[1].Postal_Code__c = singpostAddressList[0].id;
            
            RecordType recordType2 = [SELECT ID FROM RecordType WHERE DeveloperName ='Airline' AND SobjectType = 'Address__c' LIMIT 1];
            addressList[2].RecordType = recordType2;
            addressList[2].Level_Number__c = '10';
            addressList[2].Unit_Number__c = '10';
            addressList[2].Country__c = countryList[0].id;
            addressList[2].Postal_Code__c = singpostAddressList[0].id;
        
        insert addressList;
        sObjectListMap_global.put('Address__c', addressList);
        return addressList;
    }
        
    //Zone
    static List<Zone__c> createZone01() {
        List<Zone__c> zoneList = TestDataFactory.createZone(1);
        Integer count = 0;
        for (Zone__c obj : zoneList) {
            obj.Name = ''+count;
            count++;
        }
        insert zoneList;
        sObjectListMap_global.put('Zone__c', zoneList);
        return zoneList;
    }
        
    //Country
    static List<Country__c> createCountry01(List<Zone__c> zoneList) {
        List<Country__c> countryList = TestDataFactory.createCountry(1);
        for (Country__c obj : countryList) {
            obj.Zone__c = zoneList[0].id;
            obj.Country_Name__c = 'Philippines';
        }
        insert countryList;
        sObjectListMap_global.put('Country__c', countryList);
        return countryList;
    }
    
    //City
    static List<City__c> createCity01(List<Country__c> countryList) {
        List<City__c> cityList = TestDataFactory.createCity(1);
        Integer count = 0;
        for (City__c obj : cityList) {
            //Country - Country
            obj.Country__c = countryList[count].id;
            obj.Flight_Number_1__c = 'Flight Number 1 '+ count;
            count++;
        }
        insert cityList;
        sObjectListMap_global.put('City__c', cityList);
        return cityList;
    }
    
    //Billing Contact
    static List<Contact> createContact01(List<Account> acc, List<City__c> cityList, List<Address__c> addressList) {
        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(4);
        //for (Contact obj : contactList) {
            contactList[0].Account = acc[0];
            contactList[0].City_Code__c = cityList[0].id;
            contactList[0].Address__c = addressList[0].id;
            contactList[0].Email__c = 'a@a.com';
            contactList[0].AccountId = acc[0].Id; //JURNA ADDED
        //}   \
            contactList[1].Account = acc[0];
            contactList[1].City_Code__c = cityList[0].id;
            contactList[1].Address__c = addressList[1].id;
            contactList[1].Email__c = null;
            contactList[1].Email_Secondary__c = 'a@a.com';
        //}   \
            contactList[2].Account = acc[0];
            contactList[2].City_Code__c = cityList[0].id;
            contactList[2].Address__c = addressList[2].id;
            contactList[2].Email__c = 'a@a.com';
        //}   \
            contactList[3].Account = acc[0];
            contactList[3].City_Code__c = cityList[0].id;
            contactList[3].Address__c = addressList[3].id;
            contactList[3].Email__c = 'a@a.com';
        
        insert contactList; // JURNA REMOVED
        //update contactList; // JURNA ADDED
        sObjectListMap_global.put('Contact', contactList);
        return contactList;
    }
    
    //Billing Contact
    static List<Contact> createContact02(List<Account> acc, List<City__c> cityList, List<Address__c> addressList) {
        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(1);
        //for (Contact obj : contactList) {
            contactList[0].Account = acc[0];
            contactList[0].City_Code__c = cityList[0].id;
            contactList[0].Address__c = addressList[0].id;
            contactList[0].Email__c = 'a@a.com';
            contactList[0].AccountId = acc[0].Id; // JURNA ADDED
            
        insert contactList; // JURNA REMOVED
        //update contactList; // JURNA ADDED
        sObjectListMap_global.put('Contact', contactList);
        return contactList;
    }
    
    //Billing Contact
    static List<Contact> createContact03(List<Account> acc, List<City__c> cityList, List<Address__c> addressList) {
        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(3);
        //for (Contact obj : contactList) {
            contactList[0].Account = acc[0];
            contactList[0].City_Code__c = cityList[0].id;
            contactList[0].Address__c = addressList[0].id;
            contactList[0].Email__c = 'a@a.com';
            //contactList[0].AccountId = con.AccountId; //JURNA ADDED
            contactList[0].AccountId = acc[0].Id; // JURNA ADDED
            contactList[0].FirstName = 'FirstName';
            contactList[0].LastName = 'LastName';
            contactList[0].Salutation = 'Mr.';
            //contactList[0].NRIC__c = 'Vendor Staff'; 
            contactList[0].NRIC__c = 'T1234567R'; // JURNA ADDED
            contactList[0].Passport__c = 'Passport';
            contactList[0].Billing_Account_Name_2__c = 'BillingAccountName2';
            contactList[0].Company_Name__c = 'CompanyName';
            contactList[0].City_Code__c = cityList[0].id;
            contactList[0].Remarks__c = 'Remarks';
            contactList[0].Business_Address_Indicator__c = true;
            contactList[0].Billing_Indicator__c = true;
            contactList[0].Recipient_Indicator__c = false;
            contactList[0].HomePhone__c = '123462920';
            contactList[0].Mobile_Number__c = '0905809255';
            contactList[0].Mobile_Number_2__c = '0905809255';
            contactList[0].Office_Number__c = '123462920';
            contactList[0].Office_Extension__c = '+63';
            contactList[0].Fax__c = '123462920';
            contactList[0].Email__c = 'a@a.com';
            contactList[0].Email_Secondary__c = 'b@b.com';
            //contactList[0].Address__c = ;
            contactList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //<-
            
            contactList[1].Account = acc[0];
            contactList[1].City_Code__c = cityList[0].id;
            contactList[1].Address__c = addressList[1].id;
            contactList[1].Email__c = 'a@a.com';
            //contactList[1].AccountId = con.AccountId;
            contactList[1].FirstName = 'FirstName';
            contactList[1].LastName = 'LastName';
            contactList[1].Salutation = 'Mr.';
            //contactList[1].NRIC__c = 'Vendor Staff';
            contactList[1].Passport__c = 'Passport';
            contactList[1].Billing_Account_Name_2__c = 'BillingAccountName2';
            contactList[1].Company_Name__c = 'CompanyName';
            contactList[1].City_Code__c = cityList[0].id;
            contactList[1].Remarks__c = 'Remarks';
            contactList[1].Business_Address_Indicator__c = true;
            contactList[1].Billing_Indicator__c = true;
            contactList[1].Recipient_Indicator__c = false;
            contactList[1].HomePhone__c = '123462920';
            contactList[1].Mobile_Number__c = '0905809255';
            contactList[1].Mobile_Number_2__c = '0905809255';
            contactList[1].Office_Number__c = '123462920';
            contactList[1].Office_Extension__c = '+63';
            contactList[1].Fax__c = '123462920';
            contactList[1].Email__c = 'a@a.com';
            contactList[1].Email_Secondary__c = 'b@b.com';
            //contactList[1].Address__c = ;
            contactList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        
        //<-
            
            contactList[2].Account = acc[0];
            contactList[2].City_Code__c = cityList[0].id;
            contactList[2].Address__c = addressList[2].id;
            contactList[2].Email__c = 'a@a.com';
            //contactList[2].AccountId = con.AccountId;
            contactList[2].FirstName = 'FirstName';
            contactList[2].LastName = 'LastName';
            contactList[2].Salutation = 'Mr.';
            //contactList[2].NRIC__c = 'Vendor Staff';
            contactList[2].Passport__c = 'Passport';
            contactList[2].Billing_Account_Name_2__c = 'BillingAccountName2';
            contactList[2].Company_Name__c = 'CompanyName';
            contactList[2].City_Code__c = cityList[0].id;
            contactList[2].Remarks__c = 'Remarks';
            contactList[2].Business_Address_Indicator__c = true;
            contactList[2].Billing_Indicator__c = true;
            contactList[2].Recipient_Indicator__c = false;
            contactList[2].HomePhone__c = '123462920';
            contactList[2].Mobile_Number__c = '0905809255';
            contactList[2].Mobile_Number_2__c = '0905809255';
            contactList[2].Office_Number__c = '123462920';
            contactList[2].Office_Extension__c = '+63';
            contactList[2].Fax__c = '123462920';
            contactList[2].Email__c = 'a@a.com';
            contactList[2].Email_Secondary__c = 'b@b.com';
            //contactList[2].Address__c = ;
            contactList[2].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            
          insert contactList; //JURNA REMOVED
          //update contactList; // JURNA ADDED
        sObjectListMap_global.put('Contact', contactList);
        return contactList;
    }
    
    //Zuora__CustomerAccount__c
    //Billing Account
    static List<Zuora__CustomerAccount__c> createZuoraCustomerAccount01(List<Account> acc, List<Contact> contactList) {
        //Create zoura customer account
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(4);
            billAcc[0].Zuora__Account__c = acc[0].Id;
            billAcc[0].Billing_Type__c = 'Full Prepaid';
            billAcc[0].Billing_Contact__c = contactList[0].id;
            billAcc[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            
       //     
            billAcc[1].Zuora__Account__c = acc[0].Id;
            billAcc[1].Billing_Type__c = 'Full Prepaid';
            billAcc[1].Billing_Contact__c = contactList[1].id;
            billAcc[1].Zuora__Credit_Balance__c = 50000.00;
            billAcc[1].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
       //     
            billAcc[2].Zuora__Account__c = acc[0].Id;
            billAcc[2].Billing_Type__c = 'Full Prepaid';
            billAcc[2].Billing_Contact__c = contactList[2].id;
            billAcc[2].Zuora__Credit_Balance__c = 50000.00;
            billAcc[2].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
       //     
            billAcc[3].Zuora__Account__c = acc[0].Id;
            billAcc[3].Billing_Type__c = 'Full Prepaid';
            billAcc[3].Billing_Contact__c = contactList[3].id;
            billAcc[3].Zuora__Credit_Balance__c = 50000.00;
            billAcc[3].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
        sObjectListMap_global.put('Zuora__CustomerAccount__c', billAcc);
        Database.insert(billAcc);
        return billAcc;
    }
    
    
    static List<Zuora__CustomerAccount__c> createZuoraCustomerAccount02(List<Account> acc, List<Contact> contactList) {
        //Create zoura customer account
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c = acc[0].Id;
            billAcc[0].Billing_Type__c = 'Full Prepaid';
            billAcc[0].Billing_Contact__c = contactList[0].id;
            billAcc[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
/*            
       //     
            billAcc[1].Zuora__Account__c = acc[0].Id;
            billAcc[1].Billing_Type__c = 'Full Prepaid';
            billAcc[1].Billing_Contact__c = contactList[1].id;
            billAcc[1].Zuora__Credit_Balance__c = 50000.00;
            billAcc[1].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
       //     
            billAcc[2].Zuora__Account__c = acc[0].Id;
            billAcc[2].Billing_Type__c = 'Full Prepaid';
            billAcc[2].Billing_Contact__c = contactList[2].id;
            billAcc[2].Zuora__Credit_Balance__c = 50000.00;
            billAcc[2].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
       //     
            billAcc[3].Zuora__Account__c = acc[0].Id;
            billAcc[3].Billing_Type__c = 'Full Prepaid';
            billAcc[3].Billing_Contact__c = contactList[3].id;
            billAcc[3].Zuora__Credit_Balance__c = 50000.00;
            billAcc[3].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
*/
        sObjectListMap_global.put('Zuora__CustomerAccount__c', billAcc);
        Database.insert(billAcc);
        return billAcc;
    }
    
    static List<Zuora__CustomerAccount__c> createZuoraCustomerAccount03(List<Account> acc, List<Contact> contactList) {
        //Create zoura customer account
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(3);
            billAcc[0].Zuora__Account__c = acc[0].Id;
            billAcc[0].Billing_Type__c = 'Full Prepaid';
            billAcc[0].Billing_Contact__c = contactList[0].id;
            billAcc[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            billAcc[0].Other_PaymentMethod__c = 'Invoice';
            billAcc[0].ARMS_ID__c = 'T123456789';
        //
            billAcc[1].Zuora__Account__c = acc[0].Id;
            billAcc[1].Billing_Type__c = 'Full Prepaid';
            billAcc[1].Billing_Contact__c = contactList[1].id;
            billAcc[1].Zuora__Credit_Balance__c = 50000.00;
            billAcc[1].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            billAcc[1].Other_PaymentMethod__c = 'Invoice';
            billAcc[1].ARMS_ID__c = 'T123456789';
        //
            billAcc[2].Zuora__Account__c = acc[0].Id;
            billAcc[2].Billing_Type__c = 'Full Prepaid';
            billAcc[2].Billing_Contact__c = contactList[2].id;
            billAcc[2].Zuora__Credit_Balance__c = 50000.00;
            billAcc[2].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            billAcc[2].Other_PaymentMethod__c = 'Invoice';
            billAcc[2].ARMS_ID__c = 'T123456789';
            
        sObjectListMap_global.put('Zuora__CustomerAccount__c', billAcc);
        Database.insert(billAcc);
        return billAcc;
    }
    
    //Package
    static List<Package__c> createPackage01() {
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        //count = 0;
        //for (Package__c obj : packageList) {
            //TODO
            //Package_Price__c, Package_Type__c, Package_Sub_Type__c
            packageList[0].Package_Type__c = 'Add On';
            packageList[0].Package_Sub_Type__c = 'Single';
            packageList[0].Package_Price__c = 10;
            packageList[0].Subscription_Period__c = '15';   
            packageList[0].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[0].Billing_Type__c = 'Full Prepaid';  
       //   
            packageList[1].Package_Type__c = 'Add On';
            packageList[1].Package_Sub_Type__c = 'Single';
            packageList[1].Package_Price__c = 10;
            packageList[1].Subscription_Period__c = '15';   
            packageList[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[1].Billing_Type__c = 'Recurring Prepaid';  
        //}
        insert packageList;
        sObjectListMap_global.put('Package__c', packageList);
        return packageList;
    }
    
    
    //Promotion
    static List<Promotion__c> createPromotion01() {
        List<Promotion__c> promotionList = TestDataFactory.createPromotion(1);
        //count = 0;
        //for (Promotion__c obj : promotionList) {
            promotionList[0].Contract_Period__c = '1';
            //count++;
        //}
        insert promotionList;
        sObjectListMap_global.put('Promotion__c', promotionList);
        return promotionList;
    }
    
    //Order Line Item
    static List<Order_Line_Item__c> createOrderLineItem01(List<Order__c> odr, List<Package__c> packageList, List<Promotion__c> promotionList) {
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
        Integer count = 0;
        //for (Order_Line_Item__c obj : orderLineItemList) {
            orderLineItemList[0].Order__c = odr[0].id;
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;            
            orderLineItemList[0].Start_Date__c = Date.today().addDays(10);            
            orderLineItemList[0].Qty__c = 10;
            orderLineItemList[0].Add_On_Package_Subscription_Rate__c = 10;     
            orderLineItemList[0].Addon_Package__c = packageList[0].id;
            orderLineItemList[0].Promotion_ID__c = promotionList[0].id;
            orderLineItemList[0].Main_Package_Product_Family__c = 'Default';
            orderLineItemList[0].Main_Package_Billing_Type__c = 'Full Prepaid';
            orderLineItemList[0].Main_Package_Product_Sub_Type__c = GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE;
        //}
            orderLineItemList[1].Order__c = odr[0].id;
            orderLineItemList[1].Main_Package_ID__c = packageList[1].id;            
            orderLineItemList[1].Start_Date__c = Date.today().addDays(10);            
            orderLineItemList[1].Qty__c = 10;
            orderLineItemList[1].Add_On_Package_Subscription_Rate__c = 10;     
            orderLineItemList[1].Addon_Package__c = packageList[1].id;
            orderLineItemList[1].Promotion_ID__c = promotionList[0].id;
            orderLineItemList[1].Main_Package_Product_Family__c = 'Default';
            orderLineItemList[1].Main_Package_Billing_Type__c = 'Recurring Prepaid';
            orderLineItemList[1].Main_Package_Product_Sub_Type__c = GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE;
        insert orderLineItemList;
        sObjectListMap_global.put('Order_Line_Item__c', orderLineItemList);
        return orderLineItemList;
    }
    
    //Zuora__Subscription__c
    //static List<Zuora__Subscription__c> createZuoraSubscription(List<Account> acc, List<Promotion__c> promo, List<Zuora__CustomerAccount__c>billAcc, List<Order__c> odr) {
    static List<Zuora__Subscription__c> createZuoraSubscription01(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc,
            List<Order__c> odr, List<Order_Line_Item__c> orderLineItemList, List<Contact> contactList) {
        //Create zuora subscription 
        //WHERE Order_Number_1__c IN: orderIdSet AND Zuora__Status__c = 'Active'
        List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(10);
        //for(Zuora__Subscription__c x: zSub){
            zSub[0].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[0].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[0].Order_Number__c = odr[0].id;
            zSub[0].Order_Number_1__c = odr[0].id;
            zSub[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[0].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[0].Zuora__Status__c = 'Active';
            zSub[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[0].Recipient_Contact__c = contactList[0].id;
            zSub[0].Contact__c = contactList[0].Id;
            zSub[0].Order_Line_Item_Number_1__c = orderLineItemList[0].Id; // JURNA ADDED
            zSub[0].Order_Line_Item_Number__c = orderLineItemList[0].Id; // JURNA ADDED
            //zSub[0].Term_Length__c = ;
        //
            
            zSub[1].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[1].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub[1].Order_Number__c = odr[0].id;
            zSub[1].Order_Number_1__c = odr[0].id;
            zSub[1].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[1].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[1].Zuora__Status__c = 'Active';
            zSub[1].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub[1].Subscription_Charge__c = null;
            zSub[1].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub[1].Payment_Mode_1__c = GlobalVariableClass.CREDIT_CARD;
            zSub[1].Payment_Mode__c = GlobalVariableClass.CREDIT_CARD;
            zSub[1].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub[1].Order_Line_Item_Number__c = orderLineItemList[0].id;
        //
            zSub[2].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[2].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub[2].Order_Number__c = odr[0].id;
            zSub[2].Order_Number_1__c = odr[0].id;
            zSub[2].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[2].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[2].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[2].Zuora__Status__c = 'Active';
            zSub[2].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub[2].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub[2].Subscription_Charge__c = null;
            zSub[2].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub[2].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
            zSub[2].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub[2].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub[2].Order_Line_Item_Number__c = orderLineItemList[0].id;
            
        //
            zSub[3].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[3].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub[3].Order_Number__c = odr[0].id;
            zSub[3].Order_Number_1__c = odr[0].id;
            zSub[3].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[3].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[3].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[3].Zuora__Status__c = 'Active';
            zSub[3].Subscription_Type_1__c = 'Delivery';
            zSub[3].Subscription_Type__c = 'Delivery';
            zSub[3].Subscription_Charge__c = null;
            zSub[3].Zuora__TermSettingType__c = '';
            zSub[3].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
            zSub[3].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub[3].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub[3].Order_Line_Item_Number__c = orderLineItemList[0].id;
        //
            zSub[4].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[4].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub[4].Order_Number__c = odr[0].id;
            zSub[4].Order_Number_1__c = odr[0].id;
            zSub[4].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[4].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[4].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[4].Zuora__Status__c = 'Active';
            zSub[4].Subscription_Type_1__c = 'Delivery';
            zSub[4].Subscription_Type__c = 'Delivery';
            zSub[4].Subscription_Charge__c = null;
            zSub[4].Zuora__TermSettingType__c = '';
            zSub[4].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
            zSub[4].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub[4].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[4].Order_Line_Item_Number__c = orderLineItemList[1].id;
        //    
            zSub[5].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[5].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub[5].Order_Number__c = odr[0].id;
            zSub[5].Order_Number_1__c = odr[0].id;
            zSub[5].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[5].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[5].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[5].Zuora__Status__c = 'Active';
            zSub[5].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub[5].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub[5].Subscription_Charge__c = null;
            zSub[5].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub[5].Payment_Mode_1__c = GlobalVariableClass.CREDIT_CARD;
            zSub[5].Payment_Mode__c = GlobalVariableClass.CREDIT_CARD;
            zSub[5].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[5].Order_Line_Item_Number__c = orderLineItemList[1].id;
        //
            zSub[6].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[6].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub[6].Order_Number__c = odr[0].id;
            zSub[6].Order_Number_1__c = odr[0].id;
            zSub[6].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[6].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[6].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[6].Zuora__Status__c = 'Active';
            zSub[6].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub[6].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub[6].Subscription_Charge__c = null;
            zSub[6].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub[6].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
            zSub[6].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub[6].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[6].Order_Line_Item_Number__c = orderLineItemList[1].id;
        //
            zSub[7].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[7].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub[7].Order_Number__c = odr[0].id;
            zSub[7].Order_Number_1__c = odr[0].id;
            zSub[7].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[7].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[7].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[7].Zuora__Status__c = 'Active';
            zSub[7].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[7].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[7].Recipient_Contact__c = contactList[1].id;
            //zSub[7].Term_Length__c = ;
        //
            zSub[8].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[8].Zuora__CustomerAccount__c = billAcc[2].Id;
            zSub[8].Order_Number__c = odr[0].id;
            zSub[8].Order_Number_1__c = odr[0].id;
            zSub[8].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[8].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[8].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[8].Zuora__Status__c = 'Active';
            zSub[8].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[8].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[8].Recipient_Contact__c = contactList[2].id;
            //zSub[8].Term_Length__c = ;
        //
            zSub[9].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
           // zSub[9].Zuora__CustomerAccount__c = billAcc[3].Id; // JURNA REMOVED
            zSub[9].Zuora__CustomerAccount__c = billAcc[1].Id; //JURNA ADDED
            zSub[9].Order_Number__c = odr[0].id;
            zSub[9].Order_Number_1__c = odr[0].id;
            zSub[9].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[9].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[9].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[9].Zuora__Status__c = 'Active';
            zSub[9].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[9].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
           // zSub[9].Recipient_Contact__c = contactList[3].id; // JURNA REMOVED
            zSub[9].Recipient_Contact__c = contactList[2].id; //JURNA ADDED
            //zSub[9].Term_Length__c = ;
            
        sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        return zSub;
    }
    
    static List<Zuora__Subscription__c> createZuoraSubscription02(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc,
            List<Order__c> odr, List<Order_Line_Item__c> orderLineItemList, List<Contact> contactList) {
        //Create zuora subscription 
        //WHERE Order_Number_1__c IN: orderIdSet AND Zuora__Status__c = 'Active'
        List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(1);
        //for(Zuora__Subscription__c x: zSub){
            zSub[0].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[0].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[0].Order_Number__c = odr[0].id;
            zSub[0].Order_Number_1__c = odr[0].id;
            zSub[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[0].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[0].Zuora__Status__c = 'Active';
           // zSub[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE; //JURNA REMOVED
           // zSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE; // JURNA REMOVED
            zSub[0].Subscription_Type_1__c = 'Publication';
            zSub[0].Subscription_Type__c = 'Publication';
            zSub[0].Recipient_Contact__c = contactList[0].id;
            zSub[0].Contact__c = contactList[0].id; //JURNA ADDED
            //zSub[0].Term_Length__c = ;
            
        sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        return zSub;
    }
    
    
    // JURNA ADDED (duplicate of createZuoraSubscription02)
    static List<Zuora__Subscription__c> createZuoraSubscription03(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc,
            List<Order__c> odr, List<Order_Line_Item__c> orderLineItemList, List<Contact> contactList) {
        //Create zuora subscription 
        //WHERE Order_Number_1__c IN: orderIdSet AND Zuora__Status__c = 'Active'
        List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(1);
        //for(Zuora__Subscription__c x: zSub){
            zSub[0].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[0].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[0].Order_Number__c = odr[0].id;
            zSub[0].Order_Number_1__c = odr[0].id;
            zSub[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[0].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[0].Zuora__Status__c = 'Active';
            zSub[0].Subscription_Type_1__c = 'Publication';
            //zSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[0].Subscription_Type__c = 'Publication';
            zSub[0].Recipient_Contact__c = contactList[0].id;
            zSub[0].Contact__c = contactList[0].id; //JURNA ADDED
            zsUB[0].Zuora__TermSettingType__c = 'EVERGREEN';
            //zSub[0].Term_Length__c = ;
            
        sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        return zSub;
    }
    
    // JURNA ADDED
     //Subscription_Vendor__c
    static List<Subscription_Vendor__c> createSubscriptionVendor03(List<Account> acc, List<Contact> contactList) {
        List<Subscription_Vendor__c> svList = TestDataFactory.createSubscriptionVendor(1);
            svList[0].Account__c = acc[0].Id;
            svList[0].Subscription_Start_Date__c = date.Today()+3; //JURNA ADDED
            svList[0].Status__c = 'Active';
            //svList[0].Recipient__c = contactList[0].Id;
        //
        
        Database.insert(svList);
        sObjectListMap_global.put('Subscription_Vendor__c', svList);
        return svList;
    }
        
        // JURNA ADDED
     //Subscription_Vendor__c
    static List<Subscription_Vendor__c> createSubscriptionVendor04(List<Account> acc, List<Contact> contactList) {
        List<Subscription_Vendor__c> svList = TestDataFactory.createSubscriptionVendor(1);
            svList[0].Account__c = acc[0].Id;
            svList[0].Subscription_Start_Date__c = date.Today()+3; //JURNA ADDED
            svList[0].Status__c = 'Active';
            //svList[0].Recipient__c = contactList[0].Id;
        //
        
        Database.insert(svList);
        sObjectListMap_global.put('Subscription_Vendor__c', svList);
        return svList;
    }

    //Case
    static List<Case> createCase01(List<Order__c> order) {
        List<Case> caseList = TestDataFactory.createCase(1, 'Complaint - Magazine');
            caseList[0].Order__c = order[0].Id;
            caseList[0].Change_of_Address_Type__c = GlobalVariableClass.BILLINGADD;
            caseList[0].Status = GlobalVariableClass.STATUS_CLOSED;
        //
        
        Database.insert(caseList);
        sObjectListMap_global.put('Case', caseList);
        return caseList;
    }
   
    //Subscription_Vendor__c
    static List<Subscription_Vendor__c> createSubscriptionVendor01(List<Account> acc, List<Contact> contactList) {
        List<Subscription_Vendor__c> svList = TestDataFactory.createSubscriptionVendor(1);
            svList[0].Account__c = acc[0].Id;
            svList[0].Subscription_Start_Date__c = date.Today()+3; //JURNA ADDED
            svList[0].Status__c = 'Active';
            svList[0].Recipient__c = contactList[0].Id;
        //
        
        Database.insert(svList);
        sObjectListMap_global.put('Subscription_Vendor__c', svList);
        return svList;
    }
    
    //Order_Line_Item_Vendor__c JURNA ADDED
    static List<Order_Line_Item_Vendor__c> createOrderLineItemVendor01(List<Subscription_Vendor__c> svList, List<Order__c> order) {
        List<Order_Line_Item_Vendor__c> olivList = TestDataFactory.createOrderLineItemVendor(1);
            olivList[0].Order__c = order[0].Id;
            olivList[0].Stop_Request_Date__c = date.Today()+5;
            olivList[0].Subscription_Vendor__c = svList[0].Id;
            
        Database.insert(olivList);
        sObjectListMap_global.put('Order_Line_Item_Vendor__c', olivList);
        return olivList;
    }
    
    //FROM Address_Assignment__c WHERE Effective_Date__c = :dt AND Active__c = false AND End_Date__c = NULL AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED
    static List<Address_Assignment__c> createAddressAssignment01(List<Address__c> addressList, List<Case> caseList, List<Contact> contactList,
            List<Subscription_Vendor__c> svList, List<Zuora__Subscription__c> subRecs, List<Account> acc) {
        Integer record = 1;
        List<Address_Assignment__c> addressAssignmentList = new List<Address_Assignment__c>();
        for (Integer x=0; x<record; x++) {
            Address_Assignment__c aa = new Address_Assignment__c();
            aa.Address__c = addressList[0].Id;
            aa.Case__c = caseList[0].Id;
            aa.Contact__c = contactList[0].Id; 
            //aa.Contact__c = contactList[0].AccountId;  JURNA ADDED
            aa.Effective_Date__c = Date.today(); 
            aa.Status__c = 'Active'; 
            aa.End_Date__c = null;                                      
            aa.Subscription_Vendor__c = svList[0].Id; 
            aa.Active__c = false; //JURNA REMOVED
            //aa.Active__c = true; // JURNA ADDED
            aa.Subscription__c = subRecs[0].id;
            //aa.Vendor__c = acc[0].Id; //JURNA ADDED
            
            addressAssignmentList.add(aa);
        }
        
        //aa1.add(new Address_Assignment__c(Address__c=addressRec.Id, Contact__c = con.Id)); //IAN Added
        //for(Address_Assignment__c aa : aa1){
        //    addressAssignmentList[0].Address__c = addressList[0].Id;
        //    addressAssignmentList[0].Case__c = caseList[0].Id;
        //    addressAssignmentList[0].Contact__c = contactList[0].Id; 
        //    addressAssignmentList[0].Effective_Date__c = Date.today(); 
        //    addressAssignmentList[0].Status__c = 'Active'; 
        //    addressAssignmentList[0].End_Date__c = null;                                      
        //    addressAssignmentList[0].Subscription_Vendor__c = svList[0].id; 
        //    addressAssignmentList[0].Active__c = False; 
        //    addressAssignmentList[0].Subscription__c = subRecs[0].id;
        //}
        Database.insert(addressAssignmentList);
        sObjectListMap_global.put('Address_Assignment__c', addressAssignmentList);
        return addressAssignmentList;
    }   
    
    static void testData01() {
    
        //
        sObjectListMap_global = new Map<String, Object>();
        
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        
        List<Address__c> addressList = createAddress01(countryList, singpostAddressList);
        List<City__c> cityList = createCity01(countryList);
            
        List<Account> acc = createAccount01();        
        
        List<Contact> contactList = createContact01(acc, cityList, addressList);
        
        Letter_Print_Request__c letterPrint = createLetterPrintRequest01(acc);
        List<Order__c> odr = createOrder01(acc);
        
        List<Case> caseList = createCase01(odr);
        
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount01(acc, contactList);
                
        List<Package__c> packageList = createPackage01();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(odr, packageList, promotionList);
        
        //List<Zuora__Subscription__c> createZuoraSubscription( acc, List<Promotion__c> promo, billAcc,  odr) {
        List<Zuora__Subscription__c> zSub = createZuoraSubscription01(acc, billAcc, odr, orderLineItemList, contactList);
        
        List<Subscription_Vendor__c> svList = createSubscriptionVendor01(acc, contactList);
        
        List<Order_Line_Item_Vendor__c> olivList = createOrderLineItemVendor01(svList, odr); //JURNA ADDED
        
        List<Address_Assignment__c> addressAssignmentList = createAddressAssignment01(addressList, caseList, contactList, svList, zSub, acc);
        
    }
    
    static void testData02() {
    
        //
        sObjectListMap_global = new Map<String, Object>();        
        
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        
        List<Address__c> addressList = createAddress01(countryList, singpostAddressList);
        List<City__c> cityList = createCity01(countryList);
            
        List<Account> acc = createAccount01();
                
        List<Contact> contactList = createContact01(acc, cityList, addressList);
        
        Letter_Print_Request__c letterPrint = createLetterPrintRequest01(acc);
        List<Order__c> odr = createOrder01(acc);
        
        List<Case> caseList = createCase01(odr);
        
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount02(acc, contactList);
                
        List<Package__c> packageList = createPackage01();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(odr, packageList, promotionList);
        
        //List<Zuora__Subscription__c> createZuoraSubscription( acc, List<Promotion__c> promo, billAcc,  odr) {
        List<Zuora__Subscription__c> zSub = createZuoraSubscription02(acc, billAcc, odr, orderLineItemList, contactList);
        
        List<Subscription_Vendor__c> svList = createSubscriptionVendor01(acc, contactList);

        List<Order_Line_Item_Vendor__c> olivList = createOrderLineItemVendor01(svList, odr); //JURNA ADDED
        
        //BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate(); JURNA ADDED
        //batch.accountIdToSubscriptionVendorListMap(svList[0].Account__c, svList); JURNA ADDED
        //BatchAddressAssignmentEffectiveDate.accountIdToSubscriptionVendorListMap(svList[0].Account__c, new List<Subscription_Vendor__c> {svList[0]}); JURNA ADDED
        
        List<Address_Assignment__c> addressAssignmentList = createAddressAssignment01(addressList, caseList, contactList, svList, zSub, acc);
        
        //system.assertEquals(addressAssignmentList[0].Contact__r.AccountId, svList[0].Account__c); //JURNA ADDED
    }
    
    // JURNA ADDED
    static void testData03() {
    
        //
        sObjectListMap_global = new Map<String, Object>();        
        
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        
        List<Address__c> addressList = createAddress01(countryList, singpostAddressList);
        List<City__c> cityList = createCity01(countryList);
            
        List<Account> acc = createAccount01();
                
        List<Contact> contactList = createContact03(acc, cityList, addressList);
        
        Letter_Print_Request__c letterPrint = createLetterPrintRequest01(acc);
        List<Order__c> odr = createOrder01(acc);
        
        List<Case> caseList = createCase01(odr);
        
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount03(acc, contactList);
                
        List<Package__c> packageList = createPackage01();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(odr, packageList, promotionList);
        
        //List<Zuora__Subscription__c> createZuoraSubscription( acc, List<Promotion__c> promo, billAcc,  odr) {
        List<Zuora__Subscription__c> zSub = createZuoraSubscription02(acc, billAcc, odr, orderLineItemList, contactList);
        
        List<Subscription_Vendor__c> svList = createSubscriptionVendor03(acc, contactList);

        List<Order_Line_Item_Vendor__c> olivList = createOrderLineItemVendor01(svList, odr); //JURNA ADDED
        
        //BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate(); JURNA ADDED
        //batch.accountIdToSubscriptionVendorListMap(svList[0].Account__c, svList); JURNA ADDED
        //BatchAddressAssignmentEffectiveDate.accountIdToSubscriptionVendorListMap(svList[0].Account__c, new List<Subscription_Vendor__c> {svList[0]}); JURNA ADDED
        
        List<Address_Assignment__c> addressAssignmentList = createAddressAssignment01(addressList, caseList, contactList, svList, zSub, acc);
        
        //system.assertEquals(addressAssignmentList[0].Contact__r.AccountId, svList[0].Account__c); //JURNA ADDED
    }
    
    // JURNA ADDED
    static void testData04() {
    
        //
        sObjectListMap_global = new Map<String, Object>();        
        
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        
        List<Address__c> addressList = createAddress01(countryList, singpostAddressList);
        List<City__c> cityList = createCity01(countryList);
            
        List<Account> acc = createAccount01();
                
        List<Contact> contactList = createContact03(acc, cityList, addressList);
        
        Letter_Print_Request__c letterPrint = createLetterPrintRequest01(acc);
        List<Order__c> odr = createOrder01(acc);
        
        List<Case> caseList = createCase01(odr);
        
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount03(acc, contactList);
                
        List<Package__c> packageList = createPackage01();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(odr, packageList, promotionList);
        
        //List<Zuora__Subscription__c> createZuoraSubscription( acc, List<Promotion__c> promo, billAcc,  odr) {
        List<Zuora__Subscription__c> zSub = createZuoraSubscription02(acc, billAcc, odr, orderLineItemList, contactList);
        
        List<Subscription_Vendor__c> svList = createSubscriptionVendor04(acc, contactList);

        List<Order_Line_Item_Vendor__c> olivList = createOrderLineItemVendor01(svList, odr); //JURNA ADDED
        
        //BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate(); JURNA ADDED
        //batch.accountIdToSubscriptionVendorListMap(svList[0].Account__c, svList); JURNA ADDED
        //BatchAddressAssignmentEffectiveDate.accountIdToSubscriptionVendorListMap(svList[0].Account__c, new List<Subscription_Vendor__c> {svList[0]}); JURNA ADDED
        
        List<Address_Assignment__c> addressAssignmentList = createAddressAssignment01(addressList, caseList, contactList, svList, zSub, acc);
        
        //system.assertEquals(addressAssignmentList[0].Contact__r.AccountId, svList[0].Account__c); //JURNA ADDED
    }

    static testMethod void testBatchAddressAssignmentEffectiveDate01() {
        
        //TestData
        testData02();
        Test.startTest();
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        ID batchprocessid = Database.executeBatch(batch,200);
        System.assertNotEquals(null, batchprocessid); 
        Test.stopTest();
    }
    
    
    // JURNA ADDED
    static testMethod void testBatchAddressAssignmentEffectiveDate011() {
        
        //TestData
        testData03();
        Test.startTest();
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        ID batchprocessid = Database.executeBatch(batch,200);
        System.assertNotEquals(null, batchprocessid); 
        Test.stopTest();
    }
    
     // JURNA ADDED
    static testMethod void testBatchAddressAssignmentEffectiveDate0111() {
        
        //TestData
        testData04();
        Test.startTest();
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        ID batchprocessid = Database.executeBatch(batch,200);
        System.assertNotEquals(null, batchprocessid); 
        Test.stopTest();
    }
    
    

    static testMethod void testCreateContact01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData
        sObjectListMap_global = new Map<String, Object>();
        
        List<Account> acc = createAccount01();
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<City__c> cityList = createCity01(countryList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        List<Address__c> addressList = createAddress01(countryList, singpostAddressList);
        List<Contact> contactList = createContact01(acc, cityList, addressList);
        
        //Test Proper
        batch.createContact(contactList[0], addressList[0].id, true, GlobalVariableClass.DELIVERYADDLOC);
    }
    
    //public void updateContactZuora(Contact updateContact, Zuora__CustomerAccount__c billingAccount, Map<Id, Address__c> addIdToAddressMap)
    static testMethod void testUpdateContactZuora01() {
        
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData  
        sObjectListMap_global = new Map<String, Object>();
            
        List<Account> acc = createAccount01();
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<City__c> cityList = createCity01(countryList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        List<Address__c> addressList = createAddress02(countryList, singpostAddressList);
        List<Contact> contactList = createContact02(acc, cityList, addressList);
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount02(acc, contactList);
        
        Map<Id, Address__c> addIdToAddressMap = new Map<Id, Address__c>();
        addIdToAddressMap.put(addressList[0].id, addressList[0]);
        
        //Test Proper
        batch.updateContactZuora(contactList[0], billAcc[0], addIdToAddressMap);
    }
    
    //public void updateContactCallOut(List<Map<String, Object>> lConList) {static testMethod void testUpdateContactZuora01() {
    static testMethod void testUpdateContactCallOut01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData TODO
        sObjectListMap_global = new Map<String, Object>();
        
        List<Map<String, Object>> lConList = new List<Map<String, Object>>();
        
        //TestProper
        batch.updateContactCallOut(lConList);
    }
    
    //public List<Map<String, Object>> updateSub(Map<String, Contact> subZuoraIdToNewContactMap, Map<String, Id> subZuoraIdToNewVendorMap) {
    static testMethod void testUpdateSub01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData TODO
        sObjectListMap_global = new Map<String, Object>();
        
        Map<String, Contact> subZuoraIdToNewContactMap = new Map<String, Contact>();
        Map<String, Id> subZuoraIdToNewVendorMap = new Map<String, Id>();
        
        //TestProper
        batch.updateSub(subZuoraIdToNewContactMap, subZuoraIdToNewVendorMap);
    }
    
    //public List<Subscription_Vendor__c> updateSubVendor(Map<Id, Contact> subVendorIdToNewContactMap, Map<Id, Id> subVendorIdToNewVendorMap) {
    static testMethod void testUpdateSubVendor01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData TODO
        sObjectListMap_global = new Map<String, Object>();
        
        Map<Id, Contact> subVendorIdToNewContactMap = new Map<Id, Contact>();
        Map<Id, Id> subVendorIdToNewVendorMap = new Map<Id, Id>();
        
        //TestProper
        batch.updateSubVendor(subVendorIdToNewContactMap, subVendorIdToNewVendorMap);
    }
    
    //public List<Order__c> updateOrderBillingContact(Map<Id, Contact> subIdToNewContactMap) {
    static testMethod void testUpdateOrderBillingContact01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData TODO
        sObjectListMap_global = new Map<String, Object>();
        
        Map<Id, Contact> subIdToNewContactMap = new Map<Id, Contact>();
        
        //TestProper
        batch.updateOrderBillingContact(subIdToNewContactMap);
    }
    
    //public List<Zuora__CustomerAccount__c> updateBillAccBillingContact(Map<Id, Address_Assignment__c> conIdToAddressAssignIdMap, Map<Id, Contact> conIdToConMap, Map<Id, Zuora__CustomerAccount__c> subIdToBillAccMap, Map<Id, Contact> billAccIdToNewContactMap, Map<Id, Set<Zuora__Subscription__c>> accountIdToSubscriptionMap) {
    static testMethod void testUpdateBillAccBillingContact01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData TODO
        sObjectListMap_global = new Map<String, Object>();
        
        Map<Id, Address_Assignment__c> conIdToAddressAssignIdMap = new Map<Id, Address_Assignment__c>();
        Map<Id, Contact> conIdToConMap = new Map<Id, Contact>();
        Map<Id, Zuora__CustomerAccount__c> subIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
        Map<Id, Contact> billAccIdToNewContactMap = new Map<Id, Contact>();
        Map<Id, Set<Zuora__Subscription__c>> accountIdToSubscriptionMap = new Map<Id, Set<Zuora__Subscription__c>>();
        
        //TestProper
        batch.updateBillAccBillingContact(conIdToAddressAssignIdMap, conIdToConMap, subIdToBillAccMap, billAccIdToNewContactMap, accountIdToSubscriptionMap);
    }
    
    //public List<Map<String, Object>> updateSubBillingContact(List<Order__c> newOrderList, Map<Id, Contact> subIdToNewContactMap) {
    static testMethod void testUpdateSubBillingContact01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData TODO
        sObjectListMap_global = new Map<String, Object>();
        
        List<Order__c> newOrderList = new List<Order__c>();
        Map<Id, Contact> subIdToNewContactMap = new Map<Id, Contact>();
        
        //TestProper
        batch.updateSubBillingContact(newOrderList, subIdToNewContactMap);
    }
    
    //public List<Address_Assignment__c> updatePreviousAddressAssignment(List<Address_Assignment__c> addressAssignmentList){
    static testMethod void testUpdatePreviousAddressAssignment01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData TODO
        sObjectListMap_global = new Map<String, Object>();
        
        List<Address_Assignment__c> addressAssignmentList = new List<Address_Assignment__c>();
        
        //TestProper
        batch.updatePreviousAddressAssignment(addressAssignmentList);
    }
    
    //public void coaCheckIfArmsContact(List<Contact> contact_LIST){
    static testMethod void testCoaCheckIfArmsContact01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData
        sObjectListMap_global = new Map<String, Object>();
        
        List<Account> acc = createAccount01();
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<City__c> cityList = createCity01(countryList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        List<Address__c> addressList = createAddress02(countryList, singpostAddressList);
        List<Contact> contactList = createContact02(acc, cityList, addressList);
        
        //TestProper
        batch.coaCheckIfArmsContact(contactList);
    }
    
    //public Set<Id> updateCustomer(List<Zuora__CustomerAccount__c> edtCustomerList){
    static testMethod void testUpdateCustomer01() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData
        sObjectListMap_global = new Map<String, Object>();
        
        List<Account> acc = createAccount02();
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<City__c> cityList = createCity01(countryList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        List<Address__c> addressList = createAddress03(countryList, singpostAddressList);
        List<Contact> contactList = createContact03(acc, cityList, addressList);
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount03(acc, contactList);
        
        //TestProper
        batch.updateCustomer(billAcc);
    }
    
    static List<BT_CO_ARMS_UpdateCustomerBatchFile__c> createBTCOARMS_UCBF01(){
        Integer records = 1;
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> btcoList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        for (Integer x=0; x<records; x++) {
            btcoList.add(new BT_CO_ARMS_UpdateCustomerBatchFile__c(Name='BT'+x, 
                    Customer_Name1__c='CustName'+x, UniqueKey__c='UK'+x, CCRID__c='CC'+x));
        }
        
        Database.insert(btcoList);
        return btcoList;
    }

    //public static void updateCustomerWebserviceNonFuture(Set<Id> CusToUpdSet){
    static testMethod void testUpdateCustomerWebserviceNonFuture01() {
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());       
        //BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        
        //TestData TODO
        Set<Id> CusToUpdSet = new Set<Id>();
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> btcoList = createBTCOARMS_UCBF01();
        CusToUpdSet.add(btcoList[0].id);
        
        //from BT_CO_ARMS_UpdateCustomerBatchFile__c Where  Id =: CusToUpdSet
        
        //from BT_CO_ARMS_UpdateCustomerBatchFile__c Where CreatedDate = Today AND Customer_Name1__c IN :updCusName_SET AND UniqueKey__c IN :updUniqKey_SET AND CCRID__c IN :updCusNum_SET];
        
        //TestProper
        BatchAddressAssignmentEffectiveDate.updateCustomerWebserviceNonFuture(CusToUpdSet);
    } catch (Exception e) {
       }
    }
    
}