/**
* Class Name: PackingLabelsController_Test
* @author: Accenture IDC - Nilesh
* Date: 26/2/2015
* @Description: This class is used to code coverage of the PackingLabelsController class.
*
*/
@isTest (Seealldata=true)
public class PackingLabelsController_Test
{

    static testMethod void testMe01() {
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
           
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
                acc.AccountNumber = dbAcc.AccountNumber;
                //acc.Generate_Account_Number__c = true;
                //acc.Account_Auto_Number__c = '1';
                insert acc;
                //objectMap.put('Account', acc);
                
                //System.assertEquals('', acc.AccountNumber);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.Publication_Code__c = 'CO12';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                //zprpc.PublicationCode__c = 'TestCode';
                zprpc.PublicationCode__c = 'NT'; //jurna
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country.Code__c = 'UNIQUE123';
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                RecordType rectype = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Address__C' AND DeveloperName = 'Airline'];
                addressRec.RecordtypeId = rectype.id;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Address_Type__c = 'A';
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                //Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');// addRecId;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                                                   
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
             /*   Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;*/
                //objectMap.put('Billing Contact', con1);   
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
                /*
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Order_Line_Item_Number__c = orderline.id;
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Frequency_1__c = 'Mon-Fri';
                insert subRecs;*/
     /* airlineSubList = [SELECT id, name, Recipient_Contact__r.Name, Recipient_Contact__c, Frequency_1__c
                              FROM Zuora__Subscription__c 
                              WHERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__Status__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];*/
                                              
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               //packLabelBatch.Subscription__c = zsub.Id;
               // OK: packLabelBatch.Subscription__c = 'a0XN0000001JsnM';
               
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Subscriber_Account_Number__c = dbAcc.AccountNumber;
                insert packLabelBatch;  
                
                 List<Zuora__Subscription__c> subRecs2 = TestDataFactory.createSubscription(1);
                subRecs2[0].Zuora__Account__c = acc.Id;
                subRecs2[0].Zuora__Zuora_Id__c = '1123';
                subRecs2[0].Zuora__SubscriptionStartDate__c = date.today();
                subRecs2[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs2[0].Subscriber_Contact__c = con.Id;
                subRecs2[0].Recipient_Contact__c = con.Id;
                subRecs2[0].Main_Package_1__c = pack.id;
                subRecs2[0].Main_Package__c = pack.id;
                subRecs2[0].Zuora__Status__c = 'Active';
                subRecs2[0].Order_Number__c = order.Id;
                subRecs2[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs2[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs2[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs2[0].Urgent__c = 'false';
                subRecs2[0].Vendor_Conversion__c = 'false';
                subRecs2[0].Charity__c = 'false';
                subRecs2[0].Billing_Type__c = 'Full Prepaid';
                subRecs2[0].Order_Line_Item_Number__c = orderline.id;
                subRecs2[0].Order_Line_Item_Number_1__c = orderline.id;
                subRecs2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs2[0].Zuora__CustomerAccount__c = billAcc.id;
                subRecs2[0].Delivered_By_1__c = 'Mailing Agent';
                subRecs2[0].Frequency_1__c = 'Mon - Fri';
                subRecs2[0].Frequency__c = 'Mon - Fri';
                insert subRecs2;
                /*HERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__SubscriptionStartDate__c <= :todayDate AND (Zuora__SubscriptionEndDate__c >= :todayDate or Zuora__SubscriptionEndDate__c = null)
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];*/
                packLabelBatch.Subscription__c = subRecs2[0].id;
                update packLabelBatch;
                  
                System.debug('APRIL:subscription_type__c' + subRecs2[0].Subscription_Type_1__c);
                System.debug('APRIL:addRecordTypeId ' + addressRec.RecordTypeId );
                System.debug('APRIL:Zuora__Status__c' + subRecs2[0].Zuora__Status__c);
                System.debug('APRIL:AccountNumber:' + acc.AccountNumber );
                System.debug('APRIL:packinglabelbatch:' + packLabelBatch.Subscriber_Account_Number__c );
                                          
                Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubscriptionProductCharge(1)[0];
                subProdCharge.Zuora__Subscription__c =  subRecs2[0].id;
                subProdCharge.Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdCharge.Zuora__Quantity__c =  100.00;
                //subProdCharge.PublicationCode__c = 'CODE00124';
                subProdCharge.PublicationCode__c = 'ST'; //jurna
                insert subProdCharge;
                
                     
                
                
                
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                
                // TEST Proper            
                PageReference pageRef = Page.AirlineSubscriptions;
                pageRef.getParameters().put('id', packLabelBatch.Id);
                Test.setCurrentPage(pageRef);
            
            //System.assertEquals('',packLabelBatch.Subscriber_Account_Number__c);
                
                Set<String> mapString = new Set<String>();
                mapString.add('CODE123');
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                subIdPubCodeSetMap.put(pub.id,mapString);
                Set<String> subIdSet = new Set<String>();
                subIdSet.add(subRecs2[0].Id);
            
                     
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();      
                
                testInstance.overseasReportHardCopy(subIdSet);
                testInstance.initializeOSW();
                testInstance.initializeAirline();
                testInstance.initializeMagazineWrap();
                testInstance.PackingLabelsControllerClass();
                Map<Id, Map<String, Integer>> sampleMap =  testInstance.getPublication(subRecs2, subIdPubCodeSetMap);
                testInstance.getGeneralDetails();
                //testInstance.getTotalPublications();
                testInstance.airlineReportHardCopy();
                
                test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}
    }
     //jurna
     static testMethod void testMe02() {
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
           
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
                acc.AccountNumber = dbAcc.AccountNumber;
                //acc.Generate_Account_Number__c = true;
                //acc.Account_Auto_Number__c = '1';
                insert acc;
                //objectMap.put('Account', acc);
                
                //System.assertEquals('', acc.AccountNumber);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.Publication_Code__c = 'CO12';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                //zprpc.PublicationCode__c = 'TestCode';
                zprpc.PublicationCode__c = 'NT'; //jurna
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country.Code__c = 'UNIQUE123'; //jurna
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country;
                
                 //Create Country   
                Country__c country2 = TestDataFactory.createCountry(1)[0];
                country2.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country2.Code__c = 'testb'; //jurna
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country2;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                RecordType rectype = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Address__C' AND DeveloperName = 'Airline'];
                addressRec.RecordtypeId = rectype.id;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Address_Type__c = 'A';
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                //Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');// addRecId;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country2.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                                                   
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id; //jurna
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
             /*   Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;*/
                //objectMap.put('Billing Contact', con1);   
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
                /*
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Order_Line_Item_Number__c = orderline.id;
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Frequency_1__c = 'Mon-Fri';
                insert subRecs;*/
     /* airlineSubList = [SELECT id, name, Recipient_Contact__r.Name, Recipient_Contact__c, Frequency_1__c
                              FROM Zuora__Subscription__c 
                              WHERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__Status__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];*/
                                              
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               //packLabelBatch.Subscription__c = zsub.Id;
               // OK: packLabelBatch.Subscription__c = 'a0XN0000001JsnM';
               
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Subscriber_Account_Number__c = dbAcc.AccountNumber;
                insert packLabelBatch;  
                
                 List<Zuora__Subscription__c> subRecs2 = TestDataFactory.createSubscription(1);
                subRecs2[0].Zuora__Account__c = acc.Id;
                subRecs2[0].Zuora__Zuora_Id__c = '1123';
                subRecs2[0].Zuora__SubscriptionStartDate__c = date.today();
                subRecs2[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs2[0].Subscriber_Contact__c = con.Id;
                subRecs2[0].Recipient_Contact__c = con.Id;
                subRecs2[0].Main_Package_1__c = pack.id;
                subRecs2[0].Main_Package__c = pack.id;
                subRecs2[0].Zuora__Status__c = 'Active';
                subRecs2[0].Order_Number__c = order.Id;
                subRecs2[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs2[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs2[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs2[0].Urgent__c = 'false';
                subRecs2[0].Vendor_Conversion__c = 'false';
                subRecs2[0].Charity__c = 'false';
                subRecs2[0].Billing_Type__c = 'Full Prepaid';
                subRecs2[0].Order_Line_Item_Number__c = orderline.id;
                subRecs2[0].Order_Line_Item_Number_1__c = orderline.id;
                subRecs2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs2[0].Zuora__CustomerAccount__c = billAcc.id;
                subRecs2[0].Delivered_By_1__c = 'Mailing Agent';
                subRecs2[0].Frequency_1__c = 'Mon - Fri';
                subRecs2[0].Frequency__c = 'Mon - Fri';
                subRecs2[0].Number_of_Copies__c = 10;
                insert subRecs2;
                /*HERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__SubscriptionStartDate__c <= :todayDate AND (Zuora__SubscriptionEndDate__c >= :todayDate or Zuora__SubscriptionEndDate__c = null)
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];*/
                packLabelBatch.Subscription__c = subRecs2[0].id;
                update packLabelBatch;
                  
                System.debug('APRIL:subscription_type__c' + subRecs2[0].Subscription_Type_1__c);
                System.debug('APRIL:addRecordTypeId ' + addressRec.RecordTypeId );
                System.debug('APRIL:Zuora__Status__c' + subRecs2[0].Zuora__Status__c);
                System.debug('APRIL:AccountNumber:' + acc.AccountNumber );
                System.debug('APRIL:packinglabelbatch:' + packLabelBatch.Subscriber_Account_Number__c );
                                          
                Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubscriptionProductCharge(1)[0];
                subProdCharge.Zuora__Subscription__c =  subRecs2[0].id;
                subProdCharge.Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdCharge.Zuora__Quantity__c =  100.00;
                //subProdCharge.PublicationCode__c = 'CODE00124';
                subProdCharge.PublicationCode__c = 'ST'; //jurna
                insert subProdCharge;
                
                     
                
                
                
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                
                // TEST Proper            
                PageReference pageRef = Page.AirlineSubscriptions;
                pageRef.getParameters().put('id', packLabelBatch.Id);
                Test.setCurrentPage(pageRef);
            
            //System.assertEquals('',packLabelBatch.Subscriber_Account_Number__c);
                
                Set<String> mapString = new Set<String>();
                mapString.add('CODE123');
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                subIdPubCodeSetMap.put(pub.id,mapString);
                Set<String> subIdSet = new Set<String>();
                subIdSet.add(subRecs2[0].Id);
            
                     
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();      
                
                testInstance.overseasReportHardCopy(subIdSet);
                testInstance.initializeOSW();
                testInstance.initializeAirline();
                testInstance.initializeMagazineWrap();
                testInstance.PackingLabelsControllerClass();
                Map<Id, Map<String, Integer>> sampleMap =  testInstance.getPublication(subRecs2, subIdPubCodeSetMap);
                testInstance.getGeneralDetails();
                //testInstance.getTotalPublications();
                testInstance.airlineReportHardCopy();
                
                test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}
    }
    
    //jurna
     static testMethod void testMe02b() {
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
           
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
                acc.AccountNumber = dbAcc.AccountNumber;
                //acc.Generate_Account_Number__c = true;
                //acc.Account_Auto_Number__c = '1';
                insert acc;
                //objectMap.put('Account', acc);
                
                //System.assertEquals('', acc.AccountNumber);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.Publication_Code__c = 'CO12';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                //zprpc.PublicationCode__c = 'TestCode';
                zprpc.PublicationCode__c = 'NT'; //jurna
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                /*
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;*/
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country.Code__c = 'UNIQUE123'; //jurna
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country;
                
                 //Create Country   
                Country__c country2 = TestDataFactory.createCountry(1)[0];
                country2.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country2.Code__c = 'testb'; //jurna
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country2;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                RecordType rectype = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Address__C' AND DeveloperName = 'Airline'];
                addressRec.RecordtypeId = rectype.id;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Address_Type__c = 'A';
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                //Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');// addRecId;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Postal_Code__c = postal.Id;
                //addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country2.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                                                   
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id; //jurna
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
             /*   Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;*/
                //objectMap.put('Billing Contact', con1);   
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
                /*
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Order_Line_Item_Number__c = orderline.id;
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Frequency_1__c = 'Mon-Fri';
                insert subRecs;*/
     /* airlineSubList = [SELECT id, name, Recipient_Contact__r.Name, Recipient_Contact__c, Frequency_1__c
                              FROM Zuora__Subscription__c 
                              WHERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__Status__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];*/
                                              
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               //packLabelBatch.Subscription__c = zsub.Id;
               // OK: packLabelBatch.Subscription__c = 'a0XN0000001JsnM';
               
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Subscriber_Account_Number__c = dbAcc.AccountNumber;
                insert packLabelBatch;  
                
                
                
                 List<Zuora__Subscription__c> subRecs2 = TestDataFactory.createSubscription(1);
                subRecs2[0].Zuora__Account__c = acc.Id;
                subRecs2[0].Zuora__Zuora_Id__c = '1123';
                subRecs2[0].Zuora__SubscriptionStartDate__c = date.today();
                subRecs2[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs2[0].Subscriber_Contact__c = con.Id;
                subRecs2[0].Recipient_Contact__c = con.Id;
                subRecs2[0].Main_Package_1__c = pack.id;
                subRecs2[0].Main_Package__c = pack.id;
                subRecs2[0].Zuora__Status__c = 'Active';
                subRecs2[0].Order_Number__c = order.Id;
                subRecs2[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs2[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs2[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs2[0].Urgent__c = 'false';
                subRecs2[0].Vendor_Conversion__c = 'false';
                subRecs2[0].Charity__c = 'false';
                subRecs2[0].Billing_Type__c = 'Full Prepaid';
                subRecs2[0].Order_Line_Item_Number__c = orderline.id;
                subRecs2[0].Order_Line_Item_Number_1__c = orderline.id;
                subRecs2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs2[0].Zuora__CustomerAccount__c = billAcc.id;
                subRecs2[0].Delivered_By_1__c = 'Mailing Agent';
                subRecs2[0].Frequency_1__c = 'Mon - Fri';
                subRecs2[0].Frequency__c = 'Mon - Fri';
                subRecs2[0].Number_of_Copies__c = 10;
                subRecs2[0].Number_of_Copies1__c = '10';
                insert subRecs2;
                /*HERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__SubscriptionStartDate__c <= :todayDate AND (Zuora__SubscriptionEndDate__c >= :todayDate or Zuora__SubscriptionEndDate__c = null)
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];*/
                packLabelBatch.Subscription__c = subRecs2[0].id;
                update packLabelBatch;
                  
                System.debug('APRIL:subscription_type__c' + subRecs2[0].Subscription_Type_1__c);
                System.debug('APRIL:addRecordTypeId ' + addressRec.RecordTypeId );
                System.debug('APRIL:Zuora__Status__c' + subRecs2[0].Zuora__Status__c);
                System.debug('APRIL:AccountNumber:' + acc.AccountNumber );
                System.debug('APRIL:packinglabelbatch:' + packLabelBatch.Subscriber_Account_Number__c );
                                          
                Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubscriptionProductCharge(1)[0];
                subProdCharge.Zuora__Subscription__c =  subRecs2[0].id;
                subProdCharge.Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdCharge.Zuora__Quantity__c =  100.00;
                //subProdCharge.PublicationCode__c = 'CODE00124';
                subProdCharge.PublicationCode__c = 'ST'; //jurna
                insert subProdCharge;
                /*
                 PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);    */
 
                
                
                // TEST Proper            
                PageReference pageRef = Page.AirlineSubscriptions;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                //ApexPages.currentPage().getParameters().put('id', acc.id);
                //pageRef.getParameters().put('id', packLabelBatch.Id);
                
            
            //System.assertEquals('',packLabelBatch.Subscriber_Account_Number__c);
                
                Set<String> mapString = new Set<String>();
                mapString.add('CODE123');
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                subIdPubCodeSetMap.put(pub.id,mapString);
                Set<String> subIdSet = new Set<String>();
                subIdSet.add(subRecs2[0].Id);
            
                     
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();      
                
                testInstance.overseasReportHardCopy(subIdSet);
                testInstance.initializeOSW();
                //testInstance.initializeAirline();
                testInstance.initializeMagazineWrap();
                testInstance.PackingLabelsControllerClass();
                Map<Id, Map<String, Integer>> sampleMap =  testInstance.getPublication(subRecs2, subIdPubCodeSetMap);
                testInstance.getGeneralDetails();
                //testInstance.getTotalPublications();
                testInstance.airlineReportHardCopy();
                
                test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}
    }
    
     //jurna
     static testMethod void testMe02bb() {
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
           
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
                acc.AccountNumber = dbAcc.AccountNumber;
                //acc.Generate_Account_Number__c = true;
                //acc.Account_Auto_Number__c = '1';
                insert acc;
                //objectMap.put('Account', acc);
                
                //System.assertEquals('', acc.AccountNumber);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.Publication_Code__c = 'CO12';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                //zprpc.PublicationCode__c = 'TestCode';
                zprpc.PublicationCode__c = 'NT'; //jurna
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                /*
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;*/
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country.Code__c = 'UNIQUE123'; //jurna
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country;
                
                 //Create Country   
                Country__c country2 = TestDataFactory.createCountry(1)[0];
                country2.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country2.Code__c = 'testb'; //jurna
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country2;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                RecordType rectype = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Address__C' AND DeveloperName = 'Airline'];
                addressRec.RecordtypeId = rectype.id;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Address_Type__c = 'A';
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                //Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');// addRecId;
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Postal_Code__c = postal.Id;
                //addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country2.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                                                   
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id; //jurna
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
             /*   Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;*/
                //objectMap.put('Billing Contact', con1);   
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
                /*
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Order_Line_Item_Number__c = orderline.id;
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Frequency_1__c = 'Mon-Fri';
                insert subRecs;*/
     /* airlineSubList = [SELECT id, name, Recipient_Contact__r.Name, Recipient_Contact__c, Frequency_1__c
                              FROM Zuora__Subscription__c 
                              WHERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__Status__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];*/
                                              
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               //packLabelBatch.Subscription__c = zsub.Id;
               // OK: packLabelBatch.Subscription__c = 'a0XN0000001JsnM';
               packLabelBatch.Account_Name__c = acc.id;
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Subscriber_Account_Number__c = dbAcc.AccountNumber;
                insert packLabelBatch;  
                
                
                
                 List<Zuora__Subscription__c> subRecs2 = TestDataFactory.createSubscription(1);
                subRecs2[0].Zuora__Account__c = acc.Id;
                subRecs2[0].Zuora__Zuora_Id__c = '1123';
                subRecs2[0].Zuora__SubscriptionStartDate__c = date.today();
                subRecs2[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs2[0].Subscriber_Contact__c = con.Id;
                subRecs2[0].Recipient_Contact__c = con.Id;
                subRecs2[0].Main_Package_1__c = pack.id;
                subRecs2[0].Main_Package__c = pack.id;
                subRecs2[0].Zuora__Status__c = 'Active';
                subRecs2[0].Order_Number__c = order.Id;
                subRecs2[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs2[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs2[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs2[0].Urgent__c = 'false';
                subRecs2[0].Vendor_Conversion__c = 'false';
                subRecs2[0].Charity__c = 'false';
                subRecs2[0].Billing_Type__c = 'Full Prepaid';
                subRecs2[0].Order_Line_Item_Number__c = orderline.id;
                subRecs2[0].Order_Line_Item_Number_1__c = orderline.id;
                subRecs2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs2[0].Zuora__CustomerAccount__c = billAcc.id;
                subRecs2[0].Delivered_By_1__c = 'Mailing Agent';
                subRecs2[0].Frequency_1__c = 'Mon - Fri';
                subRecs2[0].Frequency__c = 'Mon - Fri';
                subRecs2[0].Number_of_Copies__c = 10;
                subRecs2[0].Number_of_Copies1__c = '10';
                insert subRecs2;
                /*HERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__SubscriptionStartDate__c <= :todayDate AND (Zuora__SubscriptionEndDate__c >= :todayDate or Zuora__SubscriptionEndDate__c = null)
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];*/
                packLabelBatch.Subscription__c = subRecs2[0].id;
                update packLabelBatch;
                  
                System.debug('APRIL:subscription_type__c' + subRecs2[0].Subscription_Type_1__c);
                System.debug('APRIL:addRecordTypeId ' + addressRec.RecordTypeId );
                System.debug('APRIL:Zuora__Status__c' + subRecs2[0].Zuora__Status__c);
                System.debug('APRIL:AccountNumber:' + acc.AccountNumber );
                System.debug('APRIL:packinglabelbatch:' + packLabelBatch.Subscriber_Account_Number__c );
                                          
                Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubscriptionProductCharge(1)[0];
                subProdCharge.Zuora__Subscription__c =  subRecs2[0].id;
                subProdCharge.Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdCharge.Zuora__Quantity__c =  100.00;
                //subProdCharge.PublicationCode__c = 'CODE00124';
                subProdCharge.PublicationCode__c = 'ST'; //jurna
                insert subProdCharge;
                /*
                 PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);    */
 
                
                
                // TEST Proper            
                PageReference pageRef = Page.AirlineSubscriptions;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                //ApexPages.currentPage().getParameters().put('id', acc.id);
                //pageRef.getParameters().put('id', packLabelBatch.Id);
                
            
            //System.assertEquals('',packLabelBatch.Subscriber_Account_Number__c);
                
                Set<String> mapString = new Set<String>();
                mapString.add('CODE123');
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                subIdPubCodeSetMap.put(pub.id,mapString);
                Set<String> subIdSet = new Set<String>();
                subIdSet.add(subRecs2[0].Id);
            
                     
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();      
                
                testInstance.overseasReportHardCopy(subIdSet);
                testInstance.initializeOSW();
                //testInstance.initializeAirline();
                testInstance.initializeMagazineWrap();
                testInstance.PackingLabelsControllerClass();
                Map<Id, Map<String, Integer>> sampleMap =  testInstance.getPublication(subRecs2, subIdPubCodeSetMap);
                testInstance.getGeneralDetails();
                //testInstance.getTotalPublications();
                testInstance.airlineReportHardCopy();
                
                test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}
    }
    
    static testMethod void testAddressLocal() {
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
            //createCustomSettings();
            
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
              //acc.AccountNumber = '12345';  //Retrieve from DB
                acc.AccountNumber = dbAcc.AccountNumber;
              //acc.Generate_Account_Number__c = true;
                //acc.Account_Auto_Number__c = '1';
                insert acc;
                //objectMap.put('Account', acc);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.Publication_Code__c = 'CO12';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country.Code__c = 'UNIQUE123';
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Address_Type__c = 'A';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
            
               /* Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                addressRec.RecordTypeId = addRecId;*/
                addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                                                   
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
                Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;
                //objectMap.put('Billing Contact', con1);   
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con1.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
                
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionStartDate__c = date.today();
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Order_Line_Item_Number__c = orderline.id;
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Frequency_1__c = 'Mon - Fri';
                subRecs.Frequency__c = 'Mon - Fri';
                insert subRecs;
                
               
          
                Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubscriptionProductCharge(1)[0];
                subProdCharge.Zuora__Subscription__c =  subRecs.id;
                subProdCharge.Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdCharge.Zuora__Quantity__c =  100.00;
                //subProdCharge.PublicationCode__c = 'CODE00124';
                subProdCharge.PublicationCode__c = 'BT'; //jurna
                insert subProdCharge;
            
                
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               //packLabelBatch.Subscription__c = zsub.Id;
               // OK: packLabelBatch.Subscription__c = 'a0XN0000001JsnM';
                packLabelBatch.Subscription__c = subRecs.id;
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Subscriber_Account_Number__c = acc.AccountNumber;
                insert packLabelBatch;  
                
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                
                // TEST Proper            
                PageReference pageRef = Page.AirlineSubscriptions;
                pageRef.getParameters().put('id', packLabelBatch.Id);
                Test.setCurrentPage(pageRef);
                
                
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();                
                testInstance.initializeOSW();
                testInstance.initializeAirline();
                testInstance.initializeMagazineWrap();
                testInstance.PackingLabelsControllerClass();
                testInstance.querySub(addressRec.RecordTypeId, pub.Publication_Type__c);
                
                testInstance.getGeneralDetails();
                //testInstance.getTotalPublications();
                testInstance.airlineReportHardCopy();
                
                test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}
    }
    
  
   static testMethod void testAddressInternal() {
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
            //createCustomSettings();
            
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
              //acc.AccountNumber = '12345';  //Retrieve from DB
                acc.AccountNumber = dbAcc.AccountNumber;
              //acc.Generate_Account_Number__c = true;
                //acc.Account_Auto_Number__c = '1';
                insert acc;
                //objectMap.put('Account', acc);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country.Code__c = 'UNIQUE123';
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal'); 
               // addressRec.Address_Type__c = 'A';
                addressRec.Postal_Code__c = postal.Id;
               /* addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                addressRec.RecordTypeId = addRecId;*/
                addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                                                  
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
                Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;
                //objectMap.put('Billing Contact', con1);   
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con1.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
                
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionStartDate__c = date.today();
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                //subRecs.Recipient_Contact_1__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Order_Line_Item_Number__c = orderline.id;
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Frequency_1__c = 'Fri - Sun';
                subRecs.Frequency__c = 'Fri - Sun';
                insert subRecs;
          
                Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubscriptionProductCharge(1)[0];
                subProdCharge.Zuora__Subscription__c =  subRecs.id;
                subProdCharge.Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdCharge.Zuora__Quantity__c =  100.00;
                //subProdCharge.PublicationCode__c = 'CODE00124';
                subProdCharge.PublicationCode__c = 'TM'; //jurna
                               
                insert subProdCharge;
            
                
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               //packLabelBatch.Subscription__c = zsub.Id;
               // OK: packLabelBatch.Subscription__c = 'a0XN0000001JsnM';
                packLabelBatch.Subscription__c = subRecs.id;
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Address_1__c = 'Address1';
                packLabelBatch.Address_2__c = 'Address2';
                packLabelBatch.Address_3__c = 'Address3';
                packLabelBatch.Address_4__c = 'Address4';
                packLabelBatch.Address_5__c = 'Address5';
                packLabelBatch.Subscriber_Account_Number__c = acc.AccountNumber;
                insert packLabelBatch;  
                
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                
                // TEST Proper            
                PageReference pageRef = Page.AirlineSubscriptions;
                pageRef.getParameters().put('id', packLabelBatch.Id);
                Test.setCurrentPage(pageRef);
            
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();                
                testInstance.initializeOSW();
                testInstance.initializeAirline();
                testInstance.initializeMagazineWrap();
                testInstance.PackingLabelsControllerClass();
                testInstance.getGeneralDetails();
                //testInstance.getTotalPublications();
                testInstance.airlineReportHardCopy();
                
                test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}
   }
     static testMethod void testAddressOverseas() { 
            try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
            //createCustomSettings();
            
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
              //acc.AccountNumber = '12345';  //Retrieve from DB
                acc.AccountNumber = dbAcc.AccountNumber;
              //acc.Generate_Account_Number__c = true;
                //acc.Account_Auto_Number__c = '1';
                insert acc;
                //objectMap.put('Account', acc);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country.Code__c = 'UNIQUE123';
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas'); 
               // addressRec.Address_Type__c = 'A';
                addressRec.Postal_Code__c = postal.Id;
       
               /* addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
             Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                addressRec.RecordTypeId = addRecId;*/
                addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                                                  
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
                Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;
                //objectMap.put('Billing Contact', con1);   
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con1.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
              
                
                Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__Account__c = acc.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Zuora__SubscriptionStartDate__c = date.today();
                subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Main_Package_1__c = pack.id;
                subRecs.Main_Package__c = pack.id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs.Urgent__c = 'false';
                subRecs.Vendor_Conversion__c = 'false';
                subRecs.Charity__c = 'false';
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Order_Line_Item_Number__c = orderline.id;
                subRecs.Order_Line_Item_Number_1__c = orderline.id;
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs.Zuora__CustomerAccount__c = billAcc.id;
                subRecs.Delivered_By_1__c = 'Mailing Agent';
                subRecs.Recipient_Contact__c = con.Id;
                insert subRecs;
          
                Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubscriptionProductCharge(1)[0];
                subProdCharge.Zuora__Subscription__c =  subRecs.id;
                subProdCharge.Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdCharge.Zuora__Quantity__c =  100.00;
                //subProdCharge.PublicationCode__c = 'CODE00124';
                subProdCharge.PublicationCode__c = 'ZB'; //jurna
                insert subProdCharge;
            
                
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               //packLabelBatch.Subscription__c = zsub.Id;
               // OK: packLabelBatch.Subscription__c = 'a0XN0000001JsnM';
                packLabelBatch.Subscription__c = subRecs.id;
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Address_1__c = 'Address1';
                packLabelBatch.Address_2__c = 'Address2';
                packLabelBatch.Address_3__c = 'Address3';
                packLabelBatch.Address_4__c = 'Address4';
                packLabelBatch.Address_5__c = 'Address5';
                packLabelBatch.Subscriber_Account_Number__c = acc.AccountNumber;
                insert packLabelBatch;  
                
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                
                // TEST Proper            
                PageReference pageRef = Page.AirlineSubscriptions;
                pageRef.getParameters().put('id', packLabelBatch.Id);
                Test.setCurrentPage(pageRef);
            
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();                
                testInstance.initializeOSW();
                testInstance.initializeAirline();
                testInstance.initializeMagazineWrap();
                testInstance.PackingLabelsControllerClass();
                testInstance.getGeneralDetails();
                //testInstance.getTotalPublications();
                testInstance.airlineReportHardCopy();
                
                test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}
    }
   
  static testMethod void testAirlineReportHardCopy() {
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
                      
            //createCustomSettings();
            
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;
                //objectMap.put('Singpost_Address__c', postal);
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
              //acc.AccountNumber = '12345';  //Retrieve from DB
                acc.AccountNumber = dbAcc.AccountNumber;
              //acc.Generate_Account_Number__c = true;
                //acc.Account_Auto_Number__c = '1';
                insert acc;
                //objectMap.put('Account', acc);
                
                //System.assertEquals('', acc.AccountNumber);
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                //objectMap.put('Package__c', pack);
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                //objectMap.put('zqu__ZProduct__c', zProduct);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.Publication_Code__c = 'CO12';
                insert pub;
                //objectMap.put('Publication__c', pub);
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                //objectMap.put('Product_Publication__c', ppc); 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
                //objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';
                //zprpc.PublicationCode__c = 'TestCode';
                zprpc.PublicationCode__c = 'WB'; //jurna
                insert zprpc;
                //objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                //objectMap.put('Package_Item__c', pItem);   
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                //objectMap.put('Zuora__CustomerAccount__c', billAcc);   
                
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                //packGroup.Packing_Group_Description__c = 'Description Test'; //jurna
                insert packGroup;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                //country.Country_Name__c = 'SINGAPORE';
                country.Code__c = 'UNIQUE123';
               // country.Code__c = 'SN';
               // country.Zone__c = zone.Id;
                insert country;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                /*addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Address_Type__c = 'A';
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';*/
                //Id addRecId = [Select Id, Name From RecordType Where SObjectType='Address__c' And Name = 'Airline' LIMIT 1].Id;
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');// addRecId;
                //addressRec.RecordTypeId = addRecId;
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                //objectMap.put('Address__c', addressRec); 
                                                   
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                insert con;
                //objectMap.put('Recipient Contact', con);   
                
                Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = addressRec.Id;
                con1.AccountId = acc.Id;
                con1.RecordTypeId = recordType;
                con1.Billing_Indicator__c = true;
                insert con1;
                //objectMap.put('Billing Contact', con1);   
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con1.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                //objectMap.put('Order__c', order);   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                //objectMap.put('Case', cas);   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                //objectMap.put('Order_Line_Item__c', orderline);  
             
              /*[SELECT id, name, Recipient_Contact__r.Name, Recipient_Contact__c, Frequency_1__c
                              FROM Zuora__Subscription__c 
                              WHERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                    AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                    AND Zuora__Status__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE
                                    AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];
*/
                
                 List<Zuora__Subscription__c> subRecs2 = TestDataFactory.createSubscription(1);
                subRecs2[0].Zuora__Account__c = acc.Id;
                subRecs2[0].Zuora__Zuora_Id__c = '1123';
                subRecs2[0].Zuora__SubscriptionStartDate__c = date.today();
                subRecs2[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs2[0].Subscriber_Contact__c = con.Id;
                subRecs2[0].Recipient_Contact__c = con.Id;
                subRecs2[0].Main_Package_1__c = pack.id;
                subRecs2[0].Main_Package__c = pack.id;
                subRecs2[0].Zuora__Status__c = 'Active';
                subRecs2[0].Order_Number__c = order.Id;
                subRecs2[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs2[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs2[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs2[0].Urgent__c = 'false';
                subRecs2[0].Vendor_Conversion__c = 'false';
                subRecs2[0].Charity__c = 'false';
                subRecs2[0].Billing_Type__c = 'Full Prepaid';
                subRecs2[0].Order_Line_Item_Number__c = orderline.id;
                subRecs2[0].Order_Line_Item_Number_1__c = orderline.id;
                subRecs2[0].Subscription_Type_1__c = 'Publication';
                subRecs2[0].Subscription_Type__c = 'Publication';
                subRecs2[0].Order_Number_1__c = order.id;
                //subRecs.Delivered_By__c = 'Mailing Agent';
                subRecs2[0].Zuora__CustomerAccount__c = billAcc.id;
                subRecs2[0].Delivered_By_1__c = 'Mailing Agent';
                insert subRecs2;
                
               
                                          
                Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubscriptionProductCharge(1)[0];
                subProdCharge.Zuora__Subscription__c =  subRecs2[0].id;
                subProdCharge.Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdCharge.Zuora__Quantity__c =  100.00;
                //subProdCharge.PublicationCode__c = 'CODE00124';
                subProdCharge.PublicationCode__c = 'BH'; //jurna
                insert subProdCharge;
                
                     
                
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               //packLabelBatch.Subscription__c = zsub.Id;
               // OK: packLabelBatch.Subscription__c = 'a0XN0000001JsnM';
                packLabelBatch.Subscription__c = subRecs2[0].id;
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Subscriber_Account_Number__c = dbAcc.AccountNumber;
                insert packLabelBatch;  
                
                
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                
                // TEST Proper            
                PageReference pageRef = Page.AirlineSubscriptions;
                pageRef.getParameters().put('id', packLabelBatch.Id);
                Test.setCurrentPage(pageRef);
                
            //System.assertEquals('',packLabelBatch.Subscriber_Account_Number__c);
                
                Set<String> mapString = new Set<String>();
                mapString.add('CODE123');
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                subIdPubCodeSetMap.put(pub.id,mapString);
                
                Set<String> var = new Set<String>();
                var.add('CO12');
                
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();  
                
                
                
                testInstance.pubCodeSet = var;
                testInstance.initializeOSW();
                testInstance.initializeAirline();
                testInstance.initializeMagazineWrap();
                testInstance.PackingLabelsControllerClass();
                Map<Id, Map<String, Integer>> sampleMap =  testInstance.getPublication(subRecs2, subIdPubCodeSetMap);
                testInstance.getGeneralDetails();
                //testInstance.getTotalPublications();
                testInstance.airlineReportHardCopy();
                
                test.stopTest();
            }
        }
        catch(Zuora.zRemoteException e) {}
        
    } 
     static testMethod void NewTestjd001() {
            
                      
           
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;

                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
                acc.AccountNumber = dbAcc.AccountNumber;               
                insert acc;
                
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.Publication_Code__c = 'CO12';
                insert pub;
                
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
               
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';                
                zprpc.PublicationCode__c = 'NT'; //jurna
                insert zprpc;
                
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                  
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                   
                
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                country.Code__c = 'UNIQUE123';

                insert country;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                RecordType rectype = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Airline'][0];
                addressRec.RecordtypeId = rectype.id;
               
                addressRec.Address_Type__c = 'A';
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                
                                                   
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con;
                  
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
                
                                              
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();
               
               
                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Subscriber_Account_Number__c = dbAcc.AccountNumber;
                insert packLabelBatch;  
                
                 List<Zuora__Subscription__c> subRecs2 = TestDataFactory.createSubscription(1);
                subRecs2[0].Zuora__Account__c = acc.Id;
                subRecs2[0].Zuora__Zuora_Id__c = '1123';
                subRecs2[0].Zuora__SubscriptionStartDate__c = date.today();
                subRecs2[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs2[0].Subscriber_Contact__c = con.Id;
                subRecs2[0].Recipient_Contact__c = con.Id;
                subRecs2[0].Main_Package_1__c = pack.id;
                subRecs2[0].Main_Package__c = pack.id;
                subRecs2[0].Zuora__Status__c = 'Active';
                subRecs2[0].Order_Number__c = order.Id;
                subRecs2[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs2[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs2[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs2[0].Urgent__c = 'false';
                subRecs2[0].Vendor_Conversion__c = 'false';
                subRecs2[0].Charity__c = 'false';
                subRecs2[0].Billing_Type__c = 'Full Prepaid';
                subRecs2[0].Order_Line_Item_Number__c = orderline.id;
                subRecs2[0].Order_Line_Item_Number_1__c = orderline.id;
                subRecs2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Order_Number_1__c = order.id;
                subRecs2[0].Number_of_Copies__c = 1;
                subRecs2[0].Zuora__CustomerAccount__c = billAcc.id;
                subRecs2[0].Delivered_By_1__c = 'Mailing Agent';
                subRecs2[0].Frequency_1__c = 'Mon - Fri';
                subRecs2[0].Frequency__c = 'Mon - Fri';
                insert subRecs2;
                
                packLabelBatch.Subscription__c = subRecs2[0].id;
                update packLabelBatch;
                  
                System.debug('APRIL:subscription_type__c' + subRecs2[0].Subscription_Type_1__c);
                System.debug('APRIL:addRecordTypeId ' + addressRec.RecordTypeId );
                System.debug('APRIL:Zuora__Status__c' + subRecs2[0].Zuora__Status__c);
                System.debug('APRIL:AccountNumber:' + acc.AccountNumber );
                System.debug('APRIL:packinglabelbatch:' + packLabelBatch.Subscriber_Account_Number__c );
                
                                          
                List<Zuora__SubscriptionProductCharge__c> subProdChargeList = TestDataFactory.createSubscriptionProductCharge(6);
                subProdChargeList[0].Zuora__Subscription__c =  subRecs2[0].id;
                subProdChargeList[0].Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdChargeList[0].Zuora__Quantity__c =  100.00;
                subProdChargeList[0].PublicationCode__c = 'BH'; 
                subProdChargeList[1].Zuora__Subscription__c =  subRecs2[0].id;
                subProdChargeList[1].Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdChargeList[1].Zuora__Quantity__c =  100.00;
                subProdChargeList[1].PublicationCode__c = 'WB'; 
                subProdChargeList[2].Zuora__Subscription__c =  subRecs2[0].id;
                subProdChargeList[2].Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdChargeList[2].Zuora__Quantity__c =  100.00;
                subProdChargeList[2].PublicationCode__c = 'NP'; 
                subProdChargeList[3].Zuora__Subscription__c =  subRecs2[0].id;
                subProdChargeList[3].Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdChargeList[3].Zuora__Quantity__c =  100.00;
                subProdChargeList[3].PublicationCode__c = 'ST'; 
                insert subProdChargeList;
               
                     
               Set<String> mapString = new Set<String>();
                mapString.add('CO12');
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                subIdPubCodeSetMap.put(pub.id,mapString);
                Set<String> subIdSet = new Set<String>();
                subIdSet.add(subRecs2[0].Id);
                
                
                ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);

                          
                PageReference pageRef = Page.AirlineSubscriptions;
                pageRef.getParameters().put('id', packLabelBatch.Id);

                Test.setCurrentPage(pageRef);

            
                     
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();      
                testInstance.pubCode = '';
                testInstance.address1 = '';
                testInstance.address2 = '';
                testInstance.address3 = '';
                testInstance.address4 = '';
                testInstance.address5 = '';
                testInstance.Sub = subRecs2[0];
                testInstance.spcList = subProdChargeList;
                testInstance.PackingLabelsControllerClass();
                testInstance.querySub('local', ''); 
                testInstance.querySub('overseas', '');
                testInstance.Country = country;
                testInstance.PackingCode = packGroup.Packing_Code__c;
                try{
                testInstance.packingLabelsOverseasWrapController();
                testInstance.pubCodeSet = mapString;
                testInstance.getTotalPublications();
                testInstance.getPublication(subRecs2, subIdPubCodeSetMap);
                }catch(Exception e){}
                test.stopTest();
        }
    }
    static testMethod void NewTestjd002() {
            
                      
           
            //Create a new user with Standard User Profile
            User testUser = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = [Select id from Profile where name = 'Standard User' Limit 1].id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='standard@test.com'
            );
            
            System.runAs(testUser) { 
                
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Building_Name__c = 'Ebloc2';
                postal.Name = 'SPostal';
                postal.House_Block_Number__c = 'TEST';
                postal.Address_Type__c = 'A';
                insert postal;

                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                Id addId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Corporate' LIMIT 1].Id;
                acc.RecordTypeId = addId;
                acc.Airline_Indicator__c = true;
                //Account dbAcc = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1];
                acc.AccountNumber = '123456789';                               
                insert acc;
                
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                insert pack;
                
                
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                insert zProduct;
                
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Publication_Type__c = 'N';
                pub.Published_Days__c = 'YNNNNNN';
                pub.Publication_Code__c = 'CO12';
                pub.Platform_Type__c = 'Print';
                insert pub;
                
                
                Product_Publication__c ppc = TestDataFactory.createProductPublication(1)[0];
                ppc.ZProduct__c = zProduct.id;
                ppc.Publication_Code__c = pub.id;
                insert ppc;
                 
                
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today()+1;
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                insert prdRatePlan;
               
                
                zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
                zprpc.Name = 'Product Rate Plan Charge';
                zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
                zprpc.zqu__ZuoraId__c = '3689922200';                
                zprpc.PublicationCode__c = 'NT'; //jurna
                insert zprpc;
                
                
                Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
                pItem.Package__c = pack.id;
                pItem.Product_Rate_Plan__c = prdRatePlan.id;
                pItem.Name = 'Test Pack Item';
                insert pItem; 
                  
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid';
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
                insert billAcc;
                   
                
                Packing_Grp__c packGroup = new Packing_Grp__c();
                packGroup.Packing_Code__c = 'MFA';
                packGroup.Packing_Group_Description__c = 'Description Test';
                insert packGroup;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
               
                //Create Country   
                Country__c country = TestDataFactory.createCountry(1)[0];
                country.Name = 'SINGAPORE';
                country.Code__c = 'UNIQUE123';

                insert country;
                
                City__c testCity = new City__c();
                testCity.Name = 'Test City';
                
                testCity.Flight_Number_1__c = 'Flight Number 1';
                testCity.Flight_Number_2__c = 'Flight Number 2';
                insert testCity;
                                            
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                //RecordType rectype = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Airline'];//Overseas][0];
                addressRec.RecordtypeId = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Airline' LIMIT 1].Id;               
                addressRec.Address_Type__c = 'A';
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Packing_Code__c = packGroup.id;
                addressRec.Country__c = country.id;
                addressRec.City__c = testCity.id;
                insert addressRec;
                
                                                   
                Id recordType = [select id from recordType where name='Customer Contact' limit 1].id;
                Contact con = TestDataFactory.createContact(1)[0];
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = recordType;
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
                insert con;
                  
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Informed_Customer__c = TRUE;
                order.Recipient_Contact__c = con.Id;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Contact__c = con.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                order.Billing_Type__c =  'Full Prepaid';
                insert order;
                   
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                //insert cas;
                   
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.End_Date__c = date.today().addDays(180);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.Earliest_Start_Date__c = date.Today() +1;
                orderline.Earliest_Stop_Date__c = date.today() +30;
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                orderline.Main_Package_Product_Sub_Type__c = 'Newspaper';
                orderline.Delivered_By__c = 'Mailing Agent';
                insert orderline;
              
                List<Zuora__Subscription__c> subRecs2 = TestDataFactory.createSubscription(1);
                subRecs2[0].Zuora__Account__c = acc.Id;
                subRecs2[0].Zuora__Zuora_Id__c = '1123';
                subRecs2[0].Zuora__SubscriptionStartDate__c = date.today();
                subRecs2[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subRecs2[0].Subscriber_Contact__c = con.Id;
                subRecs2[0].Recipient_Contact__c = con.Id;
                subRecs2[0].Recipient_Contact_1__c = con.Id;
                subRecs2[0].Main_Package_1__c = pack.id;
                subRecs2[0].Main_Package__c = pack.id;
                subRecs2[0].Zuora__Status__c = 'Active';
                subRecs2[0].Order_Number__c = order.Id;
                subRecs2[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs2[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs2[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs2[0].Urgent__c = 'false';
                subRecs2[0].Vendor_Conversion__c = 'false';
                subRecs2[0].Charity__c = 'false';
                subRecs2[0].Billing_Type__c = 'Full Prepaid';
                subRecs2[0].Order_Line_Item_Number__c = orderline.id;
                subRecs2[0].Order_Line_Item_Number_1__c = orderline.id;
                subRecs2[0].Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ;
                subRecs2[0].Order_Number_1__c = order.id;
                subRecs2[0].Number_of_Copies__c = 1;
                subRecs2[0].Zuora__CustomerAccount__c = billAcc.id;
                subRecs2[0].Delivered_By_1__c = 'Mailing Agent';
                subRecs2[0].Frequency_1__c = 'Mon - Fri';
                subRecs2[0].Frequency__c = 'Mon - Fri';
                insert subRecs2;
                
                Packing_Label_Batch__c packLabelBatch = new Packing_Label_Batch__c();

                packLabelBatch.Number_of_Copies__c = 5;
                packLabelBatch.Recipient_Type__c = 'Airline';
                packLabelBatch.Subscriber_Account_Number__c = acc.AccountNumber;
                
                system.assertEquals(packLabelBatch.Subscriber_Account_Number__c, acc.AccountNumber);
                
                //insert packLabelBatch; 
                packLabelBatch.Subscription__c = subRecs2[0].id;
                //update packLabelBatch;
                insert packLabelBatch; 
               
                  
                System.debug('APRIL:subscription_type__c' + subRecs2[0].Subscription_Type_1__c);
                System.debug('APRIL:addRecordTypeId ' + addressRec.RecordTypeId );
                System.debug('APRIL:Zuora__Status__c' + subRecs2[0].Zuora__Status__c);
                System.debug('APRIL:AccountNumber:' + acc.AccountNumber );
                System.debug('APRIL:packinglabelbatch:' + packLabelBatch.Subscriber_Account_Number__c );
                
                                          
                List<Zuora__SubscriptionProductCharge__c> subProdChargeList = TestDataFactory.createSubscriptionProductCharge(1);
                subProdChargeList[0].Zuora__Subscription__c =  subRecs2[0].id;
                subProdChargeList[0].Zuora__RatePlanName__c = 'Rate Plan'; 
                subProdChargeList[0].Zuora__Quantity__c =  100.00;
                subProdChargeList[0].PublicationCode__c = 'BH'; 

                insert subProdChargeList;
               
                     
                Set<String> mapString = new Set<String>();
                mapString.add('CO12');
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                subIdPubCodeSetMap.put(pub.id,mapString);
                Set<String> subIdSet = new Set<String>();
                subIdSet.add(subRecs2[0].Id);
                
                
                //ApexPages.currentPage().getParameters().put('id', acc.id);
                //ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);
                

                          
                 PageReference pageRef = Page.AirlineSubscriptions;
                 pageRef.getParameters().put('id', acc.Id);
                 Test.setCurrentPage(pageRef);
                 ApexPages.currentPage().getParameters().put('id', packLabelBatch.id);                                          
                 ApexPages.currentPage().getParameters().put('id', acc.id);
                     
                test.startTest();
            
                PackingLabelsController  testInstance = new PackingLabelsController();      

                testInstance.Sub = subRecs2[0];
                testInstance.spcList = subProdChargeList;
                testInstance.airlineReportHardCopy();
                testInstance.pubCodeSet = mapString;

                testInstance.getPublication(subRecs2, subIdPubCodeSetMap);
                test.stopTest();
        }
    }
} 


/*
private static RecordType getRecordType(String recordTypeValue,String objectType)
{
    RecordType testRecordType = null;
    
    if(recordTypeValue != null)
    {
        testRecordType = [SELECT id FROM RecordType WHERE SobjectType = :objectType AND Name=: recordTypeValue LIMIT 1][0];
    }
    
    return testRecordType;
}


}*/