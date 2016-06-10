/**
 * Trigger Name: BT_TH_STP050DX_StopPressSubscription
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - STP050DX Interface
 * Description: This trigger contains the business logic for STP050DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
 * History: 01/12/2014 Kevin Evasco Reconstructed the entire class to follow ESHOP Start Subscription flow. 
 * History: 05/26/2015 UD-1310 Kevin Evasco - Changed payment mode from Credit Card / Cash to eNets
 * History: 06/19/2015 D-3033 Kevin Evasco - Compilation of hotfixes
 * History: 11/26/2015 D-3993 Renino Niefes - Related to D-3911. Remove Account.Phone from the code.  It shouldn't be populated.
 * History: 05/12/2016 PD-0174 Erika Hidalgo - Commented out unused string to integer conversion.
 */

public class BT_TH_STP050DX_StopPressSubscription 
{        
    public static BT_CO_STPPRS_StopPressSubscription__c so; 
    public static ContactWrapper billingContactDetails, recipientContactDetails;
    public static String addressTypeDeliveryChargeType;
    public static Package__c packageRecord;
    public static Package_Item__c basePackageItemRecord; //START/END 12 October 2015 UD-3075 Kevin Evasco - Get base package item
    
    integer invalidRecordCount = 0;     
    
    public static Boolean isValid = true;
    public static String validationDetails = '';

    Savepoint savepointBeforeDML;   
    
    private final static String recipientKey = 'Recipient Contact';
    private final static String billingKey = 'Billing Contact';
    
    private class ContactWrapper
    {
        String name;
        String coym;
        String profession;
        String dsg;
        String sex;
        String race;
        String incomeRange;
        String ageGroup;
        String icn;
        String homeTelephone;
        String officeTelephone;
        String officeExtension;
        String faxNumber;
        String hphnn;
        String emailID;
        String salutation;
        String privacyIndicator;
        String dateOfBirth;
        
        AddressWrapper address = new AddressWrapper();
    }
    
    private class AddressWrapper 
    {
        String houseBlockNumber;
        String levelNumber;
        String unitNumber;
        String postalCode;
        String countryCode;
        String Address1;
        String Address2;
        String Address3;
        String Address4;
    }
    
    public void execute(List<BT_CO_STPPRS_StopPressSubscription__c> recordsList)
    {        
        savepointBeforeDML = Database.setSavepoint();        
        if(trigger.isInsert){
            if(recordsList.size() == 1)
            {
                processRecords(recordsList);
            }        
            else
            {
                invalidateRecords(recordsList);
            }
        }

        generateLogs(recordsList);
    }
    
    public void processRecords(List<BT_CO_STPPRS_StopPressSubscription__c> recordsList)
    {   
        Account accountRecord;
        Zuora__CustomerAccount__c billingAccount;
        Contact recipientContact, billingContact;
        Order__c orderRecord;
        Zuora__Subscription__c latestSubscription;
        String billingType;
        String orderNumber;
        Order_Line_Item__c relatedOrder;
        
        try
        {
            so = recordsList.get(0);        
            initializeWrappers();       
            
            if(isValid) {
                getPackage();
            }

            //START 12 October 2015 UD-3075 Kevin Evasco - Get base package item
            if(isValid) {
                getBasePackageItem();
            }
            //END 12 October 2015 UD-3075 Kevin Evasco - Get base package item
            /*
            if(isValid) {                        
                
                Set<String> productFamiliesSet = new Set<String>();
                productFamiliesSet.add(packageRecord.Product_Family_Current_Package__c);  
            
                isValid = NewSubscriptionService.validateSimilarSubscriptions('null', 'null', productFamiliesSet, recipientContactDetails.address.countryCode, recipientContactDetails.address.postalCode, recipientContactDetails.address.levelNumber, recipientContactDetails.address.unitNumber);
                
                if(isValid == false) {
                    validationDetails += 'There is another subscription under the same product family in the delivery address.';
                }
            }
            */

            if(isValid) {
                orderNumber = getOrderNumber(so.online_order_num__c);               
                if(orderNumber == null) {
                    isValid = false;
                }
            }
            
            if(isValid) {
                relatedOrder = getRelatedOrder(orderNumber);
            }
            
            if(relatedOrder == null) {          
                if(isValid)
                {
                    billingType = getBillingType();
                    billingType = NewSubscriptionService.getBABillingType(billingType);
                }
                
                if(isValid) {
                    billingAccount = searchBillingAccount(billingContactDetails, billingType, null); //START/END 11 October 2015 UD-3074 Kevin Evasco - Look for existing ENETS Billing Accounts.
                }
                
                if(isValid)
                {
                    if(billingAccount == null) {
                        accountRecord = createAccount(billingType);
                    }
                    else {
                        accountRecord = searchAccount(billingAccount.Zuora__Account__r.Id);
                    }
                }               
                if(isValid)
                {   
                    if(billingAccount == null) {
                        billingContact = createContact(accountRecord.Id, billingContactDetails, billingKey);
                    }
                    else {
                        billingContact = searchContact(billingAccount.Billing_Contact__r.Id);
                    }
                }
                //START 11 October 2015 UD-3074 Kevin Evasco - Look for existing ENETS Billing Accounts.
                if(isValid) {
                    //START 14 October 2015 UD-3008 Kevin Evasco - Do not check if billign account is null
                    if(billingAccount != null){
                        if(billingAccount.Other_PaymentMethod__c != GlobalVariableClass.ENETS)
                            billingAccount = searchBillingAccount(billingContactDetails, billingType, GlobalVariableClass.ENETS);
                    }                   
                    //END 14 October 2015 UD-3008 Kevin Evasco - Do not check if billign account is null
                }
                //END 11 October 2015 UD-3074 Kevin Evasco - Look for existing ENETS Billing Accounts.
                
                if(isValid)
                {
                    if(so.subscriber_type__c == 'IS')
                    {                   
                        recipientContact = createContact(accountRecord.Id, recipientContactDetails, recipientKey);
                    }
                    else if(so.subscriber_type__c == 'IP')
                    {
                        recipientContact = billingContact;
                        //recipientContactDetails = billingContactDetails; //START/END 12 October 2015 UD-3075 Kevin Evasco - Initialize recipientContactDetails at initializeWrappers method
                    }
                }                 
                
                if(isValid)
                {
                    orderRecord = createOrder(accountRecord, billingAccount, recipientContact, billingContact, billingType);
                }
            }
            else {
                orderRecord = queryOrder(relatedOrder.Order__r.Id);
                
                //START 12 October 2015 UD-3075 Kevin Evasco - Clone order to use the billing account in case order has been processed already
                Id orderBillingAccountId = getOrderBillingAccount(orderRecord);
                if(orderBillingAccountId != null)
                    orderRecord = cloneOrder(orderRecord, orderBillingAccountId);
                //END 12 October 2015 UD-3075 Kevin Evasco - Clone order to use the billing account in case order has been processed already
                
                accountRecord = searchAccount(relatedOrder.Order__r.Account__r.Id);
                recipientContact = searchContact(relatedOrder.Order__r.Recipient_Contact__r.Id);
            }
            
            if(isValid)
            {
                latestSubscription = getLatestSubscription(accountRecord.Id, recipientContactDetails);
            }
            if(isValid)
            {
                createOrderLineItem(orderRecord, recipientContact, latestSubscription);
                
                //START 22 October 2015 Kevin Evasco D-3381 D-3732 Kevin Evasco - Mailing Agent Assignment
                List<Order_Line_Item__c> lOrderLineItems = [SELECT Id, Delivered_By__c, Recipient_Postal_Code__c, Vendor_Mailing_Agent__c, 
                                Main_Package_Product_Platform__c, Order__r.Recipient_Contact__r.Address__r.Recordtype.DeveloperName, 
                                Case__r.Subscription_Name__c, Case__r.Subscription_Name__r.Delivered_By_1__c, Case__r.Subscription_Name__r.Vendor_1__c
                                FROM Order_Line_Item__c where Order__c =: orderRecord.Id];
                Vendor_Assignment vendorAssignment = new Vendor_Assignment();
                vendorAssignment.assignMailingAgent(lOrderLineItems);
                Database.update(lOrderLineItems,false);
                
                List<Order__c> orderList = new List<Order__c>();
                orderList.add(orderRecord);
                
                CreateCase caseCreator = new CreateCase();
                caseCreator.createCase2(orderList,true);
                //END 22 October 2015 Kevin Evasco D-3381 D-3732 Kevin Evasco - Mailing Agent Assignment
            }
            /*
            if(isValid)
            {            
                Subscription_Handler sh = new Subscription_Handler();
                sh.origin = 'ESHOP Webservice';
                sh.Subscription_Handler_Direct(orderRecord);
            }*/
        } catch(Exception e) {
            isValid = false;
            validationDetails += 'Type: ' + e.getTypeName() + ' ';
            validationDetails += 'Message: ' + e.getMessage() + ' ';
            validationDetails += 'Stack Trace: ' + e.getStackTraceString();
        }
        
        if(isValid)
        {             
            so.Validation_Status__c = 'Passed';
            so.Order__c = orderRecord.Id;
        }
        else
        {   
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++;        

            Database.rollback(savepointBeforeDML);                
        }             
    }    
    
