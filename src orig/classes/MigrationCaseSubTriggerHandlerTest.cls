/**
* Class Name: <//MigrationCaseSubTriggerHandlerTest>
* @author: <ChristopherCamilon>
* Date: <4/20/2016>
* Requirement/Project Name: <SPH>
* @description<Test Class for //MigrationCaseSubTriggerHandlerTest, handles bulk insert and update>
*/

@isTest (Seealldata = TRUE)
public class MigrationCaseSubTriggerHandlerTest {
 
 /*
 *Method to test the trigger insert select and update of record
 */ 

          
  static testMethod void testMigratedTempStop(){

          
 
      //Id profileID = (Id) ConstantsSLB.getKeyId('Standard_User User');
     // System.debug('>>>>>>>>>>>>>>' + profileID);
      
      Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profile.Id,            
            //ProfileId = (Id) ConstantsSLB.getKeyId('Standard_User User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardmig@test.com'
        );
        System.runAs(u) {
            
            MigrationCaseSubTriggerHandler mig = new MigrationCaseSubTriggerHandler();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '6922';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;

            Package__c pack = TestDataFactory.createPackage(1)[0];
            Account acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acct.Contact_Person__c = 'asaasayt';
            acct.Singpost_Address__c = postal.Id;
            //acct.PostalCode__c = '1145';
            acct.Telephone_Number_1__c = '0122112';
            acct.Telephone_Number_2__c = '0211544';
            acct.Unit_Number__c = '021';
            insert new List<sObject>{pack, acct};
            
            List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
            zProductList[0].ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
            zProductList[0].ProductPlatform__c = 'Online';
            Database.insert(zProductList);
            //sObjectListMap_global.put('zqu__ZProduct__c', zProductList);
        
            List<zqu__ProductRatePlan__c> prdRatePlanList = TestDataFactory.createProductRatePlan(1);
            prdRatePlanList[0].zqu__ZProduct__c = zProductList[0].Id;
            prdRatePlanList[0].RatePlanType__c = 'Bill Plan'; 
            prdRatePlanList[0].RatePlanSubType__c = 'Standard'; 
            prdRatePlanList[0].Name = 'RATE_PLAN_NAME';
            Database.insert(prdRatePlanList);
           // sObjectListMap_global.put('zqu__ProductRatePlan__c', prdRatePlanList);
        
            List<Package_Item__c> packItemList = TestDataFactory.createPackageItem(1, 'Base Product');
            packItemList[0].Package__c = pack.id;
            packItemList[0].Product_Rate_Plan__c = prdRatePlanList[0].Id;   
            Database.insert(packItemList);
            //sObjectListMap_global.put('Package_Item__c', packItemList);
           
            Account acct2 = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acct2.Contact_Person__c = 'rsasayt';
            acct2.Singpost_Address__c = postal.Id;
            //acct2.PostalCode__c = '1155';
            acct2.Telephone_Number_1__c = '0122112';
            acct2.Telephone_Number_2__c = '0211544';
            acct2.Unit_Number__c = '021';
            insert acct2;
            
            Zone__c zone = new Zone__c();
            Zone.name = 'SG';
            insert zone;
            
            List<City__c> cityList = TestDataFactory.createCity(1);
            cityList[0].City_Name__c = 'cityName_test';
            cityList[0].Flight_Number_1__c = 'cityFlightNumber1_test';
            cityList[0].Flight_Number_2__c = 'cityFlightNumber2_test';
            insert cityList;
     
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SGN';
            country.Zone__c = zone.Id;
            
            insert country;
            
             //GAAC: Get RecordType Id
            Map<String, Id> mappedRecordType = new Map<String, Id>();
            for(RecordType crt : [SELECT Name, id FROM RecordType WHERE SObjectType = 'Address__c' LIMIT 2]) {
                MappedRecordType.put(crt.Name, crt.id);
              //  System.debug ('listing all address name: ' + crt.Name + ' Id: ' + crt.id); 
            }
             
            List<Address__c> addressRec = TestDataFactory.createAddress(1); 
            addressRec[0].Country__c = country.Id;
            addressRec[0].Postal_Code__c = postal.Id;
        
            addressRec[0].Address_Unique_Id__c = 'addrUniqueId_test';
            addressRec[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Local'); //NOTE 
            addressRec[0].Name = 'Overseas'; 
            addressRec[0].Address_1__c = 'add1';
            addressRec[0].Address_2__c = 'add2';
            addressRec[0].Address_3__c = 'add3';
            addressRec[0].Address_4__c = 'add4';
            addressRec[0].Address_1__c = 'address1_test2';
            addressRec[0].Address_2__c = 'address2_test2';
            insert addressRec;
            
            List<Contact> con = TestDataFactory.createContactRecType(1, 'Vendor-MA');
            con[0].AccountId = acct.Id;
            con[0].Address__c = addressRec[0].Id;
            con[0].Recipient_Indicator__c = true;
            con[0].City_Code__c = cityList[0].Id;         
            con[0].Billing_Indicator__c = true;
            con[0].Email__c = 'email@email.com';
            con[0].Email_Secondary__c = 'email2@email.com';
            con[0].Office_Number__c = '111-111-111';
            con[0].Mobile_Number__c = '111-111-111';
            con[0].HomePhone__c = '111-111-111';
            con[0].Fax__c = '111-111-111';
            con[0].zqu__County__c = 'zouraCountry_test';
            con[0].Description = 'contactDesc_test';  
            con[0].Firstname = 'Alfred';
            con[0].Lastname = 'Abrina';
           // con[0].Contact_Address_Detail__c = 'The address is here';
            insert con;
            
            //create postal Sector
            Postal_Zone__c pzc = new Postal_Zone__c();
            pzc.Name = 'myPostal';
            pzc.Postal_Zone__c = '00154as';
            pzc.Postal_Zone_Name__c = 'myPostal';
            pzc.Legacy_Created_Date__c   = '02/27/2015';
            pzc.Legacy_Created_By__c = 'Alfred';
            pzc.Legacy_Updated_Date__c  = '02/27/2015';
            pzc.Legacy_Updated_By__c = 'mytess';
            insert pzc;
            
            Integer postal_code_u;
            
            List<Contact> contacts = [Select Id, Address__r.Postal_Code__r.Name from Contact where Id =: con[0].Id LIMIT 2];
            for(Contact recipient : contacts){
                if (recipient.Address__r.Postal_Code__r.Name != null) {      
                    String subStrPostal = recipient.Address__r.Postal_Code__r.Name.substring(0,2);              
                    postal_code_u = integer.valueOf(subStrPostal);
                }
            }

//            System.assertNotEquals (2, postal_code_u);
            
			list<Post_Sector_Ops_Rep_Mapping__c> psoList = [select id, Postal_Sector_Code__c, Vendor_Ops__c, Zone__c, 
					Legacy_Created_Date__c, Legacy_Created_By__c, Legacy_Updated_Date__c, Legacy_Updated_By__c 
					from Post_Sector_Ops_Rep_Mapping__c where Postal_Sector_Code__c = :postal_code_u limit 1];
			
			Post_Sector_Ops_Rep_Mapping__c pso = new Post_Sector_Ops_Rep_Mapping__c();		
			
			if (!psoList.isEmpty()) {
	            pso = psoList[0];
            } else {
            	
	            pso.Postal_Sector_Code__c = postal_code_u;
	            pso.Vendor_Ops__c = u.Id;
	            pso.Zone__c = pzc.Id;
	            pso.Legacy_Created_Date__c   = '02/27/2015';
	            pso.Legacy_Created_By__c = 'Alfred';
	            pso.Legacy_Updated_Date__c  = '02/27/2015';
	            pso.Legacy_Updated_By__c = 'mytess';
	            insert pso;
        	}
             
            //System.debug ('vendorOps: ' +[Select Postal_Sector_Code__c, Vendor_Ops__c from Post_Sector_Ops_Rep_Mapping__c where Postal_Sector_Code__c =:pso.Postal_Sector_Code__c LIMIT 2]);
            System.assertEquals (con[0].address__c, [Select Address__c from Contact where Id =: con[0].Id LIMIT 2].Address__c);
            //System.debug ('Selecting Address_c alfred [Id, Address__c]: '+ [Select Id, Address__c from Contact where Id =: con[0].Id LIMIT 2]);
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acct.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con[0].Id;
            orderRec.Delivery_Charge__c = 4;
            orderRec.Order_Legacy_Id__c = '3421';
            orderRec.Legacy_Create_By__c = '1';
            orderRec.Legacy_Create_Date__c = '1';
            orderRec.Legacy_Update_By__c = '1';
            orderRec.Legacy_Update_Date__c = '1';
            orderRec.Monthly_Delivery_Charge_for_Full_Payment__c = 4;
            orderRec.Credit_Balance__c =1;
            insert orderRec;
            
            //System.debug ('Selecting from order: Alfred [Id, Recipient_Type__c, Account__c]' + [Select Id, Recipient_Type__c, Account__c from Order__c where Id =: orderRec.Id]);
           //System.assertEquals ('Overseas', orderRec.Recipient_Type__c);
            
           // System.debug ('Listing receipient contact from order level: ' + [Select Recipient_Contact__c from Order__c where Id =: orderRec.Id LIMIT 2]);
            
            //System.assertEquals(orderRec.Id, [Select Id from Order__c where Id =: orderRec.Id LIMIT 2].Id);
            
            //create publication
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Test';
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'NNNNNNN';
            pub.Publication_Type__c = 'N';
            insert pub;
         
            Order_Line_Item__c orderline2 = TestDataFactory.createOrderLineItem(1)[0];
            orderline2.Order__c = orderRec.Id;
            orderline2.End_Date__c = date.newInstance(2014, 12, 2);
            orderline2.Main_Package_ID__c = pack.Id;
            orderline2.Term_Length__c = 0;
            orderline2.Main_Package_Period__c = 0;
            orderline2.Earliest_Start_Date__c = date.today();
            orderline2.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline2.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline2.Terminating_Reason__c = 'Others';
            orderline2.Amount_To_Refund__c = 0;
            orderline2.Admin_Charge__c = 0;
            orderline2.Fee_Waiver__c = TRUE;
            //orderline2.Fee_Override__c = TRUE;
            orderline2.Fee_Override__c = FALSE;
            orderline2.Ph_e__c = FALSE;
            orderline2.Ph_d__c = FALSE;
            orderline2.Override_Reason__c = 'TEST';
            orderline2.Suppress_Notification_Stop__c = TRUE;
            orderline2.Main_Package_Type__c = 'Base';
            orderline2.Start_Date__c = date.today().addDays(2);
            orderline2.End_Date__c = Date.Today().addDays(10);
            orderline2.Main_Package_Billing_Type__c = 'Recurring Prepaid';
            insert orderline2;
            
            Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
            defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
            defaultPayment.Zuora__Account__c = acct.Id; 
            insert defaultPayment;
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Main_Package_1__c = pack.Id;
            sub.Zuora__Zuora_Id__c = 'sampleId';
            sub.Zuora__Account__c = acct.Id;
            sub.Subscriber_Contact__c = con[0].Id;
            sub.Recipient_Contact__c  = con[0].Id;
            sub.Order_Number__c = orderRec.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__SubscriptionStartDate__c = date.Today();
            //sub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            sub.Zuora__SubscriptionEndDate__c = date.Today()+365;           
            sub.Billing_Type__c = 'Full Prepaid';
            sub.Charity__c = 'TRUE';
            sub.Contract_End_Date__c = String.valueof(date.Today());
            sub.New_Contract_Period__c = '1';
            sub.Penalty_Charge__c = '1000';
            sub.Promotion_Contract_Period__c = '2';
            sub.Suppress_Vendor_Start_Notice__c = 'TRUE';
            sub.Supressed_Acknowledgement_Letter__c = 'TRUE';
            sub.Supressed_Renewal_and_Reminder_Letter__c = 'TRUE';
            sub.Urgent__c= 'TRUE';
            sub.Frequency_1__c = 'Default';
            sub.Vendor__c = acct.Id ;
            sub.Vendor_Conversion__c = 'TRUE';
            sub.Order_Line_Item_Number__c = orderline2.Id;        
            sub.Zuora__CustomerAccount__c = defaultPayment.Id; 
            sub.Delivery_Charge__c = 100;
            sub.Term_Length__c = 30;
            
            insert sub;
            //Test.startTest();     
            /*Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];          
            insert SubVend; */
            
            Temp_Stop__c tsc = new Temp_Stop__c();
            tsc.Legacy_Create_Date__c = '02/10/2015';
            tsc.Legacy_Create_By__C = 'Alfred A';
            tsc.Legacy_Update_Date__c = '02/15/2015';
            tsc.Temp_Stop_Date__c = date.Today() + 1;
            tsc.Restart_Date__c = date.Today() + 19;
            tsc.qty__c = 1;
            tsc.Legacy_Update_By__c = 'GGASS';
            tsc.Cancelled__c = true;
            tsc.Order__c = orderRec.Id;
            insert tsc;
            
            Temp_Stop__c tsc2 = new Temp_Stop__c();
            tsc2.Legacy_Create_Date__c = '02/10/2015';
            tsc2.Legacy_Create_By__C = 'Alfred A';
            tsc2.Legacy_Update_Date__c = '02/15/2015';
            tsc2.Temp_Stop_Date__c = date.Today() + 1;
            tsc2.Restart_Date__c = date.Today() + 3;
            tsc2.qty__c = 1;
            tsc2.Legacy_Update_By__c = 'GGASS';
            tsc2.Cancelled__c = true;
            tsc2.Order__c = orderRec.Id;
            insert tsc2;
            
            System.runAs(u){
            
            List<Case> caseSub = TestDataFactory.createCase(2, 'Complaint - Newspaper');
            for (Case caseData: caseSub){
                caseData.AccountId = acct.Id;
                caseData.ContactId = con[0].Id;
                caseData.Order__c = orderRec.Id;
                caseData.Origin = 'Email';
                caseData.Outcome__c = 'Retained';
                caseData.Urgent_Request__c = true; 
                caseData.Requires_Urgent_Approval__c = true;                      
                caseData.Rejected_Renewal__c = true;   
                caseData.Category__c = 'Subscription Request';
                caseData.Sub_Category__c = 'Start Subscription';  
                caseData.Recipient_Address__c = addressRec[0].Id;
                caseData.Recipient__c = con[0].Id; 
                caseData.New_Order_Details__c = orderRec.Id;    
                caseData.Order_Number__c = orderRec.Id; 
            }
            
            caseSub[0].Earliest_Stop_Date__c = date.today();
            caseSub[0].Stop_Request_Date__c = date.today();           
            caseSub[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Temp Stop');
            //caseSub[0].Status = GlobalVariableClass.STATUS_CLOSED;
            //aseSub[0].Sub_Status__c = 'Temp Stop Approved';             
            caseSub[0].Requires_Urgent_Approval__c = true;
            caseSub[0].Temp_Stop__c = tsc.Id;
            //caseSub[0].Temp_Stop_Sub__c = sub.Id;
            
            caseSub[1].Earliest_Stop_Date__c = date.today();
            caseSub[1].Stop_Request_Date__c = date.today();             
            caseSub[1].RecordTypeId = ConstantsSLB.getKeyId('Case_Temp Stop');
            caseSub[1].Temp_Stop__c = tsc2.Id;
            //caseSub[0].Temp_Stop_Sub__c = sub.Id;
            
            
            insert caseSub;
            
            //update caseSub; 
            //caseSub[0].Sub_Status__c = GlobalVariableClass.TEMP_STOP_APPROVED;
            //caseSub[1].Sub_Status__c = 'Goodwill Approved';
           // caseSub[0].Temp_Stop_Sub__c = sub.Id;
            //caseSub[1].Temp_Stop_Sub__c = sub.Id;
           // update caseSub;  
            
            Case_Subscription__c newCasesub = new Case_Subscription__c();
            newCasesub.Case__c = caseSub[0].id;
            newCasesub.Subscription__c = sub.id;   
            newCasesub.Account__c = acct.Id;         
            insert newCasesub;
            Test.startTest();
            mig.runBeforeInsertTrigger();
            mig.runAfterInsertTrigger();
            mig.runBeforeUpdateTrigger();
            mig.runAfterUpdateTrigger();
            mig.runBeforeDeleteTrigger();
            mig.runAfterDeleteTrigger();
            mig.beforeInsert(newCasesub);
            mig.beforeUpdate(newCasesub,newCasesub);
            mig.AfterInsert(newCasesub);
            mig.AfterUpdate(newCasesub,newCasesub); 
            //mig.bulkBefore();          
            
            mig.andFinally();
            
         
            
          }
               
            Test.stopTest();

    } 

}
}