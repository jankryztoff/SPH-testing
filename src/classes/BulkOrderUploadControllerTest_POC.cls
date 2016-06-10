/**
Class Name: BulkOrderUploadControllerTest
@author: Flores, Emmanuel D.
@Date: 10/16/2015
@Project/Requirement: SPH 
@description This class is test class for BulkOrderUploadController
**/
@isTest (Seealldata = true)
private class BulkOrderUploadControllerTest_POC {

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

    static User createUser() {
        UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
                       EmailEncodingKey='UTF-8', LastName='Testing123', 
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                       ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
                       UserName='standardCL07@test.com', Title='Testing123');
        
        insert usr;

        return usr;
    }

    static testmethod void unitTest1() {
        User testUser = createUser();
         
        System.runAs(testUser) {
        
             Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
         postal.Name = '123';
         postal.Name = '100044';
         postal.House_Block_Number__c = '1';
         postal.Address_Type__c = 'A';
         insert postal;
         
         Country__c co = new Country__c();
         co.Code__c =  'TestCountry';
         co.Country_Name__c = 'TestCountry';
        insert co;
         Test.startTest();
         Address__c addressRec = TestDataFactory.createAddress(1)[0];
         addressRec.Address_Type__c = 'A';
         addressRec.Postal_Code__c = postal.Id;
         addressRec.Block_House_Number__c ='TEST';
         addressRec.Level_Number__c ='xx';
         addressRec.Unit_Number__c = 'yy';
         addressRec.Country__c = co.Id;
         addressRec.Address_1__c = 'address1';
         addressRec.Address_2__c = 'address2';
         addressRec.Address_3__c = 'address3';
         addressRec.Address_4__c = 'address4';
         addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
         insert addressRec;
         
         Account acc = new Account(); 
         acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
         acc.Name = 'Bulk Upload Test 1';
         acc.Email__c = 'sample@sph.com';
         acc.Acknowledgement_Letter__c = 'Email';
         acc.Renewal_Letter__c = 'Hard Copy';
         acc.Airline_Indicator__c = false;
         acc.AccountNumber = '1234567';
         insert acc;
         System.debug('account beforeinserted' + acc);
         System.debug('Query result ' + [Select Id, AccountNumber from Account Where Id = :acc.Id]);
         Contact con = TestDataFactory.createContact(1)[0];
         con.FirstName = 'Water';
         con.LastName = 'Monkey';
         con.Billing_Account_Name_2__c = 'Bulk Upload Test 1';
         con.Address__c = addressRec.Id;
         con.AccountId = acc.Id;
         con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
         con.Email__c = 'sample@sph.com';
         con.HomePhone__c = '9999222';
         insert con; 
         
         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
         billAcc.Name = 'sample123';
         billAcc.Zuora__Account__c = acc.id;
         billAcc.Billing_Contact__c = con.Id;
         billAcc.Billing_Type__c = 'Full Prepaid';
         billAcc.Zuora__DefaultPaymentMethod__c = 'Cash';
         billAcc.Zuora__AccountNumber__c = '555555';
         insert billAcc;    
         System.debug('Billing account beforeinserted' + billAcc.Zuora__AccountNumber__c);
       
         
                 
         String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
         String stringVal2 = '1234567,555555,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,12345,12345,, francis.m.b.benzon@accenture.com,,,,,,,,Email,Hard Copy,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,1234,,,,,,francis.m.b.benzon@accenture.com,,Local,100044,33,33,,,,,,,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,9999222,,,,,,francis.m.b.benzon@accenture.com,,Local,100044,33,33,,,,,,,,,,,,,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,BeritaHarianPrintDaily--MthlyPrepaid25%Discount12Mths,,,,,1,Vendor,';
                 
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'BulkOrderUploadTemplate.csv';
         Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
         doc.body = bodyBlob;
         doc.Type = 'csv';
         doc.ContentType = 'text/csv';
         insert doc;
         
         BulkOrderUploadController bulkorder = new BulkOrderUploadController();
         bulkorder.orderFile = doc;
         bulkorder.verifyDocument();  
         bulkorder.processDocument();
         bulkorder.cancel();
         //bulkorder.testCoveragePatch();
         
         BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
         bulkorder2.orderFile = NULL;
         bulkorder2.verifyDocument();
         Test.stopTest();
         }
        
     }

     
     static testmethod void unitTest2() {
        User testUser = createUser();
         
        System.runAs(testUser) {
         Test.startTest();
         String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
         String stringVal2 = ',,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,12345,12345,, francis.m.b.benzon@accenture.com,,,,,,,,Email,Hard Copy,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,1234,,,,,,francis.m.b.benzon@accenture.com,,Local,100044,33,33,,,,,,,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,9999222,,,,,,francis.m.b.benzon@accenture.com,,Local,100044,33,33,,,,,,,,,,,,,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,BeritaHarianPrintDaily--MthlyPrepaid25%Discount12Mths,,,,,1,Vendor,';
                 
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'BulkOrderUploadTemplate.csv';
         Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
         doc.body = bodyBlob;
         doc.Type = 'csv';
         doc.ContentType = 'text/csv';
         insert doc;
         
         BulkOrderUploadController bulkorder = new BulkOrderUploadController();
         bulkorder.orderFile = doc;
         bulkorder.verifyDocument();         
         bulkorder.processDocument();
         bulkorder.retrieveReferenceDoc();
         bulkorder.cancel();
         //bulkorder.testCoveragePatch();
         
         BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
         bulkorder2.orderFile = NULL;
         bulkorder2.verifyDocument();
         Test.stopTest();
         
         }
        
     }
     
     static testmethod void unitTest3() {
        User testUser = createUser();
         
        System.runAs(testUser) {
         Test.startTest();
         String stringVal1 = 'AccountNumber,BillingAccountNumber,AccountRecordType,AccountName,DateSince,AccountDateOfBirth,Designation,AccountNRIC,Passport,AccountGender,ContactPerson,AttentionSeekingSubs,AttentionToCareOfIndicator,AttentionToCareOfSalutation,AttentionToCareOf,SubGroup,VipStaffHomePhone,VipStaffMobilePhone,VipStaffEmail,AccountEmail,EmailSecondary,Education,Language,Race,GstOutOfScope,GstInvoice,CreditAlert,AcknowledgementLetter,RenewalLetter,SmsRenewalNotification,VendorCommunicationPreference,EshopRefNo,AirlineIndicator,StaffId,UniqueEntityNumber,IncomeRange,RCSalutation,RCFirstName,RCLastName,RCNRIC,RCPassport,RCAttnToName,RCAccountName2,RCBusinessAddressIndicator,RCHomeNumber,RCFax,RCMobileNumber,RCMobileNumber2,RCOfficeNumber,RCOfficeExtension,RCEmail,RCEmailSecondary,RCAddressRecordType,RCPostalCode,RCLevelNumber,RCUnitNumber,RCCountryCode,RCAddress1,RCAddress2,RCAddress3,RCAddress4,RCCompanyCode,RCDepartmentCode,RCDivisionCode,RCLocationCode,RCSectionCode,RCPackingCode,RCCityCode,RCAdditionalInfo,BCSalutation,BCFirstName,BCLastName,BCNRIC,BCPassport,BCAttnToName,BCAccountName2,BCBusinessAddressIndicator,BCHomeNumber,BCFax,BCMobileNumber,BCMobileNumber2,BCOfficeNumber,BCOfficeExtension,BCEmail,BCEmailSecondary,BCAddressRecordType,BCPostalCode,BCLevelNumber,BCUnitNumber,BCCountryCode,BCAddress1,BCAddress2,BCAddress3,BCAddress4,BCCompanyCode,BCDepartmentCode,BCDivisionCode,BCLocationCode,BCSectionCode,BCPackingCode,BCCityCode,BCAdditionalInfo,Payment Mode,OtherPaymentMode,ArmsCustomerNumber,ArmsAccountNumber,ArmsBusinessProfile,ArmsDebtManagementTreatment,CashAmountPaid,CheckAmount,CheckDated,CheckIssuingBank,CheckNumber,CheckRemarks,CostCentre,CreditCardAddress1,CreditCardCity,CreditCardCountry,CreditCardCVV,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardNumber,CreditCardType,DeliveryAmount,DeliveryChargeType,GlCode,Sponsor,VendorSmsRemark,SuppressAcknoweledgementLetter,SuppressRenewalAndReminderLetter,SuppressVendorNotification,GenerateInvoice,AutoRenew,PromotionCode,PackageCode,AddonPackageCode,GiftCodes,StartDate,NewContractPeriod,Quantity,DeliveredBy,MailingAgentCode';
         String stringVal2 = ',,Direct Individual,Bulk Upload Test 1,,,,,,,,,,,,,12345,12345,, francis.m.b.benzon@accenture.com,,,,,,,,Email,Hard Copy,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,1234,,,,,,francis.m.b.benzon@accenture.com,,Local,100044,33,33,,,,,,,,,,,,,,,Water,Monkey,,,,Bulk Upload Test 1,,9999222,,,,,,francis.m.b.benzon@accenture.com,,Local,100044,33,33,,,,,,,,,,,,,,Other,External Parties,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,2014HWJanPromo24Mths,HerWorldSingapore24Mths,,,,,1,Vendor,';
                 
         Document doc = new Document();
         doc.FolderId = UserInfo.getUserId();
         doc.Name = 'BulkOrderUploadTemplate.csv';
         Blob bodyBlob = Blob.valueOf(stringVal1 + '\n' + stringVal2);
         doc.body = bodyBlob;
         doc.Type = 'csv';
         doc.ContentType = 'text/csv';
         insert doc;
         
         BulkOrderUploadController bulkorder = new BulkOrderUploadController();
         bulkorder.orderFile = doc;
         bulkorder.verifyDocument();         
         bulkorder.processDocument();
         bulkorder.retrieveReferenceDoc();
         bulkorder.cancel();
         //bulkorder.testCoveragePatch();
         
         BulkOrderUploadController bulkorder2 = new BulkOrderUploadController();
         bulkorder2.orderFile = NULL;
         bulkorder2.verifyDocument();
         Test.stopTest();
         
         }
        
     }
 }