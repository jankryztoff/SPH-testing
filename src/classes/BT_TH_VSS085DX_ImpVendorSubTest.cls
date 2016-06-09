/**
* Class Name: BT_TH_VSS085DX_ImpVendorSubTest
* @author: Recuerdo Bregente
* @date: 07/10/2015
* @requirement/Project Name: SPH Project
* @description Batch Apex Class to test BT_TH_VSS085DX_ImportVendorSubscription class. 
* to the Subscriber via Email.
*/
@isTest(seeAllData=True)
private class BT_TH_VSS085DX_ImpVendorSubTest {

    static List<Package__c> pkg;
    static List<Zuora__CustomerAccount__c> zcaList;
    static List<Zuora__Subscription__c> zSubs;
    static List<Zuora__PaymentMethod__c> zpmList;
    static List<Zuora__Payment__c> zuoraPayment;
    static List<Zuora__SubscriptionProductCharge__c> subProdAndCharge;
    static RecordType recType;
    
    // The class to test.
    static BT_TH_VSS085DX_ImportVendorSubscription impVendorSubClass;
    
    // Test Data
    static List<BT_CO_VSS_ImportVendorSubscription__c> impVendorSubObjects;
    static Subscription_Vendor_Publication__c subVendorPub;
    static Subscription_Vendor__c subVendor;
    static List<Singpost_Address__c> postalList;
    static List<Address__c> addressList;
    static Account acc;
    static List<Contact> con;
    static Publication__c publication;
    static String startDate;
    static String endDate;
    