    public static Order_Line_Item__c getRelatedOrder(String orderNumberParam) {
        String orderNumberFilter = '%' + orderNumberParam + '-%';
        List<Order_Line_Item__c> oliList = [SELECT Id, Order__r.Id, Order__r.Account__r.Id, Order__r.Recipient_Contact__r.Id, Online_Order_Number__c FROM Order_Line_Item__c WHERE Online_Order_Number__c LIKE :orderNumberFilter];
        
        for(Order_Line_Item__c oliElement : oliList) {
            String orderNumberTemp = getOrderNumber(oliElement.Online_Order_Number__c);
            if(orderNumberTemp == orderNumberParam){
                return oliElement;
            }
        }
        
        return null;
    }
    
    public static String getOrderNumber(String onlineOrderNumberParam) {
        Integer dashIndex = so.online_order_num__c.indexOf('-');
        String orderNumberResult;
        
        try{
        dashIndex = so.online_order_num__c.indexOf('-');
        orderNumberResult = so.online_order_num__c.subString(dashIndex-6, dashIndex);
        } catch(Exception e) {
            return null;
        }
        
        return orderNumberResult;
    }
    
    public static String getBillingType() {
        String packageBillingType;
        
        List<Package__c> packageList = [SELECT Billing_Type__c FROM Package__c WHERE Package_Code__c = :so.subscription_package_code__c ORDER BY LastModifiedDate DESC LIMIT 1];
        if(packageList.size() > 0)
            packageBillingType = packageList.get(0).Billing_Type__c; 
        else{
            isValid = false;            
            validationDetails += 'Package Code \'' + so.subscription_package_code__c + '\' does not exist ';
        }
        
        return packageBillingType;
    }
    
    //START 12 October 2015 UD-3075 Kevin Evasco - Recipient Contact Details = Billing Contact Details if Subscriber Type is 'IP'
    private static void initializeWrappers()
    {
        billingContactDetails = new ContactWrapper();
        billingContactDetails.name = so.subscriber_name__c;
        billingContactDetails.coym = so.subscriber_coym__c;
        billingContactDetails.profession = so.subscriber_profession__c;
        billingContactDetails.dsg = so.subscriber_dsg__c;
        billingContactDetails.sex = so.subscriber_sex__c;
        billingContactDetails.race = so.subscriber_race__c;
        billingContactDetails.incomeRange = so.subscriber_income_range__c;
        billingContactDetails.ageGroup = so.subscriber_age_group__c;
        billingContactDetails.icn = so.subscriber_icn__c;
        billingContactDetails.homeTelephone = so.subscriber_home_tel_number__c;
        billingContactDetails.officeTelephone = so.subscriber_office_tel_number__c;
        billingContactDetails.officeExtension = so.subscriber_office_ext_number__c;
        billingContactDetails.faxNumber = so.subscriber_fax_number__c;
        billingContactDetails.hphnn = so.subscriber_hphnn__c;
        billingContactDetails.emailID = so.subscriber_email_id__c;
        billingContactDetails.salutation = so.subscriber_salutation__c;
        billingContactDetails.privacyIndicator = so.subscriber_privacy_indicator__c;
        billingContactDetails.dateOfBirth = so.subscriber_date_of_birth__c;
        
        billingContactDetails.address.houseBlockNumber = so.subscriber_house_block_number__c;
        billingContactDetails.address.postalCode = so.subscriber_postal_code__c;
        billingContactDetails.address.countryCode = so.subscriber_country_code__c;
        billingContactDetails.address.Address1 = so.subscriber_overseas_add1__c;
        billingContactDetails.address.Address2 = so.subscriber_overseas_add2__c;
        billingContactDetails.address.Address3 = so.subscriber_overseas_add3__c;
        billingContactDetails.address.Address4 = so.subscriber_overseas_add4__c; 
        
        if(so.subscriber_house_level_number__c != null){
            if(so.subscriber_house_level_number__c.length() > 1){
                billingContactDetails.address.levelNumber = so.subscriber_house_level_number__c;
            }
            else{
                billingContactDetails.address.levelNumber = '0' + so.subscriber_house_level_number__c;
            }
        }
            
        if(so.subscriber_house_unit_number__c != null){
            if(so.subscriber_house_unit_number__c.length() > 1){
                billingContactDetails.address.unitNumber = so.subscriber_house_unit_number__c;
            }
            else{
                billingContactDetails.address.unitNumber = '0' + so.subscriber_house_unit_number__c;
            }
        }    
        
        if(so.subscriber_type__c == 'IP') {
            recipientContactDetails = billingContactDetails;
        }
        else {          
            recipientContactDetails = new ContactWrapper();     
            recipientContactDetails.name = so.recipient_name__c;
            recipientContactDetails.coym = so.recipient_coym__c;
            recipientContactDetails.profession = so.recipient_profession__c;
            recipientContactDetails.dsg = so.recipient_dsg__c;
            recipientContactDetails.sex = so.recipient_sex__c;
            recipientContactDetails.race = so.recipient_race__c;
            recipientContactDetails.incomeRange = so.recipient_income_range__c;
            recipientContactDetails.ageGroup = so.recipient_age_group__c;
            recipientContactDetails.icn = so.recipient_icn__c;
            recipientContactDetails.homeTelephone = so.recipient_home_tel_num__c;
            recipientContactDetails.officeTelephone = so.recipient_office_tel_num__c;
            recipientContactDetails.officeExtension = so.recipient_office_ext_num__c;
            recipientContactDetails.faxNumber = so.recipient_fax_num__c;
            recipientContactDetails.hphnn = so.recipient_hphnn__c;
            recipientContactDetails.emailID = so.recipient_email_id__c;
            recipientContactDetails.salutation = so.recipient_salutation__c;
            recipientContactDetails.privacyIndicator = so.recipient_privacy_indicator__c;
            recipientContactDetails.dateOfBirth = so.recipient_date_of_birth__c;
            
            recipientContactDetails.address.houseBlockNumber = so.recipient_house_block_num__c;
            recipientContactDetails.address.postalCode = so.recipient_postal_code__c;
            recipientContactDetails.address.countryCode = so.recipient_country_code__c;
            recipientContactDetails.address.Address1 = so.recipient_overseas_add1__c;
            recipientContactDetails.address.Address2 = so.recipient_overseas_add2__c;
            recipientContactDetails.address.Address3 = so.recipient_overseas_add3__c;
            recipientContactDetails.address.Address4 = so.recipient_overseas_add4__c;     
            
            if(so.recipient_house_level_number__c != null){
                if(so.recipient_house_level_number__c.length() > 1){
                    recipientContactDetails.address.levelNumber = so.recipient_house_level_number__c;
                }
                else{
                    recipientContactDetails.address.levelNumber = '0' + so.recipient_house_level_number__c;
                }
            }
            if(so.recipient_house_unit_number__c != null){
                if(so.recipient_house_unit_number__c.length() > 1){
                    recipientContactDetails.address.unitNumber = so.recipient_house_unit_number__c;
                }
                else{
                    recipientContactDetails.address.unitNumber = '0' + so.recipient_house_unit_number__c;
                }
            }
        }           
    }
    //END 12 October 2015 UD-3075 Kevin Evasco - Recipient Contact Details = Billing Contact Details if Subscriber Type is 'IP'
    
