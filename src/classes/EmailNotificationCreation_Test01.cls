/**
 * Class Name: <EmailNotificationCreation_Test01>
 * Requirement/Project Name: <SPH>
 * @description: This is the test class for EmailNotificationCreation
 */

@isTest(seeAllData = true)
private class EmailNotificationCreation_Test01 {
    
    //global variables
    static Singpost_Address__c postal = null;
    static Account acc = null;
    static Promotion__c promo = null;
    static Package__c pack = null;
    static Promotion_Package__c promopack = null;
    static Zuora__CustomerAccount__c billAcc = null;
    static Address__c addressRec = null;
    static List<Contact> con = null;
    static Contact con1 = null;
    static Order__c order = null;
    static Zuora__Subscription__c subRecord = null;
    static List<Zuora__SubscriptionProductCharge__c> subProductCharge = null;
    static Zuora__Subscription__c myZub = null;
    static Case cas = null;
    static List<Case_Subscription__c> casSubs = null;
    static List <Publication__c> pubList = null;
    static Publication__c pub = null;
    static Publication__c npub = null;
    static Map<String, sObject> sObjectMap;
    //static Subscription_Vendor__c subVendor;
    
    //test01_GetDetails
    static testmethod void test01(){
        setAllData();
            
        try{
            Test.startTest();
               
               User u = new User(
                    Alias = 'stndrd',
                    isActive = true,
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    //ContactID = con.id,
                    ProfileId = [SELECT id from Profile Where Name ='System Administrator'].id,
                  
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
            
                    //database.insert(u);
                    System.runAs(u){
                                            
                        Map<String, List<Contact>> contactMapList = new Map<String, List<Contact>>();
                        contactMapList.put(con[0].AccountId, con);
                        //Arvin 4/14/2015 Class static variable cannot be accessed by below instance. 
                        //create.vendorIdVendorStaffListMap = contactMapList;
                        EmailNotificationCreation.vendorIdVendorStaffListMap = contactMapList;
                        
                        Set<String> pubCodeString = new Set<String>();
                        pubCodeString.add(subProductCharge[0].PublicationCode__c);
                        String numberOfCopies = '1111101';
                                                
                        Subscription_Vendor__c subVendor = (Subscription_Vendor__c) sObjectMap.get('Subscription_Vendor__c');
                        subVendor.Recipient__c = con[0].Id;
                        database.update(subVendor);
                        
                        Case_Vendor_Subscription__c caseVendorSubs = new Case_Vendor_Subscription__c();
                        caseVendorSubs.Account__c = acc.Id;
                        caseVendorSubs.Address__c = addressRec.Id;
                        caseVendorSubs.Case__c = cas.Id;
                        caseVendorSubs.Subscription_Vendor__c = subVendor.Id;
                        insert caseVendorSubs;
                        
                        Subscription_Vendor_Publication__c svp = new Subscription_Vendor_Publication__c();
                        svp.Account__c = acc.Id;
                        svp.Mon__c = 1;
                        svp.Tue__c = 1;
                        svp.Wed__c = 1;
                        svp.Thu__c = 1;
                        svp.Fri__c = 1;
                        svp.Sat__c = 1;
                        svp.Sun__c = 1;
                        svp.PHd__c = 1;
                        svp.PHe__c = 1;
                        svp.Order__c = order.Id;
                        svp.Publication__c = pub.Id;
                        svp.Subscription_Vendor__c = subVendor.id;
                        Database.insert(svp);
                        
                        List<Subscription_Vendor_Publication__c> svpList = new List<Subscription_Vendor_Publication__c>();
                        svpList.add(svp);
                        
                        Set<Id> pubIdSet = new Set<Id>();
                        pubIdSet.add(pub.Id);
                        Map<ID, string> mapEmail = new Map<ID, string>();
                        mapEmail.put(acc.id, 'test');
                        //  List<Contact> cont = new List<Contact>();
                        // cont.add(con);
                        String output1 = 'test';
                        Set<id> newSet = new Set<id>();
                        newSet.add(cas.id);
                        
                        String binaryFreq = 'YYYYYYY';
                        String numOfCopies = '1111101';
                        
                         EmailNotificationCreation createemail = new EmailNotificationCreation();              
                        //EmailNotificationCreation.createEmail(cas);
                        EmailNotificationCreation.getSubVenCopies(svpList, 1);
                        EmailNotificationCreation.getDetails(newSet);
                        EmailNotificationCreation.groupPubPerSub(subRecord.Id,pubCodeString, 'Default', numberOfCopies, true);   
                        EmailNotificationCreation.getFrequency(binaryFreq ,numOfCopies);
                        EmailNotificationCreation.getPublications(pubIdSet);
                        //EmailNotificationCreation.createEmail(newSet);                   
                        EmailNotificationCreation.createTask(cas,con,output1);     
                        EmailNotificationCreation.convertDateToString(date.today());
                        //EmailNotificationCreation.CreateEmailNotFuture(newSet);
                        //EmailNotificationCreation.composeEmail(cas, subRecord.id, mapEmail);
                        
                        System.assertNotEquals(null, contactMapList);
                   }             
            Test.stopTest();
        }
        catch(Zuora.zRemoteException e){} 
    }
    
    
    static testmethod void test01a(){
        setAllData();
            
        try{
            Test.startTest();
               
               User u = new User(
                    Alias = 'stndrd',
                    isActive = true,
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    //ContactID = con.id,
                    ProfileId = [SELECT id from Profile Where Name ='System Administrator'].id,
                  
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
            
                    //database.insert(u);
                    System.runAs(u){
                                            
                        Map<String, List<Contact>> contactMapList = new Map<String, List<Contact>>();
                        contactMapList.put(con[0].AccountId, con);
                        //Arvin 4/14/2015 Class static variable cannot be accessed by below instance. 
                        //create.vendorIdVendorStaffListMap = contactMapList;
                        EmailNotificationCreation.vendorIdVendorStaffListMap = contactMapList;
                        
                        Set<String> pubCodeString = new Set<String>();
                        pubCodeString.add(subProductCharge[0].PublicationCode__c);
                        String numberOfCopies = 'One';
                                                
                        Subscription_Vendor__c subVendor = (Subscription_Vendor__c) sObjectMap.get('Subscription_Vendor__c');
                        subVendor.Recipient__c = con[0].Id;
                        database.update(subVendor);
                        
                        Case_Vendor_Subscription__c caseVendorSubs = new Case_Vendor_Subscription__c();
                        caseVendorSubs.Account__c = acc.Id;
                        caseVendorSubs.Address__c = addressRec.Id;
                        caseVendorSubs.Case__c = cas.Id;
                        caseVendorSubs.Subscription_Vendor__c = subVendor.Id;
                        insert caseVendorSubs;
                        
                        Subscription_Vendor_Publication__c svp = new Subscription_Vendor_Publication__c();
                        svp.Account__c = acc.Id;
                        svp.Mon__c = 1;
                        svp.Tue__c = 1;
                        svp.Wed__c = 1;
                        svp.Thu__c = 1;
                        svp.Fri__c = 1;
                        svp.Sat__c = 1;
                        svp.Sun__c = 1;
                        svp.PHd__c = 1;
                        svp.PHe__c = 1;
                        svp.Order__c = order.Id;
                        svp.Publication__c = pub.Id;
                        svp.Subscription_Vendor__c = subVendor.id;
                        Database.insert(svp);
                        
                        List<Subscription_Vendor_Publication__c> svpList = new List<Subscription_Vendor_Publication__c>();
                        svpList.add(svp);
                        
                        Set<Id> pubIdSet = new Set<Id>();
                        pubIdSet.add(pub.Id);
                        Map<ID, string> mapEmail = new Map<ID, string>();
                        mapEmail.put(acc.id, 'test');
                        //  List<Contact> cont = new List<Contact>();
                        // cont.add(con);
                        String output1 = 'test';
                        Set<id> newSet = new Set<id>();
                        newSet.add(cas.id);
                        
                        String binaryFreq = 'YYYYYYN';
                        String numOfCopies = '1';
                        
                         EmailNotificationCreation createemail = new EmailNotificationCreation();              
                        //EmailNotificationCreation.createEmail(cas);
                        EmailNotificationCreation.getSubVenCopies(svpList, 1);
                        EmailNotificationCreation.getDetails(newSet);
                        EmailNotificationCreation.groupPubPerSub(subRecord.Id,pubCodeString, 'Mon - Sat', numberOfCopies, true);   
                        EmailNotificationCreation.getFrequency(binaryFreq ,numOfCopies);
                        EmailNotificationCreation.getPublications(pubIdSet);
                        //EmailNotificationCreation.createEmail(newSet);                   
                        EmailNotificationCreation.createTask(cas,con,output1);     
                        EmailNotificationCreation.convertDateToString(date.today());
                        //EmailNotificationCreation.CreateEmailNotFuture(newSet);
                        //EmailNotificationCreation.composeEmail(cas, subRecord.id, mapEmail);
                        
                        System.assertNotEquals(null, contactMapList);
                   }             
            Test.stopTest();
        }
        catch(Zuora.zRemoteException e){} 
    }
    
    //CreateEmail
    static testmethod void test02(){
                setAllData();
                
                Set<Id> caseIdSet = new Set<Id>();
                Case caseID =(Case) sObjectMap.get('Case');
                caseIdSet.add(caseID.Id);
                
                Subscription_Vendor__c subVendor = (Subscription_Vendor__c) sObjectMap.get('Subscription_Vendor__c');
                subVendor.Recipient__c = con[0].Id;
                update subVendor;
                
                Case_Vendor_Subscription__c caseVendorSubs = new Case_Vendor_Subscription__c();
                caseVendorSubs.Account__c = acc.Id;
                caseVendorSubs.Address__c = addressRec.Id;
                caseVendorSubs.Case__c = cas.Id;
                caseVendorSubs.Subscription_Vendor__c = subVendor.Id;
                insert caseVendorSubs;
                
        try{
                 EmailNotificationCreation.getSubVenFrequency();   
        }catch(Exception e){}   
        
        System.assertNotEquals(null, caseVendorSubs);
    }

    
       
     //testGetDetails
    static testmethod void test03(){
    
                setAllData();
                Set<Id> caseRec = new Set<Id>();
                Case caseID =(Case) sObjectMap.get('Case');
                caseRec.add(caseID.Id);
                
                Subscription_Vendor__c subVendor =(Subscription_Vendor__c) sObjectMap.get('Subscription_Vendor__c');
                
                System.assertNotEquals(null, subVendor);    
    }
   
    //get frequency and sms message method   
    static void setAllData(){
    
                sObjectMap = null;
                sObjectMap = new Map<String, sObject>(); 
            
                postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = '1234';
                database.insert(postal);
                
                recordtype rectype = [select id, name from recordtype where sObjecttype = 'Account' and Name = 'Direct Individual' LIMIT 1];
                //ConstantsSLB.getKeyId(GlobalVariableClass.CONTACT_VENDOR_STAFF);
                
                acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.RecordtypeID = rectype.id;
                acc.Name = 'TEST';
                acc.NRIC__c = 'T1234567R';
                acc.Handphone_Number__c = '09176202715';
                acc.Active__c = true;
                database.insert(acc);
                
                promo = new Promotion__c();
                promo.Name = 'promotor';
                promo.Promotion_Code__c = 'yasyd97';
                promo.Effective_Start_Date__c = date.today();
                promo.Effective_End_Date__c = date.today().addDays(1);
                promo.Contract__c = 'Yes';
                promo.Contract_Period__c = '2';
                database.insert(promo);
                
                pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BUNDLE; // Add On
                pack.Billing_Type__c = 'Full Prepaid';        
                pack.Effective_End_Date__c = date.today().addDays(31);
                pack.Effective_Start_Date__c = date.today();
                pack.Subscription_Period__c = '1';
                database.insert(pack);
                
                promopack = TestDataFactory.createPromotionPackage(1)[0];
                promopack.Promotion__c = promo.id;
                promopack.Package_Name__c = pack.id;
                database.insert(promopack);
                
                billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                billAcc.Billing_Type__c = 'Full Prepaid'; 
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other';   
                database.insert(billAcc);
                
                Recordtype rectype2 = [select id, name from recordtype where sObjecttype = 'address__c' and Name = 'Local' LIMIT 1];
                
                addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.recordtypeId = rectype2.id;
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c = '15';
                addressRec.Level_Number__c = '10';
                addressRec.Unit_Number__c = '50';
                database.insert(addressRec);
                
                //recordtype rectype = [Select Id, Name from Recordytpe where sObjecttype = 'Contact__c' and Name = ' Contact_Vendor Staff' LIMIT 1];
                
                
                con = TestDataFactory.createContact(2);
                con[0].recordtypeid = ConstantsSLB.getKeyId(GlobalVariableClass.CONTACT_VENDOR_STAFF);
                con[0].Address__c = addressRec.Id;
                con[0].AccountId = acc.Id;
                con[0].Account = acc;
                //con.RecordTypeId = rectype.id;
                con[0].Recipient_Indicator__c = true;
                con[0].Active__c = true;
                con[0].Email = 'test@test.com';
                con[0].homephone__c = '25354685';
                con[0].Vendor_Communication_Preference__c = 'Email';
                 con[0].Billing_Indicator__c = true;
                
                con[1].recordtypeid = ConstantsSLB.getKeyId(GlobalVariableClass.CONTACT_VENDOR_STAFF);
                con[1].Address__c = addressRec.Id;
                con[1].AccountId = acc.Id;
                con[1].Account = acc;
                //con.RecordTypeId = rectype.id;
                con[1].Recipient_Indicator__c = true;
                con[1].Active__c = true;
                con[1].Email = 'test@test.com';
                con[1].homephone__c = '25354685';
                con[1].Vendor_Communication_Preference__c = 'Email';
                 con[1].Billing_Indicator__c = true;
                database.insert(con);
               
               
                order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
                order.Category__c = 'Subscription Request';
                order.Eligible_for_Retention__c = TRUE;
                order.Informed_Customer__c = TRUE;
                order.Sub_Category__c ='Stop Subscription';
                order.Recipient_Contact__c = con[0].Id;
                //order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
                order.Order_Type__c = 'Renewal';
                order.Status__c = GlobalVariableClass.STATUS_DRAFT;
                order.Check_Amount__c = 100;
                order.Check_Issuing_Bank__c = 'BLANK';
                order.Check_No__c = 'SPACE';
                order.Check_Dated__c = date.today();
                order.Remarks_Check__c = 'TESTTESTTEST';     
                order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Account__c = billAcc.id;
                order.Billing_Type__c = billAcc.Billing_Type__c;    
                order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Billing_Contact__c= con[1].id;
                order.Vendor_Sms_Remarks__c = 'N/A';
                database.insert(order);
                
                subRecord = TestDataFactory.createSubscription(1)[0];
                subRecord.Zuora__Account__c = acc.Id;
                //subRecord.Order_Number__c = order.Id;
                //subRecord.Order_Number_1__c = order.id;
                subRecord.Subscriber_Contact__c = con[0].Id;
                subRecord.Recipient_Contact__c = con[0].Id;
                subRecord.Recipient_Contact_1__c = String.valueOf(con[0].id);
                subRecord.Main_Package_1__c = pack.id;
                subRecord.Zuora__Status__c = 'Active';
                subRecord.Suppress_Vendor_Start_Notice__c = 'false';
                subRecord.Supressed_Acknowledgement_Letter__c = 'false';
                subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecord.Urgent__c = 'false';
                subRecord.Vendor_Conversion__c = 'false';
                subRecord.Charity__c = 'false';
                subRecord.Billing_Type__c = 'Full Prepaid';
                subRecord.Bundled_With__c = 'TEST';
                //subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
                //subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
                subRecord.Subscription_Type__c = 'Publication';
                subRecord.Subscription_Type_1__c = 'Publication';
                subRecord.Zuora__SubscriptionStartDate__c = date.today();
                subRecord.Zuora__SubscriptionEndDate__c = null; //date.today().addDays(6);
                subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
                subRecord.Vendor__c = acc.id;
                subrecord.Vendor_1__c = acc.id;
                subRecord.Main_Package_1__c = pack.id;
                subRecord.Main_Package__c = pack.id;
                subRecord.Classification__c = 'A';
                subRecord.Zuora__CustomerAccount__c = billAcc.Id;
                subRecord.Frequency_1__c = 'Default';
                subrecord.Frequency__c = 'Default';
                database.insert(subRecord);
                        
                subProductCharge = TestDataFactory.createSubProductCharge(2);
                for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
                    spc.Name = 'Sub Product Charge Test';
                    
                    spc.Zuora__Subscription__c = subRecord.id;
                    spc.Zuora__RatePlanName__c = 'Sample Rate'; 
                    spc.Zuora__ProductSKU__c = 'Product SKU'; 
                    spc.PublicationCode__c = 'PUB1';
                    spc.Zuora__UOM__c = GlobalVariableClass.UOM_COPYWEEKDAY;
                }
                database.insert(subProductCharge);
                
                Subscription_Vendor__c subVendor = new Subscription_Vendor__c();
                    subVendor.Account__c = acc.Id;
                    subVendor.Order_Number__c = order.Id;
                     subVendor.Recipient__c = con[0].Id;
                database.insert(subVendor);
                sObjectMap.put('Subscription_Vendor__c',subVendor );
                
                myZub = [SELECT Zuora__Account__c
                                               FROM Zuora__Subscription__c 
                                               WHERE Id =: subRecord.id];
        
                cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = order.Id;
                cas.Account__c = acc.Id;
                cas.Sub_Category__c = 'Change of address';
                sObjectMap.put('Case',cas);
                database.insert(cas);
                
                casSubs = TestDataFactory.createCaseSubscription(1);
                for(Case_Subscription__c cs: casSubs) {
                    cs.Case__c = cas.id;
                    cs.Complaint_Copies__c = 5;     
                    cs.Subscription__c = subRecord.id;
                    cs.Account__c = acc.id;
                    cs.Address__c = addressRec.id;
                }
                database.insert(casSubs);
        
                pubList = new List <Publication__c>();
                pub = TestDataFactory.createPublication(1)[0];
                pub.Name = 'Test';
                pub.Publication_Code__c = 'PUB1';
                pub.Published_Days__c = 'YYYYNNY';
                pub.Publication_Type__c = 'M';
                pub.Publish_Pattern__c = 'Weekends';
                pubList.add(pub);
                
                npub = TestDataFactory.createPublication(1)[0];                                                     
                npub.Publication_Code__c = 'PUB1';
                npub.Published_Days__c = 'YYYYNNY';
                npub.Publication_Type__c = 'M';      
                pubList.add(npub);
                
                database.insert(pubList);     
                
                pubList[0].Sunday_Publication__c = pubList[1].id;
                pubList[1].Sunday_Publication__c = pubList[0].id;
                sObjectMap.put('Publication__c', pubList[0]);
                sObjectMap.put('Publication__c1', pubList[1]);
                database.update(pubList);
                
               /* zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
                zproduct.ProductPlatform__c = 'All-In-One';
                sObjectMap.put('zqu__ZProduct__c', zproduct );
                insert zproduct;
                
                zqu__ProductRatePlan__c prdrateplan = TestDataFactory.createProductRatePlan(1)[0];
              //  prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today();
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                sObjectMap.put('zqu__ProductRatePlan__c', prdrateplan);
                insert prdrateplan;
                
                Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
                packItem.Package__c = pack.id;
                packItem.Product_Rate_Plan__c = prdRatePlan.id;
                packItem.Name = 'Test Pack Item';
                //packItem.Is_All_In_One__c = true;
                sObjectMap.put('Package_Item__c', packItem );
                insert packItem;
    */
    }
    
  

}