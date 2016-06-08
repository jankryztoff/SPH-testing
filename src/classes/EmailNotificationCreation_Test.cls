/**
 * Class Name: <EmailNotificationCreation_Test>
 * @author: Thayne Recato Dy
 * Date: <2/16/2015>
 * Requirement/Project Name: <SPH>
 * @description: This is the test class for EmailNotificationCreation
 */

@isTest(seeAllData = true)
private class EmailNotificationCreation_Test {
    
    //global variables
    static Singpost_Address__c postal = null;
    static Account acc = null;
    static Promotion__c promo = null;
    static Package__c pack = null;
    static Promotion_Package__c promopack = null;
    static Zuora__CustomerAccount__c billAcc = null;
    static Address__c addressRec = null;
    static Contact con = null;
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
      //   defaultCustomSetting();
        setAllData();
            
        try{
            Test.startTest();
           
                List<Contact> contactList = new List<Contact>();
                contactList.add(con);
                contactList.add(con1);
                
                Map<String, List<Contact>> contactMapList = new Map<String, List<Contact>>();
                contactMapList.put(contactList[0].AccountId, contactList);
                //Arvin 4/14/2015 Class static variable cannot be accessed by below instance. 
                //create.vendorIdVendorStaffListMap = contactMapList;
                EmailNotificationCreation.vendorIdVendorStaffListMap = contactMapList;
                        
                Set<String> pubCodeString = new Set<String>();
                pubCodeString.add(subProductCharge[0].PublicationCode__c);
                String numberOfCopies = 'One';
                
                //EmailNotificationCreation.createEmail(cas);
                //create.createEmail(cas);
                
                EmailNotificationCreation.groupPubPerSub(subRecord.Id,pubCodeString, 'Rare', numberOfCopies, true);        
                EmailNotificationCreation.convertDateToString(date.today());
                
                //create.groupPubPerSub(pubCodeString, subRecord);        
                //create.convertDateToString(date.today());
                String binaryFreq;
                Decimal numOfCopies;
                //EmailNotificationCreation.getFrequency(subRecord,pubCodeString);
                
                System.assertNotEquals(null, contactMapList);
                    
            Test.stopTest();
        }
        catch(Zuora.zRemoteException e){} 
    }
    
    
    //CreateEmail
    static testmethod void test02(){
    //    defaultCustomSetting();
        setAllData();
        
        Set<Id> caseIdSet = new Set<Id>();
        Case caseID =(Case) sObjectMap.get('Case');
        caseIdSet.add(caseID.Id);
            
        Subscription_Vendor__c subVendor = (Subscription_Vendor__c) sObjectMap.get('Subscription_Vendor__c');
        subVendor.Recipient__c = con.Id;
        update subVendor;
        
        Case_Vendor_Subscription__c caseVendorSubs = new Case_Vendor_Subscription__c();
            caseVendorSubs.Account__c = acc.Id;
            caseVendorSubs.Address__c = addressRec.Id;
            caseVendorSubs.Case__c = cas.Id;
            caseVendorSubs.Subscription_Vendor__c = subVendor.Id;
        insert caseVendorSubs;
            
        try{
            //EmailNotificationCreation.createEmail(caseIdSet);
            EmailNotificationCreation.getSubVenFrequency();   
        }catch(Exception e){}   
        
        System.assertNotEquals(null, caseVendorSubs);
    }

    //CreateEmailNotFuture
    /*
    static testmethod void test03(){
      //  defaultCustomSetting();
        try { 
                setAllData2();
                
                Set<Id> caseIdSet = new Set<Id>();
                Case caseID =(Case) sObjectMap.get('Case');
                caseIdSet.add(caseID.Id);
                
                Subscription_Vendor__c sv = new Subscription_Vendor__c();
                     sv.Account__c = acc.id;
                     sv.Recipient__c = con.id;
                 //Database.insert(sv);
                 
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
                     svp.Subscription_Vendor__c = sv.id;
                 Database.insert(svp);
           
                
                 
                    Test.startTest();
                      //EmailNotificationCreation.createEmail(caseIdSet);
                        //EmailNotificationCreation.createEmailNotFuture(caseIdSet);   
                        EmailNotificationCreation.getSubVenFrequency();
                        EmailNotificationCreation.getFrequency('1111111','1');
                        System.assertNotEquals(null, caseIdSet);
                      
                    Test.stopTest();
            }        
           catch(Zuora.zRemoteException e) {}       
     }
     */
     //jurna
     //CreateEmailNotFuture
     /*
    static testmethod void test03b(){
     //   defaultCustomSetting();
        setAllData2();
        
        Set<Id> caseIdSet = new Set<Id>();
        Case caseID =(Case) sObjectMap.get('Case');
        caseIdSet.add(caseID.Id);
        
        Subscription_Vendor__c sv = new Subscription_Vendor__c();
             sv.Account__c = acc.id;
             sv.Recipient__c = con.id;
         //Database.insert(sv);
         
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
             svp.Subscription_Vendor__c = sv.id;
         Database.insert(svp);
         
         Set<Id> subVenIdSet = new Set<Id>();
         subVenIdSet.add(svp.id);
         
          Set<String> pubCodeString = new Set<String>();
                pubCodeString.add(subProductCharge[0].PublicationCode__c);
                String numberOfCopies = 'One';
   
        Test.startTest();
        
            try{
                //EmailNotificationCreation.createEmail(caseIdSet);
                EmailNotificationCreation.createEmailNotFuture(caseIdSet);   
                EmailNotificationCreation.getSubVenFrequency();
                EmailNotificationCreation.getFrequency('1111111','1');
            }catch(Exception e){}
            try{
            EmailNotificationCreation.createEmailNotFuture(caseIdSet);   
                EmailNotificationCreation.getSubVenFrequency();
                EmailNotificationCreation.getFrequency('1111111','1');
               }catch(Exception e){}
               EmailNotificationCreation.getSubVenPublication(subVenIdSet );
               EmailNotificationCreation.groupPubPerSub(subRecord.Id,pubCodeString, 'Rare', numberOfCopies, false); 
               //EmailNotificationCreation.CalloutSMSResponse();
        
        System.assertNotEquals(null, caseIdSet);
        
        Test.stopTest();
     }
     */
     
    //GetSubVenCopies
     static testmethod void test04(){
      //    defaultCustomSetting();   
         setAllData();
         
         Subscription_Vendor__c sv = new Subscription_Vendor__c();
             sv.Account__c = acc.id;
             sv.Recipient__c = con.id;
         //Database.insert(sv);
         
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
             svp.Subscription_Vendor__c = sv.id;
         Database.insert(svp);
         
        List<Subscription_Vendor_Publication__c> svpList = new List<Subscription_Vendor_Publication__c>();
            svpList.add(svp);
            
        EmailNotificationCreation.getSubVenCopies(svpList, 1);
         
        Set<Id> pubIdSet = new Set<Id>();
            pubIdSet.add(pub.Id);
        EmailNotificationCreation.getPublications(pubIdSet);
         
        System.assertNotEquals(null, pubIdSet);
    }
     
     //testGetDetails
    static testmethod void test05(){
     //   defaultCustomSetting();
        setAllData();
        Set<Id> caseRec = new Set<Id>();
        Case caseID =(Case) sObjectMap.get('Case');
        caseRec.add(caseID.Id);
        
        Subscription_Vendor__c subVendor =(Subscription_Vendor__c) sObjectMap.get('Subscription_Vendor__c');
        
        System.assertNotEquals(null, subVendor);    
    }
   
    //get frequency and sms message method   
    /*
    static testmethod void test06(){
     //   defaultCustomSetting();
        
        setAllData2();
        string numberOfCopies = '1';
        Set<String> pubCodeSet = new Set<String>();
        pubCodeSet.add(subProductCharge[0].PublicationCode__c);
        test.startTest(); //jurna-10-22-15
        EmailNotificationCreation.getNumberOfCopies(subRecord,pubCodeSet,numberOfCopies);
        
        EmailNotificationCreation.getFrequency('test', '1');
        EmailNotificationCreation.smsMessage = 'Hello';
        test.stopTest(); //jurna-10-22-15
        System.assertNotEquals(null, pubCodeSet); 
    }
    */
    
    //sets all prerequisite data   
    static void setAllData(){
    
        sObjectMap = null;
        sObjectMap = new Map<String, sObject>(); 
    
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Handphone_Number__c = '09176202715';
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
        try{
            insert billAcc;
        }catch(exception e){}
        addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c = '15';
        addressRec.Level_Number__c = '10';
        addressRec.Unit_Number__c = '50';
        database.insert(addressRec);
        
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        //con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
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
        order.Billing_Contact__c= con1.id;
        order.Vendor_Sms_Remarks__c = 'N/A';
        database.insert(order);
        
        subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        //subRecord.Order_Number__c = order.Id;
        //subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Recipient_Contact_1__c = String.valueOf(con.id);
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
        subRecord.Classification__c = 'A';
        subRecord.Zuora__CustomerAccount__c = billAcc.Id;
        try{
            database.insert(subRecord);
        }catch(exception e){}
        
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
        database.insert(subVendor);
        sObjectMap.put('Subscription_Vendor__c',subVendor );
        
        myZub = [SELECT Zuora__Account__c
                                       FROM Zuora__Subscription__c 
                                       WHERE Id =: subRecord.id];

        cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        cas.Account__c = acc.Id;
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
    
    }
    
    //sets all prerequisite data   //jurna-10-22-15
    static void setAllData2(){
    
        sObjectMap = null;
        sObjectMap = new Map<String, sObject>(); 
    
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Handphone_Number__c = '09176202715';
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
        billAcc.Billing_Type__c = 'Cash'; 
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';   
        try{
            insert billAcc;
        }catch(exception e){}
        
        addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c = '15';
        addressRec.Level_Number__c = '10';
        addressRec.Unit_Number__c = '50';
        database.insert(addressRec);
        
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        //con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
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
        order.Billing_Contact__c= con1.id;
        order.Vendor_Sms_Remarks__c = 'N/A';
        database.insert(order);
        
        subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        //subRecord.Order_Number__c = order.Id;
        //subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Recipient_Contact_1__c = String.valueOf(con.id);
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Main_Package__c = pack.id;
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
        subRecord.Classification__c = 'A';
        subRecord.Zuora__CustomerAccount__c = billAcc.Id;
        subRecord.Ph_d__c = true;
        subRecord.Ph_e__c = true;
        subRecord.Frequency_1__c = 'Default';
        database.insert(subRecord);
                
        subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Zuora__Account__c = acc.id;
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
            subVendor.Recipient__c = con.Id;
            subVendor.Status__c = 'Active';
        database.insert(subVendor);
        sObjectMap.put('Subscription_Vendor__c',subVendor );
        /*
        Subscription_Vendor__c subVendor = (Subscription_Vendor__c) sObjectMap.get('Subscription_Vendor__c');
        subVendor.Recipient__c = con.Id;
        update subVendor; */
        
        myZub = [SELECT Zuora__Account__c
                                       FROM Zuora__Subscription__c 
                                       WHERE Id =: subRecord.id];

        cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        cas.Account__c = acc.Id;
        cas.Sub_Category__c = 'Others';
        sObjectMap.put('Case',cas);
        database.insert(cas);
        
        Case_Vendor_Subscription__c caseVendorSubs = new Case_Vendor_Subscription__c();
            caseVendorSubs.Account__c = acc.Id;
            caseVendorSubs.Address__c = addressRec.Id;
            caseVendorSubs.Case__c = cas.Id;
            caseVendorSubs.Subscription_Vendor__c = subVendor.Id;
        insert caseVendorSubs;
        
        casSubs = TestDataFactory.createCaseSubscription(1);
        for(Case_Subscription__c cs: casSubs) {
            cs.Case__c = cas.id;
            cs.Complaint_Copies__c = 5;     
            cs.Subscription__c = subRecord.id;
            cs.Account__c = acc.id;
            cs.Address__c = addressRec.id;
            cs.Subscription__c = subRecord.Id;
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
         
        Subscription_Vendor_Publication__c subvenpub = new Subscription_Vendor_Publication__c();
        subvenpub.Account__c = acc.id;
        subvenpub.Order__c = order.id;
        subvenpub.Publication__c = publist[0].id;
        subvenpub.Subscription_Vendor__c = subVendor.Id;
        insert subvenpub;
        
        zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
        zproduct.ProductPlatform__c = 'All-In-One';
        insert zproduct;
        
        zqu__ProductRatePlan__c prdrateplan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdrateplan;
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
        packItem.Package__c = pack.id;
        packItem.Product_Rate_Plan__c = prdRatePlan.id;
        packItem.Name = 'Test Pack Item';
        //packItem.Is_All_In_One__c = true;
        try{
            //insert packItem;
        }catch(exception e){}
    }
    
     //sets all prerequisite data   //jurna-10-22-15
    static void setAllData3(){
    
        sObjectMap = null;
        sObjectMap = new Map<String, sObject>(); 
    
        postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Handphone_Number__c = '09176202715';
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
        billAcc.Billing_Type__c = 'Cash'; 
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
        try{
        database.insert(billAcc);
        }catch(exception e){}
        addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c = '15';
        addressRec.Level_Number__c = '10';
        addressRec.Unit_Number__c = '50';
        database.insert(addressRec);
        
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        //con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
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
        order.Billing_Contact__c= con1.id;
        order.Vendor_Sms_Remarks__c = 'N/A';
        database.insert(order);
        
        subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        //subRecord.Order_Number__c = order.Id;
        //subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Recipient_Contact_1__c = String.valueOf(con.id);
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Main_Package__c = pack.id;
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
        subRecord.Classification__c = 'A';
        subRecord.Zuora__CustomerAccount__c = billAcc.Id;
        subRecord.Ph_d__c = true;
        subRecord.Ph_e__c = true;
        subRecord.Frequency_1__c = 'Default';
        database.insert(subRecord);
                
        subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Zuora__Account__c = acc.id;
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
            subVendor.Recipient__c = con.Id;
            subVendor.Status__c = 'Active';
        database.insert(subVendor);
        sObjectMap.put('Subscription_Vendor__c',subVendor );
        /*
        Subscription_Vendor__c subVendor = (Subscription_Vendor__c) sObjectMap.get('Subscription_Vendor__c');
        subVendor.Recipient__c = con.Id;
        update subVendor; */
        
        myZub = [SELECT Zuora__Account__c
                                       FROM Zuora__Subscription__c 
                                       WHERE Id =: subRecord.id];

        cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        cas.Account__c = acc.Id;
        cas.Sub_Category__c = 'Others';
        sObjectMap.put('Case',cas);
        database.insert(cas);
        
        Case_Vendor_Subscription__c caseVendorSubs = new Case_Vendor_Subscription__c();
            caseVendorSubs.Account__c = acc.Id;
            caseVendorSubs.Address__c = addressRec.Id;
            caseVendorSubs.Case__c = cas.Id;
            caseVendorSubs.Subscription_Vendor__c = subVendor.Id;
        insert caseVendorSubs;
        
        casSubs = TestDataFactory.createCaseSubscription(1);
        for(Case_Subscription__c cs: casSubs) {
            cs.Case__c = cas.id;
            cs.Complaint_Copies__c = 5;     
            cs.Subscription__c = subRecord.id;
            cs.Account__c = acc.id;
            cs.Address__c = addressRec.id;
            cs.Subscription__c = subRecord.Id;
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
         
        Subscription_Vendor_Publication__c subvenpub = new Subscription_Vendor_Publication__c();
        subvenpub.Account__c = acc.id;
        subvenpub.Order__c = order.id;
        subvenpub.Publication__c = publist[0].id;
        subvenpub.Subscription_Vendor__c = subVendor.Id;
        insert subvenpub;
        
        zqu__ZProduct__c zproduct = TestDataFactory.createZProduct(1)[0];
        zproduct.ProductPlatform__c = 'All-In-One';
        insert zproduct;
        
        zqu__ProductRatePlan__c prdrateplan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdrateplan;
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        try{
        insert zprpc;
        }catch(exception e){}
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
        packItem.Package__c = pack.id;
        packItem.Product_Rate_Plan__c = prdRatePlan.id;
        packItem.Name = 'Test Pack Item';
        //packItem.Is_All_In_One__c = true;
        try{
            //insert packItem;
        }catch(exception e){}
    }
    
    
     static void defaultCustomSetting()
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
    }

}