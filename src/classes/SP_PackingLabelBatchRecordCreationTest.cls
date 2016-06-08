/**
 * Class Name: <SP_PackingLabelBatchRecordCreationTest>
 * @author: <Flores, Emmanuel>
 * Date: <7/2/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for SP_PackingLabelBatchRecordCreation>
 */
@isTest (seeAllData = true)
private class SP_PackingLabelBatchRecordCreationTest {
    /*
    static testmethod void unitTest() {
        
        //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        //insert dtl;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.Building_Name__c = 'Test Building';
        postal.Street_Name__c = 'Test';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test';
        acc.AccountNumber = '12345';
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Test';
        insert dept;
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Test';
        insert div;
        
        SPH_Section__c sec = new SPH_Section__c();
        sec.Name = 'Test';
        insert sec;
        
        SPH_Location__c loc = new SPH_Location__c();
        loc.Name = 'Test';
        insert loc;
        
        SPH_Company__c comp = new SPH_Company__c();
        comp.Company_Name__c = 'test';
        insert comp;
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'SG';
        insert ctry;
        
        City__c cit = new City__c();
        cit.Flight_Number_1__c = 'flight1';
        cit.Flight_Number_2__c = 'flight2';
        insert cit;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Unit_Number__c = 'yy';
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Company_Code__c = comp.Id;
        addressRec.Country__c = ctry.Id;
        addressRec.Department__c = dept.Id;
        addressRec.Division_Code__c = div.Id;
        addressRec.Section_Code__c = sec.Id;
        addressRec.Location_Code__c = loc.Id;
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.Recipient_Number__c = 12345;
        con.Recipient_Indicator__c = TRUE;
        con.Salutation = 'Mr.';
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c  = 'Other';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        //order.Total_Subscription_Rate__c
        order.Account__c = acc.Id;
        //order.Recipient_Contact__c = con.Id;
        insert order; 
        
        Package__c pack =  TestDataFactory.createPackage(1)[0];
        pack.Package_Price__c = 10.00;
        pack.Package_Type__c = 'Bundle';
        insert pack;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
        oli.Order__c = order.Id;
        oli.Main_Package_ID__c = pack.Id;
        insert oli;
        
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
            for(Zuora__Subscription__c zSub : sub){
                zSub.Zuora__Account__c = acc.Id;
                zSub.Vendor_1__c = acc.Id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Zuora__Status__c = 'Active';
                zSub.Recipient_Contact__c = con.Id;
                //sub[0].Grace_Period_Subscription__c = 
                zSub.Other_PaymentMethod_1__c = 'Freelist';
                zSub.Number_of_Copies__c = 100;
                zSub.Order_Number_1__c = order.Id;
                zSub.Order_Line_Item_Number_1__c = oli.Id;
                //sub[0].isFreeList__c = 
                zSub.Main_Package_1__c = pack.Id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Invoice_Line_Item_Charge__c = 0;
                zSub.Zuora__CustomerAccount__c = billAcc.Id;
                }
        insert sub;
        
        
        SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
        Database.BatchableContext BC;
        batch.start(BC);
        batch.execute(BC, sub);
        //batch.finish(BC);
    }
    
    static testmethod void unitTest2() {
        
        //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        //insert dtl;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.Building_Name__c = 'Test Building';
        postal.Street_Name__c = 'Test';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH-Interdivision')[0];
        acc.Name = 'Mr. Test';
        acc.AccountNumber = '12345';
        insert acc;
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Name = 'Test';
        insert dept;
        
        SPH_Division__c div = new SPH_Division__c();
        div.Name = 'Test';
        insert div;
        
        SPH_Section__c sec = new SPH_Section__c();
        sec.Name = 'Test';
        insert sec;
        
        SPH_Location__c loc = new SPH_Location__c();
        loc.Name = 'Test';
        insert loc;
        
        SPH_Company__c comp = new SPH_Company__c();
        comp.Company_Name__c = 'test';
        insert comp;
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'SG';
        insert ctry;
        
        City__c cit = new City__c();
        cit.Flight_Number_1__c = 'flight1';
        cit.Flight_Number_2__c = 'flight2';
        insert cit;
        
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName = 'Internal'];

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Unit_Number__c = 'yy';
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Company_Code__c = comp.Id;
        addressRec.Department__c = dept.Id;
        addressRec.Division_Code__c = div.Id;
        addressRec.Section_Code__c = sec.Id;
        addressRec.Location_Code__c = loc.Id;
        addressRec.Postal_Code__c = postal.Id;
        //addressRec.RecordTypeId = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName = 'Internal'].Id;
        //addressRec.RecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Internal'];
        addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
        //addressRec.RecordType = recType;
        //addressRec.RecordTypeId = recType.Id;
        addressRec.Country__c = ctry.Id;
        insert addressRec;

        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = addressRec.Id;
        con.Recipient_Number__c = 12345;
        con.Recipient_Indicator__c = TRUE;
        con.Salutation = 'Ms.';
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = TRUE;
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
        System.AssertEquals('Ms.', con.Salutation);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c  = 'Other';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        //order.Total_Subscription_Rate__c
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con.Id;
        insert order; 
        
        Package__c pack =  TestDataFactory.createPackage(1)[0];
        pack.Package_Price__c = 0;
        //pack.Package_Type__c = 'Bundle';
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_GRACE;
        pack.Subscription_Period__c = '1';
        insert pack;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Main_Package_Product_Sub_Type__c = 'Test';
        oli.Order__c = order.Id;
        oli.Main_Package_ID__c = pack.Id;
        oli.Earliest_Start_Date__c = date.today().addDays(2);
        insert oli;
        
        List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
            for(Zuora__Subscription__c zSub : sub){
                zSub.Zuora__Account__c = acc.Id;
                zSub.Vendor__c = acc.Id;
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Status__c = 'Active';
                zSub.Recipient_Contact__c = con.Id;
                zSub.Other_PaymentMethod__c = GlobalVariableClass.FREE_LIST;
                zSub.Number_of_Copies__c = 100;
                zSub.Order_Number__c = order.Id;
                zSub.Order_Line_Item_Number__c = oli.Id;
                zSub.Main_Package__c = pack.Id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Invoice_Line_Item_Charge__c = 0;
                zSub.Zuora__CustomerAccount__c = billAcc.Id;
                zSub.Order_Line_Item_Number_1__c = oli.Id;
            }    
        insert sub;
        
        Set<Id> subIdSet = new Set<Id>();
        for(Zuora__Subscription__c zSub : sub){
            subIdSet.add(zSub.Id);
        }
        
        List<Packing_Label_Batch__c> packLabelList = new List<Packing_Label_Batch__c>();
            for (Packing_Label_Batch__c packLabel : packLabelList){
                packLabel.Account_Name__c = acc.Id;
                packLabel.Subscription__c = sub[0].Id;
            }
        insert packLabelList;
        
        
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = TestDataFactory.createSubProductCharge(2);
            for (Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){
                subProdCharge.Name = 'Test';
                subProdCharge.Zuora__Account__c = acc.Id;
                subProdCharge.Zuora__Subscription__c = sub[0].Id;
                subProdCharge.Product_Category__c = 'Print';
                subProdCharge.Zuora__ProductName__c = 'Test';
                subProdCharge.Product_Code__c = 'ST';
                subProdCharge.PublicationCode__c = 'ST';
            }
        insert subProdChargeList;
        
       List<Publication__c> pub = TestDataFactory.createPublication(2);
       for(Publication__c p: pub){
           p.Publication_Code__c = 'ST';
           p.Published_Days__c = 'YYYYYYN';
           p.Publication_Type__c = 'N';
           p.Earliest_Start_Date__c = date.today().addDays(10);
           p.Direct_Sub_Delivery_Method__c = 'Vendor';
           p.Vendor_Sub_Delivery_Method__c = 'Mailing Agent';   
           p.Earliest_Start_Date__c = date.today();
       }
        insert pub;
        
        Non_Publication_Day__c nonPub = TestDataFactory.createNonPublicationDay(1)[0];
        nonPub.Publication_Code__c = 'ST';
        nonPub.Non_Publication_Date__c = date.today();
        database.insert(nonPub);
        
        test.startTest();
        SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
        Database.BatchableContext BC;
        batch.start(BC);
        batch.execute(BC,sub);
        test.stopTest();
     }
     */
  /*   static testmethod void unitTest3() {
     
         SP_PackingLabelBatchRecordCreation batch = new SP_PackingLabelBatchRecordCreation();
         ID batchprocessid = Database.executeBatch(batch,200);
         System.AssertNotEquals(null, batchprocessid);
         
         BATCH_JOB_SCHEDULER__c bjs = new BATCH_JOB_SCHEDULER__c();
             bjs.Status__c = 'SUCCESS';
             bjs.Batch_Run_Date__c = System.today();
             bjs.SFDC_Job_id__c = batchprocessid;
             bjs.Batch_Code__c = 'SP010';
         
         List<BATCH_JOB_SCHEDULER__c> batchJobSchedList = new List<BATCH_JOB_SCHEDULER__c>();
         batchJobSchedList.add(bjs);
         insert batchJobSchedList;
         
     } */
     
 }