    private static Zuora__CustomerAccount__c searchBillingAccount(ContactWrapper contactDetails, String billingTypeParam, String paymentMode) { //START/END 11 October 2015 UD-3074 Kevin Evasco - Look for existing ENETS Billing Accounts.
        Zuora__CustomerAccount__c billingAccountRecord;
        
        //START 11 October 2015 UD-3074 Kevin Evasco - Look for existing ENETS Billing Accounts.
        List<Zuora__CustomerAccount__c> billingAccountList;
        if(paymentMode == GlobalVariableClass.ENETS)
            billingAccountList = [SELECT Id, Name, Zuora__Account__r.Id, Billing_Contact__r.Id, Other_PaymentMethod__c FROM Zuora__CustomerAccount__c WHERE Billing_Contact__r.Address__r.Country__r.Code__c = :contactDetails.address.countryCode AND Billing_Contact__r.Address__r.Postal_Code__r.Name = :contactDetails.address.postalCode AND Billing_Contact__r.Address__r.Unit_Number__c = :contactDetails.address.unitNumber AND Billing_Contact__r.Address__r.Level_Number__c = :contactDetails.address.levelNumber AND Billing_Type__c = :billingTypeParam AND Other_PaymentMethod__c = :GlobalVariableClass.ENETS]; 
        else
            billingAccountList = [SELECT Id, Name, Zuora__Account__r.Id, Billing_Contact__r.Id, Other_PaymentMethod__c FROM Zuora__CustomerAccount__c WHERE Billing_Contact__r.Address__r.Country__r.Code__c = :contactDetails.address.countryCode AND Billing_Contact__r.Address__r.Postal_Code__r.Name = :contactDetails.address.postalCode AND Billing_Contact__r.Address__r.Unit_Number__c = :contactDetails.address.unitNumber AND Billing_Contact__r.Address__r.Level_Number__c = :contactDetails.address.levelNumber AND Billing_Type__c = :billingTypeParam];
        //END 11 October 2015 UD-3074 Kevin Evasco - Look for existing ENETS Billing Accounts.
        
        for(Zuora__CustomerAccount__c billingAccountElement : billingAccountList) {
            String billingAccountName = billingAccountElement.Name;
            if(billingAccountName.startsWith('- ')) {
                billingAccountName = billingAccountName.subString(2, billingAccountName.length() - 1);
            }
            
            if(billingAccountName == contactDetails.name) {
                billingAccountRecord = billingAccountElement;
                break;
            }
        }
        
        return billingAccountRecord;
    }
    
    private static Account searchAccount(Id accountId)
    {      
        Account accountRecord = [SELECT Id, Account_Auto_Number__c FROM Account WHERE Id = :accountId LIMIT 1];     
        return accountRecord;
    }
    
