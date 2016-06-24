public virtual class BulkOrderUploadDeclarator {

    // start constants declaration

    public final string EMPTY_STR = '';
    public final string NOT_AVAILABLE = 'Not Available';
    public final string DOC_TEMPLATE_NAME = 'BulkOrderUploadTemplate';
    public final string DOC_TEMPLATE_LABEL = 'Bulk Order Upload Template';
    public final string DOC_REF_NAME = 'BulkOrderUploadReference';
    public final string DOC_REF_LABEL = 'Bulk Order Upload Reference';
    public final string DOC_BASE_URL = '/servlet/servlet.FileDownload?file=';
    public final string ERROR_FILE_SIZE = 'Allowable file size limit exceeded. Please upload not bigger than 10MB in size.';
    public final string SUCCESS_MESSAGE = 'File successfully verified.<br /><br />Click the "Begin Upload" button to proceed with Order creation.';
    public final integer FILE_SIZE_LIMIT = 10485760; // 10MB
    public final string C_RETURN = '\r';
    public final string NEW_LINE = '\n';
    public final string TAB = '\t';
    public final string SPACE = ' ';
    public final string SEMI_COLON = ';';
    public final string HYPHEN = '-';
    public final string BRACKET_O = '[';
    public final string BRACKET_C = ']';
    public final string NULL_STR = 'null';
    public final string LOCK_ROW = 'UNABLE_TO_LOCK_ROW';
    public final string CREDIT_CARD = 'CreditCard';

    public final string CS_FIELD_IDENTIFIER = 'Identifier__c';
    public final string CS_FIELD_FIELD_NAME = 'Field_Name__c';
    public final string CS_FIELD_OBJECT_NAME = 'Object_Name__c';
    public final string CS_RECORD_TYPE_NAME = 'Record_Type_Name__c';

    public final string BA_CREATION_MODE_EXISTING = 'Use existing Billing Account';
    public final string BA_CREATION_MODE_NEW = 'Create New Billing Account';
    public final string START_STR = 'Start';
    public final string PENDING = 'Pending';
    public final string ROAD_SHOW = 'Road Show';
    public final string OTHERS = 'Others';
    public final string RECURRING_STR = 'Recurring';

    public final string PAYMENT_MODE_OTHER = 'Other';
    public final string PAYMENT_MODE_CASH = 'Cash';
    public final string PAYMENT_MODE_CHECK = 'Check';
    public final string PAYMENT_MODE_CC = 'Credit Card';
    public final string PAYMENT_MODE_PAYPAL = 'Paypal';
    
    
    public final string OTHER_PAYMENT_MODE_INVOICE = 'Invoice';
    public final string OTHER_PAYMENT_MODE_INTERNAL_CHG = 'Internal Charge';
    public final string OTHER_PAYMENT_MODE_ENETS = 'eNets';
    public final string OTHER_PAYMENT_MODE_IPP = 'IPP';
    public final string OTHER_PAYMENT_MODE_EXT_PARTIES = 'External Parties';
    public final string OTHER_PAYMENT_MODE_FREELIST = 'Freelist';   // Start/End D-4334 19Jan16 JohnD

    public final string DELIVERY_PRP_ZERO = 'Zero Charge Amount';
    public final string DELIVERY_PRP_HDB = 'HDB DELIVERY CHARGE';
    public final string DELIVERY_PRP_APT = 'APT DELIVERY CHARGE';
    public final string DELIVERY_PRP_LANDED = 'LANDED DELIVERY CHARGE';
    public final string IS_EXIST_PROMO = 'isPromoExist';
    public final string IS_EXIST_PACKAGE = 'isPackageExist';
    public final string IS_EXIST_ADDON_PACKAGE = 'isAddonPackageExist';
    public final string ROW_NUMBER = 'rowNumber';
    public final string IS_VALID_ADDON_PACKAGE = 'isValidAddonPackage';
    public final string ADD_ON = 'Add On';
    public final string PACKAGE_BILLING_TYPE = 'packageBillingType';
    public final string COUNTRY_CODE_SG = 'SG';

    // start record types
    public final string RT_CUSTOMER_CONTACT = 'Customer Contact';
    public final string RT_ADDRESS_INTERNAL = 'Internal';
    public final string RT_ADDRESS_AIRLINE = 'Airline';
    public final string RT_ADDRESS_LOCAL = 'Local';
    public final string RT_ADDRESS_OVERSEAS = 'Overseas';
    public final string RT_MAILING_AGENT = 'Mailing Agent';
    public final string RT_INTER_DIV = 'Direct SPH Inter-Division';
    public final string RT_DIRECT_CORP = 'Direct Corporate';
    // end record types

    public final string DATA_TYPE_BOOLEAN = 'boolean';
    public final string DATA_TYPE_DATE = 'date';
    public final string DATA_TYPE_DATETIME = 'dateTime';
    public final string DATA_TYPE_INTEGER = 'integer';
    public final string DATA_TYPE_DOUBLE = 'double';
    public final string DATA_TYPE_PERCENT = 'percent';
    public final string DATA_TYPE_CURRENCY = 'currency';
    public final string DATA_TYPE_ID = 'id';
    
    public final string OBJECT_ACCOUNT = 'Account';
    public final string OBJECT_RECIPIENT_ADDRESS = 'RecipientAddress';
    public final string OBJECT_BILLING_ADDRESS = 'BillingAddress';
    public final string OBJECT_RECIPIENT_CONTACT = 'RecipientContact';
    public final string OBJECT_BILLING_CONTACT = 'BillingContact';
    public final string OBJECT_ORDER = 'Order';
    public final string OBJECT_OLI = 'OrderLineItem';
    public final string OBJECT_OLIG = 'OrderLineItemGift';

    public final string S_FIELD_ACC_NUM = 'AccountNumber';
    public final string S_FIELD_FIRST_NAME = 'FirstName';
    public final string S_FIELD_LAST_NAME = 'LastName';
    public final string S_FIELD_NAME = 'Name';
    public final string S_FIELD_RECORDTYPEID = 'RecordTypeId';

    public final string FIELD_COUNTRY = 'Country__c';
    public final string FIELD_POSTAL_CODE = 'Postal_Code__c';
    public final string FIELD_BUILDING_NAME_2 = 'Building_Name_2__c';
    public final string FIELD_BLOCK_HOUSE_NUM = 'Block_House_Number__c';
    public final string FIELD_STREET_NAME_2 = 'Street_Name_2__c';
    public final string FIELD_COMPANY_CODE = 'Company_Code__c';
    public final string FIELD_DEPARTMENT = 'Department__c';
    public final string FIELD_DIVISION_CODE = 'Division_Code__c';
    public final string FIELD_LOCATION_CODE = 'Location_Code__c';
    public final string FIELD_SECTION_CODE = 'Section_Code__c';
    public final string FIELD_PACKING_CODE = 'Packing_Code__c';
    public final string FIELD_CITY = 'City__c';
    public final string FIELD_LEVEL_NUM = 'Level_Number__c';
    public final string FIELD_UNIT_NUM = 'Unit_Number__c';
    public final string FIELD_RECIPIENT_INDICATOR = 'Recipient_Indicator__c';
    public final string FIELD_BILLING_INDICATOR = 'Billing_Indicator__c';
    public final string FIELD_VENDOR_CREDIT = 'Vendor_Credit__c';
    public final string FIELD_SUBSCRIBER_CHARGE = 'Subscriber_Charge__c';
    public final string FIELD_DELIVER_CHARGE_TYPE = 'Delivery_Charge_Type__c';
    public final string FIELD_BILLING_TYPE = 'Billing_Type__c';
    public final string FIELD_ORDER_TYPE = 'Order_Type__c';
    public final string FIELD_STATUS = 'Status__c';
    public final string FIELD_DTL_DATE = 'DTL_Date__c';
    public final string FIELD_CREDIT_BALANCE = 'Credit_Balance__c';
    public final string FIELD_MONTHLY_DEL_CHG_FULL_PAYMENT = 'Monthly_Delivery_Charge_for_Full_Payment__c';
    public final string FIELD_RECURRING_DEL_CHG = 'Recurring_Delivery_Charge__c';
    public final string FIELD_BA_CREATION_MODE = 'Billing_Account_Creation_Mode__c';
    public final string FIELD_FPP_DEL_CHG = 'Full_Prepaid_Delivery_Charge__c';
    public final string FIELD_ACQ_TYPE = 'Acquisition_Type__c';
    public final string FIELD_CREATION_MODE = 'Creation_Mode__c';
    public final string FIELD_ACCOUNT_NAME = 'Account_Name__c';
    public final string FIELD_ORDER_ACTION = 'Order_Action__c';
    public final string FIELD_DEL_CHG = 'Delivery_Charge__c';
    public final string FIELD_SUBJECT = 'Subject__c';
    public final string FIELD_BILLING_ACCOUNT = 'Billing_Account__c';
    public final string FIELD_PAYMENT_MODE = 'Payment_Mode__c';
    public final string FIELD_OTHER_PAYMENT_MODE = 'Other_Payment_Mode__c';
    public final string FIELD_CHECK_AMOUNT = 'Check_Amount__c';
    public final string FIELD_CHECK_DATED = 'Check_Dated__c';
    public final string FIELD_CHECK_ISSUING_BANK = 'Check_Issuing_Bank__c';
    public final string FIELD_CHECK_NUM = 'Check_No__c';
    public final string FIELD_CHECK_REM = 'Remarks_Check__c';
    public final string FIELD_AMOUNT_PAID = 'Amount_Paid__c';
    public final string FIELD_GL_CODE = 'GL_Code__c';
    public final string FIELD_ARMS_ACC_NUM = 'ARMS_Account_Number__c';
    public final string FIELD_ARMS_CUS_NUM = 'Customer_No__c';
    public final string FIELD_ARMS_BUS_PROFILE = 'Business_Profile__c';
    public final string FIELD_ARMS_DEBT_MGT = 'Debt_Management_Treatment__c';
    public final string FIELD_ARMS_CREATE_CUS = 'Create_ARMS_Customer_Account__c';
    public final string FIELD_ARMS_CREATE_ACC = 'Create_ARMS_Account_Only__c';
    public final string FIELD_PROMOTION_ID = 'Promotion_Id__c';
    public final string FIELD_TERM_DISCUSS = 'Term_is_discussed__c';
    public final string FIELD_PENALTY_CHG = 'Penalty_Charge__c';
    public final string FIELD_NEW_CONTRACT_PERIOD = 'New_Contract_Period__c';
    public final string FIELD_MAIN_PACKAGE_ID = 'Main_Package_ID__c';
    public final string FIELD_ADDON_PACKAGE = 'Addon_Package__c';
    public final string FIELD_QTY = 'Qty__c';
    public final string FIELD_VENDOR_MAILING_AGENT = 'Vendor_Mailing_Agent__c';
    public final string FIELD_IS_DIGITAL = 'Is_Digital__c';
    public final string FIELD_IS_AIO = 'Is_All_In_One__c';
    public final string FIELD_PACKAGE_FREQ = 'Main_Package_Frequency__c';
    public final string FIELD_PRODUCT_SUB_TYPE = 'Main_Package_Product_Sub_Type__c';
    public final string FIELD_PRODUCT_PLATFORM = 'Main_Package_Product_Platform__c';
    public final string FIELD_EARLIEST_START_DATE = 'Earliest_Start_Date__c';
    public final string FIELD_DELIVERY_METHOD = 'Direct_Sub_Delivery_Method__c';
    public final string FIELD_START_DATE = 'Start_Date__c';
    public final string FIELD_TERM_LENGTH = 'Term_Length__c';
    public final string FIELD_END_DATE = 'End_Date__c';
    public final string FIELD_SUBSCRIBED_AS = 'Subscribed_As__c';
    public final string FIELD_PACKAGE_PERIOD = 'Main_Package_Period__c';
    public final string FIELD_PACKAGE_TYPE = 'Main_Package_Type__c';
    public final string FIELD_PACKAGE_SUB_TYPE = 'Main_Package_Sub_Type__c';
    public final string FIELD_PRODUCT_FAMILY = 'Main_Package_Product_Family__c';
    public final string FIELD_PACKAGE_SUB_RATE = 'Main_Package_Subscription_Rate__c';
    public final string FIELD_PACKAGE_BILLING_TYPE = 'Main_Package_Billing_Type__c';
    public final string FIELD_ADDON_PRODUCT_PLATFORM = 'Add_On_Package_Product_Platform__c';
    public final string FIELD_ADDON_PRODUCT_SUB_TYPE = 'Add_On_Package_Product_Sub_Type__c';
    public final string FIELD_ADDON_SUB_RATE = 'Add_On_Package_Subscription_Rate__c';
    public final string FIELD_DELIVERED_BY = 'Delivered_By__c';
    public final string FIELD_PROMOTION_GIFT = 'Promotion_Gift__c';
    public final string FIELD_ORDER_QUANTITY = 'Order_Quantity__c';
    public final string FIELD_CONTRACT_END_DATE = 'Contract_End_Date__c';
    public final string FIELD_STAFF_ID = 'Staff_ID__c';
    public final string FIELD_CONTACT_PERSON = 'Contact_Person__c';
    public final string FIELD_AIRLINE_IND = 'Airline_Indicator__c';
    public final string FIELD_DATE_OF_BIRTH = 'Date_of_Birth__c';
    public final string FIELD_DATE_SINCE = 'Date_Since__c';
    // Start UD-3660 14Apr16 JohnD - added variable for credit card
    public final string FIELD_CC_EXP_MONTH = 'CreditCardExpirationMonth';
    public final string FIELD_CC_EXP_YEAR = 'CreditCardExpirationYear';
    public final string FIELD_CC_HOLDER_NAME = 'CreditCardHolderName';
    public final string FIELD_CC_NUMBER = 'CreditCardNumber';
    public final string FIELD_CC_TYPE = 'CreditCardType';
    public final string FIELD_CC_EMAIL = 'CreditCardEmail';
    public final string FIELD_CC_ADDRESS = 'CreditCardAddress1';
    public final string FIELD_CC_CITY = 'CreditCardCity';
    public final string FIELD_CC_COUNTRY = 'CreditCardCountry';
    public final string FIELD_CC_SEC_CODE = 'CreditCardSecurityCode';  
    
    // End UD-3660 14Apr16 JohnD - added variable for credit card

    // start column identifier
    public final string IDE_ACC_RECORDTYPEID = OBJECT_ACCOUNT + S_FIELD_RECORDTYPEID;
    public final string IDE_ACC_ACCNUMBER = OBJECT_ACCOUNT + S_FIELD_ACC_NUM;
    public final string IDE_ACC_STAFF_ID = OBJECT_ACCOUNT + FIELD_STAFF_ID;
    public final string IDE_ACC_CONTACT_PERSON = OBJECT_ACCOUNT + FIELD_CONTACT_PERSON;
    public final string IDE_ACC_AIRLINE_IND = OBJECT_ACCOUNT + FIELD_AIRLINE_IND;
    public final string IDE_ACC_DATE_OF_BIRTH = OBJECT_ACCOUNT + FIELD_DATE_OF_BIRTH;
    public final string IDE_ACC_DATE_SINCE = OBJECT_ACCOUNT + FIELD_DATE_SINCE;
    
    
    public final string IDE_RC_ADDRESS_RECORDTYPEID = OBJECT_RECIPIENT_ADDRESS + S_FIELD_RECORDTYPEID;
    public final string IDE_RC_FIRST_NAME = OBJECT_RECIPIENT_CONTACT + S_FIELD_FIRST_NAME;
    public final string IDE_RC_LAST_NAME = OBJECT_RECIPIENT_CONTACT + S_FIELD_LAST_NAME;
    public final string IDE_RC_ADDRESS_POSTAL_CODE = OBJECT_RECIPIENT_ADDRESS + FIELD_POSTAL_CODE;
    public final string IDE_RC_ADDRESS_COUNTRY = OBJECT_RECIPIENT_ADDRESS + FIELD_COUNTRY;
    public final string IDE_RC_ADDRESS_COMPANY_CODE = OBJECT_RECIPIENT_ADDRESS + FIELD_COMPANY_CODE;
    public final string IDE_RC_ADDRESS_DEPARTMENT = OBJECT_RECIPIENT_ADDRESS + FIELD_DEPARTMENT;
    public final string IDE_RC_ADDRESS_DIVISION_CODE = OBJECT_RECIPIENT_ADDRESS + FIELD_DIVISION_CODE;
    public final string IDE_RC_ADDRESS_LOCATION_CODE = OBJECT_RECIPIENT_ADDRESS + FIELD_LOCATION_CODE;
    public final string IDE_RC_ADDRESS_SECTION_CODE = OBJECT_RECIPIENT_ADDRESS + FIELD_SECTION_CODE;
    public final string IDE_RC_ADDRESS_CITY = OBJECT_RECIPIENT_ADDRESS + FIELD_CITY;
    public final string IDE_RC_ADDRESS_PACKING_CODE = OBJECT_RECIPIENT_ADDRESS + FIELD_PACKING_CODE;
    public final string IDE_RC_ADDRESS_LEVEL_NUM = OBJECT_RECIPIENT_ADDRESS + FIELD_LEVEL_NUM;
    public final string IDE_RC_ADDRESS_UNIT_NUM = OBJECT_RECIPIENT_ADDRESS + FIELD_UNIT_NUM;
    
    public final string IDE_BC_ADDRESS_RECORDTYPEID = OBJECT_BILLING_ADDRESS + S_FIELD_RECORDTYPEID;
    public final string IDE_BC_FIRST_NAME = OBJECT_BILLING_CONTACT + S_FIELD_FIRST_NAME;
    public final string IDE_BC_LAST_NAME = OBJECT_BILLING_CONTACT + S_FIELD_LAST_NAME;
    public final string IDE_BC_ADDRESS_POSTAL_CODE = OBJECT_BILLING_ADDRESS + FIELD_POSTAL_CODE;
    public final string IDE_BC_ADDRESS_COMPANY_CODE = OBJECT_BILLING_ADDRESS + FIELD_COMPANY_CODE;
    public final string IDE_BC_ADDRESS_DEPARTMENT = OBJECT_BILLING_ADDRESS + FIELD_DEPARTMENT;
    public final string IDE_BC_ADDRESS_DIVISION_CODE = OBJECT_BILLING_ADDRESS + FIELD_DIVISION_CODE;
    public final string IDE_BC_ADDRESS_LOCATION_CODE = OBJECT_BILLING_ADDRESS + FIELD_LOCATION_CODE;
    public final string IDE_BC_ADDRESS_SECTION_CODE = OBJECT_BILLING_ADDRESS + FIELD_SECTION_CODE;
    public final string IDE_BC_ADDRESS_CITY = OBJECT_BILLING_ADDRESS + FIELD_CITY;
    public final string IDE_BC_ADDRESS_PACKING_CODE = OBJECT_BILLING_ADDRESS + FIELD_PACKING_CODE;
    public final string IDE_BC_ADDRESS_LEVEL_NUM = OBJECT_BILLING_ADDRESS + FIELD_LEVEL_NUM;
    public final string IDE_BC_ADDRESS_UNIT_NUM = OBJECT_BILLING_ADDRESS + FIELD_UNIT_NUM;

    
    public final string IDE_ORDER_BILLING_ACCOUNT = OBJECT_ORDER + FIELD_BILLING_ACCOUNT;
    public final string IDE_ORDER_PAYMENT_MODE = OBJECT_ORDER + FIELD_PAYMENT_MODE;
    public final string IDE_ORDER_OTHER_PAYMENT_MODE = OBJECT_ORDER + FIELD_OTHER_PAYMENT_MODE;
    public final string IDE_ORDER_CUST_NUM = OBJECT_ORDER + FIELD_ARMS_CUS_NUM;
    public final string IDE_ORDER_GL_CODE = OBJECT_ORDER + FIELD_GL_CODE;
    public final string IDE_ORDER_ARMS_DEBT_MGT = OBJECT_ORDER + FIELD_ARMS_DEBT_MGT;
    public final string IDE_ORDER_ARMS_BUS_PROFILE = OBJECT_ORDER + FIELD_ARMS_BUS_PROFILE;
    public final string IDE_ORDER_ARMS_ACC_NUM = OBJECT_ORDER + FIELD_ARMS_ACC_NUM;
    public final string IDE_ORDER_CHECK_DATED = OBJECT_ORDER + FIELD_CHECK_DATED;
    
    // Start UD-3660 14Apr16 JohnD - added variable for credit card
    public final string IDE_ORDER_CC_EXP_MONTH = OBJECT_ORDER + FIELD_CC_EXP_MONTH;
    public final string IDE_ORDER_CC_EXP_YEAR = OBJECT_ORDER + FIELD_CC_EXP_YEAR;
    public final string IDE_ORDER_CC_HOLDER_NAME = OBJECT_ORDER + FIELD_CC_HOLDER_NAME;
    public final string IDE_ORDER_CC_NUMBER = OBJECT_ORDER + FIELD_CC_NUMBER;
    public final string IDE_ORDER_CC_TYPE = OBJECT_ORDER + FIELD_CC_TYPE;
    public final string IDE_ORDER_CC_EMAIL = OBJECT_ORDER + FIELD_CC_EMAIL;
    public final string IDE_ORDER_CC_ADDRESS = OBJECT_ORDER + FIELD_CC_ADDRESS;
    public final string IDE_ORDER_CC_CITY = OBJECT_ORDER + FIELD_CC_CITY;
    public final string IDE_ORDER_CC_COUNTRY = OBJECT_ORDER + FIELD_CC_COUNTRY;
    public final string IDE_ORDER_CC_SEC_CODE = OBJECT_ORDER + FIELD_CC_SEC_CODE;
    // End UD-3660 14Apr16 JohnD - added variable for credit card
    
    public final string IDE_OLI_PROMOTION_ID = OBJECT_OLI + FIELD_PROMOTION_ID;
    public final string IDE_OLI_PACKAGE_ID = OBJECT_OLI + FIELD_MAIN_PACKAGE_ID;
    public final string IDE_OLI_ADDON_PACKAGE = OBJECT_OLI + FIELD_ADDON_PACKAGE;
    public final string IDE_OLI_DELIVERED_BY = OBJECT_OLI + FIELD_DELIVERED_BY;
    public final string IDE_OLI_VENDOR_MAILING_AGENT = OBJECT_OLI + FIELD_VENDOR_MAILING_AGENT;
    public final string IDE_OLI_QTY = OBJECT_OLI + FIELD_QTY;
    public final string IDE_OLI_START_DATE = OBJECT_OLI + FIELD_START_DATE;
    
    public final string IDE_OLIG_PROMOTION_GIFT = OBJECT_OLIG + FIELD_PROMOTION_GIFT;
    // end column identifier
    
    public final string DELIVERED_BY_MAILING_AGENT = 'Mailing Agent';
    public final string DELIVERED_BY_VENDOR = 'Vendor';
    public final string DELIVERED_BY_BOTH = 'Vendor or Mailing Agent';
    public final string DELIVERED_BY_NONE = 'None';

    // Start D-4334 19Jan16 JohnD
    public final set<string> paymentModeSet = new set<string>{ PAYMENT_MODE_OTHER, PAYMENT_MODE_CASH, PAYMENT_MODE_CHECK, PAYMENT_MODE_CC };
    public final set<string> otherPaymentModeSet = new set<string>{ OTHER_PAYMENT_MODE_INVOICE, OTHER_PAYMENT_MODE_INTERNAL_CHG, OTHER_PAYMENT_MODE_ENETS, OTHER_PAYMENT_MODE_IPP, OTHER_PAYMENT_MODE_EXT_PARTIES, OTHER_PAYMENT_MODE_FREELIST };
    // End D-4334 19Jan16 JohnD

    // end constants declaration
    
    public string templateUrl { get; set; }
    public string templateName { get; set; }
    public string referenceUrl { get; set; }
    public string referenceName { get; set; }
  
    public map<string, Id> mailingAgentCode_Id = new map<string, Id>();   
    public map<string, Account> accountNumber_account = new map<string, Account>();
    public map<string, zuora__CustomerAccount__c> billingAccountNumber_billingAccount = new map<string, zuora__CustomerAccount__c>();
    public map<string, set<string>> accountNumber_billingAccountNumberSet = new map<string, set<string>>();
    public map<string, set<string>> accountNumber_invoiceBillingTypeSet = new map<string, set<string>>();
    public map<string, string> armsCutomerNumber_accountNumber = new map<string, string>();
    public map<string, Contact> existingContactIdentifier_contact = new map<string, Contact>();
    public map<string, set<string>> recordTypeName_fieldSet = new map<string, set<string>>();
    public map<string, id> companyCode_id = new map<string, id>();
    public map<string, id> departmentCode_id = new map<string, id>();
    public map<string, id> divisionCode_id = new map<string, id>();
    public map<string, id> locationCode_id = new map<string, id>();
    public map<string, id> sectionCode_id = new map<string, id>();
    public map<string, id> cityCode_id = new map<string, id>();
    public map<string, id> packingCode_id = new map<string, id>(); 
    public map<integer, string> columnIndex_fieldName = new map<integer, string>();
    public map<string, set<integer>> objectName_columnIndexSet = new map<string, set<integer>>();
    public map<string, sobject> accountIdentifier_account = new map<string, sobject>();
    public map<string, sobject> addressIdentifier_address = new map<string, sobject>();
    public map<string, sobject> contactIdentifier_contact = new map<string, sobject>();
    public map<string, sobject> orderIdentifier_order = new map<string, sobject>();
    public map<string, sobject> orderLineItemIdentifier_orderLineItem = new map<string, sobject>();
    public map<string, sobject> orderLineItemGiftIdentifier_orderLineItemGift = new map<string, sobject>();
    public map<string, set<integer>> identifierName_columnIndexSet = new map<string, set<integer>>();
    public map<string, id> recordTypeName_recordTypeId = new map<string, id>();
    public map<string, Promotion__c> promotionCode_promotion = new map<string, Promotion__c>();
    public map<string, Package__c> packageCode_package = new map<string, Package__c>();
    public map<string, Promotion_Gift__c> promotionCodeGiftCode_promotionGift = new map<string, Promotion_Gift__c>();
    public map<id, Product_Publication__c> productId_productPublication = new map<id, Product_Publication__c>();
    public map<string, id> countryCode_countryId = new map<string, id>();
    public map<string, Singpost_Address__c> postalCode_singpostAddress = new map<string, Singpost_Address__c>();
    public map<string, id> postalCode_postalId = new map<string, id>();
    public map<string, string> postalCode_AddressType = new map<string, string>();
    public map<string, string> contactIdentifier_accountIdentifier = new map<string, string>();
    public map<string, string> contactIdentifier_addressIdentifier = new map<string, string>();
    public map<string, string> orderIdentifier_recipientContactIdentifier = new map<string, string>();
    public map<string, string> orderIdentifier_billingContactIdentifier = new map<string, string>();
    public map<string, string> orderIdentifier_accountIdentifier = new map<string, string>();
    public map<string, string> orderLineItemIdentifier_orderIdentifier = new map<string, string>();
    public map<string, string> orderLineItemGiftIdentifier_orderLineItemIdentifier = new map<string, string>();
    public map<string, list<sobject>> orderIdentifier_vendorOrderLineItemList = new map<string, list<sobject>>();
    public map<string, list<sobject>> orderIdentifier_agentOrderLineItemList = new map<string, list<sobject>>();
    public map<string, decimal> orderIdentifier_totalSubscriptionRate = new map<string, decimal>();
    public map<id, string> orderId_orderIdentifier = new map<id, string>();
    public map<id, string> orderLineItemId_orderLineItemIdentifier = new map<id, string>();
    public map<string, decimal> orderIdentifier_totalPostageCharge = new map<string, decimal>();
    public map<string, decimal> deliveryChargeType_amount = new map<string, decimal>();
    public map<string, string> creditCardField_value;
    public map<string, map<string, string>> orderIdentifier_creditCard = new map<string, map<string, string>>();
    public map<string, integer> fieldIdentifier_index = new map<string, integer>();
    public map<string, decimal> zoneProduct_postageCharge = new map<string, decimal>();
    public map<string, string> countryCode_zoneCode = new map<string, string>();
    public map<string, set<id>> packageCode_productIdSet = new map<string, set<id>>();
    public map<id, Set<String>> productId_setDelMethod = new  map<id, Set<String>>();
    // Start D-4801 23Jun16 JohnD - local address pre-validation
    public map<string, boolean> localAddressIdentifier_isInAddressDetail = new map<string, boolean>();
    public set<string> localAddressIdentifierSet = new set<string>();
    public string localAddressIdentifier = '';
    public final string ADD_IDEN_SEPARATOR = ';';
    public final string ADD_IDEN_DELIMITER = 'xxxxx';
    public final string ADD_IDEN_FLAG = '@';
    // End D-4801 23Jun16 JohnD - local address pre-validation
    
    public list<Case> caseList = new list<Case>();
    public list<string> warningList = new list<string>();
    public list<exception> exceptionList = new list<exception>();
    public list<list<string>> rowContent = new list<list<string>>();
    public list<string> rowHeader = new list<string>();
    public set<string> promotionPackageIdentifierSet = new set<string>();
    public set<id> urgentOrderIdSet = new set<id>();
    public set<string> existingContactAddressRecordTypeName = new set<string>();
    public set<string> existingContactFistName = new set<string>();
    public set<string> existingContactLastName = new set<string>();
    public set<integer> emptyRowSet = new set<integer>();
    public set<string> giftCodeSet = new set<string>();
    public set<string> setDeliveryMethod = new set<string>();
    

    public date dtlDate = SM_SubscriptionHelper.getDtlDate();
    public string documentName;
    public string contactIdentifier;
    public string contactAddressRecordTypeName;
    public string contactFirstName;
    public string contactLastName;
    
    public boolean isErrorEncountered = false;
    
    public string creditCardPaymentMethodId;	// Start/End UD-3660 14Apr16 JohnD
    
    public void clearAllData() {
        
        mailingAgentCode_Id = new map<string, Id>();
        accountNumber_account = new map<string, Account>();
        billingAccountNumber_billingAccount = new map<string, zuora__CustomerAccount__c>();
        accountNumber_billingAccountNumberSet = new map<string, set<string>>();
        accountNumber_invoiceBillingTypeSet = new map<string, set<string>>();
        armsCutomerNumber_accountNumber = new map<string, string>();
        existingContactIdentifier_contact = new map<string, Contact>();
        recordTypeName_fieldSet = new map<string, set<string>>();
        companyCode_id = new map<string, id>();
        departmentCode_id = new map<string, id>();
        divisionCode_id = new map<string, id>();
        locationCode_id = new map<string, id>();
        sectionCode_id = new map<string, id>();
        cityCode_id = new map<string, id>();
        packingCode_id = new map<string, id>(); 
        columnIndex_fieldName = new map<integer, string>();
        objectName_columnIndexSet = new map<string, set<integer>>();
        accountIdentifier_account = new map<string, sobject>();
        addressIdentifier_address = new map<string, sobject>();
        contactIdentifier_contact = new map<string, sobject>();
        orderIdentifier_order = new map<string, sobject>();
        orderLineItemIdentifier_orderLineItem = new map<string, sobject>();
        orderLineItemGiftIdentifier_orderLineItemGift = new map<string, sobject>();
        identifierName_columnIndexSet = new map<string, set<integer>>();
        recordTypeName_recordTypeId = new map<string, id>();
        promotionCode_promotion = new map<string, Promotion__c>();
        packageCode_package = new map<string, Package__c>();
        promotionCodeGiftCode_promotionGift = new map<string, Promotion_Gift__c>();
        productId_productPublication = new map<id, Product_Publication__c>();
        countryCode_countryId = new map<string, id>();
        postalCode_singpostAddress = new map<string, Singpost_Address__c>();
        postalCode_postalId = new map<string, id>();
        postalCode_AddressType = new map<string, string>();
        contactIdentifier_accountIdentifier = new map<string, string>();
        contactIdentifier_addressIdentifier = new map<string, string>();
        orderIdentifier_recipientContactIdentifier = new map<string, string>();
        orderIdentifier_billingContactIdentifier = new map<string, string>();
        orderIdentifier_accountIdentifier = new map<string, string>();
        orderLineItemIdentifier_orderIdentifier = new map<string, string>();
        orderLineItemGiftIdentifier_orderLineItemIdentifier = new map<string, string>();
        orderIdentifier_vendorOrderLineItemList = new map<string, list<sobject>>();
        orderIdentifier_agentOrderLineItemList = new map<string, list<sobject>>();
        orderIdentifier_totalSubscriptionRate = new map<string, decimal>();
        orderId_orderIdentifier = new map<id, string>();
        orderLineItemId_orderLineItemIdentifier = new map<id, string>();
        orderIdentifier_totalPostageCharge = new map<string, decimal>();
        deliveryChargeType_amount = new map<string, decimal>();
        creditCardField_value = null;
        orderIdentifier_creditCard = new map<string, map<string, string>>();
        fieldIdentifier_index = new map<string, integer>();
        urgentOrderIdSet = new set<id>();
        existingContactAddressRecordTypeName = new set<string>();
        existingContactFistName = new set<string>();
        existingContactLastName = new set<string>();
        emptyRowSet = new set<integer>();
        giftCodeSet = new set<string>();
        caseList = new list<Case>();
        warningList = new list<string>();
        exceptionList = new list<exception>();
        promotionPackageIdentifierSet = new set<string>();
        documentName = null;
        rowHeader = null;
        rowContent = null;
        contactIdentifier = null;
        contactAddressRecordTypeName = null;
        contactFirstName = null;
        contactLastName = null;        
        isErrorEncountered = false; 
        productId_setDelMethod = new  map<id, Set<String>>();
        zoneProduct_postageCharge = new map<string, decimal>();
        countryCode_zoneCode = new map<string, string>();
        packageCode_productIdSet = new map<string, set<id>>();
	    // Start D-4801 23Jun16 JohnD - local address pre-validation
	    map<string, boolean> localAddressIdentifier_isInAddressDetail = new map<string, boolean>();
	    set<string> localAddressIdentifierSet = new set<string>();
	    string localAddressIdentifier = '';
	    // End D-4801 23Jun16 JohnD - local address pre-validation
        
    }
        
}        // End D-4456 07Mar16 JohnD - credit card validation