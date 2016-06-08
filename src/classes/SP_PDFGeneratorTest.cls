/**
* Class Name: <SP_PDFGeneratorTest>
* @author: <Patrick Pancho>
* Date: <02/03/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for SP_PDFGenerator>
* @author: <Marjorie Gaelo>
* @Modified Date <2/19/2015>
* Modified By: Johnmar Diamante
* Modified Date: 6/19/2015
*/

@isTest
private class SP_PDFGeneratorTest {
    /**
    *  @description This method executes during class instantiation. 
    *  @name <Test_SP_PDFGenerator>
    */
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createBillingBatch();
    }  
    
    static testMethod void Test_SP_PDFGenerator() {
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
        List<String> parentIdList = new List<String>();
        String templateName = '';
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
        
        List<String> templateNameList = new List<String>{
            SP_GenerateLetterPrintBatch.overseasNewspaperWrapper,
            'testpdf',
            SP_GenerateLetterPrintBatch.acknowledgmentLetter,
            SP_GenerateLetterPrintBatch.invoiceLetter,
            SP_GenerateLetterPrintBatch.giftLetter,
            SP_GenerateLetterPrintBatch.subscriptionLetter,
            SP_GenerateLetterPrintBatch.giftRenewalLetter,
            SP_GenerateLetterPrintBatch.giftRedemptionLetter,
            SP_GenerateLetterPrintBatch.creditCardFailureNotification,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.creditNotes,
            SP_GenerateLetterPrintBatch.packingLabelLetter,
            SP_GenerateLetterPrintBatch.giftPremiumChina,
            SP_GenerateLetterPrintBatch.giftPremiumEnglish
        };
        
        List<Account> accList = TestDataFactory.createAccount(5, 'Direct Corporate');
        accList[0].AccountNumber = 'sample12345';
        insert accList;
        
        parentIdList.add(accList[0].AccountNumber);
        
        accList = [SELECT Id, Name, AccountNumber FROM Account WHERE id IN: accList];
        
        List<Zuora__ZInvoice__c> invList = TestDataFactory.createInvoice(5);
        insert invList;
        
        //fritz
        List <Billing_Batch__c> billingBatch = CustomSettingsDataFactory.createBillingBatch();
        insert billingBatch;
        
        /*
        List<Credit_Note__c> credNoteList = new List<Credit_Note__c>();
        for(Integer i = 0; i < 5; i++) {
            Credit_Note__c cn = new Credit_Note__c();
            //START UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text
            integer cnNum = 8888888 + i;
            cn.Credit_Note_Number__c = string.valueOf(cnNum);
            //END UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text
            zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz.add(cn);
        }
        insert credNoteList;
        */
        
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0; i < 5; i++) {
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Subscriber_Account_Number__c = accList[i].AccountNumber;
            plbList.add(plb);
        }
        insert plbList;
        
              
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        insert packageList;
        
                               
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = accList[0].id; 
        billAccountList[0].Zuora__AccountNumber__c = '001122';
        insert billAccountList; 
        
        //START D-4594 01April2016 Added By C. Lin
        List<Credit_Note__c> credNoteList = new List<Credit_Note__c>();
        for(Integer i = 0; i < 5; i++) {
            Credit_Note__c cn = new Credit_Note__c();
            integer cnNum = 8888888 + i;
            cn.Credit_Note_Number__c = string.valueOf(cnNum);
            cn.Billing_Account__c = billAccountList[0].Id;
            cn.Document_Date__c = Date.Today();
            credNoteList.add(cn);
        }
        insert credNoteList;
        //END D-4594 01April2016 Added By C. Lin
        
        List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        zsubList[0].Name = 'Ron';
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';        
        zsubList[0].Delivery_Charge__c = 200;
        insert zsubList; 
        
        List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);
        subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
        subProdCharge[0].PublicationCode__c = 'CD12';
        insert subProdCharge;
        
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(1);
        invoice[0].Zuora__BillingAccount__c = billAccountList[0].id;
        insert invoice;
        
        List<Publication__c> pub = TestDataFactory.createPublication(1);
        pub[0].Publication_Code__c = 'CD12';
        insert pub;
        
        for(Zuora__ZInvoice__c inv : invList) {
            parentIdList.add(String.valueOf(inv.id));
        }
        /*
        for(Credit_Note__c cn : credNoteList) {
            parentIdList.add(String.valueOf(cn.id));
        }
        */
        for(Packing_Label_Batch__c plb : plbList) {
            parentIdList.add(String.valueOf(plb.id));
        }
        
        for(Zuora__Subscription__c zSub: zSubList){
            parentIdList.add(String.valueOf(zSub.id));
        }
        
        String encodedContentsString = 'body';
          
        //START D-4594 01April2016 Added By C. Lin
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attachment1 = new Attachment();
        Attachment attachment2 = new Attachment();
        attachment1.Body = Blob.valueOf(encodedContentsString);
        attachment1.Name = String.valueOf('test.txt');
        attachment1.ParentId = accList[0].id;
        attachmentList.add(attachment1);

        attachment2.Body = Blob.valueOf(encodedContentsString);
        attachment2.Name = String.valueOf('test.txt');
        attachment2.ParentId = accList[0].id;
        attachmentList.add(attachment2);
        insert attachmentList;
        //END D-4594 01April2016 Added By C. Lin
          
        Test.startTest();
        
        //START D-4594 01April2016 Added By C. Lin
        List<String> creditNoteIdList = new List<String>();
        for(Credit_Note__c cn : credNoteList){
            creditNoteIdList.add(cn.Id);
        }
        
        String letterString = SP_GenerateLetterPrintBatch.creditNotes;
        //String letterString = '';
        //END D-4594 01April2016 Added By C. Lin
        
        List<String> letterSubTypelist = new List<String>();
        letterSubTypelist.add(letterString);
        Map<String,List<String>> newmap1 = new Map<String,List<String>>();
        newmap1.put('',letterSubTypelist);
        
        Date fromDate = date.Today();
        Date toDate = date.today()+20;
        Boolean isrecover = true;
        
        /**  for(String template : templateNameList) {
            SP_PDFGenerator.insertAttachment(parentIdList, template, letterSubTypeMap);
        }**/
        
        /*for(String key : letterSubTypeMap.keyset()) {
            SP_PDFGenerator.insertAttachment(parentIdList, templateName, letterSubTypeMap);
        } */
        SP_PDFGenerator spPGen = new SP_PDFGenerator();
        //SP_PDFGenerator.insertAttachment(letterSubTypelist, letterString, newmap1, fromDate, toDate, isrecover);
        SP_PDFGenerator.insertAttachment(creditNoteIdList, letterString, newmap1, fromDate, toDate, isrecover);
        
        Test.stopTest();
    }
    
    //START D-4594 01April2016 Added By C. Lin
    
    static testMethod void Test_SP_PDFGenerator_populateChildParentMap() {
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
        List<String> parentIdList = new List<String>();
        List<String> invIdList = new List<String>();
        String templateName = '';
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
        
        List<String> templateNameList = new List<String>{
            SP_GenerateLetterPrintBatch.overseasNewspaperWrapper,
            'testpdf',
            SP_GenerateLetterPrintBatch.acknowledgmentLetter,
            SP_GenerateLetterPrintBatch.invoiceLetter,
            SP_GenerateLetterPrintBatch.giftLetter,
            SP_GenerateLetterPrintBatch.subscriptionLetter,
            SP_GenerateLetterPrintBatch.giftRenewalLetter,
            SP_GenerateLetterPrintBatch.giftRedemptionLetter,
            SP_GenerateLetterPrintBatch.creditCardFailureNotification,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.creditNotes,
            SP_GenerateLetterPrintBatch.packingLabelLetter,
            SP_GenerateLetterPrintBatch.giftPremiumChina,
            SP_GenerateLetterPrintBatch.giftPremiumEnglish
        };
        
        List<Account> accList = TestDataFactory.createAccount(5, 'Direct Corporate');
        accList[0].AccountNumber = 'sample12345';
        insert accList;
        
        parentIdList.add(accList[0].AccountNumber);
        
        accList = [SELECT Id, Name, AccountNumber FROM Account WHERE id IN: accList];
        
        List<Zuora__ZInvoice__c> invList = TestDataFactory.createInvoice(5);
        for(Zuora__ZInvoice__c zInv : invList){
            zInv.Zuora__InvoiceDate__c = Date.Today();
        }
        insert invList;
        
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0; i < 5; i++) {
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Subscriber_Account_Number__c = accList[i].AccountNumber;
            plbList.add(plb);
        }
        insert plbList;
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        insert packageList;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = accList[0].id; 
        billAccountList[0].Zuora__AccountNumber__c = '001122';
        insert billAccountList; 
        
        List<Credit_Note__c> credNoteList = new List<Credit_Note__c>();
        for(Integer i = 0; i < 5; i++) {
            Credit_Note__c cn = new Credit_Note__c();
            integer cnNum = 8888888 + i;
            cn.Credit_Note_Number__c = string.valueOf(cnNum);
            cn.Billing_Account__c = billAccountList[0].Id;
            cn.Document_Date__c = Date.Today();
            credNoteList.add(cn);
        }
        insert credNoteList;
        
        List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        zsubList[0].Name = 'Ron';
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';        
        zsubList[0].Delivery_Charge__c = 200;
        insert zsubList; 
        
        List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);
        subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
        subProdCharge[0].PublicationCode__c = 'CD12';
        insert subProdCharge;
        
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(1);
        invoice[0].Zuora__BillingAccount__c = billAccountList[0].id;
        insert invoice;
        
        List<Publication__c> pub = TestDataFactory.createPublication(1);
        pub[0].Publication_Code__c = 'CD12';
        insert pub;
        
        for(Zuora__ZInvoice__c inv : invList) {
            invIdList.add(String.valueOf(inv.id));
        }
        
        for(Packing_Label_Batch__c plb : plbList) {
            parentIdList.add(String.valueOf(plb.id));
        }
        
        for(Zuora__Subscription__c zSub: zSubList){
            parentIdList.add(String.valueOf(zSub.id));
        }
        
        String encodedContentsString = 'body';
        
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attachment1 = new Attachment();
        Attachment attachment2 = new Attachment();
        attachment1.Body = Blob.valueOf(encodedContentsString);
        attachment1.Name = String.valueOf('test.txt');
        attachment1.ParentId = accList[0].id;
        attachmentList.add(attachment1);

        attachment2.Body = Blob.valueOf(encodedContentsString);
        attachment2.Name = String.valueOf('test.txt');
        attachment2.ParentId = accList[0].id;
        attachmentList.add(attachment2);
        insert attachmentList;
        
        Test.startTest();
        
        List<String> creditNoteIdList = new List<String>();
        for(Credit_Note__c cn : credNoteList){
            creditNoteIdList.add(cn.Id);
        }
        
        String letterString = SP_GenerateLetterPrintBatch.invoiceLetter;
        
        List<String> letterSubTypelist = new List<String>();
        letterSubTypelist.add(letterString);
        Map<String,List<String>> newmap1 = new Map<String,List<String>>();
        newmap1.put('',letterSubTypelist);
        
        Date fromDate = date.Today();
        Date toDate = date.today()+20;
        Boolean isrecover = true;
        
        SP_PDFGenerator.insertAttachment(invIdList, letterString, newmap1, fromDate, toDate, isrecover);
        
        Test.stopTest();
    }
    
    static testMethod void Test_SP_PDFGenerator_acknowledgmentLetter() {
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
        Key_Id__c keyCon = new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c = '30000000');
        insert keyCon;
        
        List<String> parentIdList = new List<String>();
        List<String> invIdList = new List<String>();
        List<String> subIdList = new List<String>();
        List<String> baIdList = new List<String>();
        String templateName = '';
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
        
        List<String> templateNameList = new List<String>{
            SP_GenerateLetterPrintBatch.overseasNewspaperWrapper,
            'testpdf',
            SP_GenerateLetterPrintBatch.acknowledgmentLetter,
            SP_GenerateLetterPrintBatch.invoiceLetter,
            SP_GenerateLetterPrintBatch.giftLetter,
            SP_GenerateLetterPrintBatch.subscriptionLetter,
            SP_GenerateLetterPrintBatch.giftRenewalLetter,
            SP_GenerateLetterPrintBatch.giftRedemptionLetter,
            SP_GenerateLetterPrintBatch.creditCardFailureNotification,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.creditNotes,
            SP_GenerateLetterPrintBatch.packingLabelLetter,
            SP_GenerateLetterPrintBatch.giftPremiumChina,
            SP_GenerateLetterPrintBatch.giftPremiumEnglish
        };
        
        List<Account> accList = TestDataFactory.createAccount(5, 'Direct Corporate');
        accList[0].AccountNumber = 'sample12345';
        insert accList;
        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].Billing_Indicator__c = true;
        conList[0].Recipient_Indicator__c = true;
        insert conList;
        
        parentIdList.add(accList[0].AccountNumber);
        
        accList = [SELECT Id, Name, AccountNumber FROM Account WHERE id IN: accList];
        
        List<Zuora__ZInvoice__c> invList = TestDataFactory.createInvoice(5);
        for(Zuora__ZInvoice__c zInv : invList){
            zInv.Zuora__InvoiceDate__c = Date.Today();
        }
        insert invList;
        
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0; i < 5; i++) {
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Subscriber_Account_Number__c = accList[i].AccountNumber;
            plbList.add(plb);
        }
        insert plbList;
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        insert packageList;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = accList[0].id; 
        billAccountList[0].Zuora__AccountNumber__c = '001122';
        billAccountList[0].Billing_Contact__c = conList[0].Id;
        insert billAccountList; 
        
        List<Credit_Note__c> credNoteList = new List<Credit_Note__c>();
        for(Integer i = 0; i < 5; i++) {
            Credit_Note__c cn = new Credit_Note__c();
            integer cnNum = 8888888 + i;
            cn.Credit_Note_Number__c = string.valueOf(cnNum);
            cn.Billing_Account__c = billAccountList[0].Id;
            cn.Document_Date__c = Date.Today();
            credNoteList.add(cn);
        }
        insert credNoteList;
        
        List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        zsubList[0].Name = 'Ron';
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';        
        zsubList[0].Delivery_Charge__c = 200;
        zsubList[0].Zuora__SubscriptionStartDate__c = date.Today();
        zsubList[0].Zuora__SubscriptionEndDate__c = null;
        zsubList[0].Zuora__TermSettingType__c = 'EVERGREEN';
        insert zsubList; 
        
        List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);
        subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
        subProdCharge[0].PublicationCode__c = 'CD12';
        insert subProdCharge;
        
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(1);
        invoice[0].Zuora__BillingAccount__c = billAccountList[0].id;
        insert invoice;
        
        List<Publication__c> pub = TestDataFactory.createPublication(1);
        pub[0].Publication_Code__c = 'CD12';
        insert pub;
        
        for(Zuora__ZInvoice__c inv : invList) {
            invIdList.add(String.valueOf(inv.id));
        }
        
        for(Zuora__CustomerAccount__c ba : billAccountList) {
            baIdList.add(String.valueOf(ba.id));
        }
        
        for(Zuora__Subscription__c zSub: zSubList){
            subIdList.add(String.valueOf(zSub.id));
        }
        
        String encodedContentsString = 'body';
        
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attachment1 = new Attachment();
        Attachment attachment2 = new Attachment();
        attachment1.Body = Blob.valueOf(encodedContentsString);
        attachment1.Name = String.valueOf('test.txt');
        attachment1.ParentId = accList[0].id;
        attachmentList.add(attachment1);

        attachment2.Body = Blob.valueOf(encodedContentsString);
        attachment2.Name = String.valueOf('test.txt');
        attachment2.ParentId = accList[0].id;
        attachmentList.add(attachment2);
        insert attachmentList;
        
        Test.startTest();
        
        List<String> creditNoteIdList = new List<String>();
        for(Credit_Note__c cn : credNoteList){
            creditNoteIdList.add(cn.Id);
        }
        
        String letterString = SP_GenerateLetterPrintBatch.acknowledgmentLetter;
        
        List<String> letterSubTypelist = new List<String>();
        letterSubTypelist.add(letterString);
        Map<String,List<String>> newmap1 = new Map<String,List<String>>();
        newmap1.put('',letterSubTypelist);
        
        Date fromDate = date.Today();
        Date toDate = date.today()+20;
        Boolean isrecover = true;
        
        SP_PDFGenerator.insertAttachment(baIdList, letterString, newmap1, fromDate, toDate, isrecover);
        
        Test.stopTest();
    }
    
    static testMethod void Test_SP_PDFGenerator_FAILED_PAYPAL_NOTIFICATION() {
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
        Key_Id__c keyCon = new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c = '30000000');
        insert keyCon;
        
        List<String> parentIdList = new List<String>();
        List<String> invIdList = new List<String>();
        List<String> subIdList = new List<String>();
        List<String> baIdList = new List<String>();
        String templateName = '';
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
        
        List<String> templateNameList = new List<String>{
            SP_GenerateLetterPrintBatch.overseasNewspaperWrapper,
            'testpdf',
            SP_GenerateLetterPrintBatch.acknowledgmentLetter,
            SP_GenerateLetterPrintBatch.invoiceLetter,
            SP_GenerateLetterPrintBatch.giftLetter,
            SP_GenerateLetterPrintBatch.subscriptionLetter,
            SP_GenerateLetterPrintBatch.giftRenewalLetter,
            SP_GenerateLetterPrintBatch.giftRedemptionLetter,
            SP_GenerateLetterPrintBatch.creditCardFailureNotification,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.creditNotes,
            SP_GenerateLetterPrintBatch.packingLabelLetter,
            SP_GenerateLetterPrintBatch.giftPremiumChina,
            SP_GenerateLetterPrintBatch.giftPremiumEnglish
        };
        
        List<Account> accList = TestDataFactory.createAccount(5, 'Direct Corporate');
        accList[0].AccountNumber = 'sample12345';
        insert accList;
        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].Billing_Indicator__c = true;
        conList[0].Recipient_Indicator__c = true;
        insert conList;
        
        parentIdList.add(accList[0].AccountNumber);
        
        accList = [SELECT Id, Name, AccountNumber FROM Account WHERE id IN: accList];
        
        List<Zuora__ZInvoice__c> invList = TestDataFactory.createInvoice(5);
        for(Zuora__ZInvoice__c zInv : invList){
            zInv.Zuora__InvoiceDate__c = Date.Today();
        }
        insert invList;
        
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0; i < 5; i++) {
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Subscriber_Account_Number__c = accList[i].AccountNumber;
            plbList.add(plb);
        }
        insert plbList;
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        insert packageList;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = accList[0].id; 
        billAccountList[0].Zuora__AccountNumber__c = '001122';
        billAccountList[0].Billing_Contact__c = conList[0].Id;
        insert billAccountList; 
        
        List<Credit_Note__c> credNoteList = new List<Credit_Note__c>();
        for(Integer i = 0; i < 5; i++) {
            Credit_Note__c cn = new Credit_Note__c();
            integer cnNum = 8888888 + i;
            cn.Credit_Note_Number__c = string.valueOf(cnNum);
            cn.Billing_Account__c = billAccountList[0].Id;
            cn.Document_Date__c = Date.Today();
            credNoteList.add(cn);
        }
        insert credNoteList;
        
        List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        zsubList[0].Name = 'Ron';
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';        
        zsubList[0].Delivery_Charge__c = 200;
        zsubList[0].Zuora__SubscriptionStartDate__c = date.Today();
        zsubList[0].Zuora__SubscriptionEndDate__c = null;
        zsubList[0].Zuora__TermSettingType__c = 'EVERGREEN';
        insert zsubList; 
        
        List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);
        subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
        subProdCharge[0].PublicationCode__c = 'CD12';
        insert subProdCharge;
        
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(1);
        invoice[0].Zuora__BillingAccount__c = billAccountList[0].id;
        insert invoice;
        
        List<Publication__c> pub = TestDataFactory.createPublication(1);
        pub[0].Publication_Code__c = 'CD12';
        insert pub;
        
        for(Zuora__ZInvoice__c inv : invList) {
            invIdList.add(String.valueOf(inv.id));
        }
        
        for(Zuora__CustomerAccount__c ba : billAccountList) {
            baIdList.add(String.valueOf(ba.id));
        }
        
        for(Zuora__Subscription__c zSub: zSubList){
            subIdList.add(String.valueOf(zSub.id));
        }
        
        String encodedContentsString = 'body';
        
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attachment1 = new Attachment();
        Attachment attachment2 = new Attachment();
        attachment1.Body = Blob.valueOf(encodedContentsString);
        attachment1.Name = String.valueOf('test.txt');
        attachment1.ParentId = accList[0].id;
        attachmentList.add(attachment1);

        attachment2.Body = Blob.valueOf(encodedContentsString);
        attachment2.Name = String.valueOf('test.txt');
        attachment2.ParentId = accList[0].id;
        attachmentList.add(attachment2);
        insert attachmentList;
        
        Test.startTest();
        
        List<String> creditNoteIdList = new List<String>();
        for(Credit_Note__c cn : credNoteList){
            creditNoteIdList.add(cn.Id);
        }
        
        String letterString = SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION;
        
        List<String> letterSubTypelist = new List<String>();
        letterSubTypelist.add(letterString);
        Map<String,List<String>> newmap1 = new Map<String,List<String>>();
        newmap1.put('',letterSubTypelist);
        
        Date fromDate = date.Today();
        Date toDate = date.today()+20;
        Boolean isrecover = true;
        
        SP_PDFGenerator.insertAttachment(baIdList, letterString, newmap1, fromDate, toDate, isrecover);
        
        Test.stopTest();
    }
    //END D-4594 01April2016 Added By C. Lin

 /*   static testMethod void Testtemplate() {
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
        List<String> parentIdList = new List<String>();
        String templateName = '';
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>();
        
        List<String> templateNameList = new List<String>{
            SP_GenerateLetterPrintBatch.overseasNewspaperWrapper,
            'testpdf',
            SP_GenerateLetterPrintBatch.acknowledgmentLetter,
            SP_GenerateLetterPrintBatch.invoiceLetter,
            SP_GenerateLetterPrintBatch.giftLetter,
            SP_GenerateLetterPrintBatch.subscriptionLetter,
            SP_GenerateLetterPrintBatch.giftRenewalLetter,
            SP_GenerateLetterPrintBatch.giftRedemptionLetter,
            SP_GenerateLetterPrintBatch.creditCardFailureNotification,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine,
            SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper,
            SP_GenerateLetterPrintBatch.creditNotes
        };
        
        List<Account> accList = TestDataFactory.createAccount(5, 'Direct Corporate');
        insert accList;
        
        accList = [SELECT Id, Name, AccountNumber FROM Account WHERE id IN: accList];
        
        List<Zuora__ZInvoice__c> invList = TestDataFactory.createInvoice(5);
        insert invList;
        
        List<Credit_Note__c> credNoteList = new List<Credit_Note__c>();
        for(Integer i = 0; i < 5; i++) {
            Credit_Note__c cn = new Credit_Note__c();
            cn.Credit_Note_Number__c = 8888888 + i;
            credNoteList.add(cn);
        }
        insert credNoteList;
        
        List<Packing_Label_Batch__c> plbList = new List<Packing_Label_Batch__c>();
        for(Integer i = 0; i < 5; i++) {
            Packing_Label_Batch__c plb = new Packing_Label_Batch__c();
            plb.Subscriber_Account_Number__c = accList[i].AccountNumber;
            plbList.add(plb);
        }
        insert plbList;
        
        for(Zuora__ZInvoice__c inv : invList) {
            parentIdList.add(String.valueOf(inv.id));
        }
        
        for(Credit_Note__c cn : credNoteList) {
            parentIdList.add(String.valueOf(cn.id));
        }
        
        for(Packing_Label_Batch__c plb : plbList) {
            parentIdList.add(String.valueOf(plb.id));
        }
        
        
        
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        insert packageList;
        
                               
       List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = accList[0].id; 
        billAccountList[0].Zuora__AccountNumber__c = '001122';
        insert billAccountList; 
       
        List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        zsubList[0].Name = 'Ron';
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';        
        zsubList[0].Delivery_Charge__c = 200;
        insert zsubList; 
        
        List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);
        subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
        subProdCharge[0].PublicationCode__c = 'CD1243';
        insert subProdCharge;
        
        
        Test.startTest();
        
       // for(String template : templateNameList) {
           // SP_PDFGenerator.insertAttachment(parentIdList, template, letterSubTypeMap);
      //  }
        
        List<String> letterSubTypelist = new List<String>(5);
        letterSubTypelist[0] = SP_GenerateLetterPrintBatch.overseasNewspaperReportHardCopy;
        letterSubTypelist[1] = SP_GenerateLetterPrintBatch.overseasNewspaperWrapper;
        letterSubTypelist[2] = SP_GenerateLetterPrintBatch.magazineInternalWrapper;
        letterSubTypelist[3] = SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy;
        letterSubTypelist[4] = SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper;
        
       // templateName = SP_GenerateLetterPrintBatch.creditNotes;
        
        if(parentIdList != null && parentIdList.size() > 5) {
            letterSubTypeMap.put(parentIdList[0], letterSubTypelist);
            letterSubTypeMap.put(parentIdList[1], letterSubTypelist);
            letterSubTypeMap.put(parentIdList[2], letterSubTypelist);
            letterSubTypeMap.put(parentIdList[3], letterSubTypelist);
            letterSubTypeMap.put(parentIdList[4], letterSubTypelist);
       
          // SP_PDFGenerator.insertAttachment(parentIdList, templateName, letterSubTypeMap);
            for(String key : letterSubTypeMap.keyset()) {
                SP_PDFGenerator.insertAttachment(parentIdList, templateName, letterSubTypeMap);
            }
       } 
        Test.stopTest();
    }*/
}