    private static Account createAccount(String billingTypeParam)
    {       
        Account accountRecord = new Account();
        accountRecord.Name = so.subscriber_name__c;
        accountRecord.Subscriber_Name__c = so.subscriber_name__c;
        accountRecord.Designation__c = so.subscriber_dsg__c;
        accountRecord.Gender__c = so.subscriber_sex__c;
        accountRecord.Race__c = so.subscriber_race__c;
        accountRecord.Income_Range__c = so.subscriber_income_range__c;
        accountRecord.Billing_Type__c = billingTypeParam;
        accountRecord.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual');
        accountRecord.Sub_Group__c = 'Public';
        accountRecord.SMS_Renewal_Notification__c = false;
        
        //START 14 October 2015 UD-3008 Kevin Evasco - Handphone Number Assignment
        try
        {
            Integer.valueOf(so.subscriber_hphnn__c);
            accountRecord.Handphone_Number__c = so.subscriber_hphnn__c;
            accountRecord.Mobile__c = so.subscriber_hphnn__c;
        }
        catch(Exception e)
        {
            validationDetails += 'Office Telephone Number is not valid. ';
            isValid = false;
        }               
        //END 14 October 2015 UD-3008 Kevin Evasco - Handphone Number Assignment
        
        try
        {
            Integer.valueOf(so.subscriber_home_tel_number__c);
            accountRecord.Telephone_Residence__c = so.subscriber_home_tel_number__c;
            //Start D-3993 2015-11-26 Renz Remove Account.Phone field from being populated.
            //accountRecord.Phone = so.subscriber_home_tel_number__c; //START 14 October 2015 UD-3008 Kevin Evasco - Home Phone Assignment
            //End D-3993 2015-11-26 Renz
        }
        catch(Exception e)
        {
            validationDetails += 'Office Telephone Number is not valid. ';
            isValid = false;
        }
        try
        {
            Integer.valueOf(so.subscriber_office_tel_number__c);
            accountRecord.Office_Number__c = so.subscriber_office_tel_number__c;
        }
        catch(Exception e)
        {
            validationDetails += 'Office Telephone Number is not valid. ';
            isValid = false;
        }
        try
        {
           Integer.valueOf(so.subscriber_office_ext_number__c);
            accountRecord.Office_Extension__c = so.subscriber_office_ext_number__c;
        }
        catch(Exception e)
        {
            validationDetails += 'Office Extension Number is not valid. ';
            isValid = false;
        }
        try
        {
            accountRecord.Telefax_Number__c = Integer.valueOf(so.subscriber_fax_number__c);
        }
        catch(Exception e)
        {
            validationDetails += 'Fax Number is not valid. ';
            isValid = false;
        }
        try
        {
            accountRecord.Email__c = so.subscriber_email_id__c;
        }
        catch(Exception e)
        {
            validationDetails += 'Subscriber Email is not valid. ';
            isValid = false;
        }
        
        if(so.subscriber_date_of_birth__c != null)
        {
            if(DateUtility.isDateDD_MM_YYYY(so.subscriber_date_of_birth__c,'\\.') == true)
            {            
                accountRecord.Date_of_Birth__c = DateUtility.convertDate(so.subscriber_date_of_birth__c,'\\.','DMY');
            }
        }
        
        accountRecord.Attention_To_Care_Of__c = so.subscriber_salutation__c;
        
        try
        {
            insert accountRecord;
            accountRecord = searchAccount(accountRecord.Id);
        }
        catch(Exception e)
        {           
            isValid = false;
            validationDetails += 'Cannot insert account record. ';
            validationDetails += 'Type: ' + e.getTypeName() + ' ';
            validationDetails += 'Message: ' + e.getMessage() + ' ';
            validationDetails += 'Stack Trace: ' + e.getStackTraceString();
        }
        
        
        return accountRecord;
    }
    
    private static Contact searchContact(Id contactIdParam) {
        return [SELECT
                Address__c,
                Address__r.Address_Type__c,
                Address__r.Block_House_Number__c,
                Address__r.Level_Number__c,         
                Address__r.Postal_Code__r.Name,
                Address__r.Unit_Number__c,
                Address__r.RecordTypeId,
                Billing_Indicator__c,
                Email__c, 
                Id,
                Name, 
                Recipient_Indicator__c,
                Zone__c
                FROM Contact
                WHERE Id = :contactIdParam];
    }
    
    private static Contact createContact(Id parentAccountId, ContactWrapper contactDetails, String type)
    {               
        String nameStr = contactDetails.name;
        List<String> nameTokens = nameStr.split(' ',0);
        String firstName, lastName;
        if(nameTokens.size() > 1){    
            lastName = nameTokens.get(nameTokens.size()-1);
            firstName = nameStr.subString(0,nameStr.length() - lastName.length()-1);
        } else {
            firstName = '-';
            lastName = nameStr;
        }
    
        Contact contactRecord = new Contact();
        contactRecord.AccountId = parentAccountId;
        contactRecord.FirstName = firstName;
        contactRecord.LastName = lastName;
        contactRecord.HomePhone = contactDetails.homeTelephone;     
        //START 14 October 2015 UD-3008 Kevin EVasco - Home Phone and Hand Phone assignment
        contactRecord.HomePhone__c = contactDetails.homeTelephone;
        contactRecord.Mobile_Number__c = contactDetails.hphnn;
        //END 14 October 2015 UD-3008 Kevin EVasco - Home Phone and Hand Phone assignment
        contactRecord.Office_Number__c = contactDetails.officeTelephone;
        
        try
        {
            contactRecord.Office_Extension__c = contactDetails.officeExtension; //START/END UD-0118 5/20/15 MGaelo change OfficeExtension into phone
        }
        catch(Exception e)
        {
            isValid = false;
            validationDetails += 'Office Extension Number is not valid. ';
        }
        
        contactRecord.Fax__c = contactDetails.faxNumber;
        contactRecord.Email__c = contactDetails.emailID;
        contactRecord.Salutation = contactDetails.salutation;    

        if(contactDetails.dateOfBirth != null)
        {
            if(DateUtility.isDateDD_MM_YYYY(contactDetails.dateOfBirth,'\\.') == true)
            {            
                contactRecord.Birthdate = DateUtility.convertDate(contactDetails.dateOfBirth,'\\.','DMY');
            }
        }       
                    
        Address__c addressRecord = searchAddress(contactDetails.address);       
        if(addressRecord == null)
        {
            addressRecord = createAddress(contactDetails.address);
        }         
        
        contactRecord.Address__c = addressRecord.Id;
        
        if(type == billingKey || so.subscriber_type__c == 'IP')
        {
            contactRecord.Billing_Indicator__c  = true;            
            contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');            
        }
        if(type == recipientKey || so.subscriber_type__c == 'IP')
        {
            contactRecord.Recipient_Indicator__c = true;            
            contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        }
        try
        {
            insert contactRecord;
            contactRecord = searchContact(contactRecord.Id);
        }
        catch(Exception e)
        {       
            isValid = false;
            validationDetails += 'Cannot insert contact record. ';
            validationDetails += 'Type: ' + e.getTypeName() + ' ';
            validationDetails += 'Message: ' + e.getMessage() + ' ';
            validationDetails += 'Stack Trace: ' + e.getStackTraceString();
        }
        
        
        return contactRecord;
    }
    
