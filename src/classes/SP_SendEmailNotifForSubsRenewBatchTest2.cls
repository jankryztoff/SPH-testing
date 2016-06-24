@isTest(seeAllData=false)
public class SP_SendEmailNotifForSubsRenewBatchTest2{

    //List of variables
    static List<Country__c> cntryList;
    static Account acnt;
    static List<Singpost_Address__c> singpostalList;
    static List<Address__c> addrList;
    static List<Contact> cntctList;
    static Zuora__CustomerAccount__c custAccount;
    static Package__c packge;
    static zqu__ZProduct__c zProducts;
    static zqu__ProductRatePlan__c prodRatePlan;
    static Product_Family__c prodFamily;
    static Package_Item__c packageItem;
    static Order__c orders;
    static List<Order_Line_Item__c> orderItemList;
    static Order_Line_Item__c ordLineItem;
    static Zuora__Subscription__c zuoraSubscription;
    static Promotion__c prom;
    static EmailTemplate validEmailTemplate;

    static void setUpTestData() {

        //CustomSettings
        RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
        RecordType Address_Local = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Local' LIMIT 1];
        RecordType addressOverseas = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Overseas' LIMIT 1];
        RecordType directCorporate = [SELECT id, Name FROM RecordType WHERE SobjectType='Account' AND Name='Direct Corporate' LIMIT 1];
        RecordType addressAirline = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Airline' LIMIT 1];
        RecordType addressInternal = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Internal' LIMIT 1];
        
        //Key_Id__c
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Local', Id__c=Address_Local.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Overseas', Id__c=addressOverseas.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Internal', Id__c=addressInternal.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Airline', Id__c=addressAirline.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Account_Direct Corporate', Id__c=directCorporate.id ,Type__c='RecordType')
        };
        Database.insert(kisList);