    // Static Data.
    static final String subPostalCode = 'SUB001';
    static final String recepPostalCode = 'REC001';
    static final String vendorNumber = 'VEN01';
    static final String publicationCode = 'P001';
    static final String subCopies = 'TEST';
    static final String subUnit = 'SU001';
    static final String recUnit = 'RU001';
    static final String subLevel = 'SL1';
    static final String recLevel = 'RL1';
    static final String hdsRecId = 'REC00001';
    static final String accNo = 'ACC0001';
    static final String hdsSubId = 'SUB00001';
    static final String vssPubLegacyId = 'VSS|SUB00001';
    static final String hdsContactId = 'CONID001';

    
    /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/10/2015
    */ 
    static void prepareTestData(Integer mainCount, String indicator, String unitData, String levelData){
        // Instantiate class to test.
        impVendorSubClass =  new BT_TH_VSS085DX_ImportVendorSubscription();
        
        // Instantiate Date objects.
        startDate = String.valueOf(Date.Today());
        endDate = String.valueOf(Date.Today().addMonths(1));

        // Create <impVendorSubObjCount> number of BT_CO_VSS_ImportVendorSubscription__c object.
        BT_CO_VSS_ImportVendorSubscription__c impVendorSubObj;
        impVendorSubObjects =  new List<BT_CO_VSS_ImportVendorSubscription__c>();
        
         
        // Create 1 account
        acc = new Account();
        acc.Name = 'Name';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber');
        acc.vendor_code__c = vendorNumber;
        acc.HDS_Recipient_Id__c = hdsRecId;
        acc.AccountNumber = accNo;
        insert acc;
        
        // Create Subscription_Vendor__c object.
        subVendor = new Subscription_Vendor__c();
        subVendor.Account__c = acc.Id;
        subVendor.HDS_Subscription_Id__c = hdsSubId;
        insert subVendor;
        
        // Create publication data.
        publication = TestDataFactory.createPublication(1)[0];
        publication.publication_code__c = publicationCode;
        insert publication;
        
        // Create Subscription_Vendor_Publication__c object.
        subVendorPub = new Subscription_Vendor_Publication__c();
        subVendorPub.Account__c = acc.Id;
        subVendorPub.HDS_Subscription_Id__c = hdsSubId;
        subVendorPub.Subscription_Vendor__c = subVendor.Id;
        subVendorPub.Publication__c = publication.Id;
        //subVendorPub.Vendor_Subscription_Pub_Legacy_Id__c = vssPubLegacyId;
        insert subVendorPub;
        
        // Create Postal object.
        postalList = TestDataFactory.createSingpostAddress(2);
        postalList[0].Name = subPostalCode;
        postalList[1].Name = recepPostalCode;
        insert postalList;
             
          
        // Create Address object.  
        addressList = TestDataFactory.createAddress(2);
        addressList[0].Postal_Code__c = postalList[0].Id;
        addressList[1].Postal_Code__c = postalList[1].Id;
        addressList[0].Unit_Number__c = unitData;
        addressList[0].Level_Number__c = levelData;
        addressList[1].Unit_Number__c = unitData;
        addressList[1].Level_Number__c = levelData;
        insert addressList;
        
        con = TestDataFactory.createContact(1);
        con[0].Phone = '1234567';
        con[0].AccountId = acc.Id;
        con[0].Address__c = addressList[0].Id;
        con[0].Billing_Indicator__c = true;
        con[0].HDS_Contact_Id__c = hdsContactId;
        insert con;
         
        for(Integer count = 1; count <= mainCount; count++) {
            
            if(mainCount == 1) {
                impVendorSubObj = createImportVendorSubObject(indicator);
            }
            else{
                impVendorSubObj = new BT_CO_VSS_ImportVendorSubscription__c();
                
                if(math.mod(count, 4) == 0) {
                    impVendorSubObj.startDate__c = parseDate(String.valueOf(Date.Today().addYears(2026)));
                    impVendorSubObj.stopDate__c = parseDate(String.valueOf(Date.Today().addYears(2027)));
                    impVendorSubObj.subscriptionCopies__c = subCopies;
                    impVendorSubObj.HdsRecipientId__c = hdsRecId;
                }
                else if(math.mod(count, 3) == 0){
                    impVendorSubObj = createImportVendorSubObject(indicator);
                } 
                else if(math.mod(count, 2) == 0){
                    impVendorSubObj.subscriberPostalCode__c = 'TEST01';
                    impVendorSubObj.recipientPostalCode__c = 'TEST01';
                    impVendorSubObj.VendorNumber__c = 'TEST1';
                    impVendorSubObj.publicationCode__c = 'T001';
                }
            }
            
            
            impVendorSubObjects.add(impVendorSubObj);
        }
        
        insert impVendorSubObjects;
    }
    
    
    /**
    * @name: testExecuteIndicatorIsP
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription execute method with P indicator.
    * @date: 07/10/2015
    */
    static testMethod void testExecuteIndicatorIsP(){
        prepareTestData(4, 'P', subUnit, subLevel);
        
        impVendorSubClass.execute(impVendorSubObjects);
        
        System.assertEquals(4, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'P'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: testExecuteIndicatorIsD
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription execute method with D indicator.
    * @date: 07/10/2015
    */
    static testMethod void testExecuteIndicatorIsD(){
        prepareTestData(1, 'D', subUnit, subLevel);
        impVendorSubClass.execute(impVendorSubObjects);
        
        System.assertEquals(1, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'D'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: testExecuteIndicatorIsV
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription execute method with V indicator.
    * @date: 07/10/2015
    */
    static testMethod void testExecuteIndicatorIsV(){
        prepareTestData(1, 'V', subUnit, subLevel);
        impVendorSubClass.execute(impVendorSubObjects);
        
        System.assertEquals(1, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'V'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: testExecuteIndicatorIsR
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription execute method with R indicator.
    * @date: 07/10/2015
    */
    static testMethod void testExecuteIndicatorIsR(){
        prepareTestData(1, 'R', subUnit, subLevel);
        impVendorSubClass.execute(impVendorSubObjects);
        
        System.assertEquals(1, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'R'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: testExecuteWithNoRecepientData
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription execute method with no recepient data.
    * @date: 07/10/2015
    */
    static testMethod void testExecuteWithNoRecepientData(){
        prepareTestData(1, 'U', recUnit, recLevel);
        
        subVendorPub.Vendor_Subscription_Pub_Legacy_Id__c = vssPubLegacyId;
        update subVendorPub;
        
        impVendorSubClass.execute(impVendorSubObjects);
        
        System.assertEquals(1, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'U'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: testExecuteWithNoSubscriberName
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription execute method with no SubscriberName.
    * @date: 07/10/2015
    */
    static testMethod void testExecuteWithNoSubscriberName(){
        prepareTestData(1, 'R', subUnit, subLevel);
        
        impVendorSubObjects[0].subscriberName__c = null;
        update impVendorSubObjects;
        
        impVendorSubClass.execute(impVendorSubObjects);
        
        System.assertEquals(1, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'R'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: testProcessAccountRecords
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription processAccountRecords.
    * @date: 07/10/2015
    */
    static testMethod void testProcessAccountRecords(){
        prepareTestData(1, 'R', subUnit, subLevel);
        
        impVendorSubClass.processAccountRecords(impVendorSubObjects);
        
        System.assertEquals(1, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'R'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: testProcessBillingContactRecords
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription processBillingContactRecords.
    * @date: 07/10/2015
    */
    static testMethod void testProcessBillingContactRecords(){
        prepareTestData(1, 'R', subUnit, subLevel);
        
        impVendorSubClass.execute(impVendorSubObjects);
        
        impVendorSubObjects[0].HdsContactId__c = 'TEST01';
        impVendorSubObjects[0].SubscriberName__c = 'TEST';
        
        impVendorSubClass.processBillingContactRecords(impVendorSubObjects);
        
        System.assertEquals(1, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'R'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: testProcessRecipientContactRecords
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_TH_VSS085DX_ImportVendorSubscription processRecipientContactRecords.
    * @date: 07/10/2015
    */
    static testMethod void testProcessRecipientContactRecords(){
        prepareTestData(1, 'R', subUnit, subLevel);
        
        impVendorSubClass.execute(impVendorSubObjects);
        
        impVendorSubObjects[0].HdsContactId__c = 'TEST01';
        impVendorSubObjects[0].RecipientName__c = 'TEST';
        
        impVendorSubClass.processRecipientContactRecords(impVendorSubObjects);
        
        System.assertEquals(1, impVendorSubObjects.size());
        boolean foundIndicator = false;
        for(BT_CO_VSS_ImportVendorSubscription__c impVenSubObj : impVendorSubObjects) {
            if(impVenSubObj.subscriptionUpdateIndicator__c ==  'R'){
                foundIndicator = true;
                break;
            }
        }
        
        System.assertEquals(true, foundIndicator);
    }
    
    /**
    * @name: parseDate
    * @author : Recuerdo Bregente
    * @description : Handles the parsing of date values.
    * @date: 07/10/2015
    */
    static String parseDate(String dateParam) {
        String[] dateValues = dateParam.split('-');
        String year = '';
        String month = '';
        String day = '';
        for(Integer index = 0; index < dateValues.size(); index++) {
            if(index == 0) {
                year = dateValues[index];
            }
            else if(index == 1) {
                month = dateValues[index];
            }
            else if(index == 2) {
                day = dateValues[index];
            }
        }
        
        return day+'.'+month+'.'+year;
    }
    
    /**
    * @name: createImportVendorSubObject
    * @author : Recuerdo Bregente
    * @description : Method to create BT_CO_VSS_ImportVendorSubscription__c object.
    * @date: 07/10/2015
    */
    static BT_CO_VSS_ImportVendorSubscription__c createImportVendorSubObject(String indicator) {
        BT_CO_VSS_ImportVendorSubscription__c obj = new BT_CO_VSS_ImportVendorSubscription__c();
        obj.subscriberPostalCode__c = subPostalCode;
        obj.recipientPostalCode__c = recepPostalCode;
        obj.hdsRecipientId__c = hdsRecId;
        obj.hdsContactId__c = 'CON00001';
        obj.hdsSubscriptionId__c = hdsSubId;
        obj.vendorGroup__c = '1';
        obj.VendorNumber__c = vendorNumber;
        obj.publicationCode__c = publicationCode;
        obj.subscriptionCopies__c = '100000000000000000000000000';
        obj.startDate__c = parseDate(startDate);
        obj.stopDate__c = parseDate(endDate);
        obj.subscriberName__c = 'Name';
        obj.subscriberUnit__c = subUnit;
        obj.SubscriberLevel__c = subLevel;
        obj.recipientUnit__c = recUnit;
        obj.RecipientLevel__c = recLevel;
        obj.subscriptionUpdateIndicator__c = indicator;
        obj.SubscriberUpdateIndicator__c = 'U';
        obj.CrsmAccountId__c = accNo;
        obj.HdsContactId__c = hdsContactId;
        obj.RecipientName__c = 'RName';
        
        return obj;
    }
 }