    public static Address__c searchAddress(AddressWrapper addressDetails)
    {
        Address__c addressRecord;  
        List<Address__c> addressList;
        if(addressDetails.countryCode == GlobalVariableClass.SINGAPORE_CODE)
        {
            addressList = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Code__c = :addressDetails.countryCode AND Postal_Code__r.Name = :addressDetails.postalCode AND Unit_Number__c = :addressDetails.unitNumber AND Level_Number__c = :addressDetails.levelNumber];
        }
        else
        {
            addressList = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Code__c = :addressDetails.countryCode AND Address_1__c = :addressDetails.Address1 AND Address_2__c = :addressDetails.Address2 AND Address_3__c = :addressDetails.Address3 AND Address_4__c = :addressDetails.Address4];
        }
        
        if(addressList.size() > 0)
        {
            addressRecord = addressList.get(0);
        }
        
        return addressRecord;
    }
    
    public static Address__c createAddress(AddressWrapper addressDetails)
    {
        Address__c newAddress = new Address__c();               
        
        if(addressDetails.countryCode == GlobalVariableClass.SINGAPORE_CODE || addressDetails.countryCode == null)
        {
            Singpost_Address__c singpostAddress = getSingpostAddress(addressDetails.postalCode);
            if(singpostAddress != null)
            {
                newAddress.Postal_Code__c = singpostAddress.Id;
            }
            newAddress.Block_House_Number__c = addressDetails.houseBlockNumber;
            if(addressDetails.levelNumber.length() > 1)
                newAddress.Level_Number__c = addressDetails.levelNumber;
            else
                newAddress.Level_Number__c = '0' + addressDetails.levelNumber;
            
            if(addressDetails.unitNumber.length() > 1)
                newAddress.Unit_Number__c = addressDetails.unitNumber;
            else
                newAddress.Unit_Number__c = '0' + addressDetails.unitNumber;
            
            newAddress.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');            
        }
        else
        {           
            newAddress.Address_1__c = addressDetails.Address1;
            newAddress.Address_2__c = addressDetails.Address2;
            newAddress.Address_3__c = addressDetails.Address3;
            newAddress.Address_4__c = addressDetails.Address4;
            
            newAddress.RecordTypeId = ConstantsSLB.getkeyid('Address_Overseas');
        }                   
        
        Country__c countryRecord;
        
        if(addressDetails.countryCode != null)
        {
            countryRecord = getCountry(addressDetails.countryCode);             
            if(countryRecord != null)
            {
                newAddress.Country__c = countryRecord.Id;  
            }
        }
        
        if(isValid)
        {
            try
            {
                insert newAddress;
            }
            catch(Exception e)
            {           
                isValid = false;
                validationDetails += 'Cannot insert new address record. ' + e.getMessage();
            }
        }
        
        return newAddress;
    }
    
    public static Country__c getCountry(String countryCode)
    {
        Country__c countryRecord;
        List<Country__c> countryList = [SELECT Id FROM Country__c WHERE Code__c = :countryCode];
        if(countryList.size() > 0)
        {
            countryRecord = countryList.get(0);
        }
        else
        {       
            isValid = false;
            validationDetails += 'Country Code ' + countryCode + ' does not exist. ';
        }
        
        return countryRecord;
    }   
    
    public static Singpost_Address__c getSingpostAddress(String postalCode)
    {
        Singpost_Address__c singpostAddressRecord;
        List<Singpost_Address__c> singpostAddressList = [SELECT Id FROM Singpost_Address__c WHERE Name = :postalCode];
        if(singpostAddressList.size() > 0)
        {
            singpostAddressRecord = singpostAddressList.get(0);
        }
        else
        {       
            isValid = false;
            validationDetails += 'Postal Code ' + postalCode + ' does not exist. ';
           
        }
        
        return singpostAddressRecord;
    }
    
    public static Zuora__Subscription__c getLatestSubscription(Id parentAccountIdParam, ContactWrapper contactDetails){
        Zuora__Subscription__c latestSubscription;
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Recipient_Contact__r.Address__r.Country__r.Code__c = :contactDetails.address.countryCode AND Recipient_Contact__r.Address__r.Postal_Code__r.Name = :contactDetails.address.postalCode AND Recipient_Contact__r.Address__r.Unit_Number__c = :contactDetails.address.unitNumber AND Recipient_Contact__r.Address__r.Level_Number__c = :contactDetails.address.levelNumber AND Product_Code__c = :basePackageItemRecord.Product_Rate_Plan__r.Product_Code__c AND Zuora__Account__r.Id = :parentAccountIdParam ORDER BY Zuora__SubscriptionEndDate__c DESC LIMIT 1]; //START/END 11 October 2015 UD-3075 Kevin Evasco - Use product code filter instead of package code
        
        if(subscriptionList.size() > 0)
            latestSubscription = subscriptionList.get(0);
        
        return latestSubscription;
    }
    
    private static Order__c createOrder(Account parentAccount, Zuora__CustomerAccount__c billingAccount, Contact recipientContact, Contact billingContact, String billingTypeParam)
    {                   
        Order__c orderRecord = new Order__c();
        //START 31 July 2015 D-3303 Kevin Evasco - Order Type default value should be Start
        orderRecord.Order_Type__c = 'Start';
        orderRecord.Order_Type1__c = 'Start';
        //END 31 July 2015 D-3303 Kevin Evasco - Order Type default value should be Start
        orderRecord.Billing_Type__c = billingTypeParam;
        orderRecord.Account__c = parentAccount.Id;
        orderRecord.DTL_Date__c = SM_SubscriptionHelper.getDtlDate();
        if(billingAccount == null) {            
            orderRecord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        } else {
            orderRecord.Billing_Account__c = billingAccount.Id;
            orderRecord.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';  
        }
        
        orderRecord.Payment_Mode__c = 'Other'; // TO-DO: Update to use pay type from so.
        orderRecord.Other_Payment_Mode__c = 'eNets';
        //orderRecord.Payment_Method_ID__c = orderDetails.paymentMethodId; // TO-DO: Payment method id required if credit card.             
        
        orderRecord.Billing_Contact__c = billingContact.Id;
        orderRecord.Credit_Balance__c = 0;
        
        orderRecord.Creation_Mode__c = 'Others';               
        orderRecord.Recipient_Contact__c = recipientContact.Id;
        
        string recipientAddressType = recipientContact.Address__r.Address_Type__c;
        
        orderRecord.Delivery_Charge_Type__c = ConstantsSLB.getDefaultDeliveryChargeType(recipientContact.Address__r.Address_Type__c);
        
        addressTypeDeliveryChargeType =  recipientAddressType + orderRecord.Delivery_Charge_Type__c;
        
        //orderRecord.Subscriber_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
        orderRecord.Delivery_Charge__c = 0;
        //orderRecord.Vendor_Credit__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
        
        orderRecord.Zone_Charge__c = ConstantsSLB.getPostageCharge(recipientContact.Zone__c);
        
        orderRecord.Monthly_Delivery_Charge_for_Full_Payment__c = 0; //months * delivery charge                    
        
        orderRecord.Acquisition_Type__c = 'STOPPRESS';          
        orderRecord.Informed_Customer__c = true;
        orderRecord.Status__c = GlobalVariableClass.TS_PENDING;
        
        /*
        if(so.payment_number__c != '' && so.payment_number__c != null)
        {
            orderRecord.Payment_Mode__c = 'Credit Card';
            orderRecord.Payment_Method_ID__c = so.payment_number__c;
        }               
        */
        try
        {
            insert orderRecord;        
            
            orderRecord = queryOrder(orderRecord.Id);
        }
        catch(Exception e)
        {
            isValid = false;
            validationDetails += 'Cannot insert order record. ' + e.getMessage();
        }
        
        return orderRecord;
    }
    
    public static Order__c queryOrder(Id orderIdParam) {
        return [SELECT Id, Recipient_Contact__r.Address__r.Postal_Code__c, Account__r.Account_Auto_Number__c,
                            Billing_Contact__c, Recipient_Contact__r.Address__c, Recipient_Contact__c, No_Vendor_Needed__c, //START/END 22 October 2015 D-3381 D-3732 Kevin Evasco - Added No_Vendor_Needed__c param
                            Account__c, Acquisition_Type__c, Remarks__c, Parent_Case__c, Billing_Account_Creation_Mode__c, Billing_Account__c, FP_Del_Usage__c, Subscriber_Charge__c, Payment_Mode__c, Other_Payment_Mode__c, Delivery_Charge_Type__c, Payment_Method_ID__c, Billing_Type__c, Billing_Account__r.Zuora__External_Id__c
                            FROM Order__c 
                            WHERE Id = :orderIdParam];    
                    
    }
    
    //START 12 October 2015 UD-3075 Kevin Evasco - Clone order to use the billing account in case original order has been processed already
    public static Id getOrderBillingAccount(Order__c orderParam){
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE Order_Number_1__c = :orderParam.Id LIMIT 1];
        
        if(!subscriptionList.isEmpty()){
            return subscriptionList[0].Zuora__CustomerAccount__c;
        } else {
            return null;
        }
    }
    
    public static Order__c cloneOrder(Order__c orderParam, Id billingAccountId) {       
        Order__c newOrder = (Order__c)SObjectAllFieldCloner.cloneObject(orderParam,orderParam.getsObjectType());
        newOrder.Id = null;
        newOrder.Billing_Account__c = billingAccountId;
        newOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';  
        
        insert newOrder;        
        newOrder = queryOrder(newOrder.Id);
        
        return newOrder;        
    }
    //END 12 October 2015 UD-3075 Kevin Evasco - Clone order to use the billing account in case original order has been processed already
    
    
    public static void getPackage() {
        List<Package__c> packageList = [SELECT Id, Billing_Type__c, Package_Sub_Type__c, Package_Type__c, Subscription_Period__c, Subscription_Type__c, Product_Family_Current_Package__c, Package_Price__c, Package_Code__c FROM Package__c WHERE Package_Code__c = :so.subscription_package_code__c];      
        
        if(packageList.size() > 0)
        {                       
            packageRecord = packageList.get(0);     
        }
        else
        {
            isValid = false;
            validationDetails += 'Package Code ' + so.subscription_package_code__c + ' does not exist. ';
        }
    }    
    
    //START 12 October 2015 UD-3075 Kevin Evasco - Get base package item
    public static void getBasePackageItem() {
        
        List<Package_Item__c> basePackageItemList = [SELECT Id, Product_Rate_Plan__r.Product_Code__c, RecordTypeID FROM Package_Item__c WHERE Package__c = :packageRecord.Id AND RecordTypeID =:ConstantsSLB.getKeyID('Package Item_Base Product') AND Product_Rate_Plan__r.Product_Code__c != NULL];

        if(!basePackageItemList.isEmpty()){
            basePackageItemRecord = basePackageItemList.get(0);
        }
        else
        {
            isValid = false;
            validationDetails += 'Package does not have a base package item or missing product code. ';
        }

    }
    //END 12 October 2015 UD-3075 Kevin Evasco - Get base package item
    
    public static void createOrderLineItem(Order__c parentOrder, Contact recipientContact, Zuora__Subscription__c latestSubscription)
    {        
        /*
        PackageEligibilityCheck.PackageEligibilityCheckRequest packageEligibilityCheckRequest = new PackageEligibilityCheck.PackageEligibilityCheckRequest();
        packageEligibilityCheckRequest.Packageid = so.subscription_package_code__c;
        //TO-DO: Where to get promo code?
        packageEligibilityCheckRequest.Promotionid = 'INSERT PROMO CODE HERE';
        packageEligibilityCheckRequest.Action = 'CAN ADD';
        packageEligibilityCheckRequest.SubscriptionId = '';
        packageEligibilityCheckRequest.subscriberid = parentOrder.Account__r.Account_Auto_Number__c;            
        
        PackageEligibilityCheck.PackageEligibilityCheckResponse packageEligibilityCheckResponse = PackageEligibilityCheck.processRequest(packageEligibilityCheckRequest);
        */
        //TO-DO: Remove 'always true' condition when the Package Eligibility check is ready for use.
        //if(packageEligibilityCheckResponse.eligibilityFlg == 'true')
        {   
            List<Package_Item__c> packageItemList = [SELECT Id, Package__r.Id, Package__r.Billing_Type__c, Billing_Type__c, Product_Rate_Plan__r.Id, Product_Rate_Plan__r.zqu__ZProduct__r.Id, Is_Newspaper__c, Is_Magazine__c FROM Package_Item__c WHERE Package__c = :packageRecord.Id];
            
            Set<Id> prpIdSet = new Set<Id>();           
            Set<Id> productIdSet = new Set<Id>();
            
            Boolean hasPostageCharge = false;
            
            List<Product_Publication__c> productPublicationList = new List<Product_Publication__c>();
            
            Map<Id,List<zqu__ProductRatePlanCharge__c>> productRatePlan_productRatePlanChargeMap = new Map<Id,List<zqu__ProductRatePlanCharge__c>>();           
            Map<Id,zqu__ProductRatePlan__c> productRatePlanMap = new Map<Id,zqu__ProductRatePlan__c>();
            Map<Id,List<Product_Publication__c>> product_productPublicationMap = new Map<Id,List<Product_Publication__c>>();
            
            initializePackageItemListVariables(packageItemList, prpIdSet);
            initializeProductRatePlanSetVariables(prpIdSet, productIdSet, productRatePlan_productRatePlanChargeMap, productRatePlanMap);
            productPublicationList = initializeProductIdSetVariables(productIdSet, productPublicationList, product_productPublicationMap);
            
            System.debug('productIdSet ' + productIdSet);
            System.debug('productPublicationList ' + productPublicationList);
            
            Order_Line_Item__c orderLineItemRecord = new Order_Line_Item__c();      
            orderLineItemRecord.Order__c = parentOrder.Id;  
            orderLineItemRecord.Main_Package_ID__c = packageRecord.Id;       
            orderLineItemRecord.Online_Order_Number__c = so.online_order_num__c;
            
            Date startDate = getEarliestStartDate(productPublicationList);
            if(so.referred_start_date__c != null && so.referred_start_date__c != '')
            {
                Date preferredStartDate = DateUtility.convertDate(so.referred_start_date__c,'\\.','DMY');
                
                if(preferredStartDate >= startDate) {
                    startDate = preferredStartDate;
                }
            }
            Integer contractPeriod = Integer.valueOf(so.sub_period__c);
            
            if(latestSubscription != null) {
                startDate = latestSubscription.Zuora__SubscriptionEndDate__c.addDays(1);
            }
            
            orderLineItemRecord.Start_Date__c = startDate;
            orderLineItemRecord.New_Contract_Period__c = contractPeriod;
            orderLineItemRecord.Contract_End_Date__c = startDate.addMonths(contractPeriod).addDays(-1);
            orderLineItemRecord.DTL_Date__c = SM_SubscriptionHelper.getDtlDate();
            
            orderLineItemRecord.Qty__c = Decimal.valueOf(so.sub_copies__c);
            orderLineItemRecord.Main_Package_Billing_Type__c = packageRecord.Billing_Type__c;
            orderLineItemRecord.Main_Package_Sub_Type__c = packageRecord.Subscription_Type__c;//Package_Sub_Type__c;
            orderLineItemRecord.Main_Package_Type__c =  packageRecord.Package_Type__c;                      
            
            orderLineItemRecord.Subscribed_as__c = 'New Buy';
            
            String termLength = packageRecord.Subscription_Period__c;
            if(termLength != 'N/A')
            {
                orderLineItemRecord.Term_Length__c = Integer.valueOf(termLength);
                orderLineItemRecord.Main_Package_Period__c = Integer.valueOf(termLength);
                orderLineItemRecord.End_Date__c = startDate.addMonths(Integer.valueOf(termLength)).addDays(-1); 
            }
            else
            {
                orderLineItemRecord.Main_Package_Period__c = 0;
                orderLineItemRecord.Term_Length__c = 0;
            }
            String DirectSubDelMethod = ConstantsSLB.getKeyId('Publication Delivered By');
            String pubDeliveredBy;
        
            try
            {
                pubDeliveredBy = product_productPublicationMap.get(productRatePlanMap.get(packageItemList[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.Id)[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
            }
            catch(Exception e)
            {       
                System.debug(e.getMessage());
            }
            
            //START 22 October 2015 D-3381 D-3732 Kevin Evasco - Commented code. Mailing Agent Assignment done by Vendor_Assignment class
            //if(recipientContact.Address__r.RecordTypeId != ConstantsSLB.getkeyid('Address_Local'))
            //{
                orderLineItemRecord.Delivered_By__c = 'Mailing Agent';
                orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Mailing Agent';                    
                parentOrder.Delivery_Charge__c = 0;
                hasPostageCharge = true;    
            //}
            /*
            else if(recipientContact.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local')&& (pubDeliveredBy == null || pubDeliveredBy == DirectSubDelMethod))
            {
               
                if(packageItemList[0].Is_Newspaper__c == true)
                {
                    orderLineItemRecord.Delivered_By__c = 'Vendor';
                    orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Vendor';
                    parentOrder.Delivery_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
                }
                else
                if(packageItemList[0].Is_Magazine__c == true)
                {
                    orderLineItemRecord.Delivered_By__c = 'Mailing Agent';
                    orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
                    parentOrder.Delivery_Charge__c = 0;
                    hasPostageCharge = true;    
                }
            }
            else if(recipientContact.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local'))
            {
                orderLineItemRecord.Delivered_By__c = pubDeliveredBy;
                orderLineItemRecord.Direct_Sub_Delivery_Method__c = pubDeliveredBy;             
                if(pubDeliveredBy == 'Vendor')
                {
                    parentOrder.Delivery_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
                }
                else if(pubDeliveredBy == 'Mailing Agent')
                {
                    parentOrder.Delivery_Charge__c = 0;
                    hasPostageCharge = true;    
                }
            }
            */
            //END 22 October 2015 D-3381 D-3732 Kevin Evasco - Commented code. Mailing Agent Assignment done by Vendor_Assignment class
            
            orderLineItemRecord.Main_Package_Subscription_Rate__c = packageRecord.Package_Price__c;     
            
            orderLineItemRecord.Earliest_Start_Date__c = getEarliestStartDate(productPublicationList);   

            String subscriptionFrequencyNum = productRatePlanMap.get(packageItemList[0].Product_Rate_Plan__r.Id).SubscriptionFrequency__c;
            String subscriptionFrequencyText;
            
            if(subscriptionFrequencyNum == '0')
            {
                subscriptionFrequencyText = 'Default';
            }
            else if(subscriptionFrequencyNum == '1')
            {
                subscriptionFrequencyText = 'Mon - Fri';
            }
            else if(subscriptionFrequencyNum == '2')
            {
                subscriptionFrequencyText = 'Sat - Sun';
            }
            else if(subscriptionFrequencyNum == '3')
            {
                subscriptionFrequencyText = 'Mon - Sat';
            }       
            
            orderLineItemRecord.Main_Package_Frequency__c = subscriptionFrequencyText;
            
            orderLineItemRecord.Main_Package_Product_Sub_Type__c = productRatePlanMap.get(packageItemList[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.ProductSubType__c;
            orderLineItemRecord.Main_Package_Product_Platform__c = productRatePlanMap.get(packageItemList[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.ProductPlatform__c;
            
            if(so.auto_renewal_indicator__c == 'Y')
            {
                orderLineItemRecord.Auto_Renew__c = true;
            }                           
    
            //START 22 October 2015 D-3381 D-3732 Kevin Evasco - Commented code. Mailing Agent Assignment done by Vendor_Assignment class
            /*
            if(parentOrder.Recipient_Contact__c != null) 
            {
                Id postalCodeId = parentOrder.Recipient_Contact__r.Address__r.Postal_Code__c;
                if(postalCodeId != null) 
                {
                    List<Vendor_Allocation__c> venAllocList = [SELECT Id, Vendor_Account__c FROM Vendor_Allocation__c
                                    WHERE SingPost_Address__c = :postalCodeId]; 
                    if(venAllocList.size() > 1 || venAllocList == null || venAllocList.size() == 0) 
                    {
                        orderLineItemRecord.Vendor_Mailing_Agent__c = null;
                        //createCase(parentOrder);          
                    }
                    else if(venAllocList.size() == 1) 
                    {
                        orderLineItemRecord.Vendor_Mailing_Agent__c = venAllocList[0].Vendor_Account__c;
                    }                      
                }
            }
            */
            //END 22 October 2015 D-3381 D-3732 Kevin Evasco - Commented code. Mailing Agent Assignment done by Vendor_Assignment class
            
            insert orderLineItemRecord;
            update parentOrder;
            
            if(hasPostageCharge)
            {
                orderLineItemRecord.Postage_Charge__c = PostageChargeHelper.getPostageChargeForLineItem(recipientContact.Id, orderLineItemRecord);
            }
            update orderLineItemRecord; 
        }
    }
    
    public static void initializePackageItemListVariables(List<Package_Item__c> packageItemList, Set<Id> productRatePlanIdSet)
    {
        for(Package_Item__c packageItem : packageItemList)
        {  
            productRatePlanIdSet.add(packageItem.Product_Rate_Plan__r.Id);
        }
    }
    
    public static void initializeProductRatePlanSetVariables
        (Set<Id> productRatePlanIdSet,
        Set<Id> productIdSet,
        Map<Id,List<zqu__ProductRatePlanCharge__c>> productRatePlan_productRatePlanChargeMap,       
        Map<Id,zqu__ProductRatePlan__c> productRatePlanMap)
    {           
        List<zqu__ProductRatePlan__c> productRatePlanList = [SELECT Id, SubscriptionFrequency__c, zqu__ZProduct__r.Id , zqu__ZProduct__r.ProductSubType__c, zqu__ZProduct__r.ProductPlatform__c
                                FROM zqu__ProductRatePlan__c WHERE Id IN :productRatePlanIdSet];
                                
        for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList)
        {
            productRatePlanMap.put(productRatePlan.Id, productRatePlan);
            productIdSet.add(productRatePlan.zqu__ZProduct__r.Id);
        }   
    
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = [SELECT Id, zqu__ProductRatePlan__r.Id, sum__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN :productRatePlanIdSet];
        
        for(zqu__ProductRatePlanCharge__c productRatePlanCharge : productRatePlanChargeList)
        {       
            if(productRatePlan_productRatePlanChargeMap.get(productRatePlanCharge.zqu__ProductRatePlan__r.Id) == null)
            {               
                productRatePlan_productRatePlanChargeMap.put(productRatePlanCharge.zqu__ProductRatePlan__r.Id, new List<zqu__ProductRatePlanCharge__c>());
            }
            productRatePlan_productRatePlanChargeMap.get(productRatePlanCharge.zqu__ProductRatePlan__r.Id).add(productRatePlanCharge);
        }
    }
    
    public static List<Product_Publication__c> initializeProductIdSetVariables
        (Set<Id> productIdSet,
        List<Product_Publication__c> productPublicationList,        
        Map<Id,List<Product_Publication__c>> product_productPublicationMap)
    {
        productPublicationList = [SELECT Id, ZProduct__c, ZProduct__r.Id, Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c
                                    FROM Product_Publication__c WHERE ZProduct__c IN :productIdSet];
                                    
        for(Product_Publication__c productPublicationRecord : productPublicationList)
        {   
            if(product_productPublicationMap.get(productPublicationRecord.ZProduct__r.Id) == null)
            {
                product_productPublicationMap.put(productPublicationRecord.ZProduct__r.Id, new List<Product_Publication__c>());
            }
            product_productPublicationMap.get(productPublicationRecord.ZProduct__r.Id).add(productPublicationRecord);
        }
                                    
        return productPublicationList;
    }
    
    /*
    public static Decimal calculateSubscriptionRate(List<Package_Item__c> packageItemList, Map<Id,List<zqu__ProductRatePlanCharge__c>> productRatePlan_productRatePlanChargeMap)
    {
        Decimal totalSubscriptionRate = 0;
        
        for(Package_Item__c packageItem : packageItemList)
        {
            totalSubscriptionRate += packageItem.Package_Price__c;
        }
        
        return totalSubscriptionRate;
    }
    */
    public static Date getEarliestStartDate(List<Product_Publication__c> productPublicationList)
    {
        if(productPublicationList == null)
            return null;
            
        Date earliestDate = productPublicationList.get(0).Publication_Code__r.Earliest_Start_Date__c;
        
        for(Product_Publication__c productPublicationRecord : productPublicationList)
        {
            Date tempDate = productPublicationRecord.Publication_Code__r.Earliest_Start_Date__c;
            if(tempDate < earliestDate)
                earliestDate = tempDate;
        }
        
        return earliestDate;
    }
    
    public static void createCase(Order__c thisOrder) 
    {
        List<Case> caseList = new List<Case>();
        Case thisCase = new Case();
        try {
            thisCase.Subject = GlobalVariableClass.SUBJECT_START_SUBSCRIPTION; 
            thisCase.RecordTypeID = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION);
            thisCase.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            thisCase.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION;
            thisCase.Status = GlobalVariableClass.STATUS_PENDING;
            thisCase.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
            thisCase.Subscriber__c = thisOrder.Billing_Contact__c;
            thisCase.Recipient_Address__c = thisOrder.Recipient_Contact__r.Address__c;
            thisCase.Recipient__c = thisOrder.Recipient_Contact__c;
            thisCase.AccountId = thisOrder.Account__c;
            thisCase.Origin = thisOrder.Acquisition_Type__c;
            thisCase.Order__c = thisOrder.Id;
            thisCase.Description = thisOrder.Remarks__c;
            if(thisOrder.Parent_Case__c != null || thisOrder.Parent_Case__c != 'null') {
                thisCase.ParentId = thisOrder.Parent_Case__c; 
            }
            caseList.add(thisCase);
            insert caseList;
        }
        catch(exception e) {
            system.debug(e.getMessage());
        }   
    }
    
    public void generateLogs(List<BT_CO_STPPRS_StopPressSubscription__c> recordsList)
    {
        BT_CO_LEG2SF_Log__c leg2sfLog;
        String interfaceId = 'STP050DX';
        Date batchRunDate = recordsList[0].Batch_Run_Date__c;
        String batchJobId = recordsList[0].Batch_Job_Id__c;            
        
        List<BT_CO_LEG2SF_Log__c> leg2sfLogList = [SELECT Id, Total_Record_Count__c, Valid_Record_Count__c, Invalid_Record_Count__c FROM BT_CO_LEG2SF_Log__c WHERE Interface_ID__c = :interfaceId AND Batch_Run_Date__c = :batchRunDate AND Batch_Job_Id__c = :batchJobId];

        if(leg2sfLogList.size() == 0)
        {
            leg2sfLog = new BT_CO_LEG2SF_Log__c();
            leg2sfLog.Interface_ID__c = interfaceId;
            leg2sfLog.Batch_Run_Date__c = batchRunDate;
            leg2sfLog.Total_Record_Count__c = recordsList.size();
            leg2sfLog.Valid_Record_Count__c = recordsList.size() - invalidRecordCount;      
            leg2sfLog.Invalid_Record_Count__c = invalidRecordCount;
            leg2sfLog.DML_Status__c = 'Success';
            leg2sfLog.Stack_Trace__c = 'Please see BT_CO_STPPRS_StopPressSubscription__c for validation details.';
            leg2sfLog.Batch_Job_Id__c = batchJobId;
            
            insert leg2sfLog;   
        }
        else
        {
            leg2sfLog = leg2sfLogList.get(0);        
            leg2sfLog.Total_Record_Count__c += recordsList.size();
            leg2sfLog.Valid_Record_Count__c += recordsList.size() - invalidRecordCount;      
            leg2sfLog.Invalid_Record_Count__c += invalidRecordCount;
            
            update leg2sfLog;
        }    
    }    
    
    public void invalidateRecords(List<BT_CO_STPPRS_StopPressSubscription__c> recordsList)
    {
        for(BT_CO_STPPRS_StopPressSubscription__c stagingObject : recordsList)
        {
            stagingObject.addError('Could not perform insert operation because batch size is greater than 1. Maximum batch size for this interface is 1.');            
        }
        invalidRecordCount = recordsList.size();
    }
}