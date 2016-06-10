@isTest(seeAllData = false)
public class SP_VendorNotificationsBatchTest2{

    /**
     **Prepare Data START
     **/
    //Singpost_Address__c
    static Singpost_Address__c createSingpostAddress01() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Street_Name__c = '123';
        postal.Building_Name__c = 'abc'; 
        insert postal;
        return postal;
    }    
    
    //create Account
    static List<Account> createAccount01() {
        List<Account> accList = TestDataFactory.createAccount(4, 'Vendor');
        RecordType rec = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Vendor'];
        for(Account acc : accList) {
            acc.RecordTypeId = rec.Id;
            acc.NRIC__c = 'T1234567R';
            acc.Handphone_Number__c = '12345';
            acc.Email__c = 'test@gmail.com';
        }
        accList[0].Vendor_Communication_Preference__c = 'Both';
        accList[1].Vendor_Communication_Preference__c = 'Email';
        accList[2].Vendor_Communication_Preference__c = 'SMS';
        accList[3].Vendor_Communication_Preference__c = 'Email';
        insert accList;
        return accList;
    }
    
    
    //create Package  
    static Package__c createPackage01() {  
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        insert pack;
        return pack;
    }
    
    //zqu__ZProduct__c
    static zqu__ZProduct__c createZQUZProduct01() {
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        return zProduct;
    }
        
    //zqu__ProductRatePlan__c
    static zqu__ProductRatePlan__c createZQUProductRatePlan01(zqu__ZProduct__c zProduct) {
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        return prdRatePlan;
    }
        
    //zqu__ProductRatePlanCharge__c
    static zqu__ProductRatePlanCharge__c createZQUProductRatePlanCharge01(zqu__ProductRatePlan__c prdRatePlan) {
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        return prpc;
    }
        
    //Package_Item__c
    static List<Package_Item__c> createPackageItem01(Package__c pack, zqu__ProductRatePlan__c prdRatePlan) {
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(2, 'Base Product');
        for (Package_Item__c pItem : pItems) {
             pItem.Package__c = pack.Id;
             pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        }
        insert pItems;
        return pItems;
    }
    
    //create Billing Account
    static List<Zuora__CustomerAccount__c> createZuoraCustomerAccount01(List<Account> accList) {
        List<Zuora__CustomerAccount__c> billAccList = TestDataFactory.createBillingAccount(4);
        billAccList[0].Zuora__Account__c = accList[0].Id;
        billAccList[1].Zuora__Account__c = accList[1].Id;
        billAccList[2].Zuora__Account__c = accList[2].Id;
        billAccList[3].Zuora__Account__c = accList[3].Id;
        insert billAccList;
        return billAccList;
    }
    
    //create Address
    static Address__c createAddress01(Singpost_Address__c postal) {
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;        
        addressRec.Block_House_Number__c = '23'; 
        addressRec.Level_Number__c = '32'; 
        addressRec.Unit_Number__c = '23'; 
        insert addressRec;
        return addressRec;
    }
    
    //create Contact
    static List<Contact> createContact01(Address__c addressRec, List<Account> accList) {
        List<Contact> conList = TestDataFactory.createContact(4);
        RecordType reccon = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Vendor Staff'];
        for(Contact con : conList) {    
            con.RecordTypeId = reccon.Id;
            con.Address__c = addressRec.Id;
            con.HomePhone__c = '123456';
            con.Active__c = true;
            con.Email = 'test@test.com';
            // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
        }
        conList[0].AccountId = accList[0].Id;
        conList[0].Vendor_Communication_Preference__c = 'SMS';
        conList[1].AccountId = accList[1].Id;
        conList[1].Vendor_Communication_Preference__c = 'Email';
        conList[2].AccountId = accList[2].Id;
        conList[2].Vendor_Communication_Preference__c = 'SMS';
        conList[3].AccountId = accList[3].Id;
        conList[3].Vendor_Communication_Preference__c = 'Email';
        insert conList;
        return conList;
    }
    
    //create Order
    static List<Order__c> createOrder01(List<Account> accList, List<Contact> conList) {
        List<Order__c> orderRecList = TestDataFactory.createOrder(4);
        for(Order__c orderRec : orderRecList) {
            orderRec.Informed_Customer__c = TRUE;
        }
        orderRecList[0].Account__c = accList[0].Id;
        orderRecList[0].Recipient_Contact__c = conList[0].Id;
        orderRecList[1].Account__c = accList[1].Id;
        orderRecList[1].Recipient_Contact__c = conList[1].Id;
        orderRecList[2].Account__c = accList[2].Id;
        orderRecList[2].Recipient_Contact__c = conList[2].Id;
        orderRecList[3].Account__c = accList[3].Id;
        orderRecList[3].Recipient_Contact__c = conList[3].Id;
        insert orderRecList;
        return orderRecList;
    }
    
    //create Case
    static List<Case> createCase01(List<Account> accList, List<Order__c> orderRecList, List<Contact> conList, List<Temp_Stop__c> tempStopList, List<Zuora__Subscription__c> subRecList) { 
        /*FROM Case WHERE 
        account.recordtype.name != \'Vendor Subscriber\' AND  
        ClosedDate = LAST_N_DAYS:30*/
        List<Case> cList = TestDataFactory.createCase(4, 'Complaint - Magazine'); 
        
        RecordType recase = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case' AND Name = 'Change of Address/Vendor']; 
        
        //[0]
        /*From Case 
            Where AccountId IN :tempStopWithCOA_MAP.values() AND 
            RecordTypeId = :ConstantsSLB.getKeyId('Case_Change in Address') AND 
            Effective_Date__c >= TODAY AND 
            Sub_Status__c != :GlobalVariableClass.SUB_STATUS_WAITING_FOR_COA_APPROVAL AND 
            Sub_Status__c != :GlobalVariableClass.SUB_STATUS_COA_REJECTED AND 
            (Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR OR Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD)];*/
        for(Case c : cList) {
            c.RecordTypeId = recase.Id;       
            c.Remarks__c = 'Remarks';
            c.Restart_Date__c = date.Today()+1;        
            c.Effective_Date__c = date.Today()+1; 
            c.Sub_Status__c = 'Case Created';  
            c.AccountId = accList[1].Id;
            c.Account = accList[1];            //TODO Added
            c.Order__c = orderRecList[0].Id;
            c.COA__c = true;
            //c.Subscription_Name__c = subRec.Id;
            c.CSO_Remarks__c = 'Test';
            //c.Temp_Stop__c = tempStopRecord.Id;
            c.Subject = '[SP_VendorNotificationsBatchTest] TEST_CLASS';
            c.Status = 'Closed';
            //c.Change_of_Address_Type__c = 'Change of Vendor';
            c.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
            c.Contact_To_Update__c = conList[1].Id;
            c.Vendor__c = accList[0].Id;
            c.Temp_Stop_Sub__c = subRecList[0].id;
        }
        //[1]
        /*caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && 
        (caseObj.Temp_Stop__r.Restart_Date__c == Date.today()+1 || caseObj.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1) && 
        caseObj.COA__c == true*/
        recase = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case' AND Name = 'Temp Stop Subscription']; 
        cList[1].RecordTypeId = recase.id;
        cList[1].Temp_Stop__c = tempStopList[0].Id;
        cList[1].Temp_Stop_Date__c = Date.today().addDays(-5);
        cList[1].Restart_Date__c = Date.today()+1;
        cList[1].Change_of_Address_Type__c = 'Change of Vendor';
        cList[1].Contact_To_Update__c = conList[0].Id;
        cList[1].Vendor__c = accList[0].Id;
        cList[1].COA__c = true;
        cList[1].AccountId = accList[1].Id;
        cList[1].Contact_To_Update__c = conList[1].Id;
        cList[1].Vendor__c = accList[1].Id;
        
        //[2]        
        /*From Case Where 
        AccountId IN :tempStopWithCOA_MAP.values() AND 
        RecordTypeId = :ConstantsSLB.getKeyId('Case_Change in Address') AND 
        Effective_Date__c >= TODAY AND 
        Sub_Status__c != :GlobalVariableClass.SUB_STATUS_WAITING_FOR_COA_APPROVAL AND 
        Sub_Status__c != :GlobalVariableClass.SUB_STATUS_COA_REJECTED AND 
        (Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR OR Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD)];*/
        cList[2].Change_of_Address_Type__c = 'Change of Vendor';
        cList[2].AccountId = accList[2].Id;
        cList[2].Contact_To_Update__c = conList[2].Id;
        cList[2].Vendor__c = accList[2].Id;
        
        cList[3].Change_of_Address_Type__c = 'Change of Vendor';
        cList[3].AccountId = accList[3].Id;
        cList[3].Contact_To_Update__c = conList[3].Id;
        cList[3].Vendor__c = accList[3].Id;
        
        insert cList;
        return cList;
    }
    
    //create Zuora__Subscription__c
    static List<Zuora__Subscription__c> createZuoraSubscription01(List<Account> accList, List<Zuora__CustomerAccount__c> billAccList, List<Contact> conList, Package__c pack, List<Order__c> orderRecList) {
        List<Zuora__Subscription__c> subRecList = TestDataFactory.createSubscription(4);
        for(Zuora__Subscription__c subRec : subRecList) {
            subRec.Zuora__Account__c = accList[0].Id;
            subRec.Number_of_Copies1__c = '2';
            subrec.Zuora__CustomerAccount__c = billAccList[0].Id;
            subRec.Zuora__SubscriptionEndDate__c = date.Today().addDays(100); 
            subRec.Subscriber_Contact__c = conList[0].Id; 
            subRec.Recipient_Contact__c = conList[0].Id; 
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Status__c = 'Active'; 
            subRec.Subscription_Type_1__c = 'Publication'; 
            subRec.Order_Number__c = orderRecList[0].Id;
            subRec.Frequency_1__c = GlobalVariableClass.FREQUENCY_FRISUN; 
            subRec.Zuora__SubscriptionEndDate__c = null;
            //subRec.Suppress_Vendor_Start_Notice__c = 'false';
            //subRec.Supressed_Acknowledgement_Letter__c = 'false';
            //subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false'; 
            //subRec.Urgent__c = 'false';
            //subRec.Vendor_Conversion__c = 'false';
            //subRec.Charity__c = 'false';
        }       
        subRecList[1].Zuora__Account__c = accList[1].Id;
        subRecList[1].Zuora__CustomerAccount__c = billAccList[1].Id;
        subRecList[1].Subscriber_Contact__c = conList[1].Id; 
        subRecList[1].Recipient_Contact__c = conList[1].Id; 
        subRecList[1].Order_Number__c = orderRecList[1].Id;
        
        subRecList[2].Zuora__Account__c = accList[2].Id;
        subRecList[2].Zuora__CustomerAccount__c = billAccList[2].Id;
        subRecList[2].Subscriber_Contact__c = conList[2].Id; 
        subRecList[2].Recipient_Contact__c = conList[2].Id; 
        subRecList[2].Order_Number__c = orderRecList[2].Id;
        
        subRecList[3].Zuora__Account__c = accList[3].Id;
        subRecList[3].Zuora__CustomerAccount__c = billAccList[3].Id;
        subRecList[3].Subscriber_Contact__c = conList[3].Id; 
        subRecList[3].Recipient_Contact__c = conList[3].Id; 
        subRecList[3].Order_Number__c = orderRecList[3].Id;
        
        insert subRecList;
        return subRecList;
    }
    
    //static List<Temp_Stop__c> createTempStop01(Order__c orderRec, List<Case> cList) {
    static List<Temp_Stop__c> createTempStop01(List<Order__c> orderRecList) {
        List<Temp_Stop__c> tempStopList = TestDataFactory.createTempStop(4);
        for(Temp_Stop__c obj : tempStopList) {
            obj.Temp_Stop_Date__c = Date.today();
            obj.Restart_Date__c = Date.today()+1;
            obj.Order__c = orderRecList[0].Id;
//            obj.Case__c = cList[0].Id;
        }
        tempStopList[1].Order__c = orderRecList[1].Id;
        tempStopList[2].Order__c = orderRecList[2].Id;
        tempStopList[3].Order__c = orderRecList[3].Id;
        Database.insert(tempStopList);
        return tempStopList;
    }
    
    static void updateTempStopCase01(List<Temp_Stop__c> tsList, List<Case> cList) {
        for(Integer i=0; i<tsList.size(); i++) {
            tsList[i].Case__c = cList[i].id;
        }
        Database.update(tsList);
    }
    
    
    //create Order Line Item
    static List<Order_Line_Item__c> createOrderLineItem01(List<Order__c> orderRecList, List<Zuora__Subscription__c> subRecList, Package__c pack) {
        
        List<Order_Line_Item__c> orderlineList = TestDataFactory.createOrderLineItem(4);
        for(Order_Line_Item__c orderline : orderlineList) {
            orderline.Stop_Request_Date__c = date.Today().addDays(1);
            orderline.End_Date__c = date.Today().addDays(5);
            orderline.Main_Package_ID__c = pack.Id;
        }
        orderlineList[0].Order__c = orderRecList[0].Id;
        orderlineList[0].Subscription__c = subRecList[0].Id;
        
        orderlineList[1].Order__c = orderRecList[1].Id;
        orderlineList[1].Subscription__c = subRecList[1].Id;
        
        orderlineList[2].Order__c = orderRecList[2].Id;
        orderlineList[2].Subscription__c = subRecList[2].Id;
        
        orderlineList[3].Order__c = orderRecList[3].Id;
        orderlineList[3].Subscription__c = subRecList[3].Id;
        
        Database.insert(orderlineList);
        return orderlineList;
    }
    
    //create Zuora__SubscriptionProductCharge__c
    static List<Zuora__SubscriptionProductCharge__c> createZuoraSubscriptionProductCharge01(List<Zuora__Subscription__c> subRecList) {
        List<Zuora__SubscriptionProductCharge__c> zSubList = TestDataFactory.createSubProductCharge(4);
        zSubList[0].Zuora__Subscription__c = subRecList[0].Id;
        zSubList[1].Zuora__Subscription__c = subRecList[1].Id;
        zSubList[2].Zuora__Subscription__c = subRecList[2].Id;
        zSubList[3].Zuora__Subscription__c = subRecList[3].Id;
        //zSub.Case__c = c.Id;
        Database.insert(zSubList);
        return zSubList;
    }
    
    //-From Case_Subscription__c Where Case__c IN :coaCase_SET
    //create Case_Subscription__c
    static List<Case_Subscription__c> createCaseSubscription01(List<Case> cList, List<Account> accList, List<Zuora__Subscription__c> subRecList) {
        List<Case_Subscription__c> csList = TestDataFactory.createCaseSubscription(4);
        
            csList[0].Case__c = cList[0].Id;
            csList[0].Account__c = accList[0].Id;
            csList[0].Subscription__c = subRecList[0].Id;
        
            csList[1].Case__c = cList[1].Id;
            csList[1].Account__c = accList[1].Id;
            csList[1].Subscription__c = subRecList[1].Id;
        
            csList[2].Case__c = cList[2].Id;
            csList[2].Account__c = accList[2].Id;
            csList[2].Subscription__c = subRecList[2].Id;
        
            csList[3].Case__c = cList[3].Id;
            csList[3].Account__c = accList[3].Id;
            csList[3].Subscription__c = subRecList[3].Id;
        
        Database.insert(csList);
        return csList;
    }
    
    //Subscription_Vendor__c
    static List<Subscription_Vendor__c> createSubscriptionVendor01(List<Account> accList) {
        List<Subscription_Vendor__c> subVenList = TestDataFactory.createSubscriptionVendor(4);
        for(Subscription_Vendor__c subVen : subVenList) {
            subVen.Legacy_Create_By__c = 'sample';
            subVen.Legacy_Create_Date__c = 'July 7, 2015';
            subVen.Legacy_Update_By__c = 'test';
            subVen.Legacy_Update_Date__c = 'July 30, 2015';
        }
        
        subVenList[0].Account__c = accList[0].Id;
        
        subVenList[1].Account__c = accList[1].Id;
        
        subVenList[2].Account__c = accList[2].Id;
        
        subVenList[3].Account__c = accList[3].Id;
        
        Database.insert(subVenList);
        return subVenList;
    }
    
    //Address_Assignment__c
    static List<Address_Assignment__c> createAddressAssignment01(List<Zuora__Subscription__c> subRecList, List<Account> accList, List<Case> cList, List<Contact> conList, 
            List<Subscription_Vendor__c> subVenList, Address__c addressRec) {
    
        List<Address_Assignment__c> adasList = new List<Address_Assignment__c>();
            
        Address_Assignment__c Adas = new Address_Assignment__c();
        Adas.Effective_Date__c = date.Today();
        Adas.Address__c = addressRec.Id;
        adasList.add(Adas); 
        Adas = new Address_Assignment__c();
        Adas.Effective_Date__c = date.Today();
        Adas.Address__c = addressRec.Id;
        adasList.add(Adas);
        Adas = new Address_Assignment__c();
        Adas.Effective_Date__c = date.Today();
        Adas.Address__c = addressRec.Id;
        adasList.add(Adas);
        Adas = new Address_Assignment__c();
        Adas.Effective_Date__c = date.Today();
        Adas.Address__c = addressRec.Id;
        adasList.add(Adas); 
        
        
        adasList[0].Subscription__c = subRecList[0].Id; 
        adasList[0].Vendor__c = accList[0].Id;
        adasList[0].Case__c = cList[0].id;
        adasList[0].Contact_ID__c = conList[0].Id;
        adasList[0].Subscription_Vendor__c = subVenList[0].id;
        adasList[0].Contact__c = conList[0].Id;    
        
        adasList[1].Subscription__c = subRecList[1].Id; 
        adasList[1].Vendor__c = accList[1].Id;
        adasList[1].Case__c = cList[1].id;
        adasList[1].Contact_ID__c = conList[1].Id;
        adasList[1].Subscription_Vendor__c = subVenList[1].id;
        adasList[1].Contact__c = conList[1].Id;  
        
        adasList[2].Subscription__c = subRecList[2].Id; 
        adasList[2].Vendor__c = accList[2].Id;
        adasList[2].Case__c = cList[2].id;
        adasList[2].Contact_ID__c = conList[2].Id;
        adasList[2].Subscription_Vendor__c = subVenList[2].id;
        adasList[2].Contact__c = conList[2].Id;  
        
        adasList[3].Subscription__c = subRecList[3].Id; 
        adasList[3].Vendor__c = accList[3].Id;
        adasList[3].Case__c = cList[3].id;
        adasList[3].Contact_ID__c = conList[3].Id;
        adasList[3].Subscription_Vendor__c = subVenList[3].id;
        adasList[3].Contact__c = conList[3].Id;      
        
        Database.insert(adasList);
        
        return adasList;
    }
    
    //-pubList
    /*FROM Publication__c Where (Sunday_Publication__c <> '' AND Has_Sunday_Pub__c = true) OR 
       (Platform_Type__c='Print' AND Published_Days__c = 'YYYYYYY' AND Publish_Pattern__c = null AND Has_Sunday_Pub__c = false)];*/
    //-noSunPubList
    //FROM Publication__c Where Has_Sunday_Pub__c = false
    //create Publication__c
    static Publication__c createPublication01() {
    
        //Sunday_Publication__c 
        Publication__c sundayPub = TestDataFactory.createPublication(1)[0];
        sundayPub.Published_Days__c = 'YYYYYYN';
        sundayPub.Publication_Type__c = 'N';
        insert sundayPub;
    
        Publication__c thisPub = TestDataFactory.createPublication(1)[0];
        thisPub.Platform_Type__c = 'Print';
        thisPub.Published_Days__c = 'YYYYYYY';
        thisPub.Publish_Pattern__c = null;
        //thisPub.Has_Sunday_Pub__c = false;
        Database.insert(thisPub);
        return thisPub;
    }
    
    /**************************
     **    Custom Settings   **
     **************************/
    
    //Custom Settings - Key_Id__c
    public static List<Key_Id__c> createKeyIds() {
    
        //-ConstantsSLB.getKeyId('Case_Change in Address')
        RecordType caseRecordTypeChangeInAddressVendor = [SELECT Id, Name, SObjectType FROM RecordType WHERE SObjectType='Case' AND Name='Change of Address/Vendor'];
        //-ConstantsSLB.getKeyId('Case_Temp Stop')
        RecordType caseRecordTypeTempStop = [SELECT Id, Name, SObjectType FROM RecordType WHERE SObjectType='Case'  AND Name='Temp Stop Subscription'];
    
        List<Key_Id__c> keyIdList = new List<Key_Id__c>{
            new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER',Id__c = '123462697',Type__c = 'Number'),
            new Key_Id__c(Name = 'Vendor Rep Role', Id__c = '123462697',Type__c = 'Number'),
            new Key_Id__c(Name = 'Case_Change in Address', Id__c = caseRecordTypeChangeInAddressVendor.id, Type__c = 'Number'),
            new Key_Id__c(Name = 'Case_Temp Stop', Id__c = caseRecordTypeTempStop.id, Type__c = 'Number')
         //,new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER',Id__c = '123462697',Type__c = 'Number')
        };
        //keyIdList[0].Name = 'NEXT_RECIPIENT_NUMBER';
        //KeyIdList[0].Id__c = '123462697';
        //KeyIdList[0].Type__c = 'Number';
        return keyIdList;
    }
    
    //Custom Settings - Cir_Planner_Schedule__c
    public static List<Cir_Planner_Schedule__c> createCirPlannerSchedule() {
        List<Cir_Planner_Schedule__c> objList = new List<Cir_Planner_Schedule__c>{
            new Cir_Planner_Schedule__c(Name = 'CIR Plan Schedule',
                Mon_Fri_End_Time__c = Date.today(), Mon_Fri_Start_Time__c = Date.today(), 
                Sat_PH_End_Time__c = Date.today(), Sat_PH_Start_Time__c = Date.today(), 
                Sun_End_Time__c = Date.today(), Sun_Start_Time__c = Date.today()
            )
        };
        return objList;
    }
    
    //Custom Settings - Other__c
    public static List<Other__c> createOther() {
        List<Other__c> objList = new List<Other__c>{
            new Other__c(Name = 'DTL', Value__c='23:59'
            )
        };
        return objList;
    }
    
    //Custom Settings - Batch_Configuration_Settings__c
    public static List<Batch_Configuration_Settings__c> createBatchConfigSettings() {
        List<Batch_Configuration_Settings__c> objList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name = 'SP_VendorNotificationsBatch', Batch_Size__c = 200,
                Max_Retries__c=10, Notification_Recipients__c = '123456789', Number_Of_Days_To_Retrieve__c=30)
        };
        return objList;
    }
    /*Prepare Data END*/


    static testMethod void testMethod01() {
    
        User u = TestDataFactory.prepareTestusers('System Administrator');
        
        System.runAs(u){
        
            //Test Data
            List<Key_Id__c> keyIds = createKeyIds();
            Database.insert(keyIds);
            List<Cir_Planner_Schedule__c> cirPSs = createCirPlannerSchedule();
            Database.insert(cirPSs);
            List<Other__c> others = createOther();
            Database.insert(others);
            List<Batch_Configuration_Settings__c> createBatchConfigSettings = createBatchConfigSettings();
            Database.insert(createBatchConfigSettings);
            
            
            Singpost_Address__c postal = createSingpostAddress01() ;
            List<Account> accList = createAccount01();
            Package__c pack = createPackage01();
            zqu__ZProduct__c zProduct = createZQUZProduct01();
            zqu__ProductRatePlan__c prdRatePlan = createZQUProductRatePlan01(zProduct);
            zqu__ProductRatePlanCharge__c prpc = createZQUProductRatePlanCharge01(prdRatePlan);
            List<Package_Item__c> pItems = createPackageItem01(pack, prdRatePlan) ;
            List<Zuora__CustomerAccount__c> billAccList = createZuoraCustomerAccount01(accList );
            Address__c addressRec = createAddress01(postal);
            List<Contact> conList = createContact01(addressRec, accList );
            List<Order__c> orderRecList = createOrder01(accList , conList);
            
            //
            List<Temp_Stop__c> tempStopList = createTempStop01(orderRecList);
            List<Zuora__Subscription__c> subRecList = createZuoraSubscription01(accList , billAccList , conList, pack, orderRecList);
            List<Case> cList = createCase01(accList , orderRecList, conList, tempStopList, subRecList);
            List<Order_Line_Item__c> orderlineList = createOrderLineItem01(orderRecList, subRecList, pack);
            List<Zuora__SubscriptionProductCharge__c> zSubList = createZuoraSubscriptionProductCharge01(subRecList);
            List<Case_Subscription__c> csList = createCaseSubscription01(cList, accList , subRecList);
            List<Subscription_Vendor__c> subVenList = createSubscriptionVendor01(accList );
            List<Address_Assignment__c> AdasList = createAddressAssignment01(subRecList, accList , cList, conList, subVenList, addressRec);
            Publication__c thisPub = createPublication01();
            
            updateTempStopCase01(tempStopList, cList);
            
            //38: Key_Id__c.getInstance('Vendor Rep Role').Id__c;
            //95: batchSettings = Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
            
            //--
            //create Case
            /*
            Case cas = TestDataFactory.createCase(1, 'Complaint - Digital')[0];
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Temp Stop');
            cas.AccountId = acc.Id;
            cas.COA__c = true;
            //c.Order__c = orderRec.Id;
            cas.Subscription_Name__c = subRec.Id;
            cas.Effective_Date__c = date.Today();
            cas.CSO_Remarks__c = 'Test';
            cas.Temp_Stop_Sub__c = subRec.Id;
            cas.Restart_Date__c = date.Today()+1;
            cas.Temp_Stop__c = tempStopList[0].Id;
            cas.Subject = '[SP_VendorNotificationsBatchTest] TEST_CLASS';
            cas.Status = 'Closed';        
            insert cas;
            tempStopList[0].case__c = cas.Id;
            Update tempStopList;
            */
        
            //Test Proper
            Test.startTest();
            SP_VendorNotificationsBatch batch = new SP_VendorNotificationsBatch();
            ID batchprocessid = Database.executeBatch(batch,200);
            System.assertNotEquals(null, batchprocessid);
            Test.stopTest();
        }
    }
    
}