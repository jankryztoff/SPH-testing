/** * Class Name: AcknowledgmentLetterEmailTest      
* @author: Accenture AprilVeloso     * Date: July 06, 2015   
* Requirement/Project Name: SPH Project     
* @description Test Class for AcknowledgmentLetterEmail
     
*/

@isTest //jurna-10-23-15
public class AcknowledgmentLetterEmailTest{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createMASS_CONFIG();
        insert CustomSettingsDataFactory.createBillingBatch();
    }
    
    //Holds all testdata values
    static Map<String, Object> sObjectListMap_global;
    
     //Letter_Print_Request__c
    static Letter_Print_Request__c createLetterPrintRequest01(List<Zuora__CustomerAccount__c> billAcc) {
         
        //WHERE Letter_Type__c = 'Acknowledgment_Letter' 
        //AND DTL_Date__c = TODAY 
        //AND (Acknowledgment_Type__c = 'Email' OR Acknowledgment_Type__c = 'Both')
        Letter_Print_Request__c letterPrint = new Letter_Print_Request__c();
        letterPrint.Name = 'Name';
        letterPrint.Letter_Type__c = 'Acknowledgment_Letter'; 
        letterPrint.DTL_Date__c = date.Today(); 
        letterPrint.Acknowledgment_Type__c  = 'Email';
        letterPrint.Record_ID__c = billAcc[0].id;
        letterPrint.Sub_Created_Date__c = system.today()+2;  
        letterPrint.Generation_From__c = system.today();  
        letterPrint.Generation_To__c = system.today()+3;    
        Database.insert(letterPrint);
        
        //sObjectListMap_global.put('Letter_Print_Request__c', letterPrint);
        return letterPrint;
    }
    
    //Account
    static List<Account> createAccount01() {
        //Create account
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual');
            acc[0].Name = 'TEST';
            acc[0].NRIC__c = 'T1234567R';
        //sObjectListMap_global.put('Account',acc);
        Database.insert(acc);
        
        return acc;
    }
    
   
    
    //Singpost Address
    static List<Singpost_Address__c> createPostalCode01() {
        List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(1);
        singpostAddressList[0].Name = '0125';
        singpostAddressList[0].House_Block_Number__c = '010';
        singpostAddressList[0].Street_Name__c = 'Asiatown';
        singpostAddressList[0].Building_Name__c = 'Ebloc2';
        insert singpostAddressList;
        
        //sObjectListMap_global.put('Singpost_Address__c', singpostAddressList);
        return singpostAddressList;
    }
    static SPH_Section__c createSection (){
        SPH_Section__c sect = new SPH_Section__c();
        sect.Section_Name__c = 'Section1';
        insert sect ;
        //sObjectListMap_global.put('SPH_Section', sect);
        return sect ;
    }
     static SPH_Department__c createDepartment (){
        SPH_Department__c dept = new SPH_Department__c();
        dept.Department_Name__c = 'Billing';
        insert dept;
        //sObjectListMap_global.put('SPH_Department', dept);
        return dept;
    }
    static SPH_Division__c createDivision (){
        SPH_Division__c divi = new SPH_Division__c();
        divi.Name = 'Division1';
        insert divi;
        //sObjectListMap_global.put('SPH_Division', divi);
        return divi;
    }
    static SPH_Company__c createCompany (){
        SPH_Company__c comp = new SPH_Company__c();
        comp.Company_Name__c= 'Accenture';
        insert comp ;
        //sObjectListMap_global.put('SPH_Company', comp );
        return comp ;
    }
     static SPH_Location__c createLocation (){
        SPH_Location__c loc = new SPH_Location__c();
        loc.Location_Name__c = 'Cebu';
        insert loc;
        //sObjectListMap_global.put('SPH_Location', loc);
        return loc;
    } 
    //   
    //Address
    static List<Address__c> createAddress01(List<Country__c> countryList, List<Singpost_Address__c> singpostAddressList, SPH_Section__c sect, SPH_Department__c dept, SPH_Division__c divi, SPH_Company__c comp,
                                             SPH_Location__c loc, List<City__c> cityList, Packing_Grp__c packGroup ) {
        List<Address__c> addressList = TestDataFactory.createAddress(6);
        RecordType recordType = [SELECT ID, DeveloperName FROM RecordType WHERE  DeveloperName ='Overseas' LIMIT 1];
        addressList[0].RecordTypeid = recordType.id;
        addressList[0].Level_Number__c = '10';
        addressList[0].Unit_Number__c = '10';
        addressList[0].Country__c = countryList[0].id;
        addressList[0].Postal_Code__c = singpostAddressList[0].id;
        addressList[0].Address_1__c = 'Asiatown';
        addressList[0].Address_2__c = 'Ebloc2';
        addressList[0].Address_3__c = 'IT Park';
        addressList[0].Address_4__c = 'Lahug';
    //
       
        RecordType recordType1 = [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName ='Internal' LIMIT 1];
        addressList[1].RecordTypeid = recordType1.id;
        addressList[1].Level_Number__c = '10';
        addressList[1].Unit_Number__c = '10';
        addressList[1].Country__c = countryList[0].id;
        addressList[1].Postal_Code__c = singpostAddressList[0].id;
        addressList[1].Section_Code__c = sect.id;
        addressList[1].Department__c = dept.id;    
        addressList[1].Division_Code__c = divi.id;
        addressList[1].Company_Code__c = comp.id;
        addressList[1].Location_Code__c = loc.id;
    //    
        RecordType recordType2 = [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName ='Airline' LIMIT 1];
        addressList[2].RecordTypeid = recordType2.id;
        addressList[2].Level_Number__c = '10';
        addressList[2].Unit_Number__c = '10';
        addressList[2].Country__c = countryList[0].id;
        addressList[2].Postal_Code__c = singpostAddressList[0].id;
        addressList[2].City__c = cityList[0].id;
        addressList[2].Packing_Code__c = packGroup.id;
    //    
        RecordType recordType3 = [SELECT ID, DeveloperName  FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName ='Airline' LIMIT 1];
        addressList[3].RecordTypeID = recordType3.id;
        addressList[3].Level_Number__c = '10';
        addressList[3].Unit_Number__c = '10';
        addressList[3].Country__c = countryList[0].id;
        addressList[3].Postal_Code__c = singpostAddressList[0].id;
        
       RecordType recordType4 = [SELECT ID, DeveloperName FROM RecordType WHERE DeveloperName ='Local' LIMIT 1];
        addressList[4].RecordTypeId = recordType4.id;
        addressList[4].Level_Number__c = '10';
        addressList[4].Unit_Number__c = '10';
        addressList[4].Country__c = countryList[0].id;
        addressList[4].Postal_Code__c = singpostAddressList[0].id;
        insert addressList;
        //sObjectListMap_global.put('Address__c', addressList);
        
         RecordType recordType5 = [SELECT ID, DeveloperName FROM RecordType WHERE  DeveloperName ='Overseas' LIMIT 1];
        addressList[5].RecordTypeid = recordType5.id;
        addressList[5].Level_Number__c = '10';
        addressList[5].Unit_Number__c = '10';
        addressList[5].Country__c = countryList[0].id;
        addressList[5].Postal_Code__c = singpostAddressList[0].id;
        addressList[5].Address_1__c = 'Asiatown';
        addressList[5].Address_2__c = 'Ebloc2';
        addressList[5].Address_3__c = 'IT Park';
        addressList[5].Address_4__c = 'Lahug';
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
        //sObjectListMap_global.put('Zone__c', zoneList);
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
        //sObjectListMap_global.put('Country__c', countryList);
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
            obj.Flight_Number_2__c = 'FlightNumber 2';
            obj.City_Name__c = 'Cebu';
            count++;
        }
        insert cityList;
        //sObjectListMap_global.put('City__c', cityList);
        return cityList;
    }
    
    //Billing Contact
    static List<Contact> createContact01(List<Account> acc, List<City__c> cityList, List<Address__c> addressList) {
        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(10);
        //for (Contact obj : contactList) {
            contactList[0].Account = acc[0];
            contactList[0].City_Code__c = cityList[0].id;
            contactList[0].Address__c = addressList[0].id;
            contactList[0].Email__c = 'a@a.com';
            contactList[0].Email_Secondary__c = 'a@a.com';
        //}   \
            contactList[1].Account = acc[0];
            contactList[1].City_Code__c = cityList[0].id;
            contactList[1].Address__c = addressList[1].id;
            contactList[1].Email__c = null;
            //contactList[1].Email__c = 'a@a.com';
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
      //  } 
            contactList[4].Account = acc[0];
            contactList[4].City_Code__c = cityList[0].id;
            contactList[4].Address__c = addressList[4].id;
            contactList[4].Email__c = 'a@a.com';  
       //  } 
            contactList[5].Account = acc[0];
            contactList[5].City_Code__c = cityList[0].id;
            contactList[5].Address__c = addressList[5].id;
            contactList[5].Email__c = 'a@a.com';    
            
       //  } 
            contactList[6].Account = acc[0];
            contactList[6].City_Code__c = cityList[0].id;
            contactList[6].Address__c = addressList[1].id;
            contactList[6].Email__c = 'a@a.com';     
       //  } 
            contactList[7].Account = acc[0];
            contactList[7].City_Code__c = cityList[0].id;
            contactList[7].Address__c = addressList[2].id;
            contactList[7].Email__c = 'a@a.com';   
       //  } 
            contactList[8].Account = acc[0];
            contactList[8].City_Code__c = cityList[0].id;
            contactList[8].Address__c = addressList[3].id;
            contactList[8].Email__c = 'a@a.com';  
       //  } 
            contactList[9].Account = acc[0];
            contactList[9].City_Code__c = cityList[0].id;
            contactList[9].Address__c = addressList[4].id;
            contactList[9].Email__c = 'a@a.com';  
        insert contactList; 
        //sObjectListMap_global.put('Contact', contactList);
        return contactList;
    }
    
    //Billing Contact
    static List<Contact> createContact02(List<Account> acc, List<City__c> cityList, List<Address__c> addressList) {
        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(10);
        //for (Contact obj : contactList) {
            contactList[0].Account = acc[0];
            contactList[0].City_Code__c = cityList[0].id;
            contactList[0].Address__c = addressList[0].id;
            contactList[0].Email__c = null;
            //contactList[0].Email__c = 'a@a.com';
            contactList[0].Email_Secondary__c = 'a@a.com';
        //}   \
            contactList[1].Account = acc[0];
            contactList[1].City_Code__c = cityList[0].id;
            contactList[1].Address__c = addressList[1].id;
            contactList[1].Email__c = null;
            contactList[1].Email_Secondary__c = 'a@a.com';
            //contactList[1].Email__c = 'a@a.com';
            
        //}   \
            contactList[2].Account = acc[0];
            contactList[2].City_Code__c = cityList[0].id;
            contactList[2].Address__c = addressList[2].id;
            //contactList[2].Email__c = 'a@a.com';
            contactList[2].Email__c = null;
            contactList[2].Email_Secondary__c = 'a@a.com';
        //}   \
            contactList[3].Account = acc[0];
            contactList[3].City_Code__c = cityList[0].id;
            contactList[3].Address__c = addressList[3].id;
            contactList[3].Email__c = null;
            //contactList[3].Email__c = 'a@a.com';
            contactList[3].Email_Secondary__c = 'a@a.com';
      //  } 
            contactList[4].Account = acc[0];
            contactList[4].City_Code__c = cityList[0].id;
            contactList[4].Address__c = addressList[4].id;
            //contactList[4].Email__c = 'a@a.com'; 
            contactList[4].Email__c = null; 
            contactList[4].Email_Secondary__c = 'a@a.com';
       //  } 
            contactList[5].Account = acc[0];
            contactList[5].City_Code__c = cityList[0].id;
            contactList[5].Address__c = addressList[5].id;
           // contactList[5].Email__c = 'a@a.com';  
            contactList[5].Email__c = null;  
            contactList[5].Email_Secondary__c = 'a@a.com';
            
       //  } 
            contactList[6].Account = acc[0];
            contactList[6].City_Code__c = cityList[0].id;
            contactList[6].Address__c = addressList[1].id;
            //contactList[6].Email__c = 'a@a.com';
            contactList[6].Email__c = null;  
            contactList[6].Email_Secondary__c = 'a@a.com';   
       //  } 
            contactList[7].Account = acc[0];
            contactList[7].City_Code__c = cityList[0].id;
            contactList[7].Address__c = addressList[2].id;
            //contactList[7].Email__c = 'a@a.com';
            contactList[7].Email__c = null; 
            contactList[7].Email_Secondary__c = 'a@a.com';  
       //  } 
            contactList[8].Account = acc[0];
            contactList[8].City_Code__c = cityList[0].id;
            contactList[8].Address__c = addressList[3].id;
            //contactList[8].Email__c = 'a@a.com';  
            contactList[8].Email__c = null;
            contactList[8].Email_Secondary__c = 'a@a.com';
       //  } 
            contactList[9].Account = acc[0];
            contactList[9].City_Code__c = cityList[0].id;
            contactList[9].Address__c = addressList[4].id;
            //contactList[9].Email__c = 'a@a.com';
            contactList[9].Email__c = null;  
            contactList[9].Email_Secondary__c = 'a@a.com';
        insert contactList; 
        //sObjectListMap_global.put('Contact', contactList);
        return contactList;
    }
    
    //Zuora__CustomerAccount__c
    //Billing Account
    static List<Zuora__CustomerAccount__c> createZuoraCustomerAccount01(List<Account> acc, List<Contact> contactList) {
        //Create zoura customer account
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(6);
            billAcc[0].Zuora__Account__c = acc[0].Id;
            billAcc[0].Billing_Type__c = 'Full Prepaid';
            billAcc[0].Billing_Contact__c = contactList[0].id;
            billAcc[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            
       //     
            billAcc[1].Zuora__Account__c = acc[0].Id;
           // billAcc[1].Billing_Type__c = 'Full Prepaid';
            billAcc[1].Billing_Type__c = 'Recurring Prepaid'; //jurna
            billAcc[1].Billing_Contact__c = contactList[1].id;
            billAcc[1].Zuora__Credit_Balance__c = 50000.00;
            billAcc[1].Zuora__DefaultPaymentMethod__c = 'Credit Card';
       //     
            billAcc[2].Zuora__Account__c = acc[0].Id;
            //billAcc[2].Billing_Type__c = 'Full Prepaid';
            billAcc[2].Billing_Type__c = 'Recurring Postpaid';
            billAcc[2].Billing_Contact__c = contactList[2].id;
            billAcc[2].Zuora__Credit_Balance__c = 50000.00;
            billAcc[2].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
       //     
            billAcc[3].Zuora__Account__c = acc[0].Id;
            billAcc[3].Billing_Type__c = 'Full Prepaid';
            billAcc[3].Billing_Contact__c = contactList[3].id;
            billAcc[3].Zuora__Credit_Balance__c = 50000.00;
            billAcc[3].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            
            billAcc[4].Zuora__Account__c = acc[0].Id;
            billAcc[4].Billing_Type__c = 'Full Prepaid';
            billAcc[4].Billing_Contact__c = contactList[4].id;
            billAcc[4].Zuora__Credit_Balance__c = 50000.00;
            billAcc[4].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            
            billAcc[5].Zuora__Account__c = acc[0].Id;
            billAcc[5].Billing_Type__c = 'Full Prepaid';
            billAcc[5].Billing_Contact__c = contactList[5].id;
            billAcc[5].Zuora__Credit_Balance__c = 50000.00;
            billAcc[5].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
        //sObjectListMap_global.put('Zuora__CustomerAccount__c', billAcc);
        Database.insert(billAcc);
        return billAcc;
    }
    
    //APRIL
    static List<Zuora__CustomerAccount__c> createZuoraCustomerAccount02(List<Account> acc, List<Contact> contactList) {
        //Create zoura customer account
        List<Zuora__CustomerAccount__c> billAcc2 = TestDataFactory.createBillingAccount(6);
            billAcc2[0].Zuora__Account__c = acc[0].Id;    
            billAcc2[0].Billing_Type__c = 'Recurring Prepaid';
            billAcc2[0].Billing_Contact__c = contactList[0].id;
            billAcc2[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[0].Zuora__DefaultPaymentMethod__c = 'Recurring Prepaid';
            
       //     
            billAcc2[1].Zuora__Account__c = acc[0].Id;
            billAcc2[1].Billing_Type__c = 'Recurring Prepaid';
            billAcc2[1].Billing_Contact__c = contactList[1].id;
            billAcc2[1].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[1].Zuora__DefaultPaymentMethod__c = 'Recurring Prepaid';
       //     
            billAcc2[2].Zuora__Account__c = acc[0].Id;
            billAcc2[2].Billing_Type__c = 'Recurring Prepaid';
            billAcc2[2].Billing_Contact__c = contactList[2].id;
            billAcc2[2].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[2].Zuora__DefaultPaymentMethod__c = 'Recurring Prepaid';
       //     
            billAcc2[3].Zuora__Account__c = acc[0].Id;
            billAcc2[3].Billing_Type__c = 'Recurring Prepaid';
            billAcc2[3].Billing_Contact__c = contactList[3].id;
            billAcc2[3].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[3].Zuora__DefaultPaymentMethod__c = 'Recurring Prepaid';
            
            billAcc2[4].Zuora__Account__c = acc[0].Id;
            billAcc2[4].Billing_Type__c = 'Recurring Prepaid';
            billAcc2[4].Billing_Contact__c = contactList[4].id;
            billAcc2[4].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[4].Zuora__DefaultPaymentMethod__c = 'Recurring Prepaid';
            
            billAcc2[5].Zuora__Account__c = acc[0].Id;
            billAcc2[5].Billing_Type__c = 'Recurring Prepaid';
            billAcc2[5].Billing_Contact__c = contactList[5].id;
            billAcc2[5].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[5].Zuora__DefaultPaymentMethod__c = 'Recurring Prepaid';

        //sObjectListMap_global.put('Zuora__CustomerAccount__c', billAcc2);
        Database.insert(billAcc2);
        return billAcc2;
    } 
    
    //APRIL
    static List<Zuora__CustomerAccount__c> createZuoraCustomerAccount03(List<Account> acc, List<Contact> contactList) {
        //Create zoura customer account
        List<Zuora__CustomerAccount__c> billAcc2 = TestDataFactory.createBillingAccount(6);
            billAcc2[0].Zuora__Account__c = acc[0].Id;    
            billAcc2[0].Billing_Type__c = 'Recurring Postpaid';
            billAcc2[0].Billing_Contact__c = contactList[0].id;
            billAcc2[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[0].Zuora__DefaultPaymentMethod__c = 'Recurring Postpaid';
            
       //     
            billAcc2[1].Zuora__Account__c = acc[0].Id;
            billAcc2[1].Billing_Type__c = 'Recurring Postpaid';
            billAcc2[1].Billing_Contact__c = contactList[1].id;
            billAcc2[1].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[1].Zuora__DefaultPaymentMethod__c = 'Recurring Postpaid';
       //     
            billAcc2[2].Zuora__Account__c = acc[0].Id;
            billAcc2[2].Billing_Type__c = 'Recurring Postpaid';
            billAcc2[2].Billing_Contact__c = contactList[2].id;
            billAcc2[2].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[2].Zuora__DefaultPaymentMethod__c = 'Recurring Postpaid';
       //     
            billAcc2[3].Zuora__Account__c = acc[0].Id;
            billAcc2[3].Billing_Type__c = 'Recurring Postpaid';
            billAcc2[3].Billing_Contact__c = contactList[3].id;
            billAcc2[3].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[3].Zuora__DefaultPaymentMethod__c = 'Recurring Postpaid';
            
            billAcc2[4].Zuora__Account__c = acc[0].Id;
            billAcc2[4].Billing_Type__c = 'Recurring Postpaid';
            billAcc2[4].Billing_Contact__c = contactList[4].id;
            billAcc2[4].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[4].Zuora__DefaultPaymentMethod__c = 'Recurring Prepaid';
            
            billAcc2[5].Zuora__Account__c = acc[0].Id;
            billAcc2[5].Billing_Type__c = 'Recurring Postpaid';
            billAcc2[5].Billing_Contact__c = contactList[5].id;
            billAcc2[5].Zuora__Credit_Balance__c = 50000.00;
            billAcc2[5].Zuora__DefaultPaymentMethod__c = 'Recurring Prepaid';

        //sObjectListMap_global.put('Zuora__CustomerAccount__c', billAcc2);
        Database.insert(billAcc2);
        return billAcc2;
    }
     
    //Order__c
    static List<Order__c> createOrder01(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc) {
        //Create order
        //WHERE Account__c IN: accountIdSet AND DTL_Date__c = TODAY]
        List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c = acc[0].Id;
            odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c = 'Full Prepaid';
            odr[0].DTL_Date__c = Date.today();
            odr[0].Other_Payment_Mode__c = 'Invoice';
        //sObjectListMap_global.put('Order__c', odr);
        Database.insert(odr);
        return odr;
    }
    
    //Order__c
    static List<Order__c> createOrder02(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc) {
        //Create order
        //WHERE Account__c IN: accountIdSet AND DTL_Date__c = TODAY]
        List<Order__c> odr2 = TestDataFactory.createOrder(1);
            odr2[0].Account__c = acc[0].Id;
            odr2[0].Billing_Account__c = billAcc[0].Id;
            odr2[0].Billing_Type__c = 'Recurring Prepaid';
            odr2[0].DTL_Date__c = Date.today();
            odr2[0].Other_Payment_Mode__c = 'Recurring Prepaid';
        //sObjectListMap_global.put('Order__c', odr);
        Database.insert(odr2);
        return odr2;
    }
    
     //Order__c
    static List<Order__c> createOrder03(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc) {
        //Create order
        //WHERE Account__c IN: accountIdSet AND DTL_Date__c = TODAY]
        List<Order__c> odr2 = TestDataFactory.createOrder(1);
            odr2[0].Account__c = acc[0].Id;
            odr2[0].Billing_Account__c = billAcc[0].Id;
            odr2[0].Billing_Type__c = 'Recurring Postpaid';
            odr2[0].DTL_Date__c = Date.today();
            odr2[0].Other_Payment_Mode__c = 'Recurring Postpaid';
        //sObjectListMap_global.put('Order__c', odr);
        Database.insert(odr2);
        return odr2;
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
            packageList[0].Billing_Type__c = 'Recurring Prepaid';  
       //   
            packageList[1].Package_Type__c = 'Add On';
            packageList[1].Package_Sub_Type__c = 'Single';
            packageList[1].Package_Price__c = 10;
            packageList[1].Subscription_Period__c = '15';   
            packageList[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[1].Billing_Type__c = 'Full Prepaid';  
        //}
        insert packageList;
        //sObjectListMap_global.put('Package__c', packageList);
        return packageList;
    }
    
    //Package
    static List<Package__c> createPackage02() {
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
            packageList[0].Billing_Type__c = 'Recurring Prepaid';  
       //   
            packageList[1].Package_Type__c = 'Add On';
            packageList[1].Package_Sub_Type__c = 'Single';
            packageList[1].Package_Price__c = 10;
            packageList[1].Subscription_Period__c = '15';   
            packageList[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[1].Billing_Type__c = 'Recurring Prepaid';  
        //}
        insert packageList;
        //sObjectListMap_global.put('Package__c', packageList);
        return packageList;
    }
    
    //Package
    static List<Package__c> createPackage03() {
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
            packageList[0].Billing_Type__c = 'Recurring Postpaid';  
       //   
            packageList[1].Package_Type__c = 'Add On';
            packageList[1].Package_Sub_Type__c = 'Single';
            packageList[1].Package_Price__c = 10;
            packageList[1].Subscription_Period__c = '15';   
            packageList[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Default'; 
            packageList[1].Billing_Type__c = 'Recurring Postpaid';  
        //}
        insert packageList;
        //sObjectListMap_global.put('Package__c', packageList);
        return packageList;
    }
    
    static Packing_Grp__c createPackingGroup() {
        Packing_Grp__c packGroup = new Packing_Grp__c ();
        packGroup.Airline__c = 'Group1';
        insert packGroup ;
        //sObjectListMap_global.put('Packing_Grp', packGroup);
        return packGroup ;
    }
    static Case createCase(List<Account> acc) {
        Case caseRec = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        caseRec.AccountId = acc[0].id;
        caseRec.Status = 'Closed';
        caseRec.RecordtypeId =/* [SELECT Id FROM RecordType WHERE sObjectType = 'Case__c' AND Name = 'Case Stop'].id;*/ConstantsSLB.getKeyId('Case_Stop'); //jurna-10-23-15
        caseRec.Sub_Status__c = 'Ready for Submission';
         
        insert caseRec ;
        //sObjectListMap_global.put('Case', caseRec);
        return caseRec ;
    }
    
    static Case createCase02(List<Account> acc, List<Zuora__Subscription__c> zSub) {
        Case caseRec = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        caseRec.AccountId = acc[0].id;
        caseRec.Account__c = acc[0].id;
        caseRec.Subscription_Name__c = zSub[0].id;
        caseRec.Status = 'Closed';
        //caseRec.RecordtypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case__c' AND Name = 'Case Stop'].id;//ConstantsSLB.getKeyId('Case_Stop'); //jurna-10-23-15
        caseRec.Sub_Status__c = 'Ready for Submission';
        insert caseRec ;
        //sObjectListMap_global.put('Case', caseRec);
        return caseRec ;
    }
    
    static List<Case_Subscription__c> createCaseSubscription(List<Account> acc, List<Address__c> addressList, List<Zuora__Subscription__c> zSub, Case caseRec) {
        
        List<Case_Subscription__c>  caseSubList = TestDataFactory.createCaseSubscription(2);
        
        caseSubList[0].Account__c = acc[0].id;
        caseSubList[0].Address__c = addressList[0].id;
        caseSubList[0].isComplaint__c = false;
        caseSubList[0].Subscription__c = zSub[0].id;
        caseSubList[0].Case__c = caseRec.id;
        
        caseSubList[1].Account__c = acc[0].id;
        caseSubList[1].Address__c = addressList[1].id;
        caseSubList[1].isComplaint__c = false;
        caseSubList[1].Subscription__c = zSub[1].id;
        caseSubList[1].Case__c = caseRec.id;
        Test.startTest();
        insert caseSubList ;
        //sObjectListMap_global.put('Case_Subscription', caseSubList );
        return caseSubList ;
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
        //sObjectListMap_global.put('Promotion__c', promotionList);
        return promotionList;
    }
    //(sub.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE
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
            orderLineItemList[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
            orderLineItemList[0].Main_Package_Product_Sub_Type__c = 'Magazine';
        //}
            orderLineItemList[1].Order__c = odr[0].id;
            orderLineItemList[1].Main_Package_ID__c = packageList[1].id;            
            orderLineItemList[1].Start_Date__c = Date.today().addDays(10);            
            orderLineItemList[1].Qty__c = 10;
            orderLineItemList[1].Add_On_Package_Subscription_Rate__c = 10;     
            orderLineItemList[1].Addon_Package__c = packageList[1].id;
            orderLineItemList[1].Promotion_ID__c = promotionList[0].id;
            orderLineItemList[1].Main_Package_Product_Family__c = 'Default';
            orderLineItemList[1].Main_Package_Billing_Type__c = 'Full Prepaid';
            orderLineItemList[1].Main_Package_Product_Sub_Type__c = 'Mags';
        insert orderLineItemList;
        //sObjectListMap_global.put('Order_Line_Item__c', orderLineItemList);
        return orderLineItemList;
    }
    
    //Order Line Item
    static List<Order_Line_Item__c> createOrderLineItem02(List<Order__c> odr, List<Package__c> packageList, List<Promotion__c> promotionList) {
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
            orderLineItemList[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
            orderLineItemList[0].Main_Package_Product_Sub_Type__c = 'Magazine';
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
            orderLineItemList[1].Main_Package_Product_Sub_Type__c = 'Mags';
        insert orderLineItemList;
        //sObjectListMap_global.put('Order_Line_Item__c', orderLineItemList);
        return orderLineItemList;
    }
    
    //Order Line Item
    static List<Order_Line_Item__c> createOrderLineItem03(List<Order__c> odr, List<Package__c> packageList, List<Promotion__c> promotionList) {
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
            orderLineItemList[0].Main_Package_Billing_Type__c = 'Recurring Postpaid';
            orderLineItemList[0].Main_Package_Product_Sub_Type__c = 'Magazine';
        //}
            orderLineItemList[1].Order__c = odr[0].id;
            orderLineItemList[1].Main_Package_ID__c = packageList[1].id;            
            orderLineItemList[1].Start_Date__c = Date.today().addDays(10);            
            orderLineItemList[1].Qty__c = 10;
            orderLineItemList[1].Add_On_Package_Subscription_Rate__c = 10;     
            orderLineItemList[1].Addon_Package__c = packageList[1].id;
            orderLineItemList[1].Promotion_ID__c = promotionList[0].id;
            orderLineItemList[1].Main_Package_Product_Family__c = 'Default';
            orderLineItemList[1].Main_Package_Billing_Type__c = 'Recurring Postpaid';
            orderLineItemList[1].Main_Package_Product_Sub_Type__c = 'Mags';
        insert orderLineItemList;
        //sObjectListMap_global.put('Order_Line_Item__c', orderLineItemList);
        return orderLineItemList;
    }
    
    //Zuora__Subscription__c
    //static List<Zuora__Subscription__c> createZuoraSubscription(List<Account> acc, List<Promotion__c> promo, List<Zuora__CustomerAccount__c>billAcc, List<Order__c> odr) {
    static List<Zuora__Subscription__c> createZuoraSubscription01(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc,
            List<Order__c> odr, List<Order_Line_Item__c> orderLineItemList, List<Contact> contactList, List<Package__c> packageList) {
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
            zSub[0].Zuora__Status__c = 'Cancelled';
            zSub[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[0].Payment_Mode_1__c = 'Credit Card';
            zSub[0].Payment_Mode__c = 'Credit Card';
            zSub[0].Billing_Type__c = 'Recurring Prepaid';
            zSub[0].Other_PaymentMethod_1__c = 'Invoice';
            zSub[0].Other_PaymentMethod__c = 'Invoice';
            zSub[0].Main_Package__c = packageList[0].id;
            zSub[0].Main_Package_1__c = packageList[0].id;
          //zSub[0].Subscription_Type_1__c = 'Publication';
            zSub[0].Term_Length__c = 2;
            zSub[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSub[0].Recipient_Contact__c = contactList[0].id;
            zSub[0].New_Contract_Period_1__c = 10;
            zSub[0].New_Contract_Period__c = '10';
        //
            
            zSub[1].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[1].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[1].Order_Number__c = odr[0].id;
            zSub[1].Order_Number_1__c = odr[0].id;
            //zSub[1].Recipient_Contact__c = contactList[1].id;
            zSub[1].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[1].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[1].Zuora__Status__c = 'Active';
            zSub[1].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[1].Subscription_Charge__c = null;
            zSub[1].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub[1].Payment_Mode_1__c = 'PayPal';
            zSub[1].Payment_Mode__c = 'PayPal';
            zSub[1].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub[1].Billing_Type__c = 'Recurring Prepaid'; // TODO
            zSub[1].Main_Package__c = packageList[1].id;
            zSub[1].Main_Package_1__c = packageList[1].id;
            zSub[1].Other_PaymentMethod_1__c = 'Invoice';
            zSub[1].Other_PaymentMethod__c = 'Invoice';
            zSub[1].Term_Length__c = 2;
            zSub[1].Recipient_Contact__c = contactList[1].id;
            zSub[1].New_Contract_Period_1__c = 10;
            zSub[1].New_Contract_Period__c = '10';
        //
            zSub[2].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[2].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[2].Order_Number__c = odr[0].id;
            zSub[2].Order_Number_1__c = odr[0].id;
            //zSub[2].Recipient_Contact__c = contactList[2].id;
            zSub[2].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[2].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[2].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[2].Zuora__Status__c = 'Active';
            zSub[2].Subscription_Type_1__c = 'Delivery';
            zSub[2].Subscription_Type__c = 'Delivery';
            zSub[2].Subscription_Type_1__c = 'Publication';
            zSub[2].Subscription_Type__c = 'Publication';
            zSub[2].Subscription_Charge__c = null;
            zSub[2].Zuora__TermSettingType__c = 'EVERGREEN';
//            zSub[2].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
//            zSub[2].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub[2].Payment_Mode_1__c = 'Credit Card';
            zSub[2].Payment_Mode__c = 'Credit Card';
            zSub[2].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[2].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub[2].Billing_Type__c = 'Recurring Postpaid';
            //zSub[2].Billing_Type__c = 'Full Prepaid';
            zSub[2].Main_Package__c = packageList[0].id;
            zSub[2].Main_Package_1__c = packageList[0].id;
            zSub[2].Term_Length__c = 2;
            zSub[2].Recipient_Contact__c = contactList[2].id;
            zSub[2].Other_PaymentMethod_1__c = 'Invoice';
            zSub[2].Other_PaymentMethod__c = 'Invoice';
            zSub[2].New_Contract_Period_1__c = 10;
            zSub[2].New_Contract_Period__c = '10';
        // 
            zSub[3].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[3].Zuora__CustomerAccount__c = billAcc[0].Id;
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
            zSub[3].Payment_Mode_1__c = 'Paypal';
            zSub[3].Payment_Mode__c = 'Paypal';
            zSub[3].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub[3].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSub[3].Billing_Type__c = 'Recurring Prepaid';
            zSub[3].Main_Package__c = packageList[1].id;
            zSub[3].Main_Package_1__c = packageList[1].id;
            zSub[3].Term_Length__c = 2;
            zSub[3].Recipient_Contact__c = contactList[3].id;
            zSub[3].Other_PaymentMethod_1__c = 'Invoice';
            zSub[3].Other_PaymentMethod__c = 'Invoice';
            zSub[3].New_Contract_Period_1__c = 10;
            zSub[3].New_Contract_Period__c = '10';
        //
            zSub[4].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[4].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub[4].Order_Number__c = odr[0].id;
            zSub[4].Order_Number_1__c = odr[0].id;
            zSub[4].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[4].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[4].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[4].Zuora__Status__c = 'Active';
            zSub[4].Subscription_Type_1__c = 'Delivery';
            zSub[4].Subscription_Type__c = 'Delivery';
            zSub[4].Subscription_Charge__c = null;
            zSub[4].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub[4].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
            zSub[4].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub[4].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[4].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub[4].Term_Length__c = 2;
            zSub[4].Recipient_Contact__c = contactList[4].id;
            zSub[4].Main_Package__c = packageList[1].id;
            zSub[4].Main_Package_1__c = packageList[1].id;
            zSub[4].New_Contract_Period_1__c = 10;
            zSub[4].New_Contract_Period__c = '10';

        //
       
            zSub[5].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[5].Zuora__CustomerAccount__c = billAcc[0].Id;
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
            zSub[5].Recipient_Contact__c = contactList[5].id;
            zSub[5].Term_Length__c = 5;
            zSub[5].Main_Package__c = packageList[0].id;
            zSub[5].Main_Package_1__c = packageList[0].id;
          //zSub[0].Subscription_Type_1__c = 'Publication';
            zSub[5].New_Contract_Period_1__c = 10;
            zSub[5].New_Contract_Period__c = '10';

           
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
            zSub[6].Term_Length__c = 5;
            zSub[6].Main_Package__c = packageList[0].id;
            zSub[6].Main_Package_1__c = packageList[0].id;
            zSub[6].Recipient_Contact__c = contactList[6].id;
            zSub[6].New_Contract_Period_1__c = 10;
            zSub[6].New_Contract_Period__c = '10';
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
            zSub[7].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub[7].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[7].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[7].Recipient_Contact__c = contactList[7].id;
            zSub[7].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[7].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub[7].Term_Length__c = 5;
            zSub[7].Main_Package__c = packageList[0].id;
            zSub[7].Main_Package_1__c = packageList[0].id;
            zSub[7].New_Contract_Period_1__c = 10;
            zSub[7].New_Contract_Period__c = '10';
          //  zSub[7].Term_Length__c = 5;
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
            zSub[8].Recipient_Contact__c = contactList[8].id;
            zSub[8].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[8].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub[8].Term_Length__c = 5;
            zSub[8].Main_Package__c = packageList[0].id;
            zSub[8].Main_Package_1__c = packageList[0].id;
            zSub[8].New_Contract_Period_1__c = 10;
            zSub[8].New_Contract_Period__c = '10';
         //   zSub[8].Term_Length__c = 5;
        //
            zSub[9].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub[9].Zuora__CustomerAccount__c = billAcc[3].Id;
            zSub[9].Order_Number__c = odr[0].id;
            zSub[9].Order_Number_1__c = odr[0].id;
            zSub[9].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[9].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[9].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[9].Zuora__Status__c = 'Active';
            zSub[9].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[9].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[9].Recipient_Contact__c = contactList[9].id;
            zSub[9].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub[9].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub[9].Term_Length__c = 5;
            zSub[9].Main_Package__c = packageList[0].id;
            zSub[9].Main_Package_1__c = packageList[0].id;
            zSub[9].New_Contract_Period_1__c = 10;
            zSub[9].New_Contract_Period__c = '10';
       //     zSub[9].Term_Length__c = 5 ;
            
        //sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        return zSub;
    }
    
    //Zuora__Subscription__c
    //static List<Zuora__Subscription__c> createZuoraSubscription(List<Account> acc, List<Promotion__c> promo, List<Zuora__CustomerAccount__c>billAcc, List<Order__c> odr) {
    static List<Zuora__Subscription__c> createZuoraSubscription02(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc,
            List<Order__c> odr, List<Order_Line_Item__c> orderLineItemList, List<Contact> contactList, List<Package__c> packageList) {
        //Create zuora subscription 
        //WHERE Order_Number_1__c IN: orderIdSet AND Zuora__Status__c = 'Active'
        List<Zuora__Subscription__c> zSub2 = TestDataFactory.createSubscription(10);
        //for(Zuora__Subscription__c x: zSub){
            zSub2[0].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[0].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[0].Order_Number__c = odr[0].id;
            zSub2[0].Order_Number_1__c = odr[0].id;
            zSub2[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[0].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[0].Zuora__Status__c = 'Cancelled';
            zSub2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[0].Payment_Mode_1__c = 'Other';
            zSub2[0].Payment_Mode__c = 'Other';
            zSub2[0].Billing_Type__c = 'Recurring Prepaid';
            zSub2[0].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[0].Other_PaymentMethod__c = 'Invoice';
            zSub2[0].Main_Package__c = packageList[0].id;
            zSub2[0].Main_Package_1__c = packageList[0].id;
          //zSub[0].Subscription_Type_1__c = 'Publication';
            zSub2[0].Term_Length__c = 2;
            zSub2[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub2[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSub2[0].Recipient_Contact__c = contactList[0].id;
            zSub2[0].New_Contract_Period_1__c = 10;
            zSub2[0].New_Contract_Period__c = '10';
        //
            
            zSub2[1].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[1].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[1].Order_Number__c = odr[0].id;
            zSub2[1].Order_Number_1__c = odr[0].id;
            //zSub[1].Recipient_Contact__c = contactList[1].id;
            zSub2[1].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[1].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[1].Zuora__Status__c = 'Active';
            zSub2[1].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[1].Subscription_Charge__c = null;
            zSub2[1].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[1].Payment_Mode_1__c = 'Other';
            zSub2[1].Payment_Mode__c = 'Other';
            zSub2[1].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[1].Billing_Type__c = 'Recurring Prepaid'; // TODO
            zSub2[1].Main_Package__c = packageList[1].id;
            zSub2[1].Main_Package_1__c = packageList[1].id;
            zSub2[1].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[1].Other_PaymentMethod__c = 'Invoice';
            zSub2[1].Term_Length__c = 2;
            zSub2[1].Recipient_Contact__c = contactList[1].id;
            zSub2[1].New_Contract_Period_1__c = 10;
            zSub2[1].New_Contract_Period__c = '10';
        //
            zSub2[2].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[2].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[2].Order_Number__c = odr[0].id;
            zSub2[2].Order_Number_1__c = odr[0].id;
            //zSub[2].Recipient_Contact__c = contactList[2].id;
            zSub2[2].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[2].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[2].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[2].Zuora__Status__c = 'Active';
            zSub2[2].Subscription_Type_1__c = 'Delivery';
            zSub2[2].Subscription_Type__c = 'Delivery';
            zSub2[2].Subscription_Type_1__c = 'Publication';
            zSub2[2].Subscription_Type__c = 'Publication';
            zSub2[2].Subscription_Charge__c = null;
            zSub2[2].Zuora__TermSettingType__c = 'EVERGREEN';
//            zSub[2].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
//            zSub[2].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub2[2].Payment_Mode_1__c = 'Other';
            zSub2[2].Payment_Mode__c = 'Other';
            zSub2[2].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[2].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[2].Billing_Type__c = 'Recurring Prepaid';
            //zSub[2].Billing_Type__c = 'Full Prepaid';
            zSub2[2].Main_Package__c = packageList[0].id;
            zSub2[2].Main_Package_1__c = packageList[0].id;
            zSub2[2].Term_Length__c = 2;
            zSub2[2].Recipient_Contact__c = contactList[2].id;
            zSub2[2].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[2].Other_PaymentMethod__c = 'Invoice';
            zSub2[2].New_Contract_Period_1__c = 10;
            zSub2[2].New_Contract_Period__c = '10';
        // 
            zSub2[3].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[3].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[3].Order_Number__c = odr[0].id;
            zSub2[3].Order_Number_1__c = odr[0].id;
            zSub2[3].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[3].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[3].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[3].Zuora__Status__c = 'Active';
            zSub2[3].Subscription_Type_1__c = 'Delivery';
            zSub2[3].Subscription_Type__c = 'Delivery';
            zSub2[3].Subscription_Charge__c = null;
            zSub2[3].Zuora__TermSettingType__c = '';
            zSub2[3].Payment_Mode_1__c = 'Other';
            zSub2[3].Payment_Mode__c = 'Other';
            zSub2[3].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub2[3].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSub2[3].Billing_Type__c = 'Recurring Prepaid';
            zSub2[3].Main_Package__c = packageList[1].id;
            zSub2[3].Main_Package_1__c = packageList[1].id;
            zSub2[3].Term_Length__c = 2;
            zSub2[3].Recipient_Contact__c = contactList[3].id;
            zSub2[3].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[3].Other_PaymentMethod__c = 'Invoice';
            zSub2[3].New_Contract_Period_1__c = 10;
            zSub2[3].New_Contract_Period__c = '10';
        //
            zSub2[4].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[4].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[4].Order_Number__c = odr[0].id;
            zSub2[4].Order_Number_1__c = odr[0].id;
            zSub2[4].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[4].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[4].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[4].Zuora__Status__c = 'Active';
            zSub2[4].Subscription_Type_1__c = 'Delivery';
            zSub2[4].Subscription_Type__c = 'Delivery';
            zSub2[4].Subscription_Charge__c = null;
            zSub2[4].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[4].Payment_Mode_1__c = 'Other';
            zSub2[4].Payment_Mode__c = 'Other';
            zSub2[4].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[4].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[4].Term_Length__c = 2;
            zSub2[4].Recipient_Contact__c = contactList[4].id;
            zSub2[4].Main_Package__c = packageList[1].id;
            zSub2[4].Main_Package_1__c = packageList[1].id;
            zSub2[4].New_Contract_Period_1__c = 10;
            zSub2[4].New_Contract_Period__c = '10';
            zSub2[4].Billing_Type__c = 'Recurring Prepaid';

        //
       
            zSub2[5].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[5].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[5].Order_Number__c = odr[0].id;
            zSub2[5].Order_Number_1__c = odr[0].id;
            zSub2[5].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[5].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[5].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[5].Zuora__Status__c = 'Active';
            zSub2[5].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[5].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[5].Subscription_Charge__c = null;
            zSub2[5].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[5].Payment_Mode_1__c = 'Other';
            zSub2[5].Payment_Mode__c = 'Other';
            zSub2[5].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[5].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[5].Recipient_Contact__c = contactList[5].id;
            zSub2[5].Term_Length__c = 5;
            zSub2[5].Main_Package__c = packageList[0].id;
            zSub2[5].Main_Package_1__c = packageList[0].id;
          //zSub[0].Subscription_Type_1__c = 'Publication';
            zSub2[5].New_Contract_Period_1__c = 10;
            zSub2[5].New_Contract_Period__c = '10';
            zSub2[5].Billing_Type__c = 'Recurring Prepaid';

           
        //
            zSub2[6].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[6].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub2[6].Order_Number__c = odr[0].id;
            zSub2[6].Order_Number_1__c = odr[0].id;
            zSub2[6].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[6].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[6].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[6].Zuora__Status__c = 'Active';
            zSub2[6].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[6].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[6].Subscription_Charge__c = null;
            zSub2[6].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[6].Payment_Mode_1__c = 'Other';
            zSub2[6].Payment_Mode__c = 'Other';
            zSub2[6].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[6].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[6].Term_Length__c = 5;
            zSub2[6].Main_Package__c = packageList[0].id;
            zSub2[6].Main_Package_1__c = packageList[0].id;
            zSub2[6].Recipient_Contact__c = contactList[6].id;
            zSub2[6].New_Contract_Period_1__c = 10;
            zSub2[6].New_Contract_Period__c = '10';
            zSub2[6].Billing_Type__c = 'Recurring Prepaid';
        //
            zSub2[7].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[7].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub2[7].Order_Number__c = odr[0].id;
            zSub2[7].Order_Number_1__c = odr[0].id;
            zSub2[7].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[7].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[7].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[7].Zuora__Status__c = 'Active';
            zSub2[7].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[7].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[7].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[7].Recipient_Contact__c = contactList[7].id;
            zSub2[7].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[7].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[7].Term_Length__c = 5;
            zSub2[7].Main_Package__c = packageList[0].id;
            zSub2[7].Main_Package_1__c = packageList[0].id;
            zSub2[7].New_Contract_Period_1__c = 10;
            zSub2[7].New_Contract_Period__c = '10';
            zSub2[7].Billing_Type__c = 'Recurring Prepaid';
            zSub2[7].Payment_Mode_1__c = 'Other';
            zSub2[7].Payment_Mode__c = 'Other';
          //  zSub[7].Term_Length__c = 5;
        //
            zSub2[8].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[8].Zuora__CustomerAccount__c = billAcc[2].Id;
            zSub2[8].Order_Number__c = odr[0].id;
            zSub2[8].Order_Number_1__c = odr[0].id;
            zSub2[8].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[8].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[8].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[8].Zuora__Status__c = 'Active';
            zSub2[8].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[8].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[8].Recipient_Contact__c = contactList[8].id;
            zSub2[8].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[8].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[8].Term_Length__c = 5;
            zSub2[8].Main_Package__c = packageList[0].id;
            zSub2[8].Main_Package_1__c = packageList[0].id;
            zSub2[8].New_Contract_Period_1__c = 10;
            zSub2[8].New_Contract_Period__c = '10';
            zSub2[8].Billing_Type__c = 'Recurring Prepaid';
            zSub2[8].Payment_Mode_1__c = 'Other';
            zSub2[8].Payment_Mode__c = 'Other';
         //   zSub[8].Term_Length__c = 5;
        //
            zSub2[9].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[9].Zuora__CustomerAccount__c = billAcc[3].Id;
            zSub2[9].Order_Number__c = odr[0].id;
            zSub2[9].Order_Number_1__c = odr[0].id;
            zSub2[9].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[9].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[9].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[9].Zuora__Status__c = 'Active';
            zSub2[9].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[9].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[9].Recipient_Contact__c = contactList[9].id;
            zSub2[9].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[9].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[9].Term_Length__c = 5;
            zSub2[9].Main_Package__c = packageList[0].id;
            zSub2[9].Main_Package_1__c = packageList[0].id;
            zSub2[9].New_Contract_Period_1__c = 10;
            zSub2[9].New_Contract_Period__c = '10';
            zSub2[9].Billing_Type__c = 'Recurring Prepaid';
            zSub2[9].Payment_Mode_1__c = 'Other';
            zSub2[9].Payment_Mode__c = 'Other';
       //     zSub[9].Term_Length__c = 5 ;
            
        //sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub2);
        return zSub2;
    }
    
    //Zuora__Subscription__c
    //static List<Zuora__Subscription__c> createZuoraSubscription(List<Account> acc, List<Promotion__c> promo, List<Zuora__CustomerAccount__c>billAcc, List<Order__c> odr) {
    static List<Zuora__Subscription__c> createZuoraSubscription03(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc,
            List<Order__c> odr, List<Order_Line_Item__c> orderLineItemList, List<Contact> contactList, List<Package__c> packageList) {
        //Create zuora subscription 
        //WHERE Order_Number_1__c IN: orderIdSet AND Zuora__Status__c = 'Active'
        List<Zuora__Subscription__c> zSub2 = TestDataFactory.createSubscription(10);
        //for(Zuora__Subscription__c x: zSub){
            zSub2[0].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[0].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[0].Order_Number__c = odr[0].id;
            zSub2[0].Order_Number_1__c = odr[0].id;
            zSub2[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[0].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[0].Zuora__Status__c = 'Cancelled';
            zSub2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[0].Payment_Mode_1__c = 'Other';
            zSub2[0].Payment_Mode__c = 'Other';
            zSub2[0].Billing_Type__c = 'Recurring Prepaid';
            zSub2[0].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[0].Other_PaymentMethod__c = 'Invoice';
            zSub2[0].Main_Package__c = packageList[0].id;
            zSub2[0].Main_Package_1__c = packageList[0].id;
          //zSub[0].Subscription_Type_1__c = 'Publication';
            zSub2[0].Term_Length__c = 13;
            zsub2[0].Term_Length1__c = '13';
            zSub2[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub2[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSub2[0].Recipient_Contact__c = contactList[0].id;
            zSub2[0].New_Contract_Period_1__c = 10;
            zSub2[0].New_Contract_Period__c = '10';
        //
            
            zSub2[1].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[1].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[1].Order_Number__c = odr[0].id;
            zSub2[1].Order_Number_1__c = odr[0].id;
            //zSub[1].Recipient_Contact__c = contactList[1].id;
            zSub2[1].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[1].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[1].Zuora__Status__c = 'Active';
            zSub2[1].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[1].Subscription_Charge__c = null;
            zSub2[1].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[1].Payment_Mode_1__c = 'Other';
            zSub2[1].Payment_Mode__c = 'Other';
            zSub2[1].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[1].Billing_Type__c = 'Recurring Prepaid'; // TODO
            zSub2[1].Main_Package__c = packageList[1].id;
            zSub2[1].Main_Package_1__c = packageList[1].id;
            zSub2[1].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[1].Other_PaymentMethod__c = 'Invoice';
            zSub2[1].Term_Length__c = 13;
            zsub2[1].Term_Length1__c = '13';
            zSub2[1].Recipient_Contact__c = contactList[1].id;
            zSub2[1].New_Contract_Period_1__c = 10;
            zSub2[1].New_Contract_Period__c = '10';
        //
            zSub2[2].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[2].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[2].Order_Number__c = odr[0].id;
            zSub2[2].Order_Number_1__c = odr[0].id;
            //zSub[2].Recipient_Contact__c = contactList[2].id;
            zSub2[2].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[2].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[2].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[2].Zuora__Status__c = 'Active';
            zSub2[2].Subscription_Type_1__c = 'Delivery';
            zSub2[2].Subscription_Type__c = 'Delivery';
            zSub2[2].Subscription_Type_1__c = 'Publication';
            zSub2[2].Subscription_Type__c = 'Publication';
            zSub2[2].Subscription_Charge__c = null;
            zSub2[2].Zuora__TermSettingType__c = 'EVERGREEN';
//            zSub[2].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
//            zSub[2].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub2[2].Payment_Mode_1__c = 'Other';
            zSub2[2].Payment_Mode__c = 'Other';
            zSub2[2].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[2].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[2].Billing_Type__c = 'Recurring Prepaid';
            //zSub[2].Billing_Type__c = 'Full Prepaid';
            zSub2[2].Main_Package__c = packageList[0].id;
            zSub2[2].Main_Package_1__c = packageList[0].id;
            zSub2[2].Term_Length__c = 13;
            zsub2[2].Term_Length1__c = '13';
            zSub2[2].Recipient_Contact__c = contactList[2].id;
            zSub2[2].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[2].Other_PaymentMethod__c = 'Invoice';
            zSub2[2].New_Contract_Period_1__c = 10;
            zSub2[2].New_Contract_Period__c = '10';
        // 
            zSub2[3].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[3].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[3].Order_Number__c = odr[0].id;
            zSub2[3].Order_Number_1__c = odr[0].id;
            zSub2[3].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[3].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[3].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[3].Zuora__Status__c = 'Active';
            zSub2[3].Subscription_Type_1__c = 'Delivery';
            zSub2[3].Subscription_Type__c = 'Delivery';
            zSub2[3].Subscription_Charge__c = null;
            zSub2[3].Zuora__TermSettingType__c = '';
            zSub2[3].Payment_Mode_1__c = 'Other';
            zSub2[3].Payment_Mode__c = 'Other';
            zSub2[3].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub2[3].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSub2[3].Billing_Type__c = 'Recurring Prepaid';
            zSub2[3].Main_Package__c = packageList[1].id;
            zSub2[3].Main_Package_1__c = packageList[1].id;
            zSub2[3].Term_Length__c = 13;
            zsub2[3].Term_Length1__c = '13';
            zSub2[3].Recipient_Contact__c = contactList[3].id;
            zSub2[3].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[3].Other_PaymentMethod__c = 'Invoice';
            zSub2[3].New_Contract_Period_1__c = 10;
            zSub2[3].New_Contract_Period__c = '10';
        //
            zSub2[4].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[4].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[4].Order_Number__c = odr[0].id;
            zSub2[4].Order_Number_1__c = odr[0].id;
            zSub2[4].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[4].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[4].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[4].Zuora__Status__c = 'Active';
            zSub2[4].Subscription_Type_1__c = 'Delivery';
            zSub2[4].Subscription_Type__c = 'Delivery';
            zSub2[4].Subscription_Charge__c = null;
            zSub2[4].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[4].Payment_Mode_1__c = 'Other';
            zSub2[4].Payment_Mode__c = 'Other';
            zSub2[4].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[4].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[4].Term_Length__c = 13;
            zsub2[4].Term_Length1__c = '13';
            zSub2[4].Recipient_Contact__c = contactList[4].id;
            zSub2[4].Main_Package__c = packageList[1].id;
            zSub2[4].Main_Package_1__c = packageList[1].id;
            zSub2[4].New_Contract_Period_1__c = 10;
            zSub2[4].New_Contract_Period__c = '10';
            zSub2[4].Billing_Type__c = 'Recurring Prepaid';

        //
       
            zSub2[5].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[5].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[5].Order_Number__c = odr[0].id;
            zSub2[5].Order_Number_1__c = odr[0].id;
            zSub2[5].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[5].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[5].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[5].Zuora__Status__c = 'Active';
            zSub2[5].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[5].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[5].Subscription_Charge__c = null;
            zSub2[5].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[5].Payment_Mode_1__c = 'Other';
            zSub2[5].Payment_Mode__c = 'Other';
            zSub2[5].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[5].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[5].Recipient_Contact__c = contactList[5].id;
            zSub2[5].Term_Length__c = 13;
            zsub2[5].Term_Length1__c = '13';
            zSub2[5].Main_Package__c = packageList[0].id;
            zSub2[5].Main_Package_1__c = packageList[0].id;
          //zSub[0].Subscription_Type_1__c = 'Publication';
            zSub2[5].New_Contract_Period_1__c = 10;
            zSub2[5].New_Contract_Period__c = '10';
            zSub2[5].Billing_Type__c = 'Recurring Prepaid';

           
        //
            zSub2[6].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[6].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub2[6].Order_Number__c = odr[0].id;
            zSub2[6].Order_Number_1__c = odr[0].id;
            zSub2[6].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[6].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[6].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[6].Zuora__Status__c = 'Active';
            zSub2[6].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[6].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[6].Subscription_Charge__c = null;
            zSub2[6].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[6].Payment_Mode_1__c = 'Other';
            zSub2[6].Payment_Mode__c = 'Other';
            zSub2[6].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[6].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[6].Term_Length__c = 13;
            zsub2[6].Term_Length1__c = '13';
            zSub2[6].Main_Package__c = packageList[0].id;
            zSub2[6].Main_Package_1__c = packageList[0].id;
            zSub2[6].Recipient_Contact__c = contactList[6].id;
            zSub2[6].New_Contract_Period_1__c = 10;
            zSub2[6].New_Contract_Period__c = '10';
            zSub2[6].Billing_Type__c = 'Recurring Prepaid';
        //
            zSub2[7].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[7].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub2[7].Order_Number__c = odr[0].id;
            zSub2[7].Order_Number_1__c = odr[0].id;
            zSub2[7].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[7].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[7].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[7].Zuora__Status__c = 'Active';
            zSub2[7].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[7].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[7].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[7].Recipient_Contact__c = contactList[7].id;
            zSub2[7].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[7].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[7].Term_Length__c = 13;
            zsub2[7].Term_Length1__c = '13';
            zSub2[7].Main_Package__c = packageList[0].id;
            zSub2[7].Main_Package_1__c = packageList[0].id;
            zSub2[7].New_Contract_Period_1__c = 10;
            zSub2[7].New_Contract_Period__c = '10';
            zSub2[7].Billing_Type__c = 'Recurring Prepaid';
            zSub2[7].Payment_Mode_1__c = 'Other';
            zSub2[7].Payment_Mode__c = 'Other';
          //  zSub[7].Term_Length__c = 5;
        //
            zSub2[8].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[8].Zuora__CustomerAccount__c = billAcc[2].Id;
            zSub2[8].Order_Number__c = odr[0].id;
            zSub2[8].Order_Number_1__c = odr[0].id;
            zSub2[8].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[8].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[8].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[8].Zuora__Status__c = 'Active';
            zSub2[8].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[8].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[8].Recipient_Contact__c = contactList[8].id;
            zSub2[8].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[8].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[8].Term_Length__c = 13;
            zsub2[8].Term_Length1__c = '13';
            zSub2[8].Main_Package__c = packageList[0].id;
            zSub2[8].Main_Package_1__c = packageList[0].id;
            zSub2[8].New_Contract_Period_1__c = 10;
            zSub2[8].New_Contract_Period__c = '10';
            zSub2[8].Billing_Type__c = 'Recurring Prepaid';
            zSub2[8].Payment_Mode_1__c = 'Other';
            zSub2[8].Payment_Mode__c = 'Other';
         //   zSub[8].Term_Length__c = 5;
        //
            zSub2[9].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[9].Zuora__CustomerAccount__c = billAcc[3].Id;
            zSub2[9].Order_Number__c = odr[0].id;
            zSub2[9].Order_Number_1__c = odr[0].id;
            zSub2[9].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[9].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[9].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[9].Zuora__Status__c = 'Active';
            zSub2[9].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[9].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[9].Recipient_Contact__c = contactList[9].id;
            zSub2[9].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[9].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[9].Term_Length__c = 13;
            zsub2[9].Term_Length1__c = '13';
            zSub2[9].Main_Package__c = packageList[0].id;
            zSub2[9].Main_Package_1__c = packageList[0].id;
            zSub2[9].New_Contract_Period_1__c = 10;
            zSub2[9].New_Contract_Period__c = '10';
            zSub2[9].Billing_Type__c = 'Recurring Prepaid';
            zSub2[9].Payment_Mode_1__c = 'Other';
            zSub2[9].Payment_Mode__c = 'Other';
       //     zSub[9].Term_Length__c = 5 ;
            
        //sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub2);
        return zSub2;
    }
    
    //Zuora__Subscription__c
    //static List<Zuora__Subscription__c> createZuoraSubscription(List<Account> acc, List<Promotion__c> promo, List<Zuora__CustomerAccount__c>billAcc, List<Order__c> odr) {
    static List<Zuora__Subscription__c> createZuoraSubscription04(List<Account> acc, List<Zuora__CustomerAccount__c> billAcc,
            List<Order__c> odr, List<Order_Line_Item__c> orderLineItemList, List<Contact> contactList, List<Package__c> packageList) {
        //Create zuora subscription 
        //WHERE Order_Number_1__c IN: orderIdSet AND Zuora__Status__c = 'Active'
        List<Zuora__Subscription__c> zSub2 = TestDataFactory.createSubscription(10);
        //for(Zuora__Subscription__c x: zSub){
            zSub2[0].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[0].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[0].Order_Number__c = odr[0].id;
            zSub2[0].Order_Number_1__c = odr[0].id;
            zSub2[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[0].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[0].Zuora__Status__c = 'Cancelled';
            zSub2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[0].Payment_Mode_1__c = 'Other';
            zSub2[0].Payment_Mode__c = 'Other';
            zSub2[0].Billing_Type__c = 'Recurring Postpaid';
            zSub2[0].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[0].Other_PaymentMethod__c = 'Invoice';
            zSub2[0].Main_Package__c = packageList[0].id;
            zSub2[0].Main_Package_1__c = packageList[0].id;
          //zSub[0].Subscription_Type_1__c = 'Publication';
            zSub2[0].Subscription_Charge__c = 20; 
            zSub2[0].Term_Length__c = 13;
            zsub2[0].Term_Length1__c = '13';
            zSub2[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub2[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSub2[0].Recipient_Contact__c = contactList[0].id;
            zSub2[0].New_Contract_Period_1__c = 10;
            zSub2[0].New_Contract_Period__c = '10';
        //
            
            zSub2[1].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[1].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[1].Order_Number__c = odr[0].id;
            zSub2[1].Order_Number_1__c = odr[0].id;
            //zSub[1].Recipient_Contact__c = contactList[1].id;
            zSub2[1].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[1].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[1].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[1].Zuora__Status__c = 'Active';
            zSub2[1].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[1].Subscription_Charge__c = 20;
            zSub2[1].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[1].Payment_Mode_1__c = 'Other';
            zSub2[1].Payment_Mode__c = 'Other';
            zSub2[1].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[1].Billing_Type__c = 'Recurring Postpaid'; // TODO
            zSub2[1].Main_Package__c = packageList[1].id;
            zSub2[1].Main_Package_1__c = packageList[1].id;
            zSub2[1].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[1].Other_PaymentMethod__c = 'Invoice';
            zSub2[1].Term_Length__c = 13;
            zsub2[1].Term_Length1__c = '13';
            zSub2[1].Recipient_Contact__c = contactList[1].id;
            zSub2[1].New_Contract_Period_1__c = 10;
            zSub2[1].New_Contract_Period__c = '10';
        //
            zSub2[2].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[2].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[2].Order_Number__c = odr[0].id;
            zSub2[2].Order_Number_1__c = odr[0].id;
            //zSub[2].Recipient_Contact__c = contactList[2].id;
            zSub2[2].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[2].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[2].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[2].Zuora__Status__c = 'Active';
            zSub2[2].Subscription_Type_1__c = 'Delivery';
            zSub2[2].Subscription_Type__c = 'Delivery';
            zSub2[2].Subscription_Type_1__c = 'Publication';
            zSub2[2].Subscription_Type__c = 'Publication';
            zSub2[2].Subscription_Charge__c = 20;
            zSub2[2].Zuora__TermSettingType__c = 'EVERGREEN';
//            zSub[2].Payment_Mode_1__c = GlobalVariableClass.INVOICE;
//            zSub[2].Payment_Mode__c = GlobalVariableClass.INVOICE;
            zSub2[2].Payment_Mode_1__c = 'Other';
            zSub2[2].Payment_Mode__c = 'Other';
            zSub2[2].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[2].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[2].Billing_Type__c = 'Recurring Postpaid';
            //zSub[2].Billing_Type__c = 'Full Prepaid';
            zSub2[2].Main_Package__c = packageList[0].id;
            zSub2[2].Main_Package_1__c = packageList[0].id;
            zSub2[2].Term_Length__c = 13;
            zsub2[2].Term_Length1__c = '13';
            zSub2[2].Recipient_Contact__c = contactList[2].id;
            zSub2[2].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[2].Other_PaymentMethod__c = 'Invoice';
            zSub2[2].New_Contract_Period_1__c = 10;
            zSub2[2].New_Contract_Period__c = '10';
        // 
            zSub2[3].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[3].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[3].Order_Number__c = odr[0].id;
            zSub2[3].Order_Number_1__c = odr[0].id;
            zSub2[3].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[3].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[3].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[3].Zuora__Status__c = 'Active';
            zSub2[3].Subscription_Type_1__c = 'Delivery';
            zSub2[3].Subscription_Type__c = 'Delivery';
            zSub2[3].Subscription_Charge__c = 20;
            zSub2[3].Zuora__TermSettingType__c = '';
            zSub2[3].Payment_Mode_1__c = 'Other';
            zSub2[3].Payment_Mode__c = 'Other';
            zSub2[3].Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zSub2[3].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zSub2[3].Billing_Type__c = 'Recurring Postpaid';
            zSub2[3].Main_Package__c = packageList[1].id;
            zSub2[3].Main_Package_1__c = packageList[1].id;
            zSub2[3].Term_Length__c = 13;
            zsub2[3].Term_Length1__c = '13';
            zSub2[3].Recipient_Contact__c = contactList[3].id;
            zSub2[3].Other_PaymentMethod_1__c = 'Invoice';
            zSub2[3].Other_PaymentMethod__c = 'Invoice';
            zSub2[3].New_Contract_Period_1__c = 10;
            zSub2[3].New_Contract_Period__c = '10';
        //
            zSub2[4].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[4].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[4].Order_Number__c = odr[0].id;
            zSub2[4].Order_Number_1__c = odr[0].id;
            zSub2[4].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[4].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[4].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[4].Zuora__Status__c = 'Active';
            zSub2[4].Subscription_Type_1__c = 'Delivery';
            zSub2[4].Subscription_Type__c = 'Delivery';
            zSub2[4].Subscription_Charge__c = 20;
            zSub2[4].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[4].Payment_Mode_1__c = 'Other';
            zSub2[4].Payment_Mode__c = 'Other';
            zSub2[4].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[4].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[4].Term_Length__c = 13;
            zsub2[4].Term_Length1__c = '13';
            zSub2[4].Recipient_Contact__c = contactList[4].id;
            zSub2[4].Main_Package__c = packageList[1].id;
            zSub2[4].Main_Package_1__c = packageList[1].id;
            zSub2[4].New_Contract_Period_1__c = 10;
            zSub2[4].New_Contract_Period__c = '10';
            zSub2[4].Billing_Type__c = 'Recurring Postpaid';

        //
       
            zSub2[5].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[5].Zuora__CustomerAccount__c = billAcc[0].Id;
            zSub2[5].Order_Number__c = odr[0].id;
            zSub2[5].Order_Number_1__c = odr[0].id;
            zSub2[5].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[5].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[5].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[5].Zuora__Status__c = 'Active';
            zSub2[5].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[5].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[5].Subscription_Charge__c = 20;
            zSub2[5].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[5].Payment_Mode_1__c = 'Other';
            zSub2[5].Payment_Mode__c = 'Other';
            zSub2[5].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[5].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[5].Recipient_Contact__c = contactList[5].id;
            zSub2[5].Term_Length__c = 13;
            zsub2[5].Term_Length1__c = '13';
            zSub2[5].Main_Package__c = packageList[0].id;
            zSub2[5].Main_Package_1__c = packageList[0].id;
          //zSub[0].Subscription_Type_1__c = 'Publication';
            zSub2[5].New_Contract_Period_1__c = 10;
            zSub2[5].New_Contract_Period__c = '10';
            zSub2[5].Billing_Type__c = 'Recurring Postpaid';

           
        //
            zSub2[6].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[6].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub2[6].Order_Number__c = odr[0].id;
            zSub2[6].Order_Number_1__c = odr[0].id;
            zSub2[6].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[6].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[6].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[6].Zuora__Status__c = 'Active';
            zSub2[6].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[6].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            zSub2[6].Subscription_Charge__c = 20;
            zSub2[6].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[6].Payment_Mode_1__c = 'Other';
            zSub2[6].Payment_Mode__c = 'Other';
            zSub2[6].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[6].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[6].Term_Length__c = 13;
            zsub2[6].Term_Length1__c = '13';
            zSub2[6].Main_Package__c = packageList[0].id;
            zSub2[6].Main_Package_1__c = packageList[0].id;
            zSub2[6].Recipient_Contact__c = contactList[6].id;
            zSub2[6].New_Contract_Period_1__c = 10;
            zSub2[6].New_Contract_Period__c = '10';
            zSub2[6].Billing_Type__c = 'Recurring Postpaid';
        //
            zSub2[7].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[7].Zuora__CustomerAccount__c = billAcc[1].Id;
            zSub2[7].Order_Number__c = odr[0].id;
            zSub2[7].Order_Number_1__c = odr[0].id;
            zSub2[7].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[7].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[7].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[7].Zuora__Status__c = 'Active';
            zSub2[7].Zuora__TermSettingType__c = 'EVERGREEN';
            zSub2[7].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[7].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[7].Recipient_Contact__c = contactList[7].id;
            zSub2[7].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[7].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[7].Term_Length__c = 13;
            zsub2[7].Term_Length1__c = '13';
            zSub2[7].Main_Package__c = packageList[0].id;
            zSub2[7].Main_Package_1__c = packageList[0].id;
            zSub2[7].New_Contract_Period_1__c = 10;
            zSub2[7].New_Contract_Period__c = '10';
            zSub2[7].Billing_Type__c = 'Recurring Postpaid';
            zSub2[7].Payment_Mode_1__c = 'Other';
            zSub2[7].Payment_Mode__c = 'Other';
            zSub2[7].Subscription_Charge__c = 20;
          //  zSub[7].Term_Length__c = 5;
        //
            zSub2[8].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[8].Zuora__CustomerAccount__c = billAcc[2].Id;
            zSub2[8].Order_Number__c = odr[0].id;
            zSub2[8].Order_Number_1__c = odr[0].id;
            zSub2[8].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[8].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[8].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[8].Zuora__Status__c = 'Active';
            zSub2[8].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[8].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[8].Recipient_Contact__c = contactList[8].id;
            zSub2[8].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[8].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[8].Term_Length__c = 13;
            zsub2[8].Term_Length1__c = '13';
            zSub2[8].Main_Package__c = packageList[0].id;
            zSub2[8].Main_Package_1__c = packageList[0].id;
            zSub2[8].New_Contract_Period_1__c = 10;
            zSub2[8].New_Contract_Period__c = '10';
            zSub2[8].Billing_Type__c = 'Recurring Postpaid';
            zSub2[8].Payment_Mode_1__c = 'Other';
            zSub2[8].Payment_Mode__c = 'Other';
            zSub2[8].Subscription_Charge__c = 20;
         //   zSub[8].Term_Length__c = 5;
        //
            zSub2[9].Zuora__Account__c = acc[0].id;
            //x.Promotion_1__c = promo[0].id;
            zSub2[9].Zuora__CustomerAccount__c = billAcc[3].Id;
            zSub2[9].Order_Number__c = odr[0].id;
            zSub2[9].Order_Number_1__c = odr[0].id;
            zSub2[9].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub2[9].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub2[9].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub2[9].Zuora__Status__c = 'Active';
            zSub2[9].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[9].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub2[9].Recipient_Contact__c = contactList[9].id;
            zSub2[9].Order_Line_Item_Number_1__c = orderLineItemList[1].id;
            zSub2[9].Order_Line_Item_Number__c = orderLineItemList[1].id;
            zSub2[9].Term_Length__c = 13;
            zsub2[9].Term_Length1__c = '13';
            zSub2[9].Main_Package__c = packageList[0].id;
            zSub2[9].Main_Package_1__c = packageList[0].id;
            zSub2[9].New_Contract_Period_1__c = 10;
            zSub2[9].New_Contract_Period__c = '10';
            zSub2[9].Billing_Type__c = 'Recurring Postpaid';
            zSub2[9].Payment_Mode_1__c = 'Other';
            zSub2[9].Payment_Mode__c = 'Other';
            zSub2[9].Subscription_Charge__c = 20;
       //     zSub[9].Term_Length__c = 5 ;
            
        //sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub2);
        return zSub2;
    }
    
    /* static Map<Id, Map<Id, List<Zuora__Subscription__c>>> billAcctIdMap(List<Account> acc, List<Zuora__Subscription__c> zSub){
       Map<Id, Map<Id, List<Zuora__Subscription__c>>> billAcctIdRecConIdPubSubListMap2 = new Map<Id, Map<Id, List<Zuora__Subscription__c>>>();   
       Map<Id, List<Zuora__Subscription__c>> subMap = new Map<Id, List<Zuora__Subscription__c>>();
       subMap.put(acc[0].id,  zSub);
       billAcctIdRecConIdPubSubListMap2.put(acc[0].id, subMap) ;
       sObjectListMap_global.put('Map<Id, Map<Id, List<Zuora__Subscription__c>>>', billAcctIdRecConIdPubSubListMap2);
    
   }*/
   /*APRIL
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
            zSub[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[0].Recipient_Contact__c = contactList[0].id;
            APRIL*/
         /*   zSub[0].Billing_Type__c = 'Full Prepaid';
            zSub[0].Subscription_Type_1__c = 'Publication';
            zSub[0].Subscription_Type__c = 'Publication';
            zSub[0].Payment_Mode_1__c = 'Credit Card';
            zSub[0].Payment_Mode__c = 'Credit Card';
            zSub[0].Other_PaymentMethod_1__c = 'Invoice';
            zSub[0].Other_PaymentMethod__c = 'Invoice';*/
        //    zSub[0].Term_Length__c = ;
        //
/*            
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
            zSub[9].Zuora__CustomerAccount__c = billAcc[3].Id;
            zSub[9].Order_Number__c = odr[0].id;
            zSub[9].Order_Number_1__c = odr[0].id;
            zSub[9].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSub[9].Zuora__SubscriptionEndDate__c = Date.today().addDays(90);
            zSub[9].Contract_End_Date_1__c = Date.today().addDays(90);
            zSub[9].Zuora__Status__c = 'Active';
            zSub[9].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[9].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
            zSub[9].Recipient_Contact__c = contactList[3].id;
            //zSub[9].Term_Length__c = ;

        sObjectListMap_global.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        return zSub;
    }*/
    
    static void setData01() {
    
        //
        //sObjectListMap_global = new Map<String, Object>();
        
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        SPH_Section__c sect = createSection();
        SPH_Department__c dept  =  createDepartment();
        SPH_Division__c divi =  createDivision();
        SPH_Company__c comp = createCompany();
        SPH_Location__c loc = createLocation();
        Packing_Grp__c packGroup = createPackingGroup();
        List<City__c> cityList = createCity01(countryList);
        
       
        List<Address__c> addressList = createAddress01(countryList, singpostAddressList, sect, dept, divi, comp, loc, cityList , packGroup );
        
            
        List<Account> acc = createAccount01();        
        Case caseRec = createCase(acc);
        List<Contact> contactList = createContact01(acc, cityList, addressList);
        
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount01( acc, contactList);
        
        List<Order__c> odr = createOrder01(acc, billAcc);
        
        //List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount01(acc, contactList);
                
        List<Package__c> packageList = createPackage01();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(odr, packageList, promotionList);
        
        //List<Zuora__Subscription__c> createZuoraSubscription( acc, List<Promotion__c> promo, billAcc,  odr) {
        List<Zuora__Subscription__c> zSub = createZuoraSubscription01(acc, billAcc, odr, orderLineItemList, contactList, packageList);
        Letter_Print_Request__c letterPrint = createLetterPrintRequest01(billAcc);
        List<Case_Subscription__c> caseSub =  createCaseSubscription(acc, addressList,  zSub,  caseRec);
       
    }
   /*APRIL 
    static void setData02() {
    
        //
        sObjectListMap_global = new Map<String, Object>();        
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        SPH_Section__c sect = createSection();
        SPH_Department__c dept  =  createDepartment();
        SPH_Division__c divi =  createDivision();
        SPH_Company__c comp = createCompany();
        SPH_Location__c loc = createLocation();
        Packing_Grp__c packGroup = createPackingGroup();
        List<City__c> cityList = createCity01(countryList);
       
        List<Address__c> addressList = createAddress01(countryList, singpostAddressList, sect, dept, divi, comp, loc, cityList , packGroup );
        
            
        List<Account> acc = createAccount01();
                
        List<Contact> contactList = createContact01(acc, cityList, addressList);
        
        Letter_Print_Request__c letterPrint = createLetterPrintRequest01(acc);
        List<Order__c> odr = createOrder01(acc);
        
        List<Zuora__CustomerAccount__c> billAcc = createZuoraCustomerAccount02(acc, contactList);
                
        List<Package__c> packageList = createPackage01();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(odr, packageList, promotionList);
        
        //List<Zuora__Subscription__c> createZuoraSubscription( acc, List<Promotion__c> promo, billAcc,  odr) {
        List<Zuora__Subscription__c> zSub = createZuoraSubscription02(acc, billAcc, odr, orderLineItemList, contactList);
   
        
    }APRIL*/
    
    
    static testMethod void testBatch01() {
        
        //defaultCustomSetting(); // jurna-10-23-15
        // Test Data
        //setData01();
        
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        SPH_Section__c sect = createSection();
        SPH_Department__c dept  =  createDepartment();
        SPH_Division__c divi =  createDivision();
        SPH_Company__c comp = createCompany();
        SPH_Location__c loc = createLocation();
        Packing_Grp__c packGroup = createPackingGroup();
        List<Account> acc = createAccount01();
        Case caseRec = createCase(acc);
        List<City__c> city = createCity01(countryList);
        List<Address__c> add = createAddress01(countryList, singpostAddressList, sect, dept, divi, comp, loc, city , packGroup);
        List<Contact> con = createContact01(acc, city, add);
        List<Zuora__CustomerAccount__c> customerAcc = createZuoraCustomerAccount01(acc, con);
        Letter_Print_Request__c letterprint = createLetterPrintRequest01(customerAcc); 
        List<Order__c> odr = createOrder01(acc, customerAcc);
        List<Package__c> packageList = createPackage01();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(odr, packageList, promotionList);
        List<Zuora__Subscription__c> zSub = createZuoraSubscription01(acc, customerAcc, odr, orderLineItemList, con, packageList);
        List<Case_Subscription__c> caseSub =  createCaseSubscription(acc, add,  zSub,  caseRec);
        
        System.debug('Letter_Type__c: '+letterprint.Letter_Type__c+ ' Acknowledgment_Type__c: '
        +letterprint.Acknowledgment_Type__c +' Sub_Created_Date__c: '+ letterprint.Sub_Created_Date__c +' Sub_Created_Date__c:'
        +letterprint.Sub_Created_Date__c +'  Generation_From__c: '+letterprint.Generation_From__c +' Generation_To__c: '+letterprint.Generation_To__c);
        
        Set<Id> LetterId = new Set<Id>();
        LetterId.add(letterprint.Id); 
        
        Document docu = new Document();
        docu.FolderId = userinfo.getUserId();
        docu.Name = 'SPH Logo v2';
        Blob bodyBlob = Blob.valueOf('SPH Logo v2');
        docu.body = bodyBlob;
        insert docu;
        
       
        //Test.startTest();  
        // Test Proper 
        AcknowledgmentLetterEmail batch = new AcknowledgmentLetterEmail();
        AcknowledgmentLetterEmail batch2 = new AcknowledgmentLetterEmail(LetterId);
        //AcknowledgmentLetterEmail batch3 = new AcknowledgmentLetterEmail(othersList[0].name,othersList[1].name);
        //batch.accIdRecConIdPubSubListMap = listMap;
        //batch.getAcknowledgmentDetails(letterPrint2);    
       
        ID batchprocessid = Database.executeBatch(batch2, 20);        
        System.assertNotEquals(null, batchprocessid); 
        Test.stopTest();
    }
    
    //jurna
    static testMethod void testBatch02() {
        
        //defaultCustomSetting(); // jurna-10-23-15
        // Test Data
        //setData01();
         
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        SPH_Section__c sect = createSection();
        SPH_Department__c dept  =  createDepartment();
        SPH_Division__c divi =  createDivision();
        SPH_Company__c comp = createCompany();
        SPH_Location__c loc = createLocation();
        Packing_Grp__c packGroup = createPackingGroup();
        List<Account> acc = createAccount01();
        Case caseRec = createCase(acc);
        List<City__c> city = createCity01(countryList);
        List<Address__c> add = createAddress01(countryList, singpostAddressList, sect, dept, divi, comp, loc, city , packGroup);
        List<Contact> con = createContact01(acc, city, add);
        List<Zuora__CustomerAccount__c> customerAcc2 = createZuoraCustomerAccount02(acc, con);
        Letter_Print_Request__c letterprint = createLetterPrintRequest01(customerAcc2); 
        List<Order__c> odr = createOrder02(acc, customerAcc2);
        List<Package__c> packageList = createPackage02();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem02(odr, packageList, promotionList);
        List<Zuora__Subscription__c> zSub = createZuoraSubscription02(acc, customerAcc2, odr, orderLineItemList, con, packageList);
        List<Case_Subscription__c> caseSub =  createCaseSubscription(acc, add,  zSub,  caseRec);
        
        System.debug('Letter_Type__c: '+letterprint.Letter_Type__c+ ' Acknowledgment_Type__c: '
        +letterprint.Acknowledgment_Type__c +' Sub_Created_Date__c: '+ letterprint.Sub_Created_Date__c +' Sub_Created_Date__c:'
        +letterprint.Sub_Created_Date__c +'  Generation_From__c: '+letterprint.Generation_From__c +' Generation_To__c: '+letterprint.Generation_To__c);
        Set<Id> LetterId = new Set<Id>();
        LetterId.add(letterprint.Id); 
        
        Document docu = new Document();
        docu.FolderId = userinfo.getUserId();
        docu.Name = 'SPH Logo v2';
        Blob bodyBlob = Blob.valueOf('SPH Logo v2');
        docu.body = bodyBlob;
        insert docu;
        
       
        //Test.startTest();  
        // Test Proper 
        //AcknowledgmentLetterEmail batch = new AcknowledgmentLetterEmail();
        //AcknowledgmentLetterEmail batch1 = new AcknowledgmentLetterEmail(LetterId);
        AcknowledgmentLetterEmail batch2 = new AcknowledgmentLetterEmail(system.today(), system.today()+3);
        //AcknowledgmentLetterEmail batch3 = new AcknowledgmentLetterEmail(othersList[0].name,othersList[1].name);
        //batch.accIdRecConIdPubSubListMap = listMap;
        //batch.getAcknowledgmentDetails(letterPrint2);    
       
        ID batchprocessid = Database.executeBatch(batch2, 200);        
        System.assertNotEquals(null, batchprocessid); 
        Test.stopTest();
    }
    
    //jurna
    static testMethod void testBatch03() {
        
        //defaultCustomSetting(); // jurna-10-23-15
        // Test Data
        //setData01();
        
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        SPH_Section__c sect = createSection();
        SPH_Department__c dept  =  createDepartment();
        SPH_Division__c divi =  createDivision();
        SPH_Company__c comp = createCompany();
        SPH_Location__c loc = createLocation();
        Packing_Grp__c packGroup = createPackingGroup();
        List<Account> acc = createAccount01();
        Case caseRec = createCase(acc);
        List<City__c> city = createCity01(countryList);
        List<Address__c> add = createAddress01(countryList, singpostAddressList, sect, dept, divi, comp, loc, city , packGroup);
        List<Contact> con = createContact01(acc, city, add);
        List<Zuora__CustomerAccount__c> customerAcc = createZuoraCustomerAccount01(acc, con);
        Letter_Print_Request__c letterprint = createLetterPrintRequest01(customerAcc); 
        List<Order__c> odr = createOrder01(acc, customerAcc);
        List<Package__c> packageList = createPackage01();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem01(odr, packageList, promotionList);
        List<Zuora__Subscription__c> zSub = createZuoraSubscription01(acc, customerAcc, odr, orderLineItemList, con, packageList);
        List<Case_Subscription__c> caseSub =  createCaseSubscription(acc, add,  zSub,  caseRec);
        
        System.debug('Letter_Type__c: '+letterprint.Letter_Type__c+ ' Acknowledgment_Type__c: '
        +letterprint.Acknowledgment_Type__c +' Sub_Created_Date__c: '+ letterprint.Sub_Created_Date__c +' Sub_Created_Date__c:'
        +letterprint.Sub_Created_Date__c +'  Generation_From__c: '+letterprint.Generation_From__c +' Generation_To__c: '+letterprint.Generation_To__c);
        Set<Id> LetterId = new Set<Id>();
        LetterId.add(letterprint.Id); 
        Document docu = new Document();
        docu.FolderId = userinfo.getUserId();
        docu.Name = 'SPH Logo v2';
        //Blob bodyBlob = Blob.valueOf('SPH Logo v2');
        //docu.body = bodyBlob;
        insert docu;
        
       
        //Test.startTest();   
        // Test Proper 
        //AcknowledgmentLetterEmail batch = new AcknowledgmentLetterEmail();
        AcknowledgmentLetterEmail batch1 = new AcknowledgmentLetterEmail(LetterId);
        //AcknowledgmentLetterEmail batch2 = new AcknowledgmentLetterEmail(system.today(), system.today()+3);
        //AcknowledgmentLetterEmail batch3 = new AcknowledgmentLetterEmail(othersList[0].name,othersList[1].name);
        //batch.accIdRecConIdPubSubListMap = listMap;
        //batch.getAcknowledgmentDetails(letterPrint2);    
       
        ID batchprocessid = Database.executeBatch(batch1, 20);        
        System.assertNotEquals(null, batchprocessid); 
        Test.stopTest();
    }
    
    //jurna
    static testMethod void testBatch04() {
        
        //defaultCustomSetting(); // jurna-10-23-15
        // Test Data
        //setData01();
         
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        SPH_Section__c sect = createSection();
        SPH_Department__c dept  =  createDepartment();
        SPH_Division__c divi =  createDivision();
        SPH_Company__c comp = createCompany();
        SPH_Location__c loc = createLocation();
        Packing_Grp__c packGroup = createPackingGroup();
        List<Account> acc = createAccount01();
        Case caseRec = createCase(acc);
        List<City__c> city = createCity01(countryList);
        List<Address__c> add = createAddress01(countryList, singpostAddressList, sect, dept, divi, comp, loc, city , packGroup);
        List<Contact> con = createContact01(acc, city, add);
        List<Zuora__CustomerAccount__c> customerAcc2 = createZuoraCustomerAccount03(acc, con);
        Letter_Print_Request__c letterprint = createLetterPrintRequest01(customerAcc2); 
        List<Order__c> odr = createOrder03(acc, customerAcc2);
        List<Package__c> packageList = createPackage03();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem03(odr, packageList, promotionList);
        List<Zuora__Subscription__c> zSub = createZuoraSubscription04(acc, customerAcc2, odr, orderLineItemList, con, packageList);
        List<Case_Subscription__c> caseSub =  createCaseSubscription(acc, add,  zSub,  caseRec);
        
        System.debug('Letter_Type__c: '+letterprint.Letter_Type__c+ ' Acknowledgment_Type__c: '
        +letterprint.Acknowledgment_Type__c +' Sub_Created_Date__c: '+ letterprint.Sub_Created_Date__c +' Sub_Created_Date__c:'
        +letterprint.Sub_Created_Date__c +'  Generation_From__c: '+letterprint.Generation_From__c +' Generation_To__c: '+letterprint.Generation_To__c);
        Set<Id> LetterId = new Set<Id>();
        LetterId.add(letterprint.Id); 
        
        Document docu = new Document();
        docu.FolderId = userinfo.getUserId();
        docu.Name = 'SPH Logo v2';
        Blob bodyBlob = Blob.valueOf('SPH Logo v2');
        docu.body = bodyBlob;
        insert docu;
        
       
        //Test.startTest(); 
        // Test Proper 
        //AcknowledgmentLetterEmail batch = new AcknowledgmentLetterEmail();
        // AcknowledgmentLetterEmail batch1 = new AcknowledgmentLetterEmail(LetterId);
        AcknowledgmentLetterEmail batch2 = new AcknowledgmentLetterEmail(system.today(), system.today()+3);
        //AcknowledgmentLetterEmail batch3 = new AcknowledgmentLetterEmail(othersList[0].name,othersList[1].name);
        //batch.accIdRecConIdPubSubListMap = listMap;
        //batch.getAcknowledgmentDetails(letterPrint2);    
       
        ID batchprocessid = Database.executeBatch(batch2, 200 );        
        System.assertNotEquals(null, batchprocessid); 
        Test.stopTest();
    }
    
    //jurna
    static testMethod void testBatch05() {
        
        //defaultCustomSetting(); // jurna-10-23-15
        // Test Data
        //setData01();
         
        List<Zone__c> zoneList = createZone01();
        List<Country__c> countryList = createCountry01(zoneList);
        List<Singpost_Address__c> singpostAddressList = createPostalCode01();
        SPH_Section__c sect = createSection();
        SPH_Department__c dept  =  createDepartment();
        SPH_Division__c divi =  createDivision();
        SPH_Company__c comp = createCompany();
        SPH_Location__c loc = createLocation();
        Packing_Grp__c packGroup = createPackingGroup();
        List<Account> acc = createAccount01();
        List<City__c> city = createCity01(countryList);
        List<Address__c> add = createAddress01(countryList, singpostAddressList, sect, dept, divi, comp, loc, city , packGroup);
        List<Contact> con = createContact02(acc, city, add);
        List<Zuora__CustomerAccount__c> customerAcc2 = createZuoraCustomerAccount03(acc, con);
        List<Order__c> odr = createOrder03(acc, customerAcc2);
        List<Package__c> packageList = createPackage03();
        List<Promotion__c> promotionList = createPromotion01();
        List<Order_Line_Item__c> orderLineItemList = createOrderLineItem03(odr, packageList, promotionList);
        List<Zuora__Subscription__c> zSub = createZuoraSubscription04(acc, customerAcc2, odr, orderLineItemList, con, packageList);
        Case caseRec = createCase02(acc, zSub);
        List<Case_Subscription__c> caseSub =  createCaseSubscription(acc, add,  zSub,  caseRec);
        Letter_Print_Request__c letterprint = createLetterPrintRequest01(customerAcc2); 
        System.debug('Letter_Type__c: '+letterprint.Letter_Type__c+ ' Acknowledgment_Type__c: '
        +letterprint.Acknowledgment_Type__c +' Sub_Created_Date__c: '+ letterprint.Sub_Created_Date__c +' Sub_Created_Date__c:'
        +letterprint.Sub_Created_Date__c +'  Generation_From__c: '+letterprint.Generation_From__c +' Generation_To__c: '+letterprint.Generation_To__c);
        Set<Id> LetterId = new Set<Id>();
        LetterId.add(letterprint.Id); 
        
        Document docu = new Document();
        docu.FolderId = userinfo.getUserId();
        docu.Name = 'SPH Logo v2';
        Blob bodyBlob = Blob.valueOf('SPH Logo v2');
        docu.body = bodyBlob;
        insert docu;
        
        List<Letter_Print_Request__c> lprlist = new List<Letter_Print_Request__c>();
        lprlist.add(letterprint);
       
        //Test.startTest();  
        // Test Proper 
        //AcknowledgmentLetterEmail batch = new AcknowledgmentLetterEmail();
         //AcknowledgmentLetterEmail batch1 = new AcknowledgmentLetterEmail(LetterId);
        AcknowledgmentLetterEmail batch2 = new AcknowledgmentLetterEmail(system.today(), system.today()+3);
        //AcknowledgmentLetterEmail batch3 = new AcknowledgmentLetterEmail(othersList[0].name,othersList[1].name);
        //batch.accIdRecConIdPubSubListMap = listMap;
        //batch.getAcknowledgmentDetails(letterPrint2);    
       
        ID batchprocessid = Database.executeBatch(batch2, 200);      
        batch2.getAcknowledgmentDetails(lprlist); 
        System.assertNotEquals(null, batchprocessid); 
        Test.stopTest();
    }
    
    /*APRIL
    static testMethod void testBatch02() {
         
        // Test Data
        setData02();
        
     
        // Test Proper 
        AcknowledgmentLetterEmail batch = new AcknowledgmentLetterEmail();
        //batch.accIdRecConIdPubSubListMap = listMap;
        //batch.getAcknowledgmentDetails(letterPrint2);        
        ID batchprocessid = Database.executeBatch(batch, 5);        
        System.assertNotEquals(null, batchprocessid); 
    } APRIL*/
    //jurna-10-23-15
    /*static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
        
        
        List<Other__c> othersList = new List<Other__c>();
        for(Integer i = 0; i < 3 ; i++)
        {
        Other__c others = new Other__c();
        others.DateTime__c = system.Today(); //'21/10/2015 01:23';
        if (i == 0)
            {
            others.Name = 'SP18_SDT1';
            others.value__c = 'SP18_SDT1';
            }    
        else if (i== 1) {
            others.Name = 'SP18_SDT2';
            others.value__c = 'SP18_SDT2';
            }
        else {
            others.Name = 'SPH Logo v2';
            others.value__c = 'SPH Logo v2';
            }
        //others.Value__c = ;
        othersList.add(others);
        }
        insert othersList;
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
    } **/
}