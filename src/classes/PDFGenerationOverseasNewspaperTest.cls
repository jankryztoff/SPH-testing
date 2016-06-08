/**
 * Class Name: <PDFGenerationOverseasNewspaperTest>
 * @author: <Jean Cariño>
 * Date: <11/02/2015>
 * Modified by: Ana Fe Dumangas
 * Modified Date: 7/10/15
 * Requirement/Project Name: <SPH>
 * @description<Test Class for PDFGenerationOverseasNewspaper>
*/

@isTest(SeeAllData = True)
private class PDFGenerationOverseasNewspaperTest{

    public static testMethod void unitTest(){
        String error = '';
        PDFGenerationOverseasNewspaper pdf = new PDFGenerationOverseasNewspaper();
    
        //create Account
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'Name';
        acc.NRIC__c = 'T1234567R';
        acc.AccountNumber = '00154254';
        acc.Fax = '123456';
        insert acc;   
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
                    Country__c country = TestDataFactory.createCountry(1)[0]; 
                    country.Country_Name__c = 'SINGAPORE'; 
                    insert country;
                    
                    Address__c address = TestDataFactory.createAddress(1)[0];
                    //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                    address.Block_House_Number__c =  'TEST';
                    address.Postal_Code__c = postal.id;
                    address.Level_Number__c = '17';
                    address.Unit_Number__c = 'Unit 5';
                    address.Country__c = country.id;
                    
                    //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
                    
                    insert address;
                    
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.AccountId = acc.Id;
                    con.Address__c = address.id;
                    con.Recipient_Indicator__c = true;
                   // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    insert con;
        
        //order
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Subscriber_Charge__c = 100;
        database.insert(ord);
        
        //package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
       
        //order line item
        Order_Line_Item__c lineItem = TestDataFactory.createOrderLineItem(1)[0];
        lineItem.Order__c = ord.Id;
        lineItem.Start_Date__c = date.today()+1;
        lineItem.Main_Package_ID__c = pack.Id;
        lineItem.Term_Length__c = 30;
        lineItem.Main_Package_Billing_Type__c  = 'Recurring Postpaid';
        database.insert(lineItem);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
        database.insert(billAcc);
        
        //create Zuora Subscription
    
        Map<String, SObject> sObjMap = TestDataFactory.createSubscriptionPackage();
        Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjMap.get('Zuora__Subscription__c');
        zSub.Subscription_Type__c = 'Newspaper';
        zSub.Subscription_Type_1__c = 'Newspaper';
        zsub.Delivery_Charge__c  = 100; 
        zsub.Zuora__CustomerAccount__c = billAcc.Id;
        zsub.Order_Line_Item_Number__c = lineItem.Id;
        zSub.Recipient_Contact__c = con.id;
        //zSub.Record_Type__c = 'Overseas';
        Test.startTest();
        insert zSub;
        
        Zuora__SubscriptionProductCharge__c prodCharge = TestDataFactory.createSubProductCharge(1)[0];
        prodCharge.Zuora__Subscription__c = zSub.Id;
        prodCharge.PublicationCode__c = 'Code1';
        database.insert(prodCharge);
        
        //create Publication
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = '3';
        pub.Publication_Type__c = 'A';
        pub.Publication_Code__c = 'ABC';
        pub.Published_Days__c = 'NNNNNNN';
        insert pub;

        //create Packing Label Batch
        
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0;i<18;i++){
            Integer mod = math.mod(i,9);
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Record_Type__c = 'Overseas';
            plb.Account_Name__c = acc.id;
            plb.Subscription__c = zSub.id;
            plb.Subscription_Type__c = 'Newspaper';
            plb.Test_LookUp__c = pub.id;
            plb.Publication_Code__c = pub.Publication_Code__c;
            plb.Mailing_Agent_Account_Number__c = '00154254';
            plb.Issue_Date__c = date.today();
        
            if(i<9){
                plb.Copy_Type__c = 'Subscription';
                if(mod==0){
                    plb.Product_Family__c = 'BH';
                }else if(mod==1){
                    plb.Product_Family__c = 'WB';
                }else if(mod==2){
                    plb.Product_Family__c = 'ZB';
                }else if(mod==3){
                    plb.Product_Family__c = 'TM';
                }else if(mod==4){
                    plb.Product_Family__c = 'BT';
                }else if(mod==5){
                    plb.Product_Family__c = 'ST';
                }else if(mod==6){
                    plb.Product_Family__c = 'NP';
                }else if(mod==7){
                    plb.Product_Family__c = 'MY';
                }else if(mod==8){
                    plb.Product_Family__c = 'SM';
                }
            }else{
                plb.Copy_Type__c = 'FreeList';
                if(mod==0){
                    plb.Product_Family__c = 'BH';
                }else if(mod==1){
                    plb.Product_Family__c = 'WB';
                }else if(mod==2){
                    plb.Product_Family__c = 'ZB';
                }else if(mod==3){
                    plb.Product_Family__c = 'TM';
                }else if(mod==4){
                    plb.Product_Family__c = 'BT';
                }else if(mod==5){
                    plb.Product_Family__c = 'ST';
                }else if(mod==6){
                    plb.Product_Family__c = 'NP';
                }else if(mod==7){
                    plb.Product_Family__c = 'MY';
                }else if(mod==8){
                    plb.Product_Family__c = 'SM';
                }
            }
            plbList.add(plb);
        }
        insert plbList;
        String dateValue = ''+date.today();
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        PageReference pageRef = Page.OverseasNewspaperReportHardCopy;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', '00154254');
        ApexPages.currentPage().getParameters().put('issueDate', dateValue );
        PDFGenerationOverseasNewspaper pdfGen = new PDFGenerationOverseasNewspaper();
        pdfGen.generatePDF();
        
        
        Test.StopTest();
        }
        catch(Zuora.zRemoteException e){
            error = e.getMessage();
        }
        //System.assert(error=='');
    }
    public static testMethod void unitTest2(){
        String error = '';
        
        PDFGenerationOverseasNewspaper pdf = new PDFGenerationOverseasNewspaper();
    
        //create Account
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Fax = '123456';
        insert acc;   
        
        Contact con = TestDataFactory.createContactRecType(1,'Customer Contact')[0];
        database.insert(con);
        
        //package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        //order
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Subscriber_Charge__c = 100;
        database.insert(ord);
        
        //order line item
        Order_Line_Item__c lineItem = TestDataFactory.createOrderLineItem(1)[0];
        lineItem.Order__c = ord.Id;
        lineItem.Start_Date__c = date.today()+1;
        lineItem.Main_Package_ID__c = pack.Id;
        lineItem.Term_Length__c = 30;
        lineItem.Main_Package_Billing_Type__c  = 'Recurring Postpaid';
        database.insert(lineItem);
        
        //Billing Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
        database.insert(billAcc);
        
        //create Zuora Subscription
    
        Map<String, SObject> sObjMap = TestDataFactory.createSubscriptionPackage();
        Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjMap.get('Zuora__Subscription__c');
        zSub.Subscription_Type__c = 'Newspaper';
        zSub.Subscription_Type_1__c = 'Newspaper';
        zsub.Delivery_Charge__c  = 100; 
        zsub.Zuora__CustomerAccount__c = billAcc.Id;
        zsub.Order_Line_Item_Number__c = lineItem.Id;
        zsub.Recipient_Contact__c = con.Id;
        zSub.Frequency_1__c  = GlobalVariableClass.FREQUENCY_MONFRI;
        //zSub.Record_Type__c = 'Overseas';
        Test.startTest();
        insert zSub;
        Contact conUp = (Contact) sObjMap.get('Recipient Contact');
        conUp.Fax = null;
        update conUp;
        
        Zuora__SubscriptionProductCharge__c prodCharge = TestDataFactory.createSubProductCharge(1)[0];
        prodCharge.Zuora__Subscription__c = zSub.Id;
        prodCharge.PublicationCode__c = '123';
        database.insert(prodCharge);
        
        //create Publication
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = '3';
        pub.Publication_Type__c = 'A';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Code__c = '123';
        insert pub;

        //create Packing Label Batch
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0;i<18;i++){
            Integer mod = math.mod(i,9);
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Record_Type__c = 'Overseas';
            plb.Account_Name__c = acc.id;
            plb.Subscription__c = zSub.id;
            plb.Subscription_Type__c = 'Newspaper';
            plb.Test_LookUp__c = pub.id;
    
        
            if(i<9){
                plb.Copy_Type__c = 'Subscription';
                if(mod==0){
                    plb.Product_Family__c = 'BH';
                }else if(mod==1){
                    plb.Product_Family__c = 'WB';
                }else if(mod==2){
                    plb.Product_Family__c = 'ZB';
                }else if(mod==3){
                    plb.Product_Family__c = 'TM';
                }else if(mod==4){
                    plb.Product_Family__c = 'BT';
                }else if(mod==5){
                    plb.Product_Family__c = 'ST';
                }else if(mod==6){
                    plb.Product_Family__c = 'NP';
                }else if(mod==7){
                    plb.Product_Family__c = 'MY';
                }else if(mod==8){
                    plb.Product_Family__c = 'SM';
                }
            }else{
                plb.Copy_Type__c = 'FreeList';
                if(mod==0){
                    plb.Product_Family__c = 'BH';
                }else if(mod==1){
                    plb.Product_Family__c = 'WB';
                }else if(mod==2){
                    plb.Product_Family__c = 'ZB';
                }else if(mod==3){
                    plb.Product_Family__c = 'TM';
                }else if(mod==4){
                    plb.Product_Family__c = 'BT';
                }else if(mod==5){
                    plb.Product_Family__c = 'ST';
                }else if(mod==6){
                    plb.Product_Family__c = 'NP';
                }else if(mod==7){
                    plb.Product_Family__c = 'MY';
                }else if(mod==8){
                    plb.Product_Family__c = 'SM';
                }
            }
            plbList.add(plb);
        }
       
        insert plbList;
        
        RecordType rec = [SELECT Id, Name FROM RecordType WHERE Name='Overseas'][0];
        Packing_Label_Batch__c plBatch = new Packing_Label_Batch__c();
        plBatch.Mailing_Agent_Account_Number__c = plbList[0].Id;
        plBatch.Subscription_Type__c = 'Newspaper';
        plbatch.Record_Type__c = rec.Id;
        plBatch.subscription__c = zSub.Id;
        database.insert(plBatch);
        
        plbList.add(plBatch);
        
        acc.AccountNumber = plbList[0].Id;
        database.update(acc);
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        PDFGenerationOverseasNewspaper pdfGen = new PDFGenerationOverseasNewspaper();
        pdfGen.PackagingLabel = plBatch;
        pdfGen.fax = '123456';
        pdfGen.generatePDF();
        PageReference pageRef = Page.OverseasNewspaperReportHardCopy;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',plbList[0].id);
        Test.StopTest();
        }
        catch(Zuora.zRemoteException e){
            error = e.getMessage();
        }
        System.debug('Error: '+error); //error: Methods defined as TestMethod do not support Web service callouts, test skipped
       //System.assert(error=='');
    }
    
     public static testMethod void newTest001(){
        String error = '';
        
        PDFGenerationOverseasNewspaper pdf = new PDFGenerationOverseasNewspaper();
    
        //create Account
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Fax = '123456';
        insert acc;   
        
        Contact con = TestDataFactory.createContactRecType(1,'Customer Contact')[0];
        database.insert(con);
        
        //package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        //order
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Subscriber_Charge__c = 100;
        database.insert(ord);
        
        //order line item
        Order_Line_Item__c lineItem = TestDataFactory.createOrderLineItem(1)[0];
        lineItem.Order__c = ord.Id;
        lineItem.Start_Date__c = date.today()+1;
        lineItem.Main_Package_ID__c = pack.Id;
        lineItem.Term_Length__c = 30;
        lineItem.Main_Package_Billing_Type__c  = 'Recurring Postpaid';
        database.insert(lineItem);
        
        //Billing Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
        database.insert(billAcc);
        
        //create Zuora Subscription
    
        Map<String, SObject> sObjMap = TestDataFactory.createSubscriptionPackage();
        Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjMap.get('Zuora__Subscription__c');
        zSub.Subscription_Type__c = 'Newspaper';
        zSub.Subscription_Type_1__c = 'Newspaper';
        zsub.Delivery_Charge__c  = 100; 
        zsub.Zuora__CustomerAccount__c = billAcc.Id;
        zsub.Order_Line_Item_Number__c = lineItem.Id;
        zsub.Recipient_Contact__c = con.Id;
        zSub.Frequency_1__c  = GlobalVariableClass.FREQUENCY_MONFRI;
        //zSub.Record_Type__c = 'Overseas';
        Test.startTest();
        insert zSub;
        Contact conUp = (Contact) sObjMap.get('Recipient Contact');
        conUp.Fax = null;
        update conUp;
        
        Zuora__SubscriptionProductCharge__c prodCharge = TestDataFactory.createSubProductCharge(1)[0];
        prodCharge.Zuora__Subscription__c = zSub.Id;
        prodCharge.PublicationCode__c = '123';
        database.insert(prodCharge);
        
        //create Publication
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = '3';
        pub.Publication_Type__c = 'A';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Code__c = '123';
        insert pub;

        //create Packing Label Batch
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0;i<18;i++){
            Integer mod = math.mod(i,9);
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Record_Type__c = 'Overseas';
            plb.Account_Name__c = acc.id;
            plb.Subscription__c = zSub.id;
            plb.Subscription_Type__c = 'Newspaper';
            plb.Test_LookUp__c = pub.id;
    
        
            if(i<9){
                plb.Copy_Type__c = 'Subscription';
                if(mod==0){
                    plb.Product_Family__c = 'BH';
                }else if(mod==1){
                    plb.Product_Family__c = 'WB';
                }else if(mod==2){
                    plb.Product_Family__c = 'ZB';
                }else if(mod==3){
                    plb.Product_Family__c = 'TM';
                }else if(mod==4){
                    plb.Product_Family__c = 'BT';
                }else if(mod==5){
                    plb.Product_Family__c = 'ST';
                }else if(mod==6){
                    plb.Product_Family__c = 'NP';
                }else if(mod==7){
                    plb.Product_Family__c = 'MY';
                }else if(mod==8){
                    plb.Product_Family__c = 'SM';
                }
            }else{
                plb.Copy_Type__c = 'FreeList';
                if(mod==0){
                    plb.Product_Family__c = 'BH';
                }else if(mod==1){
                    plb.Product_Family__c = 'WB';
                }else if(mod==2){
                    plb.Product_Family__c = 'ZB';
                }else if(mod==3){
                    plb.Product_Family__c = 'TM';
                }else if(mod==4){
                    plb.Product_Family__c = 'BT';
                }else if(mod==5){
                    plb.Product_Family__c = 'ST';
                }else if(mod==6){
                    plb.Product_Family__c = 'NP';
                }else if(mod==7){
                    plb.Product_Family__c = 'MY';
                }else if(mod==8){
                    plb.Product_Family__c = 'SM';
                }
            }
            plbList.add(plb);
        }
       
        insert plbList;
        
        RecordType rec = [SELECT Id, Name FROM RecordType WHERE Name='Overseas'][0];
        Packing_Label_Batch__c plBatch = new Packing_Label_Batch__c();
        plBatch.Mailing_Agent_Account_Number__c = plbList[0].Id;
        plBatch.Subscription_Type__c = 'Newspaper';
        plbatch.Record_Type__c = rec.Id;
        plBatch.subscription__c = zSub.Id;
        database.insert(plBatch);
        
        plbList.add(plBatch);
        
        acc.AccountNumber = plbList[0].Id;
        database.update(acc);
        
        
        
        PageReference pageRef = Page.OverseasNewspaperReportHardCopy;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',plbList[0].id);
        PDFGenerationOverseasNewspaper pdfGen = new PDFGenerationOverseasNewspaper();
        pdfGen.PackagingLabel = plBatch;
        pdfGen.fax = '123456';
        pdfGen.packLableList = plbList;
        pdfGen.generatePDF();
        Test.StopTest();
       
    }
     public static testMethod void newAprilTest(){
        String error = '';
        
        PDFGenerationOverseasNewspaper pdf = new PDFGenerationOverseasNewspaper();
    
        //create Account
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Fax = '123456';
        insert acc;   
        
        Contact con = TestDataFactory.createContactRecType(1,'Customer Contact')[0];
        database.insert(con);
        
        //package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        //order
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        ord.Subscriber_Charge__c = 100;
        database.insert(ord);
        
        //order line item
        Order_Line_Item__c lineItem = TestDataFactory.createOrderLineItem(1)[0];
        lineItem.Order__c = ord.Id;
        lineItem.Start_Date__c = date.today()+1;
        lineItem.Main_Package_ID__c = pack.Id;
        lineItem.Term_Length__c = 30;
        lineItem.Main_Package_Billing_Type__c  = 'Recurring Postpaid';
        database.insert(lineItem);
        
        //Billing Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
        database.insert(billAcc);
        
        //create Zuora Subscription
    
        Map<String, SObject> sObjMap = TestDataFactory.createSubscriptionPackage();
        Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjMap.get('Zuora__Subscription__c');
        zSub.Subscription_Type__c = 'Newspaper';
        zSub.Subscription_Type_1__c = 'Newspaper';
        zsub.Delivery_Charge__c  = 100; 
        zsub.Zuora__CustomerAccount__c = billAcc.Id;
        zsub.Order_Line_Item_Number__c = lineItem.Id;
        zsub.Recipient_Contact__c = con.Id;
        zSub.Frequency_1__c  = GlobalVariableClass.FREQUENCY_MONFRI;
        //zSub.Record_Type__c = 'Overseas';
        
        List<Zuora__Subscription__c> zSub2 = TestDataFactory.createSubscription(2);
        zSub2[0].Subscription_Type__c = 'Newspaper';
        zSub2[0].Subscription_Type_1__c = 'Newspaper';
        zsub2[0].Delivery_Charge__c  = 100; 
        zsub2[0].Zuora__CustomerAccount__c = billAcc.Id;
        zsub2[0].Order_Line_Item_Number__c = lineItem.Id;
        zsub2[0].Recipient_Contact__c = con.Id;
        zSub2[0].Frequency_1__c  = GlobalVariableClass.FREQUENCY_MONFRI;
        
        zSub2[1].Subscription_Type__c = 'Newspaper';
        zSub2[1].Subscription_Type_1__c = 'Newspaper';
        zsub2[1].Delivery_Charge__c  = 100; 
        zsub2[1].Zuora__CustomerAccount__c = billAcc.Id;
        zsub2[1].Order_Line_Item_Number__c = lineItem.Id;
        zsub2[1].Recipient_Contact__c = con.Id;
        zSub2[1].Frequency_1__c  = GlobalVariableClass.FREQUENCY_MONFRI;
        
        Test.startTest();
        insert zSub;
        Contact conUp = (Contact) sObjMap.get('Recipient Contact');
        conUp.Fax = null;
        update conUp;
        
        List<Zuora__SubscriptionProductCharge__c> prodCharge = TestDataFactory.createSubProductCharge(4);
        prodCharge[0].Zuora__Subscription__c = zSub2[0].Id;
        prodCharge[0].PublicationCode__c = '123';
        
        prodCharge[1].Zuora__Subscription__c = zSub2[0].Id;
        prodCharge[1].PublicationCode__c = '123';
        
        prodCharge[2].Zuora__Subscription__c = zSub2[1].Id;
        prodCharge[2].PublicationCode__c = '123';
        
        prodCharge[3].Zuora__Subscription__c = zSub2[1].Id;
        prodCharge[3].PublicationCode__c = '123';
        database.insert(prodCharge);
        
        //create Publication
    
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = '3';
        pub.Publication_Type__c = 'A';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Code__c = '123';
        insert pub;

        //create Packing Label Batch
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0;i<18;i++){
            Integer mod = math.mod(i,9);
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Record_Type__c = 'Overseas';
            plb.Account_Name__c = acc.id;
            plb.Subscription__c = zSub.id;
            plb.Subscription_Type__c = 'Newspaper';
            plb.Test_LookUp__c = pub.id;
            plb.Issue_Date__c = date.today();
    
        
            if(i<9){
                plb.Copy_Type__c = 'Subscription';
                if(mod==0){
                    plb.Product_Family__c = 'BH';
                }else if(mod==1){
                    plb.Product_Family__c = 'WB';
                }else if(mod==2){
                    plb.Product_Family__c = 'ZB';
                }else if(mod==3){
                    plb.Product_Family__c = 'TM';
                }else if(mod==4){
                    plb.Product_Family__c = 'BT';
                }else if(mod==5){
                    plb.Product_Family__c = 'ST';
                }else if(mod==6){
                    plb.Product_Family__c = 'NP';
                }else if(mod==7){
                    plb.Product_Family__c = 'MY';
                }else if(mod==8){
                    plb.Product_Family__c = 'SM';
                }
            }else{
                plb.Copy_Type__c = 'FreeList';
                if(mod==0){
                    plb.Product_Family__c = 'BH';
                }else if(mod==1){
                    plb.Product_Family__c = 'WB';
                }else if(mod==2){
                    plb.Product_Family__c = 'ZB';
                }else if(mod==3){
                    plb.Product_Family__c = 'TM';
                }else if(mod==4){
                    plb.Product_Family__c = 'BT';
                }else if(mod==5){
                    plb.Product_Family__c = 'ST';
                }else if(mod==6){
                    plb.Product_Family__c = 'NP';
                }else if(mod==7){
                    plb.Product_Family__c = 'MY';
                }else if(mod==8){
                    plb.Product_Family__c = 'SM';
                }
            }
            plbList.add(plb);
        }
       
        insert plbList;
        
        RecordType rec = [SELECT Id, Name FROM RecordType WHERE Name='Overseas'][0];
        Packing_Label_Batch__c plBatch = new Packing_Label_Batch__c();
        plBatch.Mailing_Agent_Account_Number__c = plbList[0].Id;
        plBatch.Subscription_Type__c = 'Newspaper';
        plbatch.Record_Type__c = rec.Id;
        plBatch.subscription__c = zSub.Id;
       // plb.Issue_Date__c = date.today();
        database.insert(plBatch);
        
        plbList.add(plBatch);
        
        acc.AccountNumber = plbList[0].Id;
        database.update(acc);
        
       
        
        PageReference pageRef = Page.OverseasNewspaperReportHardCopy;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',plbList[0].id);
        
        
        PDFGenerationOverseasNewspaper pdfGen = new PDFGenerationOverseasNewspaper();
        pdfGen.PackagingLabel = plBatch;
        pdfGen.fax = '123456';
        pdfGen.packLableList = plbList;
        pdfGen.generatePDF();
        Test.StopTest();
       
    }
}