        //Other__c
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);
       
        //Setup Country__c records
        cntryList = TestDataFactory.createCountry(2);
        cntryList[0].Country_Name__c = 'Singapore';
        cntryList[0].Code__c = 'Singapore';
        cntryList[1].Country_Name__c = 'Philippines';
        cntryList[1].Code__c = 'Philippines';
        insert cntryList;
        
        //Setup Account records
        acnt = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acnt.NRIC__c = 'T1234567R';
        acnt.Name = 'Test Account';
        acnt.Phone = '123-456';
        acnt.Email__c = 'test@test.com';
        acnt.Date_of_Birth__c = date.today();
        acnt.Gender__c = 'Male';
        acnt.Race__c = 'Chinese';
        acnt.Language__c = 'Others';
        acnt.Contact_Person__c = 'Contact Person';
        acnt.Sub_Group__c = 'Freelist(MY)';
        acnt.Generate_Account_Number__c = true;
        acnt.Renewal_Letter__c = 'Email';

        insert acnt;

        //Setup Postal records
        singpostalList = TestDataFactory.createSingpostAddress(2);
        singpostalList[0].Name = 'SPostal';
        singpostalList[0].House_Block_Number__c = 'TEST';
        singpostalList[0].Address_Type__c = 'A';
        singpostalList[0].Building_Name__c = 'Building';
        singpostalList[0].Street_Name__c = 'Street';
        singpostalList[1].Name = 'PPostal';
        singpostalList[1].House_Block_Number__c = 'TEST';
        singpostalList[1].Address_Type__c = 'A';
        singpostalList[1].Building_Name__c = 'Building';
        singpostalList[1].Street_Name__c = 'Street';
        insert singpostalList;
        
        //Address
        addrList = TestDataFactory.createAddress(2);
        addrList[0].Address_Type__c = 'A';
        addrList[0].Postal_Code__c = singpostalList[0].Id;
        addrList[0].Block_House_Number__c ='TEST';
        addrList[0].Level_Number__c ='xx';
        addrList[0].Unit_Number__c = 'yy';
        addrList[0].Country__c = cntryList[0].id;
        addrList[0].Address_1__c = 'Address 1';
        addrList[0].Address_2__c = 'Address 2';
        addrList[0].Address_3__c = 'Address 3';
        addrList[0].Address_4__c = 'Address 4';
        addrList[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        addrList[1].Address_Type__c = 'A';
        addrList[1].Postal_Code__c = singpostalList[1].Id;
        addrList[1].Block_House_Number__c ='TEST';
        addrList[1].Level_Number__c ='xx';
        addrList[1].Unit_Number__c = 'yy';
        addrList[1].Country__c = cntryList[1].id;
        addrList[1].Address_1__c = 'Address 1';
        addrList[1].Address_2__c = 'Address 2';
        addrList[1].Address_3__c = 'Address 3';
        addrList[1].Address_4__c = 'Address 4';
        addrList[1].RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        insert addrList; 
        
        //Setup Contact records
        cntctList = TestDataFactory.createContact(2);
        cntctList[0].Address__c = addrList[0].Id;
        cntctList[0].AccountId = acnt.Id;
        cntctList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        cntctList[0].Billing_Indicator__c = true;
        cntctList[0].FirstName = 'Test';
        cntctList[0].LastName = 'Contact';
        cntctList[0].Passport__c = 'PassTest';
        cntctList[0].HomePhone__c = '123 456';
        cntctList[0].Mobile_Number__c = '123456';
        cntctList[0].Email = 'test@test.com';
        cntctList[1].Address__c = addrList[1].Id;
        cntctList[1].AccountId = acnt.Id;
        cntctList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        cntctList[1].Billing_Indicator__c = true;
        cntctList[1].FirstName = 'Test1';
        cntctList[1].LastName = 'Contact';
        cntctList[1].Email = 'test@test.com';
        insert cntctList;
        
        String ZuoraExternalId = 'try1234';
        String ZuoraZuoraIdc = 'Test1';
        String PackageCodec   = 'afds132';
        String PromotionCodec = 'yasyd97';
        
        //Setup Zuora__CustomerAccount__c
        custAccount = TestDataFactory.createBillingAccount(1)[0];
        custAccount.Zuora__Account__c = acnt.Id;
        custAccount.Billing_Contact__c = cntctList[1].Id;
        custAccount.Zuora__Zuora_Id__c = ZuoraZuoraIdc;
        custAccount.Billing_Type__c = 'Full Prepaid';
        custAccount.Zuora__DefaultPaymentMethod__c = 'Other';
        custAccount.Zuora__AccountNumber__c = 'Test1';
        
        insert custAccount;

        //Setup Package records
        packge = TestDataFactory.createPackage(1)[0];
        packge.Billing_Type__c = 'Full Prepaid';
        packge.Package_Type__c = 'Grace Period';
        packge.Subscription_Period__c = '1';
        packge.Package_Code__c = PackageCodec;
        packge.Product_Family_Current_Package__c = 'test';
        insert packge;
        
        //Setup zqu__ZProduct__c records
        zProducts = TestDataFactory.createZProduct(1)[0];
        zProducts.ProductSubType__c = 'Magazine';
        zProducts.zqu__ZuoraId__c = 'Test';
        insert zProducts ;
        
        //Setup zqu__ProductRatePlan__c records
        prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
        prodRatePlan.zqu__ZProduct__c = zProducts.Id;
        prodRatePlan.RatePlanType__c= 'Proration';
        prodRatePlan.zqu__EffectiveStartDate__c= date.today();
        prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prodRatePlan.zqu__Deleted__c = false;
        prodRatePlan.zqu__ZuoraId__c = 'Test';
        insert prodRatePlan;

        //Setup Product_Family__c records
        prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'Trythis';
        prodFamily.Product_Family_Name__c = 'testtest';
        insert prodFamily;
        
        //Setup Package Item records
        packageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packageItem.Package__c = packge.id;
        packageItem.Product_Rate_Plan__c = prodRatePlan.id;
        packageItem.Name = 'Test Pack Item';
        packageItem.Product_Family__c = prodFamily.Id;
        insert packageItem;
        
        //Setup Order records
        orders = TestDataFactory.createOrder(1)[0];
        orders.Account__c = acnt.Id;
        orders.Informed_Customer__c = TRUE;
        orders.Order_Type__c = 'Renewal';
        orders.Status__c = 'Draft';
        orders.Eligible_for_Retention__c = TRUE;
        orders.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orders.Payment_Mode__c = 'Credit Card';
        orders.Billing_Account__c = custAccount.id;
        orders.Billing_Type__c = 'Full Prepaid';
        orders.Billing_Contact__c = cntctList[1].id;
        orders.Case_Record_Type__c = 'Complaint - Magazine';
        orders.Category__c = 'Subscription Request';
        orders.Sub_Category__c ='Stop Subscription';
        orders.Credit_Balance__c = 0;
        orders.Delivery_Charge__c = 0;
        orders.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orders.Order_Type__c = 'Change of Subscription Package';
        orders.PO_Number__c = 'PO00000';
        orders.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
        orders.Delivery_Charge_Type__c = 'C';
        orders.Subscriber_Charge__c = 10.00;
        insert orders;
         
        //Order Line Item
        orderItemList = new List<Order_Line_Item__c>(1);
        ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem.Order__c = orders.Id;
        ordLineItem.Start_Date__c = date.today().addDays(1);
        ordLineItem.End_Date__c = date.Today().addDays(4);
        ordLineItem.Main_Package_ID__c = packge.Id;
        ordLineItem.Term_Length__c = 0;
        ordLineItem.Main_Package_Period__c = 0;
        ordLineItem.Earliest_Start_Date__c = date.today();
        ordLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
        ordLineItem.Stop_Request_Date__c =  date.Today().addDays(4);
        ordLineItem.Terminating_Reason__c = 'Others';
        ordLineItem.Amount_To_Refund__c = 0;
        ordLineItem.Admin_Charge__c = 0;
        ordLineItem.Fee_Waiver__c = TRUE;
        ordLineItem.Fee_Override__c = FALSE;
        ordLineItem.Override_Reason__c = 'TEST';
        ordLineItem.Suppress_Notification_Stop__c = TRUE;
        ordLineItem.Main_Package_Type__c = 'Base';
        insert ordLineItem;
        orderItemList.add(ordLineItem);
        
        //Setup Zoura Records
        zuoraSubscription = TestDataFactory.createSubscription(1)[0];
        zuoraSubscription.Zuora__Account__c = acnt.Id;
        zuoraSubscription.Order_Line_Item_Number__c = ordLineItem.Id;
        zuoraSubscription.Subscriber_Contact__c = cntctList[0].Id;
        zuoraSubscription.Recipient_Contact__c = cntctList[0].Id;
        zuoraSubscription.Main_Package_1__c = packge.Id;
        zuoraSubscription.Main_Package__c = packge.Id;
        zuoraSubscription.Zuora__Status__c = 'Active';
        zuoraSubscription.Order_Number__c = orders.Id;
        zuoraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zuoraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zuoraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zuoraSubscription.Urgent__c = 'false';
        zuoraSubscription.Vendor_Conversion__c = 'false';
        zuoraSubscription.Charity__c = 'false';
        zuoraSubscription.Subscription_Type__c = 'Publication';
        zuoraSubscription.Subscription_Type_1__c = 'Publication';
        zuoraSubscription.Zuora__SubscriptionEndDate__c= date.today();
        zuoraSubscription.Zuora__SubscriptionStartDate__c = date.today();
        zuoraSubscription.Zuora__CustomerAccount__c = custAccount.Id;
        zuoraSubscription.Contact__c = cntctList[0].id;
        zuoraSubscription.Zuora__External_Id__c = ZuoraExternalId;
        zuoraSubscription.Zuora__Zuora_Id__c = ZuoraExternalId;
        zuoraSubscription.Order_Line_Item_Number_1__c = ordLineItem.Id;
        zuoraSubscription.Delivered_By__c = 'Vendor';
        insert zuoraSubscription; 

        validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Test_Name';
        validEmailTemplate.DeveloperName = 'Test_Developer';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.HtmlValue = '<html> <table width="100%"> <tr> <td width=68% align=left> <div style = "font-family:Arial; font-size: 9pt;"> {{Insert Table}}<br> <br> {{Contact.FirstName}} {{Contact.LastName}}<br> </div> </html>';

        insert validEmailTemplate;
    }

      @testSetup static void setUpData() {
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            String rtId = AccountRecordTypeInfo.get('Direct Corporate').getRecordTypeId(); 

            Key_Id__c keyId = new Key_Id__c();
            keyId.Name = 'Account_Direct Corporate';
            keyId.Type__c = 'RecordType';
            keyId.Id__c = rtId;
            insert keyId;
      }

      static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch(){
        Integer counter=0;
        
        counter=0;

        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='SPH Logo v2', Value__c='SPH Logo v2')
        };
        database.insert(otherList);
        
         
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.Renewal_Letter__c = 'Email';
         database.insert(acc);
         
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Street_Name__c = 'test';
         postal.Building_Name__c = 'build';
         database.insert(postal);
         
         Country__c country = TestDataFactory.createCountry(1)[0];
         country.Country_Name__c = 'Singapore';
         database.insert(country);
         
         SPH_Section__c section = new SPH_Section__c();
         section.Section_Name__c = 'name';
         database.insert(section);
         
         SPH_Department__c dept = new SPH_Department__c();
         dept.Department_Name__c = 'name';
         database.insert(dept);
         
         SPH_Division__c div = new SPH_Division__c();
         div.Name = 'Name';
         database.insert(div);
         
         SPH_Company__c com = new SPH_Company__c();
         com.Company_Name__c = 'name';
         database.insert(com);
         
         SPH_Location__c loc = new SPH_Location__c();
         loc.Location_Name__c = 'name';
         database.insert(loc);
         
         City__c city = new City__c();
         city.City_Name__c = 'name';
         city.Flight_Number_1__c = '123';
         city.Flight_Number_2__c = '432';
         database.insert(city);
         
         Packing_Grp__c packCode = new Packing_Grp__c();
         packCode.Airline__c = 'airline';
         database.insert(packCode);

         List<Address__c> ad = TestDataFactory.createAddress(4);
         for(Address__c a: ad){
             if(counter==0){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Local'].Id;
             }
             else if(counter==1){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Overseas'].Id;
             }
             else if(counter==2){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Internal'].Id;
             }
             else{
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Airline'].Id;
             }
             a.Block_House_Number__c = '01';
             a.Level_Number__c = '01';
             a.Unit_Number__c = '01';
             a.Postal_Code__c = postal.Id;
             a.Country__c = country.Id;
             a.Address_1__c = 'ass';
             a.Address_2__c = 'ss';
             a.Address_3__c = 'ss';
             a.Address_4__c = 'ss';
             a.Section_Code__c = section.Id;
             a.Department__c = dept.Id;
             a.Division_Code__c = div.Id;
             a.Company_Code__c = com.Id;
             a.Location_Code__c = loc.Id;
             a.City__c = city.Id;
             //a.Airline_Number__c = '123';
             //a.Flight_Number_1__c = '345';
            //a.Flight_Number_2__c = '564';
             a.Packing_Code__c = packCode.Id;
             counter++;
         }
         database.insert(ad);
         
         counter=0;
         List<Contact> con = TestDataFactory.createContactRecType(4, 'Customer Contact');
         for(Contact c: con){
             if(counter==0){
                 c.Address__c = ad[0].Id;
             }
             else if(counter==1){
                 c.Address__c = ad[1].Id;
             }
             else if(counter==2){
                 c.Address__c = ad[2].Id;
             }
             else{
                 c.Address__c = ad[3].Id;
             }
             c.Email__c = 'sample@ab.c';
             c.Email_Secondary__c = 'samplEmail@ab.com';
             counter++;
         }
         database.insert(con);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         database.insert(pack);
         
         counter=0;
         List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
         for(zqu__ZProduct__c z: zp){
             if(counter==0){
                 z.ProductSubType__c = 'Magazine';
             }
             else{
                 z.ProductSubType__c = 'Newspaper';
             }
             z.ProductCode__c = '1';
             counter++;
         }
         database.insert(zp);
         test.startTest();
         zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
         prp.zqu__ZProduct__c = zp[0].Id;
         database.insert(prp);
         
         Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         packItem.Product_Rate_Plan__c = prp.Id;
         packItem.Package__c = pack.Id;
         database.insert(packItem);
         
         counter=0;
         List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub: subs){
             sub.is1stNotifEmailSent__c = false;
             sub.Zuora__SubscriptionEndDate__c = System.Today().addDays(42);
             sub.Zuora__TermSettingType__c = 'TERMED';
             sub.Zuora__AutoRenew__c = false;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type__c = 'Publication';
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             //sub.Order_Line_Item_Number_1__c = orderline.Id;
             //sub.Subscription_Type__c = 'Delivery';
             sub.Product_Code__c = '1';
             sub.Term_Length__c = 0.0;
             sub.Term_Length1__c = '0.0';
             sub.Zuora__SubscriptionStartDate__c = System.Today().addDays(42);
             sub.Main_Package__c = pack.Id;
             sub.Subscriber_Contact__c = con[0].Id;
             //sub.Main_Package_Product_Sub_Type_Mapping__c = 'Magazine';
             if(/*counter==0 || */counter==1){
               sub.Subscription_Type__c = 'Delivery';  
             }
             else if(counter==2){
                 sub.Contact__c = con[0].Id;
             }
             else if(counter==3){
                 sub.Contact__c = con[1].Id;
             }
             else if(counter==4){
                 sub.Contact__c = con[2].Id;
             }
             else if(counter==5){
                 sub.Contact__c = con[3].Id;
             }
             counter++;
         }
         database.insert(subs);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c  = acc.Id;
         ord.Base_Subscription__c = subs[0].id;
         database.insert(ord);
         
         Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
         ordLine.Order__c = ord.Id;
         ordLine.Main_Package_ID__c = pack.Id;
         ordLine.Main_Package_Product_Sub_Type__c = 'Magazine';
         ordLine.Start_Date__c = System.Today().addDays(43);
         database.insert(ordLine);
         
         system.assertEquals(subs[0].Zuora__SubscriptionEndDate__c, System.Today().addDays(42));
         
         Zuora__Subscription__c subsQ = [SELECT id, Zuora__Account__r.Renewal_Letter__c, Zuora__Account__r.RecordType.Id, Zuora__Account__c, Zuora__Account__r.RecordType.Name, Subscription_Type_1__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, is1stNotifEmailSent__c, Zuora__AutoRenew__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id];
        
         //date firstNotifDate = subsQ.Zuora__SubscriptionEndDate__c-42;
         //date firstNotifDate = date.newInstance(subsQ.Zuora__SubscriptionEndDate__c.year(), subsQ.Zuora__SubscriptionEndDate__c.month(), subsQ.Zuora__SubscriptionEndDate__c.day()-42);
         date firstNotifDate1 = subsQ.Zuora__SubscriptionEndDate__c; //.addDays(42);
         date firstNotifDate = date.newInstance(firstNotifDate1.year(),firstNotifDate1.month(),firstNotifDate1.day()-42);
         //system.assertEquals(firstNotifDate, firstNotifDate1);
         system.assertEquals(subsQ.is1stNotifEmailSent__c, false);
         system.assertEquals(subsQ.Zuora__AutoRenew__c, false);
         system.assertEquals(subsQ.Zuora__Status__c, 'Active');
         system.assertEquals(subsQ.Subscription_Type_1__c, 'Publication');
         system.assertEquals(subsQ.Zuora__Account__r.RecordType.Id, ConstantsSLB.getKeyId('Account_Direct Corporate'));
         system.assertEquals(subsQ.Zuora__Account__r.Renewal_Letter__c, GlobalVariableClass.REFERENCE_EMAIL);
            
         List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
         for(Zuora__SubscriptionProductCharge__c sp : spc){
             sp.Zuora__Subscription__c = subs[2].Id;
         }
         database.insert(spc);
         
         //Document doc = new Document();
         //doc.Name = 'SPH Logo v2';
         //database.insert(doc);
         
         Set<id> renewalSubsId = new Set<id>();
         renewalSubsId.add(subs[0].id);
         
         
             SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
             database.executeBatch(batch, 200);
         test.stopTest();
    }

     //jurna
      static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch2(){
         Integer counter=0;
     
         List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='SPH Logo v2', Value__c='SPH Logo v2')
        };
        database.insert(otherList);
        
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
         database.insert(acc);
         
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Street_Name__c = 'test';
         postal.Building_Name__c = 'build';
         database.insert(postal);
         
         Country__c country = TestDataFactory.createCountry(1)[0];
         country.Country_Name__c = 'Singapore';
         database.insert(country);
         
         SPH_Section__c section = new SPH_Section__c();
         section.Section_Name__c = 'name';
         database.insert(section);
         
         SPH_Department__c dept = new SPH_Department__c();
         dept.Department_Name__c = 'name';
         database.insert(dept);
         
         SPH_Division__c div = new SPH_Division__c();
         div.Name = 'Name';
         database.insert(div);
         
         SPH_Company__c com = new SPH_Company__c();
         com.Company_Name__c = 'name';
         database.insert(com);
         
         SPH_Location__c loc = new SPH_Location__c();
         loc.Location_Name__c = 'name';
         database.insert(loc);
         
         City__c city = new City__c();
         city.City_Name__c = 'name';
         city.Flight_Number_1__c = '123';
         city.Flight_Number_2__c = '432';
         database.insert(city);
         
         Packing_Grp__c packCode = new Packing_Grp__c();
         packCode.Airline__c = 'airline';
         database.insert(packCode);
         
         counter=0;
         List<Address__c> ad = TestDataFactory.createAddress(4);
         for(Address__c a: ad){
             if(counter==0){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Local'].Id;
             }
             else if(counter==1){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Overseas'].Id;
             }
             else if(counter==2){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Internal'].Id;
             }
             else{
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Airline'].Id;
             }
             a.Block_House_Number__c = '01';
             a.Level_Number__c = '01';
             a.Unit_Number__c = '01';
             a.Postal_Code__c = postal.Id;
             a.Country__c = country.Id;
             a.Address_1__c = 'ass';
             a.Address_2__c = 'ss';
             a.Address_3__c = 'ss';
             a.Address_4__c = 'ss';
             a.Section_Code__c = section.Id;
             a.Department__c = dept.Id;
             a.Division_Code__c = div.Id;
             a.Company_Code__c = com.Id;
             a.Location_Code__c = loc.Id;
             a.City__c = city.Id;
             //a.Airline_Number__c = '123';
             //a.Flight_Number_1__c = '345';
            //a.Flight_Number_2__c = '564';
             a.Packing_Code__c = packCode.Id;
             counter++;
         }
         database.insert(ad);
         
         counter=0;
         List<Contact> con = TestDataFactory.createContactRecType(4, 'Customer Contact');
         for(Contact c: con){
             if(counter==0){
                 c.Address__c = ad[0].Id;
             }
             else if(counter==1){
                 c.Address__c = ad[1].Id;
             }
             else if(counter==2){
                 c.Address__c = ad[2].Id;
             }
             else{
                 c.Address__c = ad[3].Id;
             }
             c.Email__c = 'sample@ab.c';
             c.Email_Secondary__c = 'samplEmail@ab.com';
             counter++;
         }
         database.insert(con);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         database.insert(pack);
         
         counter=0;
         List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
         for(zqu__ZProduct__c z: zp){
             if(counter==0){
                 z.ProductSubType__c = 'Magazine';
             }
             else{
                 z.ProductSubType__c = 'Newspaper';
             }
             z.ProductCode__c = '1';
             counter++;
         }
         database.insert(zp);
         
         zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
         prp.zqu__ZProduct__c = zp[0].Id;
         database.insert(prp);
         
         Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         packItem.Product_Rate_Plan__c = prp.Id;
         packItem.Package__c = pack.Id;
         database.insert(packItem);
         
         counter=0;
         List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(10);
         for(Zuora__Subscription__c sub: subs){
             sub.is1stNotifEmailSent__c = false;
             sub.Zuora__SubscriptionEndDate__c = System.Today().addDays(42);
             sub.Zuora__TermSettingType__c = 'TERMED';
             sub.Zuora__AutoRenew__c = false;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type__c = 'Publication';
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Recipient_Contact__c = con[0].id;
             //sub.Order_Line_Item_Number_1__c = orderline.Id;
             //sub.Subscription_Type__c = 'Delivery';
             sub.Main_Package_1__c = pack.id;
             sub.Main_Package__c = pack.id;
             sub.Product_Code__c = '1';
             sub.Term_Length__c = 0.0;
             sub.Term_Length1__c = '0.0';
             sub.Zuora__SubscriptionStartDate__c = System.Today().addDays(42);
             sub.Main_Package__c = pack.Id;
             sub.Subscriber_Contact__c = con[0].Id;
             //sub.Main_Package_Product_Sub_Type_Mapping__c = 'Magazine';
             if(/*counter==0 || */counter==1){
               sub.Subscription_Type__c = 'Delivery';  
             }
             else if(counter==2){
                 sub.Contact__c = con[0].Id;
             }
             else if(counter==3){
                 sub.Contact__c = con[1].Id;
             }
             else if(counter==4){
                 sub.Contact__c = con[2].Id;
             }
             else if(counter==5){
                 sub.Contact__c = con[3].Id;
             }
             counter++;
         }
         database.insert(subs);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c  = acc.Id;
         ord.Base_Subscription__c = subs[0].id;
         database.insert(ord);
         
         Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
         ordLine.Order__c = ord.Id;
         ordLine.Main_Package_ID__c = pack.Id;
         ordLine.Main_Package_Product_Sub_Type__c = 'Magazine';
         ordLine.Start_Date__c = System.Today().addDays(43);
         database.insert(ordLine);
         
         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(subs[0].Id);
         letterPrintRequest.Language_Medium__c = 'C';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(subs[0].Id);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
         
         system.assertEquals(subs[0].Zuora__SubscriptionEndDate__c, System.Today().addDays(42));
         
         Zuora__Subscription__c subsQ = [SELECT id, Zuora__Account__r.Renewal_Letter__c, Zuora__Account__r.RecordType.Id, Subscription_Type_1__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, is1stNotifEmailSent__c, Zuora__AutoRenew__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id];
         
         //date firstNotifDate = subsQ.Zuora__SubscriptionEndDate__c-42;
         //date firstNotifDate = date.newInstance(subsQ.Zuora__SubscriptionEndDate__c.year(), subsQ.Zuora__SubscriptionEndDate__c.month(), subsQ.Zuora__SubscriptionEndDate__c.day()-42);
         date firstNotifDate1 = subsQ.Zuora__SubscriptionEndDate__c; //.addDays(42);
         date firstNotifDate = date.newInstance(firstNotifDate1.year(),firstNotifDate1.month(),firstNotifDate1.day()-42);
         //system.assertEquals(firstNotifDate, firstNotifDate1);
         system.assertEquals(subsQ.is1stNotifEmailSent__c, false);
         system.assertEquals(subsQ.Zuora__AutoRenew__c, false);
         system.assertEquals(subsQ.Zuora__Status__c, 'Active');
         system.assertEquals(subsQ.Subscription_Type_1__c, 'Publication');
         system.assertEquals(subsQ.Zuora__Account__r.RecordType.Id, ConstantsSLB.getKeyId('Account_Direct Corporate'));
         system.assertEquals(subsQ.Zuora__Account__r.Renewal_Letter__c, GlobalVariableClass.REFERENCE_EMAIL);
        
         List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
         for(Zuora__SubscriptionProductCharge__c sp : spc){
             sp.Zuora__Subscription__c = subs[2].Id;
         }
         database.insert(spc);
         
         Document doc = new Document();
         doc.Name = 'SPH Logo v2';
         doc.FolderId = UserInfo.getUserId();
         database.insert(doc);
         
         Set<id> renewalSubsId = new Set<id>();
         renewalSubsId.add(subs[0].id);
         
         Set<id> renewallpr = new Set<id>();
         renewallpr.add(lprList[1].id);
         
         test.startTest();
             //SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
             //database.executeBatch(batch, 200);
             SP_SendEmailNotifForSubsRenewalsBatch batch2 = new SP_SendEmailNotifForSubsRenewalsBatch(renewallpr, firstNotifDate);
             database.executeBatch(batch2, 200);
             
            // Database.BatchableContext BC;
            // batch2.execute(BC, letterPrintReqList);
         test.stopTest();
     }
     
     //jurna
      static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch3(){
         Integer counter=0;
     
         List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='SPH Logo v2', Value__c='SPH Logo v2')
        };
        database.insert(otherList);
        
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
         database.insert(acc);
         
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Street_Name__c = 'test';
         postal.Building_Name__c = 'build';
         database.insert(postal);
         
         Country__c country = TestDataFactory.createCountry(1)[0];
         country.Country_Name__c = 'Singapore';
         database.insert(country);
         
         SPH_Section__c section = new SPH_Section__c();
         section.Section_Name__c = 'name';
         database.insert(section);
         
         SPH_Department__c dept = new SPH_Department__c();
         dept.Department_Name__c = 'name';
         database.insert(dept);
         
         SPH_Division__c div = new SPH_Division__c();
         div.Name = 'Name';
         database.insert(div);
         
         SPH_Company__c com = new SPH_Company__c();
         com.Company_Name__c = 'name';
         database.insert(com);
         
         SPH_Location__c loc = new SPH_Location__c();
         loc.Location_Name__c = 'name';
         database.insert(loc);
         
         City__c city = new City__c();
         city.City_Name__c = 'name';
         city.Flight_Number_1__c = '123';
         city.Flight_Number_2__c = '432';
         database.insert(city);
         
         Packing_Grp__c packCode = new Packing_Grp__c();
         packCode.Airline__c = 'airline';
         database.insert(packCode);
         
         counter=0;
         List<Address__c> ad = TestDataFactory.createAddress(4);
         for(Address__c a: ad){
             if(counter==0){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Local'].Id;
             }
             else if(counter==1){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Overseas'].Id;
             }
             else if(counter==2){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Internal'].Id;
             }
             else{
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Airline'].Id;
             }
             a.Block_House_Number__c = '01';
             a.Level_Number__c = '01';
             a.Unit_Number__c = '01';
             a.Postal_Code__c = postal.Id;
             a.Country__c = country.Id;
             a.Address_1__c = 'ass';
             a.Address_2__c = 'ss';
             a.Address_3__c = 'ss';
             a.Address_4__c = 'ss';
             a.Section_Code__c = section.Id;
             a.Department__c = dept.Id;
             a.Division_Code__c = div.Id;
             a.Company_Code__c = com.Id;
             a.Location_Code__c = loc.Id;
             a.City__c = city.Id;
             //a.Airline_Number__c = '123';
             //a.Flight_Number_1__c = '345';
            //a.Flight_Number_2__c = '564';
             a.Packing_Code__c = packCode.Id;
             counter++;
         }
         database.insert(ad);
         
         counter=0;
         List<Contact> con = TestDataFactory.createContactRecType(4, 'Customer Contact');
         for(Contact c: con){
             if(counter==0){
                 c.Address__c = ad[0].Id;
             }
             else if(counter==1){
                 c.Address__c = ad[1].Id;
             }
             else if(counter==2){
                 c.Address__c = ad[2].Id;
             }
             else{
                 c.Address__c = ad[3].Id;
             }
             c.Email__c = 'sample@ab.c';
             c.Email_Secondary__c = 'samplEmail@ab.com';
             counter++;
         }
         database.insert(con);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         database.insert(pack);
         
         counter=0;
         List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
         for(zqu__ZProduct__c z: zp){
             if(counter==0){
                 z.ProductSubType__c = 'Magazine';
             }
             else{
                 z.ProductSubType__c = 'Newspaper';
             }
             z.ProductCode__c = '1';
             counter++;
         }
         database.insert(zp);
         
         zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
         prp.zqu__ZProduct__c = zp[0].Id;
         database.insert(prp);
         
         Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         packItem.Product_Rate_Plan__c = prp.Id;
         packItem.Package__c = pack.Id;
         database.insert(packItem);
         
         counter=0;
         List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(10);
         for(Zuora__Subscription__c sub: subs){
             sub.is1stNotifEmailSent__c = false;
             sub.Zuora__SubscriptionEndDate__c = System.Today().addDays(42);
             sub.Zuora__TermSettingType__c = 'TERMED';
             sub.Zuora__AutoRenew__c = false;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type__c = 'Publication';
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Recipient_Contact__c = con[0].id;
             //sub.Order_Line_Item_Number_1__c = orderline.Id;
             //sub.Subscription_Type__c = 'Delivery';
             sub.Main_Package_1__c = pack.id;
             sub.Main_Package__c = pack.id;
             sub.Product_Code__c = '1';
             sub.Term_Length__c = 0.0;
             sub.Term_Length1__c = '0.0';
             sub.Zuora__SubscriptionStartDate__c = System.Today().addDays(42);
             sub.Main_Package__c = pack.Id;
             sub.Subscriber_Contact__c = con[0].Id;
             //sub.Main_Package_Product_Sub_Type_Mapping__c = 'Magazine';
             if(/*counter==0 || */counter==1){
               sub.Subscription_Type__c = 'Delivery';  
             }
             else if(counter==2){
                 sub.Contact__c = con[0].Id;
             }
             else if(counter==3){
                 sub.Contact__c = con[1].Id;
             }
             else if(counter==4){
                 sub.Contact__c = con[2].Id;
             }
             else if(counter==5){
                 sub.Contact__c = con[3].Id;
             }
             counter++;
         }
         database.insert(subs);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c  = acc.Id;
         ord.Base_Subscription__c = subs[0].id;
         database.insert(ord);
         
         Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
         ordLine.Order__c = ord.Id;
         ordLine.Main_Package_ID__c = pack.Id;
         ordLine.Main_Package_Product_Sub_Type__c = 'Magazine';
         ordLine.Start_Date__c = System.Today().addDays(43);
         database.insert(ordLine);
         
         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(subs[0].Id);
         letterPrintRequest.Language_Medium__c = 'C';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(subs[0].Id);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
         
         system.assertEquals(subs[0].Zuora__SubscriptionEndDate__c, System.Today().addDays(42));
         
         Zuora__Subscription__c subsQ = [SELECT id, Zuora__Account__r.Renewal_Letter__c, Zuora__Account__r.RecordType.Id, Subscription_Type_1__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, is1stNotifEmailSent__c, Zuora__AutoRenew__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id];
         
         //date firstNotifDate = subsQ.Zuora__SubscriptionEndDate__c-42;
         //date firstNotifDate = date.newInstance(subsQ.Zuora__SubscriptionEndDate__c.year(), subsQ.Zuora__SubscriptionEndDate__c.month(), subsQ.Zuora__SubscriptionEndDate__c.day()-42);
         date firstNotifDate1 = subsQ.Zuora__SubscriptionEndDate__c; //.addDays(42);
         date firstNotifDate = date.newInstance(firstNotifDate1.year(),firstNotifDate1.month(),firstNotifDate1.day()-42);
         //system.assertEquals(firstNotifDate, firstNotifDate1);
         system.assertEquals(subsQ.is1stNotifEmailSent__c, false);
         system.assertEquals(subsQ.Zuora__AutoRenew__c, false);
         system.assertEquals(subsQ.Zuora__Status__c, 'Active');
         system.assertEquals(subsQ.Subscription_Type_1__c, 'Publication');
         system.assertEquals(subsQ.Zuora__Account__r.RecordType.Id, ConstantsSLB.getKeyId('Account_Direct Corporate'));
         system.assertEquals(subsQ.Zuora__Account__r.Renewal_Letter__c, GlobalVariableClass.REFERENCE_EMAIL);
        
         List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
         for(Zuora__SubscriptionProductCharge__c sp : spc){
             sp.Zuora__Subscription__c = subs[2].Id;
         }
         database.insert(spc);
         
         Document doc = new Document();
         doc.Name = 'SPH Logo v2';
         doc.FolderId = UserInfo.getUserId();
         database.insert(doc);
         
         Set<id> renewalSubsId = new Set<id>();
         renewalSubsId.add(subs[0].id);
         
         Set<id> renewallpr = new Set<id>();
         renewallpr.add(lprList[1].id);
         
         test.startTest();
             //SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
             //database.executeBatch(batch, 200);
             SP_SendEmailNotifForSubsRenewalsBatch batch2 = new SP_SendEmailNotifForSubsRenewalsBatch(renewallpr, firstNotifDate);
             database.executeBatch(batch2, 200);
             
            // Database.BatchableContext BC;
            // batch2.execute(BC, letterPrintReqList);
         test.stopTest();
     }
     
     //jurna
      static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch4(){
         Integer counter=0;
     
         List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='SPH Logo v2', Value__c='SPH Logo v2')
        };
        database.insert(otherList);
        
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
         database.insert(acc);
         
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Street_Name__c = 'test';
         postal.Building_Name__c = 'build';
         database.insert(postal);
         
         Country__c country = TestDataFactory.createCountry(1)[0];
         country.Country_Name__c = 'Singapore';
         database.insert(country);
         
         SPH_Section__c section = new SPH_Section__c();
         section.Section_Name__c = 'name';
         database.insert(section);
         
         SPH_Department__c dept = new SPH_Department__c();
         dept.Department_Name__c = 'name';
         database.insert(dept);
         
         SPH_Division__c div = new SPH_Division__c();
         div.Name = 'Name';
         database.insert(div);
         
         SPH_Company__c com = new SPH_Company__c();
         com.Company_Name__c = 'name';
         database.insert(com);
         
         SPH_Location__c loc = new SPH_Location__c();
         loc.Location_Name__c = 'name';
         database.insert(loc);
         
         City__c city = new City__c();
         city.City_Name__c = 'name';
         city.Flight_Number_1__c = '123';
         city.Flight_Number_2__c = '432';
         database.insert(city);
         
         Packing_Grp__c packCode = new Packing_Grp__c();
         packCode.Airline__c = 'airline';
         database.insert(packCode);
         
         counter=0;
         List<Address__c> ad = TestDataFactory.createAddress(4);
         for(Address__c a: ad){
             if(counter==0){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Local'].Id;
             }
             else if(counter==1){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Overseas'].Id;
             }
             else if(counter==2){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Internal'].Id;
             }
             else{
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Airline'].Id;
             }
             a.Block_House_Number__c = '01';
             a.Level_Number__c = '01';
             a.Unit_Number__c = '01';
             a.Postal_Code__c = postal.Id;
             a.Country__c = country.Id;
             a.Address_1__c = 'ass';
             a.Address_2__c = 'ss';
             a.Address_3__c = 'ss';
             a.Address_4__c = 'ss';
             a.Section_Code__c = section.Id;
             a.Department__c = dept.Id;
             a.Division_Code__c = div.Id;
             a.Company_Code__c = com.Id;
             a.Location_Code__c = loc.Id;
             a.City__c = city.Id;
             //a.Airline_Number__c = '123';
             //a.Flight_Number_1__c = '345';
            //a.Flight_Number_2__c = '564';
             a.Packing_Code__c = packCode.Id;
             counter++;
         }
         database.insert(ad);
         
         counter=0;
         List<Contact> con = TestDataFactory.createContactRecType(4, 'Customer Contact');
         for(Contact c: con){
             if(counter==0){
                 c.Address__c = ad[0].Id;
             }
             else if(counter==1){
                 c.Address__c = ad[1].Id;
             }
             else if(counter==2){
                 c.Address__c = ad[2].Id;
             }
             else{
                 c.Address__c = ad[3].Id;
             }
             c.Email__c = 'sample@ab.c';
             c.Email_Secondary__c = 'samplEmail@ab.com';
             counter++;
         }
         database.insert(con);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         database.insert(pack);
         
         counter=0;
         List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
         for(zqu__ZProduct__c z: zp){
             if(counter==0){
                 z.ProductSubType__c = 'Magazine';
             }
             else{
                 z.ProductSubType__c = 'Newspaper';
             }
             z.ProductCode__c = '1';
             counter++;
         }
         database.insert(zp);
         
         zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
         prp.zqu__ZProduct__c = zp[0].Id;
         database.insert(prp);
         
         Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         packItem.Product_Rate_Plan__c = prp.Id;
         packItem.Package__c = pack.Id;
         database.insert(packItem);
         
         counter=0;
         List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(10);
         for(Zuora__Subscription__c sub: subs){
             sub.is1stNotifEmailSent__c = false;
             sub.Zuora__SubscriptionEndDate__c = System.Today().addDays(42);
             sub.Zuora__TermSettingType__c = 'TERMED';
             sub.Zuora__AutoRenew__c = false;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type__c = 'Publication';
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Recipient_Contact__c = con[0].id;
             //sub.Order_Line_Item_Number_1__c = orderline.Id;
             //sub.Subscription_Type__c = 'Delivery';
             sub.Main_Package_1__c = pack.id;
             sub.Main_Package__c = pack.id;
             sub.Product_Code__c = '1';
             sub.Term_Length__c = 0.0;
             sub.Term_Length1__c = '0.0';
             sub.Zuora__SubscriptionStartDate__c = System.Today().addDays(42);
             sub.Main_Package__c = pack.Id;
             sub.Subscriber_Contact__c = con[0].Id;
             //sub.Main_Package_Product_Sub_Type_Mapping__c = 'Magazine';
             if(/*counter==0 || */counter==1){
               sub.Subscription_Type__c = 'Delivery';  
             }
             else if(counter==2){
                 sub.Contact__c = con[0].Id;
             }
             else if(counter==3){
                 sub.Contact__c = con[1].Id;
             }
             else if(counter==4){
                 sub.Contact__c = con[2].Id;
             }
             else if(counter==5){
                 sub.Contact__c = con[3].Id;
             }
             counter++;
         }
         database.insert(subs);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c  = acc.Id;
         ord.Base_Subscription__c = subs[0].id;
         database.insert(ord);
         
         Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
         ordLine.Order__c = ord.Id;
         ordLine.Main_Package_ID__c = pack.Id;
         ordLine.Main_Package_Product_Sub_Type__c = 'Magazine';
         ordLine.Start_Date__c = System.Today().addDays(43);
         database.insert(ordLine);
         
         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(subs[0].Id);
         letterPrintRequest.Language_Medium__c = 'E';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(subs[0].Id);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
         
         system.assertEquals(subs[0].Zuora__SubscriptionEndDate__c, System.Today().addDays(42));
         
         Zuora__Subscription__c subsQ = [SELECT id, Zuora__Account__r.Renewal_Letter__c, Zuora__Account__r.RecordType.Id, Subscription_Type_1__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, is1stNotifEmailSent__c, Zuora__AutoRenew__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id];
         
         //date firstNotifDate = subsQ.Zuora__SubscriptionEndDate__c-42;
         //date firstNotifDate = date.newInstance(subsQ.Zuora__SubscriptionEndDate__c.year(), subsQ.Zuora__SubscriptionEndDate__c.month(), subsQ.Zuora__SubscriptionEndDate__c.day()-42);
         date firstNotifDate1 = subsQ.Zuora__SubscriptionEndDate__c; //.addDays(42);
         date firstNotifDate = date.newInstance(firstNotifDate1.year(),firstNotifDate1.month(),firstNotifDate1.day()-42);
         //system.assertEquals(firstNotifDate, firstNotifDate1);
         system.assertEquals(subsQ.is1stNotifEmailSent__c, false);
         system.assertEquals(subsQ.Zuora__AutoRenew__c, false);
         system.assertEquals(subsQ.Zuora__Status__c, 'Active');
         system.assertEquals(subsQ.Subscription_Type_1__c, 'Publication');
         system.assertEquals(subsQ.Zuora__Account__r.RecordType.Id, ConstantsSLB.getKeyId('Account_Direct Corporate'));
         system.assertEquals(subsQ.Zuora__Account__r.Renewal_Letter__c, GlobalVariableClass.REFERENCE_EMAIL);
        
         List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
         for(Zuora__SubscriptionProductCharge__c sp : spc){
             sp.Zuora__Subscription__c = subs[2].Id;
         }
         database.insert(spc);
         
         Document doc = new Document();
         doc.Name = 'SPH Logo v2';
         doc.FolderId = UserInfo.getUserId();
         database.insert(doc);
         
         Set<id> renewalSubsId = new Set<id>();
         renewalSubsId.add(subs[0].id);
         
         Set<id> renewallpr = new Set<id>();
         renewallpr.add(lprList[1].id);
         
         test.startTest();
             //SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
             //database.executeBatch(batch, 200);
             SP_SendEmailNotifForSubsRenewalsBatch batch2 = new SP_SendEmailNotifForSubsRenewalsBatch(renewallpr, firstNotifDate);
             database.executeBatch(batch2, 200);
             
            // Database.BatchableContext BC;
            // batch2.execute(BC, letterPrintReqList);
         test.stopTest();
     }
     
     //jurna
      static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch5(){
         Integer counter=0;
     
         List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='SPH Logo v2', Value__c='SPH Logo v2')
        };
        database.insert(otherList);
        
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
         database.insert(acc);
         
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Street_Name__c = 'test';
         postal.Building_Name__c = 'build';
         database.insert(postal);
         
         Country__c country = TestDataFactory.createCountry(1)[0];
         country.Country_Name__c = 'Singapore';
         database.insert(country);
         
         SPH_Section__c section = new SPH_Section__c();
         section.Section_Name__c = 'name';
         database.insert(section);
         
         SPH_Department__c dept = new SPH_Department__c();
         dept.Department_Name__c = 'name';
         database.insert(dept);
         
         SPH_Division__c div = new SPH_Division__c();
         div.Name = 'Name';
         database.insert(div);
         
         SPH_Company__c com = new SPH_Company__c();
         com.Company_Name__c = 'name';
         database.insert(com);
         
         SPH_Location__c loc = new SPH_Location__c();
         loc.Location_Name__c = 'name';
         database.insert(loc);
         
         City__c city = new City__c();
         city.City_Name__c = 'name';
         city.Flight_Number_1__c = '123';
         city.Flight_Number_2__c = '432';
         database.insert(city);
         
         Packing_Grp__c packCode = new Packing_Grp__c();
         packCode.Airline__c = 'airline';
         database.insert(packCode);
         
         counter=0;
         List<Address__c> ad = TestDataFactory.createAddress(4);
         for(Address__c a: ad){
             if(counter==0){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Local'].Id;
             }
             else if(counter==1){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Overseas'].Id;
             }
             else if(counter==2){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Internal'].Id;
             }
             else{
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Airline'].Id;
             }
             a.Block_House_Number__c = '01';
             a.Level_Number__c = '01';
             a.Unit_Number__c = '01';
             a.Postal_Code__c = postal.Id;
             a.Country__c = country.Id;
             a.Address_1__c = 'ass';
             a.Address_2__c = 'ss';
             a.Address_3__c = 'ss';
             a.Address_4__c = 'ss';
             a.Section_Code__c = section.Id;
             a.Department__c = dept.Id;
             a.Division_Code__c = div.Id;
             a.Company_Code__c = com.Id;
             a.Location_Code__c = loc.Id;
             a.City__c = city.Id;
             //a.Airline_Number__c = '123';
             //a.Flight_Number_1__c = '345';
            //a.Flight_Number_2__c = '564';
             a.Packing_Code__c = packCode.Id;
             counter++;
         }
         database.insert(ad);
         
         counter=0;
         List<Contact> con = TestDataFactory.createContactRecType(4, 'Customer Contact');
         for(Contact c: con){
             if(counter==0){
                 c.Address__c = ad[0].Id;
             }
             else if(counter==1){
                 c.Address__c = ad[1].Id;
             }
             else if(counter==2){
                 c.Address__c = ad[2].Id;
             }
             else{
                 c.Address__c = ad[3].Id;
             }
             c.Email__c = 'sample@ab.c';
             c.Email_Secondary__c = 'samplEmail@ab.com';
             c.Company_Name__c = 'testComp';
             //c.Name = 'testn';
             counter++;
         }
         database.insert(con);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         billAcc.Billing_Contact__c = con[0].id;
         database.insert(billAcc);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         database.insert(pack);
         
         counter=0;
         List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
         for(zqu__ZProduct__c z: zp){
             if(counter==0){
                 z.ProductSubType__c = 'Magazine';
             }
             else{
                 z.ProductSubType__c = 'Newspaper';
             }
             z.ProductCode__c = '1';
             counter++;
         }
         database.insert(zp);
         
         zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
         prp.zqu__ZProduct__c = zp[0].Id;
         database.insert(prp);
         
         Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         packItem.Product_Rate_Plan__c = prp.Id;
         packItem.Package__c = pack.Id;
         database.insert(packItem);
         
         counter=0;
         List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(10);
         for(Zuora__Subscription__c sub: subs){
             sub.is1stNotifEmailSent__c = false;
             sub.Zuora__SubscriptionEndDate__c = System.Today().addDays(42);
             sub.Zuora__TermSettingType__c = 'TERMED';
             sub.Zuora__AutoRenew__c = false;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type__c = 'Publication';
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Recipient_Contact__c = con[0].id;
             //sub.Order_Line_Item_Number_1__c = orderline.Id;
             //sub.Subscription_Type__c = 'Delivery';
             sub.Main_Package_1__c = pack.id;
             sub.Main_Package__c = pack.id;
             sub.Product_Code__c = '1';
             sub.Term_Length__c = 0.0;
             sub.Term_Length1__c = '0.0';
             sub.Zuora__SubscriptionStartDate__c = System.Today().addDays(42);
             sub.Main_Package__c = pack.Id;
             sub.Subscriber_Contact__c =     con[0].Id;
             //sub.Zuora__SubscriptionEndDate__c = date.today()+3;
             //sub.Main_Package_Product_Sub_Type_Mapping__c = 'Magazine';
             if(/*counter==0 || */counter==1){
               sub.Subscription_Type__c = 'Delivery';  
             }
             else if(counter==2){
                 sub.Contact__c = con[0].Id;
             }
             else if(counter==3){
                 sub.Contact__c = con[1].Id;
             }
             else if(counter==4){
                 sub.Contact__c = con[2].Id;
             }
             else if(counter==5){
                 sub.Contact__c = con[3].Id;
             }
             counter++;
         }
         database.insert(subs);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c  = acc.Id;
         ord.Base_Subscription__c = subs[0].id;
         database.insert(ord);
         
         Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
         ordLine.Order__c = ord.Id;
         ordLine.Main_Package_ID__c = pack.Id;
         ordLine.Main_Package_Product_Sub_Type__c = 'Magazine';
         ordLine.Start_Date__c = system.Today().addDays(43);
         database.insert(ordLine);
         
         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(subs[0].Id);
         letterPrintRequest.Language_Medium__c = 'E';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(subs[0].Id);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
         
         system.assertEquals(subs[0].Zuora__SubscriptionEndDate__c, System.Today().addDays(42));
         
         Zuora__Subscription__c subsQ = [SELECT id, Zuora__Account__r.Renewal_Letter__c, Zuora__Account__r.RecordType.Id, Subscription_Type_1__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, is1stNotifEmailSent__c, Zuora__AutoRenew__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id];
         
         //date firstNotifDate = subsQ.Zuora__SubscriptionEndDate__c-42;
         //date firstNotifDate = date.newInstance(subsQ.Zuora__SubscriptionEndDate__c.year(), subsQ.Zuora__SubscriptionEndDate__c.month(), subsQ.Zuora__SubscriptionEndDate__c.day()-42);
         date firstNotifDate1 = subsQ.Zuora__SubscriptionEndDate__c; //.addDays(42);
         date firstNotifDate = date.newInstance(firstNotifDate1.year(),firstNotifDate1.month(),firstNotifDate1.day()-42);
         //system.assertEquals(firstNotifDate, firstNotifDate1);
         system.assertEquals(subsQ.is1stNotifEmailSent__c, false);
         system.assertEquals(subsQ.Zuora__AutoRenew__c, false);
         system.assertEquals(subsQ.Zuora__Status__c, 'Active');
         system.assertEquals(subsQ.Subscription_Type_1__c, 'Publication');
         system.assertEquals(subsQ.Zuora__Account__r.RecordType.Id, ConstantsSLB.getKeyId('Account_Direct Corporate'));
         system.assertEquals(subsQ.Zuora__Account__r.Renewal_Letter__c, GlobalVariableClass.REFERENCE_EMAIL);
        
         List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
         for(Zuora__SubscriptionProductCharge__c sp : spc){
             sp.Zuora__Subscription__c = subs[2].Id;
         }
         database.insert(spc);
         
         Document doc = new Document();
         doc.Name = 'SPH Logo v2';
         doc.FolderId = UserInfo.getUserId();
         database.insert(doc);
         
         Set<id> renewalSubsId = new Set<id>();
         renewalSubsId.add(subs[0].id);
         
         Set<id> renewallpr = new Set<id>();
         renewallpr.add(lprList[1].id);
         
         test.startTest();
             //SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
             //database.executeBatch(batch, 200);
             SP_SendEmailNotifForSubsRenewalsBatch batch2 = new SP_SendEmailNotifForSubsRenewalsBatch(renewallpr, firstNotifDate);
             database.executeBatch(batch2, 200);
             
            // Database.BatchableContext BC;
            // batch2.execute(BC, letterPrintReqList);
         test.stopTest();
     }
     
     //jurna
      static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch6(){
         Integer counter=0;
     
         List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='SPH Logo v2', Value__c='SPH Logo v2')
        };
        database.insert(otherList);
        
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
         database.insert(acc);
         
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Street_Name__c = 'test';
         postal.Building_Name__c = 'build';
         database.insert(postal);
         
         Country__c country = TestDataFactory.createCountry(1)[0];
         country.Country_Name__c = 'Singapore';
         database.insert(country);
         
         SPH_Section__c section = new SPH_Section__c();
         section.Section_Name__c = 'name';
         database.insert(section);
         
         SPH_Department__c dept = new SPH_Department__c();
         dept.Department_Name__c = 'name';
         database.insert(dept);
         
         SPH_Division__c div = new SPH_Division__c();
         div.Name = 'Name';
         database.insert(div);
         
         SPH_Company__c com = new SPH_Company__c();
         com.Company_Name__c = 'name';
         database.insert(com);
         
         SPH_Location__c loc = new SPH_Location__c();
         loc.Location_Name__c = 'name';
         database.insert(loc);
         
         City__c city = new City__c();
         city.City_Name__c = 'name';
         city.Flight_Number_1__c = '123';
         city.Flight_Number_2__c = '432';
         database.insert(city);
         
         Packing_Grp__c packCode = new Packing_Grp__c();
         packCode.Airline__c = 'airline';
         database.insert(packCode);
         
         counter=0;
         List<Address__c> ad = TestDataFactory.createAddress(4);
         for(Address__c a: ad){
             if(counter==0){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Local'].Id;
             }
             else if(counter==1){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Overseas'].Id;
             }
             else if(counter==2){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Internal'].Id;
             }
             else{
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Airline'].Id;
             }
             a.Block_House_Number__c = '01';
             a.Level_Number__c = '01';
             a.Unit_Number__c = '01';
             a.Postal_Code__c = postal.Id;
             a.Country__c = country.Id;
             a.Address_1__c = 'ass';
             a.Address_2__c = 'ss';
             a.Address_3__c = 'ss';
             a.Address_4__c = 'ss';
             a.Section_Code__c = section.Id;
             a.Department__c = dept.Id;
             a.Division_Code__c = div.Id;
             a.Company_Code__c = com.Id;
             a.Location_Code__c = loc.Id;
             a.City__c = city.Id;
             //a.Airline_Number__c = '123';
             //a.Flight_Number_1__c = '345';
            //a.Flight_Number_2__c = '564';
             a.Packing_Code__c = packCode.Id;
             counter++;
         }
         database.insert(ad);
         
         counter=0;
         List<Contact> con = TestDataFactory.createContactRecType(4, 'Customer Contact');
         for(Contact c: con){
             if(counter==0){
                 c.Address__c = ad[0].Id;
             }
             else if(counter==1){
                 c.Address__c = ad[1].Id;
             }
             else if(counter==2){
                 c.Address__c = ad[2].Id;
             }
             else{
                 c.Address__c = ad[3].Id;
             }
             c.Email__c = 'sample@ab.c';
             c.Email_Secondary__c = 'samplEmail@ab.com';
             c.Company_Name__c = 'testComp';
             //c.Name = 'testn';
             counter++;
         }
         database.insert(con);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         billAcc.Billing_Contact__c = con[0].id;
         database.insert(billAcc);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         database.insert(pack);
         
         counter=0;
         List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
         for(zqu__ZProduct__c z: zp){
             if(counter==0){
                 z.ProductSubType__c = 'Magazine';
             }
             else{
                 z.ProductSubType__c = 'Newspaper';
             }
             z.ProductCode__c = '1';
             counter++;
         }
         database.insert(zp);
         
         zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
         prp.zqu__ZProduct__c = zp[0].Id;
         database.insert(prp);
         
         Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         packItem.Product_Rate_Plan__c = prp.Id;
         packItem.Package__c = pack.Id;
         database.insert(packItem);
         
         counter=0;
         List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(10);
         for(Zuora__Subscription__c sub: subs){
             sub.is1stNotifEmailSent__c = false;
             sub.Zuora__SubscriptionEndDate__c = System.Today().addDays(42);
             sub.Zuora__TermSettingType__c = 'TERMED';
             sub.Zuora__AutoRenew__c = false;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type__c = 'Publication';
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Recipient_Contact__c = con[0].id;
             //sub.Order_Line_Item_Number_1__c = orderline.Id;
             //sub.Subscription_Type__c = 'Delivery';
             sub.Main_Package_1__c = pack.id;
             sub.Main_Package__c = pack.id;
             sub.Product_Code__c = '1';
             sub.Term_Length__c = 0.0;
             sub.Term_Length1__c = '0.0';
             sub.Zuora__SubscriptionStartDate__c = System.Today().addDays(42);
             sub.Main_Package__c = pack.Id;
             sub.Subscriber_Contact__c =     con[0].Id;
             //sub.Zuora__SubscriptionEndDate__c = date.today()+3;
             //sub.Main_Package_Product_Sub_Type_Mapping__c = 'Magazine';
             if(/*counter==0 || */counter==1){
               sub.Subscription_Type__c = 'Delivery';  
             }
             else if(counter==2){
                 sub.Contact__c = con[0].Id;
             }
             else if(counter==3){
                 sub.Contact__c = con[1].Id;
             }
             else if(counter==4){
                 sub.Contact__c = con[2].Id;
             }
             else if(counter==5){
                 sub.Contact__c = con[3].Id;
             }
             counter++;
         }
         database.insert(subs);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c  = acc.Id;
         ord.Base_Subscription__c = subs[0].id;
         database.insert(ord);
         
         Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
         ordLine.Order__c = ord.Id;
         ordLine.Main_Package_ID__c = pack.Id;
         ordLine.Main_Package_Product_Sub_Type__c = 'Magazine';
         ordLine.Start_Date__c = system.Today().addDays(43);
         database.insert(ordLine);
         
         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(subs[0].Id);
         letterPrintRequest.Language_Medium__c = 'E';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(subs[0].Id);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
         
         system.assertEquals(subs[0].Zuora__SubscriptionEndDate__c, System.Today().addDays(42));
         
         Zuora__Subscription__c subsQ = [SELECT id, Zuora__Account__r.Renewal_Letter__c, Zuora__Account__r.RecordType.Id, Subscription_Type_1__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, is1stNotifEmailSent__c, Zuora__AutoRenew__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id];
         
         //date firstNotifDate = subsQ.Zuora__SubscriptionEndDate__c-42;
         //date firstNotifDate = date.newInstance(subsQ.Zuora__SubscriptionEndDate__c.year(), subsQ.Zuora__SubscriptionEndDate__c.month(), subsQ.Zuora__SubscriptionEndDate__c.day()-42);
         date firstNotifDate1 = subsQ.Zuora__SubscriptionEndDate__c; //.addDays(42);
         date firstNotifDate = date.newInstance(firstNotifDate1.year(),firstNotifDate1.month(),firstNotifDate1.day()-42);
         //system.assertEquals(firstNotifDate, firstNotifDate1);
         system.assertEquals(subsQ.is1stNotifEmailSent__c, false);
         system.assertEquals(subsQ.Zuora__AutoRenew__c, false);
         system.assertEquals(subsQ.Zuora__Status__c, 'Active');
         system.assertEquals(subsQ.Subscription_Type_1__c, 'Publication');
         system.assertEquals(subsQ.Zuora__Account__r.RecordType.Id, ConstantsSLB.getKeyId('Account_Direct Corporate'));
         system.assertEquals(subsQ.Zuora__Account__r.Renewal_Letter__c, GlobalVariableClass.REFERENCE_EMAIL);
        
         List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
         for(Zuora__SubscriptionProductCharge__c sp : spc){
             sp.Zuora__Subscription__c = subs[2].Id;
         }
         database.insert(spc);
         
         Document doc = new Document();
         doc.Name = 'SPH Logo v2';
         doc.FolderId = UserInfo.getUserId();
         database.insert(doc);
         
         Set<id> renewalSubsId = new Set<id>();
         renewalSubsId.add(subs[0].id);
         
         Set<id> renewallpr = new Set<id>();
         renewallpr.add(lprList[1].id);
         
         test.startTest();
             //SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
             //database.executeBatch(batch, 200);
             SP_SendEmailNotifForSubsRenewalsBatch batch2 = new SP_SendEmailNotifForSubsRenewalsBatch(renewallpr, firstNotifDate);
             database.executeBatch(batch2, 200);
             
            // Database.BatchableContext BC;
            // batch2.execute(BC, letterPrintReqList);
         test.stopTest();
     }
     
     //jurna
      static testMethod void testSP_SendEmailNotifForSubsRenewalsBatch7(){
         Integer counter=0;
     
         List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='SPH Logo v2', Value__c='SPH Logo v2')
        };
        database.insert(otherList);
        
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.Renewal_Letter__c = GlobalVariableClass.REFERENCE_EMAIL;
         database.insert(acc);
         
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Street_Name__c = 'test';
         postal.Building_Name__c = 'build';
         database.insert(postal);
         
         Country__c country = TestDataFactory.createCountry(1)[0];
         country.Country_Name__c = 'Singapore';
         database.insert(country);
         
         SPH_Section__c section = new SPH_Section__c();
         section.Section_Name__c = 'name';
         database.insert(section);
         
         SPH_Department__c dept = new SPH_Department__c();
         dept.Department_Name__c = 'name';
         database.insert(dept);
         
         SPH_Division__c div = new SPH_Division__c();
         div.Name = 'Name';
         database.insert(div);
         
         SPH_Company__c com = new SPH_Company__c();
         com.Company_Name__c = 'name';
         database.insert(com);
         
         SPH_Location__c loc = new SPH_Location__c();
         loc.Location_Name__c = 'name';
         database.insert(loc);
         
         City__c city = new City__c();
         city.City_Name__c = 'name';
         city.Flight_Number_1__c = '123';
         city.Flight_Number_2__c = '432';
         database.insert(city);
         
         Packing_Grp__c packCode = new Packing_Grp__c();
         packCode.Airline__c = 'airline';
         database.insert(packCode);
         
         counter=0;
         List<Address__c> ad = TestDataFactory.createAddress(4);
         for(Address__c a: ad){
             if(counter==0){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Local'].Id;
             }
             else if(counter==1){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Overseas'].Id;
             }
             else if(counter==2){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Internal'].Id;
             }
             else{
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Airline'].Id;
             }
             a.Block_House_Number__c = '01';
             a.Level_Number__c = '01';
             a.Unit_Number__c = '01';
             a.Postal_Code__c = postal.Id;
             a.Country__c = country.Id;
             a.Address_1__c = 'ass';
             a.Address_2__c = 'ss';
             a.Address_3__c = 'ss';
             a.Address_4__c = 'ss';
             a.Section_Code__c = section.Id;
             a.Department__c = dept.Id;
             a.Division_Code__c = div.Id;
             a.Company_Code__c = com.Id;
             a.Location_Code__c = loc.Id;
             a.City__c = city.Id;
             //a.Airline_Number__c = '123';
             //a.Flight_Number_1__c = '345';
            //a.Flight_Number_2__c = '564';
             a.Packing_Code__c = packCode.Id;
             counter++;
         }
         database.insert(ad);
         
         counter=0;
         List<Contact> con = TestDataFactory.createContactRecType(4, 'Customer Contact');
         for(Contact c: con){
             if(counter==0){
                 c.Address__c = ad[0].Id;
             }
             else if(counter==1){
                 c.Address__c = ad[1].Id;
             }
             else if(counter==2){
                 c.Address__c = ad[2].Id;
             }
             else{
                 c.Address__c = ad[3].Id;
             }
             c.Email__c = 'sample@ab.c';
             c.Email_Secondary__c = 'samplEmail@ab.com';
             c.Company_Name__c = 'testComp';
             //c.Name = 'testn';
             counter++;
         }
         database.insert(con);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         billAcc.Billing_Contact__c = con[0].id;
         database.insert(billAcc);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         database.insert(pack);
         
         counter=0;
         List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
         for(zqu__ZProduct__c z: zp){
             if(counter==0){
                 z.ProductSubType__c = 'Magazine';
             }
             else{
                 z.ProductSubType__c = 'Newspaper';
             }
             z.ProductCode__c = '1';
             counter++;
         }
         database.insert(zp);
         
         zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
         prp.zqu__ZProduct__c = zp[0].Id;
         database.insert(prp);
         
         Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
         packItem.Product_Rate_Plan__c = prp.Id;
         packItem.Package__c = pack.Id;
         database.insert(packItem);
         
         counter=0;
         List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(10);
         for(Zuora__Subscription__c sub: subs){
             sub.is1stNotifEmailSent__c = false;
             sub.Zuora__SubscriptionEndDate__c = System.Today().addDays(42);
             sub.Zuora__TermSettingType__c = 'TERMED';
             sub.Zuora__AutoRenew__c = false;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type__c = 'Publication';
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             sub.Recipient_Contact__c = con[0].id;
             //sub.Order_Line_Item_Number_1__c = orderline.Id;
             //sub.Subscription_Type__c = 'Delivery';
             sub.Main_Package_1__c = pack.id;
             sub.Main_Package__c = pack.id;
             sub.Product_Code__c = '1';
             sub.Term_Length__c = 0.0;
             sub.Term_Length1__c = '0.0';
             sub.Zuora__SubscriptionStartDate__c = System.Today().addDays(42);
             sub.Main_Package__c = pack.Id;
             sub.Subscriber_Contact__c =     con[0].Id;
             //sub.Zuora__SubscriptionEndDate__c = date.today()+3;
             //sub.Main_Package_Product_Sub_Type_Mapping__c = 'Magazine';
             if(/*counter==0 || */counter==1){
               sub.Subscription_Type__c = 'Delivery';  
             }
             else if(counter==2){
                 sub.Contact__c = con[0].Id;
             }
             else if(counter==3){
                 sub.Contact__c = con[1].Id;
             }
             else if(counter==4){
                 sub.Contact__c = con[2].Id;
             }
             else if(counter==5){
                 sub.Contact__c = con[3].Id;
             }
             counter++;
         }
         database.insert(subs);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c  = acc.Id;
         ord.Base_Subscription__c = subs[0].id;
         database.insert(ord);
         
         Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
         ordLine.Order__c = ord.Id;
         ordLine.Main_Package_ID__c = pack.Id;
         ordLine.Main_Package_Product_Sub_Type__c = 'Magazine';
         ordLine.Start_Date__c = system.Today().addDays(43);
         database.insert(ordLine);
         
         Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(subs[0].Id);
         letterPrintRequest.Language_Medium__c = 'E';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         //letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(subs[0].Id);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         update letterPrintRequest;
         
         List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
         lprList.add(letterPrintRequest2);
         lprList.add(letterPrintRequest);
         
         system.assertEquals(subs[0].Zuora__SubscriptionEndDate__c, System.Today().addDays(42));
         
         Zuora__Subscription__c subsQ = [SELECT id, Zuora__Account__r.Renewal_Letter__c, Zuora__Account__r.RecordType.Id, Subscription_Type_1__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, is1stNotifEmailSent__c, Zuora__AutoRenew__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id];
         
         //date firstNotifDate = subsQ.Zuora__SubscriptionEndDate__c-42;
         //date firstNotifDate = date.newInstance(subsQ.Zuora__SubscriptionEndDate__c.year(), subsQ.Zuora__SubscriptionEndDate__c.month(), subsQ.Zuora__SubscriptionEndDate__c.day()-42);
         date firstNotifDate1 = subsQ.Zuora__SubscriptionEndDate__c; //.addDays(42);
         date firstNotifDate = date.newInstance(firstNotifDate1.year(),firstNotifDate1.month(),firstNotifDate1.day()-42);
         //system.assertEquals(firstNotifDate, firstNotifDate1);
         system.assertEquals(subsQ.is1stNotifEmailSent__c, false);
         system.assertEquals(subsQ.Zuora__AutoRenew__c, false);
         system.assertEquals(subsQ.Zuora__Status__c, 'Active');
         system.assertEquals(subsQ.Subscription_Type_1__c, 'Publication');
         system.assertEquals(subsQ.Zuora__Account__r.RecordType.Id, ConstantsSLB.getKeyId('Account_Direct Corporate'));
         system.assertEquals(subsQ.Zuora__Account__r.Renewal_Letter__c, GlobalVariableClass.REFERENCE_EMAIL);
        
         List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
         for(Zuora__SubscriptionProductCharge__c sp : spc){
             sp.Zuora__Subscription__c = subs[2].Id;
         }
         database.insert(spc);
         
         Document doc = new Document();
         doc.Name = 'SPH Logo v2';
         doc.FolderId = UserInfo.getUserId();
         database.insert(doc);
         
         Set<id> renewalSubsId = new Set<id>();
         renewalSubsId.add(subs[0].id);
         
         Set<id> renewallpr = new Set<id>();
         renewallpr.add(lprList[1].id);
         
         test.startTest();
             //SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch();
             //database.executeBatch(batch, 200);
             SP_SendEmailNotifForSubsRenewalsBatch batch2 = new SP_SendEmailNotifForSubsRenewalsBatch(renewallpr, firstNotifDate);
             database.executeBatch(batch2, 200);
             
            // Database.BatchableContext BC;
            // batch2.execute(BC, letterPrintReqList);
         test.stopTest();
     }
     
     
     
     //veloso
     static testMethod void testSP_SendEmailNotifForSubsRenewalsBatchRecent(){
         Integer counter=0;
     
         List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'), 
            new Other__c(Name='SPH Logo v2', Value__c='SPH Logo v2')
        };
        database.insert(otherList);
        
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.Renewal_Letter__c = 'Email';
         database.insert(acc);
         
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Street_Name__c = 'test';
         postal.Building_Name__c = 'build';
         database.insert(postal);
         
         Country__c country = TestDataFactory.createCountry(1)[0];
         country.Country_Name__c = 'Singapore';
         database.insert(country);
         
         SPH_Section__c section = new SPH_Section__c();
         section.Section_Name__c = 'name';
         database.insert(section);
         
         SPH_Department__c dept = new SPH_Department__c();
         dept.Department_Name__c = 'name';
         database.insert(dept);
         
         SPH_Division__c div = new SPH_Division__c();
         div.Name = 'Name';
         database.insert(div);
         
         SPH_Company__c com = new SPH_Company__c();
         com.Company_Name__c = 'name';
         database.insert(com);
         
         SPH_Location__c loc = new SPH_Location__c();
         loc.Location_Name__c = 'name';
         database.insert(loc);
         
         City__c city = new City__c();
         city.City_Name__c = 'name';
         city.Flight_Number_1__c = '123';
         city.Flight_Number_2__c = '432';
         database.insert(city);
         
         Packing_Grp__c packCode = new Packing_Grp__c();
         packCode.Airline__c = 'airline';
         database.insert(packCode);
         
         counter=0;
         List<Address__c> ad = TestDataFactory.createAddress(4);
         for(Address__c a: ad){
             if(counter==0){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Local'].Id;
             }
             else if(counter==1){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Overseas'].Id;
             }
             else if(counter==2){
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Internal'].Id;
             }
             else{
                 a.RecordTypeId = [SELECT Id, recordType.developerName FROM RecordType WHERE SObjectType='Address__c' AND recordType.developerName = 'Airline'].Id;
             }
             a.Block_House_Number__c = '01';
             a.Level_Number__c = '01';
             a.Unit_Number__c = '01';
             a.Postal_Code__c = postal.Id;
             a.Country__c = country.Id;
             a.Address_1__c = 'ass';
             a.Address_2__c = 'ss';
             a.Address_3__c = 'ss';
             a.Address_4__c = 'ss';
             a.Section_Code__c = section.Id;
             a.Department__c = dept.Id;
             a.Division_Code__c = div.Id;
             a.Company_Code__c = com.Id;
             a.Location_Code__c = loc.Id;
             a.City__c = city.Id;
             //a.Airline_Number__c = '123';
             //a.Flight_Number_1__c = '345';
            //a.Flight_Number_2__c = '564';
             a.Packing_Code__c = packCode.Id;
             counter++;
         }
         database.insert(ad);
         
         counter=0;
         List<Contact> con = TestDataFactory.createContactRecType(4, 'Customer Contact');
         for(Contact c: con){
             if(counter==0){
                 c.Address__c = ad[0].Id;
             }
             else if(counter==1){
                 c.Address__c = ad[1].Id;
             }
             else if(counter==2){
                 c.Address__c = ad[2].Id;
             }
             else{
                 c.Address__c = ad[3].Id;
             }
             c.Email__c = 'sample@ab.c';
             c.Email_Secondary__c = 'samplEmail@ab.com';
             counter++;
         }
         database.insert(con);
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Zuora__Account__c = acc.Id;
         database.insert(billAcc);
         
         Package__c pack = TestDataFactory.createPackage(1)[0];
         database.insert(pack);
         
         
         List<zqu__ZProduct__c> zp = TestDataFactory.createZProduct(2);
         zp[0].ProductSubType__c = 'Magazine';
         zp[0].RenewalPkgCodeMag1YrBase__c = pack.id;
         zp[0].RenewalPkgCodeMag1YrDisc__c = pack.id;
         zp[0].RenewalPkgCodeMag2YrBase__c = pack.id;
         zp[0].RenewalPkgCodeMag2YrDisc__c = pack.id;
         zp[0].RenewalPkgCodeNewspaper__c = pack.id;
         
         zp[1].ProductSubType__c = 'Newspaper';
         zp[1].RenewalPkgCodeMag1YrBase__c = pack.id;
         zp[1].RenewalPkgCodeMag1YrDisc__c = pack.id;
         zp[1].RenewalPkgCodeMag2YrBase__c = pack.id;
         zp[1].RenewalPkgCodeMag2YrDisc__c = pack.id;
         zp[1].RenewalPkgCodeNewspaper__c = pack.id;
         database.insert(zp);
         
         List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
         prp[0].zqu__ZProduct__c = zp[0].Id;
         prp[1].zqu__ZProduct__c = zp[1].Id;
         database.insert(prp);
         
         List<Package_Item__c> packItem = TestDataFactory.createPackageItem(2,'Base Product');
         packItem[0].Product_Rate_Plan__c = prp[0].Id;
         packItem[0].Package__c = pack.Id;
        /* START D-4413 Gdelrosario
        packItem[0].RenewalPkgCodeMag1YrBase__c = pack.id;
         packItem[0].RenewalPkgCodeMag1YrDisc__c = pack.id;
         packItem[0].RenewalPkgCodeMag2YrBase__c  = pack.id;
         packItem[0].RenewalPkgCodeMag2YrDisc__c = pack.id;
         packItem[0].RenewalPkgCodeNewspaper__c  = pack.id;
         */
         
         packItem[1].Product_Rate_Plan__c = prp[1].Id;
         packItem[1].Package__c = pack.Id;
        /* packItem[1].RenewalPkgCodeMag1YrBase__c = pack.id;
         packItem[1].RenewalPkgCodeMag1YrDisc__c = pack.id;
         packItem[1].RenewalPkgCodeMag2YrBase__c  = pack.id;       
         packItem[1].RenewalPkgCodeMag2YrDisc__c = pack.id;
         packItem[1].RenewalPkgCodeNewspaper__c  = pack.id;
         END D-4413 Gdelrosario*/
         database.insert(packItem);
         
         counter=0;
         List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
         for(Zuora__Subscription__c sub: subs){
             sub.is1stNotifEmailSent__c = false;
             sub.Zuora__SubscriptionEndDate__c = System.Today().addDays(42);
             sub.Zuora__TermSettingType__c = 'TERMED';
             sub.Zuora__AutoRenew__c = false;
             sub.Zuora__Status__c = 'Active';
             sub.Subscription_Type__c = 'Publication';
             sub.Zuora__Account__c = acc.Id;
             sub.Zuora__CustomerAccount__c = billAcc.Id;
             //sub.Order_Line_Item_Number_1__c = orderline.Id;
             //sub.Subscription_Type__c = 'Delivery';
             sub.Product_Code__c = '1';
             sub.Term_Length__c = 0.0;
             sub.Term_Length1__c = '0.0';
             sub.Zuora__SubscriptionStartDate__c = System.Today().addDays(42);
             sub.Main_Package__c = pack.Id;
             sub.Subscriber_Contact__c = con[0].Id;
             //sub.Main_Package_Product_Sub_Type_Mapping__c = 'Magazine';
             if(/*counter==0 || */counter==1){
               sub.Subscription_Type__c = 'Delivery';  
             }
             else if(counter==2){
                 sub.Contact__c = con[0].Id;
             }
             else if(counter==3){
                 sub.Contact__c = con[1].Id;
             }
             else if(counter==4){
                 sub.Contact__c = con[2].Id;
             }
             else if(counter==5){
                 sub.Contact__c = con[3].Id;
             }
             counter++;
         }
          test.startTest();
         database.insert(subs);
         
         Order__c ord = TestDataFactory.createOrder(1)[0];
         ord.Account__c  = acc.Id;
         ord.Base_Subscription__c = subs[0].id;
         database.insert(ord);
         
         Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
         ordLine.Order__c = ord.Id;
         ordLine.Main_Package_ID__c = pack.Id;
         ordLine.Main_Package_Product_Sub_Type__c = 'Magazine';
         ordLine.Start_Date__c = System.Today().addDays(43);
         database.insert(ordLine);
         
         system.assertEquals(subs[0].Zuora__SubscriptionEndDate__c, System.Today().addDays(42));
         
         Zuora__Subscription__c subsQ = [SELECT id, Zuora__Account__r.Renewal_Letter__c, Zuora__Account__r.RecordType.Id, Subscription_Type_1__c, Zuora__Status__c, Zuora__SubscriptionEndDate__c, is1stNotifEmailSent__c, Zuora__AutoRenew__c FROM Zuora__Subscription__c WHERE id=:subs[0].Id];
         
         //date firstNotifDate = subsQ.Zuora__SubscriptionEndDate__c-42;
         //date firstNotifDate = date.newInstance(subsQ.Zuora__SubscriptionEndDate__c.year(), subsQ.Zuora__SubscriptionEndDate__c.month(), subsQ.Zuora__SubscriptionEndDate__c.day()-42);
         date firstNotifDate1 = subsQ.Zuora__SubscriptionEndDate__c; //.addDays(42);
         date firstNotifDate = date.newInstance(firstNotifDate1.year(),firstNotifDate1.month(),firstNotifDate1.day()-42);
         //system.assertEquals(firstNotifDate, firstNotifDate1);
         system.assertEquals(subsQ.is1stNotifEmailSent__c, false);
         system.assertEquals(subsQ.Zuora__AutoRenew__c, false);
         system.assertEquals(subsQ.Zuora__Status__c, 'Active');
         system.assertEquals(subsQ.Subscription_Type_1__c, 'Publication');
         system.assertEquals(subsQ.Zuora__Account__r.RecordType.Id, ConstantsSLB.getKeyId('Account_Direct Corporate'));
         system.assertEquals(subsQ.Zuora__Account__r.Renewal_Letter__c, GlobalVariableClass.REFERENCE_EMAIL);
        
         List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
         for(Zuora__SubscriptionProductCharge__c sp : spc){
             sp.Zuora__Subscription__c = subs[2].Id;
         }
         database.insert(spc);
      
         
         Set<id> renewalSubsId = new Set<id>();
         renewalSubsId.add(subs[0].id);
         
        
            
             SP_SendEmailNotifForSubsRenewalsBatch batch2 = new SP_SendEmailNotifForSubsRenewalsBatch(renewalSubsId, firstNotifDate);
             database.executeBatch(batch2, 200);
             
         test.stopTest();
    }

    static User createUser() {
        UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
                       EmailEncodingKey='UTF-8', LastName='Testing123', 
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                       ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
                       UserName='testDeploymentUser@sph.com', Title='Testing123');
        insert usr;

        return usr;
    }


    static testMethod void testUpdateRenewalFieldsInSubscription() {
        User usr = createUser();

        System.runAs(usr) {
            Test.startTest();

            SP_SendEmailNotifForSubsRenewalsBatch emailBatch = new SP_SendEmailNotifForSubsRenewalsBatch();
            Zuora__Subscription__c zuora = emailBatch.updateRenewalFieldsInSubscription(new Zuora__Subscription__c(), true, 'First_Renewal_Reminder_for_Magazine');
            System.assertNotEquals(null, zuora);

            SP_SendEmailNotifForSubsRenewalsBatch emailBatch2 = new SP_SendEmailNotifForSubsRenewalsBatch();
            Zuora__Subscription__c zuora2 = emailBatch2.updateRenewalFieldsInSubscription(new Zuora__Subscription__c(), true, 'Second_Renewal_Reminder_for_Magazine');
            System.assertNotEquals(null, zuora2);

            Test.stopTest();
        }
    }

    static testMethod void testGetParsedEmail() {
        User usr = createUser();

        System.runAs(usr) {
            setUpTestData();

            Map<id, Contact> recipientContactMap = new Map<id, Contact>();
            recipientContactMap.put(cntctList[0].Id, cntctList[0]);

            Set<Id> orderSet = new Set<Id>();
            orderSet.add(ordLineItem.Id);

            Map<Id, Set<Id>> recipientOrderLineItemListMap = new Map<Id, Set<Id>>();
            recipientOrderLineItemListMap.put(cntctList[0].Id, orderSet);

            List<Zuora__Subscription__c> zSubsList = new List<Zuora__Subscription__c>();
            zSubsList.add(zuoraSubscription);

            Map<Id,List<Zuora__Subscription__c>> orderLineIdSubListMap = new Map<Id,List<Zuora__Subscription__c>>();
            orderLineIdSubListMap.put(ordLineItem.Id, zSubsList);

            SP_RenewalReminderHelper.RenewalRate renewal = new SP_RenewalReminderHelper.RenewalRate();
            renewal.renewalBaseRate1 = 1.1;
            renewal.renewalBaseRate2 = 1.1;
            renewal.renewalDiscRate1 = 1.1;
            renewal.renewalDiscRate2 = 1.1;
            renewal.renewalNewspaperRate = 1.1;

            SP_RenewalReminderHelper.DeliveryPostageFee delivery = new SP_RenewalReminderHelper.DeliveryPostageFee();
            delivery.deliveryFee = 1.1;
            delivery.postageFee = 1.2;

            Map<Id, SP_RenewalReminderHelper.DeliveryPostageFee> recipientIdDelPostChargeMap = new Map<Id, SP_RenewalReminderHelper.DeliveryPostageFee>();
            recipientIdDelPostChargeMap.put(cntctList[0].Id, delivery);

            Map<Id, SP_RenewalReminderHelper.RenewalRate> orderLineItemRenewalRateMap = new Map<Id, SP_RenewalReminderHelper.RenewalRate>();
            orderLineItemRenewalRateMap.put(ordLineItem.Id, renewal);

            Map<String, zqu__ZProduct__c> productMap = new Map<String, zqu__ZProduct__c>();
            productMap.put('test', zProducts);

            Map<id, Package__c> packageMap = new Map<id, Package__c>();
            packageMap.put(packge.Id, packge);

            Renewal_Notifications__c renNotifcations = new Renewal_Notifications__c();
            renNotifcations.Name = 'Renewal Notifications Values';
            renNotifcations.X1st_Expiry_Notification_Date__c = 42;

            insert renNotifcations;

            Zuora__CustomerAccount__c billingAccount = [SELECT Zuora__Account__c, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c,
                                                               Billing_Contact__c, Billing_Contact__r.Email, Billing_Contact__r.Company_Name__c,
                                                               Billing_Contact__r.HomePhone__c, Billing_Contact__r.Office_Number__c,
                                                               Billing_Contact__r.Name, Billing_Contact__r.Mobile_Number__c,
                                                               Billing_Contact__r.Email_Secondary__c, Billing_Contact__r.Address__r.RecordTypeId,
                                                               Billing_Contact__r.Address__c, Billing_Contact__r.Address__r.Block_House_Number__c,
                                                               Billing_Contact__r.Address__r.Street_Name__c,
                                                               Billing_Contact__r.Address__r.Level_Number__c,
                                                               Billing_Contact__r.Address__r.Unit_Number__c,
                                                               Billing_Contact__r.Address__r.Building_Name__c,
                                                               Billing_Contact__r.Address__r.Country__r.Country_Name__c,
                                                               Billing_Contact__r.Address__r.Postal_Code__r.Name,
                                                               Billing_Contact__r.Address__r.Address_1__c,
                                                               Billing_Contact__r.Address__r.Address_2__c,
                                                               Billing_Contact__r.Address__r.Address_3__c,
                                                               Billing_Contact__r.Address__r.Address_4__c
                                                        FROM Zuora__CustomerAccount__c 
                                                        WHERE Id=:custAccount.Id LIMIT 1];
            Test.startTest();

            SP_SendEmailNotifForSubsRenewalsBatch emailBatch = new SP_SendEmailNotifForSubsRenewalsBatch();
            Messaging.SingleEmailMessage email = emailBatch.getParsedEmail(validEmailTemplate, 'Magazine', Date.today(), billingAccount,
                                                                recipientContactMap, recipientOrderLineItemListMap, orderLineIdSubListMap,
                                                                recipientIdDelPostChargeMap, 'sphLogo', orderLineItemRenewalRateMap, 
                                                                productMap, packageMap, 'First_Renewal_Reminder_for_Magazine');

            System.assertNotEquals(null, email);

            SP_SendEmailNotifForSubsRenewalsBatch emailBatch2 = new SP_SendEmailNotifForSubsRenewalsBatch();
            Messaging.SingleEmailMessage email2 = emailBatch2.getParsedEmail(validEmailTemplate, 'Newspaper', Date.today(), billingAccount,
                                                                recipientContactMap, recipientOrderLineItemListMap, orderLineIdSubListMap,
                                                                recipientIdDelPostChargeMap, 'sphLogo', orderLineItemRenewalRateMap, 
                                                                productMap, packageMap, 'First_Renewal_Reminder_for_Magazine');

            System.assertNotEquals(null, email2);

            zuoraSubscription.Delivered_By__c = 'Mailing Agent';

            update zuoraSubscription;

            SP_SendEmailNotifForSubsRenewalsBatch emailBatch3 = new SP_SendEmailNotifForSubsRenewalsBatch();
            Messaging.SingleEmailMessage email3 = emailBatch3.getParsedEmail(validEmailTemplate, 'Newspaper', Date.today(), billingAccount,
                                                                recipientContactMap, recipientOrderLineItemListMap, orderLineIdSubListMap,
                                                                recipientIdDelPostChargeMap, 'sphLogo', orderLineItemRenewalRateMap, 
                                                                productMap, packageMap, 'First_Renewal_Reminder_for_Magazine');

            System.assertNotEquals(null, email3);

            validEmailTemplate.HtmlValue = '<html> <table width="100%"> <tr> <td width=68% align=left> <div style = "font-family:Arial; font-size: 9pt;"> {{notifRenewal}}<br> <br> {{Contact.FirstName}} {{Contact.LastName}}<br> </div> </html>';

            update validEmailTemplate;

            SP_SendEmailNotifForSubsRenewalsBatch emailBatch4 = new SP_SendEmailNotifForSubsRenewalsBatch();
            Messaging.SingleEmailMessage email4 = emailBatch4.getParsedEmail(validEmailTemplate, 'Newspaper', Date.today(), billingAccount,
                                                                recipientContactMap, recipientOrderLineItemListMap, orderLineIdSubListMap,
                                                                recipientIdDelPostChargeMap, 'sphLogo', orderLineItemRenewalRateMap, 
                                                                productMap, packageMap, 'First_Renewal_Reminder_for_Magazine');

            System.assertNotEquals(null, email4);


            SP_SendEmailNotifForSubsRenewalsBatch emailBatch5 = new SP_SendEmailNotifForSubsRenewalsBatch();
            Messaging.SingleEmailMessage email5 = emailBatch5.getParsedEmail(validEmailTemplate, 'Newspaper', Date.today(), billingAccount,
                                                                recipientContactMap, recipientOrderLineItemListMap, orderLineIdSubListMap,
                                                                recipientIdDelPostChargeMap, 'sphLogo', orderLineItemRenewalRateMap, 
                                                                productMap, packageMap, 'Second_Renewal_Reminder_for_Magazine');

            System.assertNotEquals(null, email5);

            Test.stopTest();
        }
    }    

    static testMethod void testBatchExecution() {
        User usr = createUser();

        System.runAs(usr) {
            setUpTestData();

            Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
            letterPrintRequest.Billing_Account__c = custAccount.Id;
            letterPrintRequest.Type__c = 'Master';
            letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            letterPrintRequest.Status_Email__c = 'Tagged';
            //letterPrintRequest.Record_Id__c = 'Email';
            letterPrintRequest.Record_Id__c = String.ValueOf(zuoraSubscription.Id);
            letterPrintRequest.Language_Medium__c = 'E';
            insert letterPrintRequest;
             
            Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
            letterPrintRequest2.Billing_Account__c = custAccount.Id;
            letterPrintRequest2.Type__c = 'Master';
            letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            letterPrintRequest2.Status_Email__c = 'Tagged';
            letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
            //letterPrintRequest2.Record_Id__c = 'Email';
            letterPrintRequest2.Record_Id__c = String.ValueOf(zuoraSubscription.Id);
            insert letterPrintRequest2;
             
            letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
            update letterPrintRequest;

            List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
            lprList.add(letterPrintRequest2);
            lprList.add(letterPrintRequest);

            Set<id> renewallpr = new Set<id>();
            renewallpr.add(lprList[1].id);

            test.startTest();
                SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch(renewallpr, zuoraSubscription.Zuora__SubscriptionEndDate__c);
                database.executeBatch(batch, 10);
            test.stopTest();
        }
    }

    static testMethod void testBatchExecution2() {
        User usr = createUser();

        System.runAs(usr) {
            setUpTestData();
            
            cntctList[1].Email = null;
            update cntctList;

            Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
            letterPrintRequest.Billing_Account__c = custAccount.Id;
            letterPrintRequest.Type__c = 'Master';
            letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            letterPrintRequest.Status_Email__c = 'Tagged';
            //letterPrintRequest.Record_Id__c = 'Email';
            letterPrintRequest.Record_Id__c = String.ValueOf(zuoraSubscription.Id);
            letterPrintRequest.Language_Medium__c = 'C';
            insert letterPrintRequest;
             
            Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
            letterPrintRequest2.Billing_Account__c = custAccount.Id;
            letterPrintRequest2.Type__c = 'Master';
            letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            letterPrintRequest2.Status_Email__c = 'Tagged';
            letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
            //letterPrintRequest2.Record_Id__c = 'Email';
            letterPrintRequest2.Record_Id__c = String.ValueOf(zuoraSubscription.Id);
            insert letterPrintRequest2;
             
            letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
            update letterPrintRequest;

            List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
            lprList.add(letterPrintRequest2);
            lprList.add(letterPrintRequest);

            Set<id> renewallpr = new Set<id>();
            renewallpr.add(lprList[1].id);

            test.startTest();
                SP_SendEmailNotifForSubsRenewalsBatch batch = new SP_SendEmailNotifForSubsRenewalsBatch(renewallpr, zuoraSubscription.Zuora__SubscriptionEndDate__c);
                database.executeBatch(batch, 10);
            test.stopTest();
        }
    }
}