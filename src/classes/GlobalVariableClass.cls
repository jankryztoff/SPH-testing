/**
 * Class Name: GlobalVariableClass
 * @author: Jb Domingo
 * Date: 8/15/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class for global variables
 *
 */
 

    /*
    * ------Revision------
    * Version 1.0: Pilot Release
    * By: <Kristine Campang>
    * Description: Added some variables
    */

 Global class GlobalVariableClass{
 
    //Start PD-0350 VPernicia
    global static final string AdjustmentUOM = 'Adjustment';
    global static final string AdjustmentNoTaxUOM= 'Adjustment No Tax';
    //End PD-0350 VPernicia
 
    //Start UD-2016 VPernicia
    global static final string EMAIL_DELIVERY_NOTIFICATION = 'Delivery Notification'; 
    //End UD-2016 VPernicia 
    global static final string USERNAME = 'username'; 
    global static final string SVC = 'svc';
    global static final string IP = 'ip';
    global static final string QUOTA= 'quota';
    global static final string API_UPDATECONCURRENT = 'apiUpdateConcurrentConfig';
    global static final string API_ENABLE_SERVICE = 'apiEnableService';
    global static final string API_CHECK_USER = 'apiCheckUserAvailability';
    global static final string DISPLAY_NAME = 'displayName';
    global static final string API_CHECK_DISPLAY_NAME = 'apiCheckDisplayNameAvailability';
    global static final string FFF = 'fff';
    global static final string UUU = 'uuu'; 
    global static final string PPP = 'ppp';
    global static final string API_CHECK_AUTH = 'apiCheckAuth'; 
    global static final string API_CHECK_AUTH2 = 'apiCheckAuth2';
    global static final string API_CHECK_AUTH3 = 'apiCheckAuth3';       
    global static final string PASSWORD = 'password';
    global static final string PASS_CHALLENGE = 'passwordChallenge';
    global static final string PASS_RESPONSE = 'passwordResponse';
    global static final string FNAME = 'firstName';
    global static final string LNAME = 'lastName';
    global static final string EMAIL = 'email';
    global static final string PHONE = 'phoneNumber';
    global static final string ENABLE = 'enable';
    global static final string API_SIGNUP = 'apiSignUp';
    global static final string API_VIEW_USER_DETAILS = 'apiViewUserDetails';
    global static final string API_RESET_PASSWORD = 'apiResetUserPassword';
    global static final string NEWPASSWORD = 'newPassword';
    global static final string API_ENABLE_ACCOUNT = 'apiEnableAccount';
    //START UD-0877 04-27-2015 MarvinG
    global static final string API_DISABLE_ACCOUNT = 'apiDisableAccount';
    //END UD-0877 04-27-2015 MarvinG
    
    global static final string EMPTYSTR = '';
    global static final string API_DISABLE_SERVICE = 'apiDisableService';
    
    //Variable use for Renewal Subscription Redirect
    global static final string SUBRETURL = 'retUrl';
    
    //START UD-2375 Dags Variable Message Declaration
    global static final string BUSDEBT1 = ' (Values Should be Business Profile:';
    global static final string BUSDEBT2 = ' and Debt Management:';
    //END UD-2375 Dags Variable Message Declaration
    
    //START PD-0116 Gdelrosario/JDacutan : added  for COS
    global static final string CASECHANGEOFSUBSCRIPTION = 'Case_Change of Subscription';
    //END PD-0116 Gdelrosario/JDacutan : added  for
    
    //Variable use for RefundComputation
    global static final string UOM = 'UOM';
    global static final string QUANTITY = 'Quantity';
    global static final string STARTDATETIME = 'StartDateTime';
    global static final string ACCOUNTID = 'AccountId';
    global static final string SUBSCRIPTIONID = 'SubscriptionId';
    global static final string CHARGEID = 'ChargeId';
    
    //Variable use for AsiaOneFacade
    global static final string ENDPOINTDELEGATOR = 'Endpoint Delegator';
    global static final string POSTMETHOD = 'PostMethod';
    global static final string CONTENTTYPE = 'Content-Type';
    global static final string APPLICATIONJSON = 'ApplicationJSON';
    
    //Variable use for CreateCase
    //record types
    global static final string RECTYPE_START_SUBSCRIPTION = 'Start Subscription';
    global static final string RECTYPE_STOP_SUBSCRIPTION = 'Stop Subscription';
    global static final string RECTYPE_CHANGE_OF_SUBSCRIPTION = 'Change of Subscription';
    global static final string RECTYPE_RENEWAL_OF_SUBSCRIPTION = 'Renewal of Subscription'; //START-END D-4099 K. Tan 12/18/2015    
    //START UD-3424 01/28/16 RReyes
    global static final string RECTYPE_COMPLAINT_NEWSPAPER = 'Complaint - Newspaper';
    global static final string RECTYPE_COA = 'Change of Address/Vendor';
    //END UD-3424 01/28/16 RReyes
    //status
    global static final string STATUS_NEW = 'New';
    global static final string STATUS_PENDING = 'Pending';
    global static final string STATUS_DRAFT = 'Draft';
    global static final string STATUS_VOID = 'Void';
    global static final string STATUS_CANCELLED = 'Cancelled';
    global static final string STATUS_PROVISIONED = 'Provisioned';
    global static final string STATUS_CLOSE = 'Close';
    global static final string STATUS_CLOSED = 'Closed';
    global static final string STATUS_PENDING_VENDOR_ASSIGN = 'Pending Vendor Assignment';
    
    
    //Substatus
    global static final string SUB_STATUS_FOR_RETENTION_OFFER = 'For Retention Offer';
    global static final string SUB_STATUS_WAITING_FOR_URGENT_STOP = 'Waiting for Urgent Stop Approval';
    global static final string SUB_STATUS_WAITING_FOR_URGENT_START = 'Waiting for Urgent Start Approval';
    //START UD-0778 4/29/2015 Added by Manolo Valena - Changed from "Waived" to "Waiver"
    global static final string SUB_STATUS_WAITING_FOR_WAIVED = 'Waiting for Waiver Approval';
    //END UD-0778 4/29/2015 Added by Manolo Valena
    global static final string SUB_STATUS_READY_FOR_SUBMISSION = 'Ready for Submission';
    global static final string SUB_STATUS_PROVISIONING = 'Provisioning';
    global static final string SUB_STATUS_PROVISIONED = 'Provisioned';
    global static final string SUB_STATUS_CLOSE = 'Closed';
    global static final string SUB_STATUS_STOP_COMPLETED = 'Subscription Stop Completed';
    global static final string SUB_STATUS_SUBS_CREATED ='Subscription Created';
    global static final string SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN = 'Waiting for Vendor Assignment';
    //START: D-1355 01/07/15 Added by ABanaag    
    global static final string SUB_STATUS_READY_FOR_SUBSCRIPTION = 'Ready for Subscription';
    //END: D-1355 01/07/15 Added by ABanaag  
    //START D-2003 D-1977 AddedBy FrancisBenzon : Variables for Change of Subscription Sub Status
    global static final string SUB_STATUS_CHANGE_OF_SUB_COMPLETED = 'Change of Subscription Completed';
    //END D-2003 D-1977 AddedBy FrancisBenzon : Variables for Change of Subscription Sub Status
    
    //category
    global static final string CATEGORY_SUBSCRIPTION_REQUEST = 'Subscription Request';
    global static final string CATEGORY_START_SUBSCRIPTION = 'Start Subscription';
    
    //Subcategory
    global static final string SUBCATEGORY_START_SUBCRIPTION = 'Start Subscription';
    global static final string SUBCATEGORY_STOP_SUBCRIPTION = 'Stop Subscription';
    global static final string SUBCATEGORY_CHANGE_OF_SUBCRIPTION= 'Change of Subscription Packages';
    //Start MMallorca UD-1454 Add Renewal of Subscription 06/16/2015
    global static final string SUBCATEGORY_RENEWAL_OF_SUBCRIPTION = 'Renewal of Subscription';
    //End MMallorca UD-1454 06/16/2015
    global static final string SUBCATEGORY_CHANGE_OF_ADDRESS = 'Change of Address'; //START/END UD-3381 12/15/15 RReyes
    //Subject
    global static final string SUBJECT_START_SUBSCRIPTION = 'Start Subscription';
    global static final string SUBJECT_STOP_SUBSCRIPTION = 'Stop Subscription';
    //START UD-0420 3/25/2015 GDEL ROSARIO : Added renewal Subject for renewal of subscription
    global static final string SUBJECT_RENEWAL_OF_SUBSCRIPTION = 'Renewal of Subscription';
    //END UD-0420 3/25/2015 GDEL ROSARIO : Added renewal Subject for renewal of subscription
     //end Create Case
    
    //variable use for Amendment
    global static final string CONTRACT_EFFECTIVEDATE = 'ContractEffectiveDate';
    global static final string DESCRIPTION = 'Description';
    global static final string CANCEL_A_SUBSCRIPTION_AMENDMENT = 'Cancel a Subscription amendment';
    global static final string EFFECTIVE_DATE = 'EffectiveDate';
    global static final string NAME = 'Name';
    global static final string COMPLETED = 'Completed';
    global static final string STATUS = 'Status';
    global static final string SUBSCRIPTION_ID = 'SubscriptionId';
    global static final string TYPE = 'Type';
    global static final string CANCELATION = 'Cancellation';
    global static final string AMENDMENT = 'Amendment';

    //Variable use for RetentionEligibility
    global static final string ACCOUNT_DIRECT_INDIVIDUAL = 'Account_Direct Individual';
    global static final string ACCOUNT_VENDOR_SUBSCRIBER = 'Account_Vendor Subscriber';
    global static final string ACCOUNT_MAILING_AGENT = 'Account_Mailing Agent';
           
    //variables for Subscription
    global static final string SUBSCRIPTION_TYPE_DELIVERY = 'Delivery';
    global static final string SUBSCRIPTION_TYPE_PUBLICATION = 'Publication';
    global static final string SUBSCRIPTION_TYPE_POSTAGE = 'Postage'; //KRITHIKA 2/13/2015 D-2103
    global static final string SUBSCRIPTION_TYPE_GIFT = 'Gift'; //START END Wenjun 2/25/15 D-2327
    global static final string SUBSCRIPTION_STATUS_ACTIVE = 'Active';
    global static final string SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID = 'Full Prepaid';
    
    //variable use for SP_MidMonthTempStopBatch
    global static final integer MAX_NO_OF_COPY_30 = 30;
    
    // START D-2199    2015-02-17    Mic De Lara
    //classification for notifications
    global static final string NOTIF_CLASS_DIRECT = 'direct sub';
    global static final string NOTIF_CLASS_VENDOR = 'vendor sub';
    // END    D-2199

    //variable use for SP_SendEmailNotifForFailedCCBatch
    global static final string ZUORA_ACCOUNTNUMBER = 'Zuora__AccountNumber__c';
    global static final string MAILINGADDRESS = 'MailingAddress';
    global static final string EXPIRATION_DATE = 'Expiration_Date__c';
    global static final string ZUORA_CREDITCARDMASKNUMBER = 'Zuora__CreditCardMaskNumber__c';
    global static final string PAYMENT_AMOUNT = 'Payment_amount__c';
    //START D-2039 2/6/2015 Added By J. Sarion - Added for Email Notif
    global static final string PAYMENT_DATE = 'Payment_Date__c';
    //END D-2039 2/6/2015 Added By J. Sarion
    
    //variable use for SP_SendEmailNotifForSubsRenewalsBatch
    global static final integer DAYS_TO_EXPIRE_14 = 14;
    global static final string ZUORA_STATUS_ACTIVE = 'Active';
    global static final string ZUORA_STATUS_CANCEL = 'Cancelled'; //START END D-2105 D-2261 D-2337 D-2349 D-2452 D-2453 Wenjun 16-03-15
    global static final string FIRST_NAME = 'FirstName';
    global static final string LAST_NAME = 'LastName';
    global static final string ACCOUNT_NAME = 'AccountName';
    global static final string ACCOUNT_NUMBER = 'AccountNumber';
    global static final string EXPIRY_DATE = 'ExpiryDate';
    
    //variable use for changeofsubscription
    global static final string ADMIN_CHARGE = 'Admin Charge';
    
    //variable use for TempStopDirectController
    global static final string TEMP_STOP_APPROVED = 'Temp Stop Approved';
    global static final string WAITING_URGENT_TEMPSTOP_RESTART_APPROVAL = 'Waiting for Urgent Temp Stop/Restart Approval';
    
    //variable use for SP_loadMonthlyUsageDataBatch
    global static final integer MAX_NO_OF_RECORD_50 = 50;
    global static final integer MAX_BATCH_SIZE_450 = 450;
    global static final string FAILED_USAGE_TO_ZUORA = 'Failed to send Usage records to Zuora';
    global static final string FAILED_USAGE_RECORDS_TO_ZUORA = 'The following records failed upon sending to Zuora: \n';    

    //variables for scheduled processes
    global static final decimal GST_AMOUNT = 1.07;
    global static final string START_NEW = 'Start - New';
    //START D-2212 03-06-2015 Marvin Gatchalian
    global static final string START_URGENT = 'Start - Urgent';
    global static final string STOP_NORMAL = 'Stop';
    //START D-2212 03-06-2015 Marvin Gatchalian
    global static final string STOP_URGENT = 'Stop - Urgent';
    global static final string STOP_TEMPSTOP = 'Stop - TempStop';
    // START D-2199    2015-02-17    Mic De Lara
    global static final string STOP_TEMPSTOP_URGENT = 'Stop-Urgent TempStop';
    // END D-2199
    global static final string START_CONVERSION = 'Start-Conversion';
    
    //variable for StopSubOrderEntryDirectController
    global static final string PAGEREFERENCE_TOVIEW = '/apex/StopSub_Order_Entry_Direct_View?';
    global static final string PAGEREFERENCE_TOEDIT = '/apex/StopSub_Order_Entry_Direct_Edit?';
    global static final string PARAMETER_ORDERID = 'orderId';
    global static final string PARAMETER_ACCOUNTID = 'accountId';
    global static final string PARAMETER_RECORDTYPE = 'recordtype';
    //START D-2327 25/02/15 Wenjun - Package Type and Sub Type
    global static final string PACKAGETYPE_ADDON = 'Add On';
    global static final string PACKAGETYPE_BUNDLE = 'Bundle';
    global static final string PACKAGETYPE_BASE = 'Base';
    global static final string PACKAGETYPE_DISCOUNT = 'Discount';
    global static final string PACKAGETYPE_GRACE = 'Grace Period';
    global static final string PACKAGESUBTYPE_SINGLE = 'Single';
    global static final string PACKAGESUBTYPE_TIERED = 'Tiered';
    global static final string PACKAGESUBTYPE_EXTENSION = 'Extension';
    //Rate Plan Type
    global static final string RATEPLANTYPE_BILL = 'Bill Plan';
    global static final string RATEPLANTYPE_GIFT = 'Gift';
    global static final string RATEPLANTYPE_DELIVERY = 'Delivery Charge';
    global static final string RATEPLANTYPE_POSTAGE = 'Postage Charge';
    global static final string RATEPLANNAME_PRORATION = 'Proration';
    //Subscription Product Charge Type
    global static final string SPC_TYPE_ONETIME = 'One-Time';
    global static final string SPC_TYPE_RECURRING = 'Recurring';
    global static final string SPC_TYPE_USAGE = 'Usage';
    //Subscription Product Charge Model
    global static final string SPC_MODEL_UNIT = 'Per Unit Pricing';
    global static final string SPC_MODEL_DISCOUNT = 'Discount-Percentage';
    //END D-2327 25/02/15 Wenjun
    global static final string FREQUENCY_DEFAULT = 'Default';
    global static final string FREQUENCY_MONFRI = 'Mon-Fri';
    global static final string FREQUENCY_FRISUN = 'Fri-Sun';
    global static final string FREQUENCY_SATSUN = 'Sat-Sun';
        
    //variable for StopSubOrderEntry_VendorController
    global static final string PAGEREFERENCE_TOVIEWVENDOR = '/apex/StopSubOrderEntry_Vendor_View?';
    global static final string PARAMETER_RECORDTYPEID = 'recordtypeId';
    
    //variable for ChangeInAddressExtensionNew
    global static final string PAGEREFERENCE_CASEASSIGN = '/apex/CaseAssignSelectedSubscription?';
    global static final string PAGEREFERENCE_CHANGEADDRESS = '/apex/ChangeOfAddress?';
    global static final string PAGEREFERENCE_CASECHANGEADDRESS = '/apex/CaseChangeInAddress?';
    global static final string PARAMETER_ID = 'Id';
    global static final string PARAMETER_CONTACTID = 'contactId';
    global static final string PARAMETER_CASEID = 'caseId';
    //global static final string DELIVERYADDLOC = 'Change of Delivery Address ? Local to Local';
    //START: D-1124 1/14/2015 Added By J. Sarion - Implement new process for COA
    //START D-2223 2/16/2015 Charles Lin
    global static final string DELIVERYADDLOC = 'Change of Delivery Address - Local to Local';
    global static final string DELIVERYADDLOCOVSEA = 'Change of Delivery Address - Local to Overseas';
    global static final string DELIVERYADDOVSEALOC = 'Change of Delivery Address - Overseas to Local';
    //END D-2223 2/16/2015 Charles Lin
    global static final string BILLINGADD = 'Change of Billing address';
    //START D-2219 2/13/2015 Added By J.Sarion - Implementation of new COA
    global static final string SAMECASE = 'SameCase';
    //END D-2219 2/13/2015 Added By J.Sarion
    //END: D-1124 1/14/2015 Added By J. Sarion
    //START D-3942 13Nov2015 Added By C. Lin - Error for Same Contact To Update and Effective Date
    global static final string SAMECONTACTCASE = 'SameContactCase';
    //END D-3942 13Nov2015 Added By C. Lin
    global static final string GENERICERROR= 'Generic Error';
    global static final string NULLVALUE= 'null';
    global static final string EFFDATECHANGEADD = 'Effective Date';
    global static final string BLANKCONTACT='BlankContactInCase';
    global static final string BILLDELIVERYADD = 'Change of Billing and Delivery Address';
    global static final string CHANGEVENDOR = 'Change of Vendor';
    //START D-0974 1/20/2015 Added By C. Lin - Implementation of new COA
    //START D-2223 2/16/2015 Charles Lin
    global static final string DELIVERYADDOVSEA = 'Change of Delivery Address - Overseas to Overseas';
    //END D-2223 2/16/2015 Charles Lin
    global static final string BLANKCONTACTTOUPDATE = 'ContactToUpdateRequired';
    global static final string BLANKVENDOR = 'VendorRequired';
    global static final string BILLINDICATORREQUIRED = 'BillIndicatorRequired';
    global static final string RECIPINDICATORREQUIRED = 'RecipIndicatorRequired';
    global static final string BILLRECIPINDICATORREQUIRED = 'BillRecipIndicatorRequired';
    global static final string BLANKNEWADDRESS = 'BlankAddressinCase';
    global static final string SELECTSUBSCRIPTIONS = 'SelectSubscriptionForChangOfAddress';
    //END D-0974 1/20/2015 Added By C. Lin
    //START D-0974 1/20/2015 Added By MGaelo - Implementation of new COA
    global static final string NEWADDNEOLDADD = 'NewAddressNotEqualToOldAddress';
    //END D-0974 1/20/2015 Added By MGaelo
    //START D-1955 2/11/2015 Added By J.Sarion - COA Approval Process
    global static final string URGENTCOAAPPROVED = 'Urgent CoA Approved';
    //END D-1955 2/11/2015 Added By J.Sarion
    //START D-0116 3/2/2015 Added By C. Lin - COA Type No Subscription Error
    global static final string COATYPENOSUBS = 'COATypeNoSubscription';
    //END D-0116 3/2/2015
    //START D-3861 11/4/2015 Added By C. Lin
    global static final string CASEWFVA = 'HasCaseWaitingForVendorAssignment';
    //END D-3861 11/4/2015 Added By C. Lin
    
    //variable for Temp Stop Direct
    global static final string TS_OPTION_CALL = 'Call';
    global static final string TS_OPTION_EMAIL = 'Email';
    global static final string TS_OPTION_FAX = 'Fax';
    global static final string TS_OPTION_MAIL = 'Mail';
    global static final string TS_OPTION_ESHOP = 'Eshop';
    global static final string TS_RADIO_CREATE_TEMP_STOP = 'Create New Temp Stop';
    global static final string TS_RADIO_UPDATE_TEMP_STOP = 'Update Temp Stop Request';
    global static final string TS_RADIO_CANCEL_TEMP_STOP = 'Cancel Temp Stop Request';
    global static final string TS_TEMP_STOP = 'Temp Stop';
    global static final string TS_NEW = 'New';
    global static final string TS_UPDATE = 'Update';
    global static final string TS_CLOSED = 'Closed';
    global static final string TS_PENDING = 'Pending';
    global static final string TS_CANCEL = 'Cancel';
    global static final string TS_CREATE = 'Create';
    global static final string TS_YES = 'Yes';
    global static final string TS_NO = 'No';
    global static final string TS_REDIRECT_TO_RECORD = '500/o';
    global static final string TS_STATUS_ONGOING = 'On-going';
    global static final string TS_STATUS_NOTSTARTED = 'Not Started';
    global static final string TS_STATUS_CANCELLED = 'Cancelled';
    global static final string TS_SUBSCRIPTION_REQUEST = 'Subscription Request';
    global static final string TS_SUBJECT = 'Temp Stop Subscription';
    global static final string TS_URGENT_APPROVAL_STATUS = 'Waiting for Urgent Temp Stop/Restart Approval';
    global static final string TS_APPROVED = 'Temp Stop Approved';
    global static final string TS_TASK_SUBJECT = 'Call and inform the Vendor Rep';

    //EshopService for TempStop
    global static final string SVC_STATUS_SUCCESS = 'SUCCESS';
    global static final string SVC_STATUS_FAILURE = 'FAILURE';
    global static final string ERROR_CODE_GENERAL = 'EXES0000';
    global static final string ERROR_MESSAGE_GENERAL = 'General Error';
    global static final string ERROR_CODE_MANDATORY = 'EXES0001';
    global static final string ERROR_MESSAGE_MANDATORY = 'Mandatory fields are not populated';                
    global static final string ERROR_CODE_EITHER = 'EXES0003';
    global static final string ERROR_MESSAGE_SUBSCRIBER = 'SubscriberId not found';    
    global static final string ERROR_CODE_INVALID_INPUT = 'EXES0004';
    global static final string ERROR_MESSAGE_SUBSCRIPTION = 'SubscriptionId not found';    
    global static final string ERROR_MESSAGE_INVALID_INPUT = 'Invalid Input';    
    global static final string ERROR_CODE_BOTH = 'EXES0011';
    global static final string ERROR_MESSAGE_BOTH = 'Subscriber and Subscription are not found';    
    global static final string ERROR_CODE_OVERLAPPING = 'EXES0012';   
    global static final string ERROR_MESSAGE_OVERLAPPING = 'Overlapping Temp Stop Period';    
    global static final string ERROR_CODE_TSTOP = 'EXES0013';
    global static final string ERROR_MESSAGE_TSTOP = 'Temp Stop Date should not be earlier than Earliest Start Date';
    // START : D-0926 12/6/2014 Added by Alyana Navarro - Error message for EShopTempStopService
    global static final string ERROR_MESSAGE_PERIOD = 'Temp Stop Period must not be more than three months';
    // END : D-0926 12/6/2014
    //START: D-1563 01/20/2014 Added by S.Puli Filter correct values of payment mode
    global static final string ERROR_INCORRECT_PAYMENT_MODE = 'Invalid input in the field, backend validation failure';
    //END: D-1563 01/20/2014 Added by S.Puli Filter correct values of payment mode
    global static final string ERROR_CODE_MORETHANONE_SUBSCRIPTIONQTY = 'EXES0014';//KRITHIKA D D-2198 03/02/2015
    
    //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input.
    //ChangeAddressService
    global static final string CAS_ERROR_MESSAGE_ACCOUNT_NUMBER = 'Invalid Input. No Account record has been found for the Customer Account Number: ';
    global static final string CAS_ERROR_MESSAGE_BILL_ACCOUNT_NUMBER = 'Invalid Input. No Billing Account record has been found for the Billing Account Number: ';
    //START UD-1050 28-Apr-2015 Added by Raviteja  - Error message for Subscription
    global static final string CAS_ERROR_MESSAGE_BILL_ACCOUNT = 'Billing Account is not belong to Customer Account: ';
    global static final string CAS_ERROR_MESSAGE_SUBSCRIPTION = 'Subscription is not belong to Customer Account: ';
    //End UD-1050 28-Apr-2015 Added by Raviteja
    global static final string CAS_ERROR_MESSAGE_COUNTRY = 'Invalid Input. No Country record has been found for the Country: ';
    global static final string CAS_ERROR_MESSAGE_SINGPOST = 'Invalid Input. No Singpost Address record has been found for the Postal Code: ';
    global static final string CAS_ERROR_MESSAGE_INVALID_SUBID = 'Invalid Input. Subscription Id is not valid.';
    //END D-1683 1/21/2015 Added By C. Lin
    
    //NewSubscriptionService
    global static final string NSS_ERROR_CODE_GENERIC = 'EXGN0000';
    global static final string NSS_ERROR_MESSAGE_GENERIC = 'Generic Error';
    global static final string NSS_ERROR_CODE_MANDATORY = 'EXES0001';
    global static final string NSS_ERROR_MESSAGE_MANDATORY = 'Mandatory validation failed.';
    global static final string NSS_ERROR_CODE_INVALID_INPUT = 'EXES0004';
    global static final string NSS_ERROR_MESSAGE_INVALID_INPUT = 'Invalid input. Backend validation failed.';
    //START 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion checkbox assignment
    global static final string NSS_ERROR_CODE_MULTIPLE_VENSUB = 'EXES0005';
    global static final string NSS_ERROR_MESSAGE_MULTIPLE_VENSUB = 'Multiple Vendor Subscriptions are found with the given recipient address and product familly. Vendor conversion request cannot be executed. ';
    //END 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion checkbox assignment
    //START: D-1685 01/26/2015 Added by Mark Gatdula, Error message for request with invalid/incorrect account number
    global static final string NSS_ERROR_MESSAGE_NO_CUSTOMER = 'Customer not found. ';
    global static final string SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID = 'Recurring Prepaid';
    global static string API_DISABLED_ACCOUNT = 'apiDisableAccount';
    //END: D-1685 01/26/2015 Added by Mark Gatdula
     //START D-1573 KRITHIKA D 2/23/2015
    global static final string PAYMENT_MODE_CREDITCARD = 'CreditCard';
    global static final string PAYMENT_MODE_OTHER = 'Other';
    //END D-1573 KRITHIKA D 2/23/2015
   
    //variable use for SP_SendEmailNotifForSubsRenewalsBatch
    global static final string DEFACCID = 'def_account_id';
    global static final string DEFCONID = 'def_contact_id';
    global static final string DEFPARID = 'def_parent_id';  
    global static final string CASECOMPMAG = 'Case_Complaint Magazine';
    global static final string COMPNEWS = 'Complaint_Newspaper';
    global static final string CASEPAYMENTTYPPE = 'Case_Change of Payment Type';
    global static final string CASECHANGECC = 'Case_Change of Credit Card';
    global static final string CASEBYPASSCC = 'Case_Bypass Credit Card';
    global static final string CASEADJUSTMENTS = 'Case_Adjustments';
    global static final string CASECHANGEADD = 'Case_Change in Address';
    global static final string CASESTARTSUB = 'Case_Start Sub';
    global static final string CASESTOP = 'Case_Stop';
    global static final string CASEPARTICULARS = 'Case_Particulars';
    global static final string CASERESETPASS = 'Case_Reset Password';
    global static final string CASERETENTION = 'Case_Retention';
    global static final string CASETEMPSTOP = 'Case_Temp Stop';
    global static final string CASEREFUND = 'Case_Refund';
    global static final string CASEDIGITAL = 'Case_Digital';
    global static final string CASEENQUIRY = 'Case_Enquiry';
    global static final string CASECHANGESUB = 'Case_Change of Subscription';
    global static final string ACCDIRCORP = 'Account_Direct Corporate';
    global static final string ACCDIRINDIVIDUAL = 'Account_Direct Individual';
    global static final string ACCDIRSPH = 'Account_Direct SPH Inter-Division';
    global static final string ACCVENDOR = 'Account_Vendor';
    global static final string ACCVENDORSUB = 'Account_Vendor Subscriber';
    global static final string CASERENEWAL = 'Case Renewal of Subscription';
    global static final string PAGEREFERENCE_COMPMAG = '/apex/ComplaintMagazineEditPage?';
    global static final string VENDOR = 'Vendor';
    global static final string VENDORSUB = 'Vendor Subscriber';
    
    
    //Acquisition Type
    global static final string ACQTYPE_ESHOP_ECOMZ_ONLINE = 'ESHOP / ECOMZ (ONLINE)';
    
    //EmailMessageTriggerHandler
    global static final string ERROR_MESSAGE_INVALID_SENDER = 'Invalid sender.';
    global static final string EMAIL_TEMPLATE_AUTO_RESPONSE_1 = 'Email_to_Case_AutoResponse_Message_1';
    
    //EmailSendToZuoraQuotes
    global static final string PLAIN_TEXT_BODY = 'Your subscription has been successfully saved.';
    global static final string SENDER_DISPLAY_NAME = 'Singapore Press Holdings';
    global static final string EMAIL_SUBJECT = 'Your subscription has been successfully saved!';


    //ZuoraCallout
    global static final string ZUORA_ERROR = 'Error:';
    global static final string ZUORA_SUCCESS = 'Success';
    global static final string ZUORA_FAILED = 'Failed';

    //Custom Field IDs
    global static final string BILLINGACCOUNTCASE = 'Billing_Account_Case_Field';
    
    //START D-1718 1/20/2015 Added by Manolo Vale?a - Added new variable to avoid hard coding.
    //variable for PackagePriceComputation Class
    global static final string RECURRING_POSTPAID = 'Recurring Postpaid';
    //END D-1718 1/20/2015 Added by Manolo Vale?a
    
    //Adjustments
    global static final string ADJ_REDIRECT_TO_RECORD = '500/o';
    global static final string BILLINGACCOUNT_ID = 'billingaccountId';
    global static void dummyMethod() {
        System.debug('This is a dummy method called in test class to cover test coverage.');

    }
    
    //Start D-1610 AddedBy FrancisBenzon 1/26/2015 : Variables for Billing Account field assignments
    global static final string SUBL = 'SUBL';
    global static final string SUBH = 'SUBH';
    global static final string GOVT = 'GOVT';
    global static final string NORM = 'NORM';
    global static final string GIRO = 'GIRO';
    global static final string PAYMENT_TERM_SUBL = 'Net 10';
    global static final string PAYMENT_TERM_SUBH = 'Net 15';
    global static final string PAYMENT_TERM_GOVT = 'Net 30';
    global static final string PAYMENT_TERM_NORM = 'Due Upon Receipt';
    global static final string PAYMENT_TERM_GIRO = '0'; 
    //End D-1610 AddedBy FrancisBenzon 1/26/2015 : Variables for Billing Account field assignments  
    
    //Start D-1755 AprilBanaag 1/28/2015
    global static final string CREATEVENDORSTART_WEEKEND = 'Weekends';
    global static final string CREATEVENDORSTART_WEEKDAY = 'Weekdays';
    //End D-1755 AprilBanaag 1/28/2015
    
    //START D-1775 Kevin Evasco 1/28/2015
    global static final String ESHOP_COA_Mandatory_PostalCode = 'Postal Code is mandatory. ';
    global static final String ESHOP_COA_Mandatory_BlockNumber = 'Block Number is mandatory. ';
    global static final String ESHOP_COA_Mandatory_LevelNumber = 'Level Number is mandatory. ';
    global static final String ESHOP_COA_Mandatory_StreetName = 'Street Name is mandatory. ';
    global static final String ESHOP_COA_Mandatory_BuildingName = 'Building Name is mandatory. ';
    global static final String ESHOP_COA_Mandatory_UnitNumber = 'Unit Number is mandatory. ';
    global static final String SINGAPORE_CODE = 'SG'; //START/END D-3066 05/28/15 Kevin Evasco - Change Singapore Country Code from SIN to SG
    global static final String ESHOP_COA_Mandatory_Address1 = 'Address1 is mandatory for international addresses. ';
    //END D-1775 Kevin Evasco 1/28/2015
    
    //START D-1942 Francis Benzon 1/28/2015
    global static final String CS_ADDRESSLOCAL = 'Address_Local';
    //END D-1942 Francis Benzon 1/28/2015
     
    //START D-1957 Manolo Valena 1/28/2015
    global static final string COMMA= ',';
    //END D-1957 Manolo Valena 1/28/2015
    
    //START D-1933, D-1938 Sherwin Puli  1/28/2015
    global static final string CASE_ORIGIN_ESHOP = 'Eshop/Ecomz';
    global static final string ERROR_CODE_TS_SUBS_CANCELLED = 'EXES0020';
    //END D-1933, D-1938 Sherwin Puli  1/28/2015
    
    //START D-1776, D-1777 Kevin Evasco
    global static final String ESHOP_ORIGIN = 'ESHOP Webservice';
    //END D-1776, D-1777 Kevin Evasco
    
    //START D-1647 Alyana Navarro 1/29/2015
    global static final String NOT_ELIGIBLE_ERROR_CODE = 'EXES0021';
    global static final String NOT_ELIGIBLE_ERROR_MESSAGE = 'Customer not eligible for promotion.';
    global static final String BOOLEAN_FALSE = 'false';
    global static final String ACTION_ADD = 'Add';
    //END D-1647 Alyana Navarro 1/29/2015
    
    //START D-1615, D-1618, D-1619 JeffreyTeves 1/30/2015
    global static final String POSTPAID_USAGE = 'Postpaid Usage';
    global static final String PRORATION_CHARGE_USAGE = 'Proration Charge Usage';
    global static final String PRORATION_CREDIT_USAGE = 'Proration Credit Usage';
    //START D-1968 Karl Tan 3/04/2015 - Added to cater Proration for No Credit Usage
    global static final String PRORATION_NO_CREDIT_USAGE = 'Non Chargeable Copy Usage';
    //END D-1968 Karl Tan 3/04/2015 - Added to cater Proration for No Credit Usage
    //global static final String RECURRING_PREPAID = 'Recurring Prepaid'; SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID
    //global static final String RECURRING_POSTPAID = 'Recurring Postpaid'; RECURRING_POSTPAID
    global static final String WEEKDAY_UOM_STRING = 'Weekday';
    global static final String SATURDAY_UOM_STRING  = 'Sat';
    global static final String SUNDAY_UOM_STRING  = 'Sun';
    global static final String MONDAY_STRING = 'Monday';
    global static final String TUESDAY_STRING = 'Tuesday';
    global static final String WEDNESDAY_STRING = 'Wednesday';
    global static final String THURSDAY_STRING = 'Thursday';
    global static final String FRIDAY_STRING = 'Friday';
    global static final String SATURDAY_STRING = 'Saturday';
    global static final String SUNDAY_STRING = 'Sunday';
    global static final String STATUS_ACTIVE = 'Active';
    global static final String STATUS_EXPIRED = 'Expired';
    //START D-1615, D-1618, D-1619 JeffreyTeves 1/30/2015
    
    //START:D-2180 2/13/15 Added by Manolo Vale?a - Updated values to follow new picklist values of Letter Template field of Gift Letter Batch Object. Also added 2 new variables for the 2 new templates to be created.
    //START: 1/27/2015 D-1982 Kevin Evasco - Gift Redemption Letter Types
    /*global static final string LP_GIFT_GIFT_LETTER = 'Gift Letter';
    global static final string LP_GIFT_PRESENT_LETTER = 'Present Gift';
    global static final string LP_GIFT_SUBSCRIPTION_LETTER = 'Subscription Letter';
    global static final string LP_GIFT_RENEWAL_LETTER = 'Renewal Letter';
    global static final string LP_GIFT_REDEMPTION_LETTER = 'Redemption Letter';*/
    
    global static final string LP_GIFT_GIFT_LETTER = 'SPHM (Eng)';
    global static final string LP_GIFT_SUBSCRIPTION_LETTER = 'SPH Mag w/o Date (Eng)';
    global static final string LP_GIFT_RENEWAL_LETTER = 'Retention (Eng)';
    global static final string LP_GIFT_REDEMPTION_LETTER = 'IPP (Eng)';
    global static final string LP_GIFT_PREMIUM_CHINA = 'Premium (Chi)';
    global static final string LP_GIFT_PREMIUM_ENGLISH = 'Premium (Eng)';
    //END: 1/27/2015 D-1982 Kevin Evasco - Gift Redemption Letter Types
    //END:D-2180 2/13/15 Added by Manolo Vale?a
    
    //Start CODECLEANUP Added by FrancisBenzon 2/3/15 
    global static final string UPDATE_ARMS_INFO_RESULTID = ConstantsSLB.getKeyId('UpdateARMSInfoResultId');
    global static final string CREDITCARD = 'CreditCard';
    global static final string CASH = 'Cash';
    // Start UD-0721 Ronald Dagaraga Updated cheque to Check
    global static final string CHEQUE = 'Check';
    // End UD-0721 Ronald Dagaraga Updated cheque to Check
    //START:D-2738 4/13/15 Added by Karl Tan
    global static final string CHEQUEPT = 'Cheque';
    //END:D-2738 4/13/15 Added by Karl Tan
    global static final string PARAMETER_ACCTID_STRING = 'accountId';
    global static final string PARAMETER_RECORDTYPE_STRING = 'RecordType';
    global static final string PARAMETER_ID_STRING = 'id';
    global static final string PARAMETER_CONTACTID_STRING = 'contactId';
    global static final string PARAMETER_BILLINGACCOUNTID_STRING = 'billingaccountId';
    global static final string REFUND_MAXLIMIT = '0000399999';
    global static final string REFUND_MINLIMIT = '0000200000';
    //End CODECLEANUP Added by FrancisBenzon 2/3/15
    
    // Start : D-1796 2/4/2015 Alyana Navarro
    global static final String COMPLAINT_TRANSACTION_NAME = 'Complaint';
    global static final String CONTACT_VENDOR_STAFF = 'Contact_Vendor Staff';
    // END : D-1796 2/4/2015
    
    //Start : D-1394 2/5/15 Jillian Banaag
    global static final string ZPRODUCTSUBTYPE_NEWSPAPER = 'Newspaper';
    global static final string ZPRODUCTSUBTYPE_MAGAZINE = 'Magazine';
    global static final string OLIDELIVEREDBY_VENDOR= 'Vendor';
    global static final string OLIDELIVEREDBY_MAILING_AGENT = 'Mailing Agent';
    //End : D-1394 2/5/15 Jillian Banaag
    
    //Start D-1983 2/6/15 Sherwin Puli 
    global static final string USER_LICENSE = 'Partner Community';
    global static final string VENDOR_STAFF = 'Vendor Staff';
    //End D-1983 2/6/15 Sherwin Puli 
    
    //Start D-1929 2/11/15 Kay Lorica 
     global static final string PAYPAL = 'Paypal';
     global static final string REF_PENDING = 'Pending';
    //End D-1929 2/11/15 Kay Lorica 
    
    //Start D-0726 02/13/15 April Banaag
    global static final string SUB_STATUS_WAIVED_APPROVED = 'Waived Approved';
    global static final string SUB_STATUS_WAIVED_REJECTED = 'Waived Rejected';
    global static final string SUB_STATUS_URGENT_STOP_APPROVED = 'Urgent Stop Approved';
    global static final string SUB_STATUS_URGENT_STOP_REJECTED = 'Urgent Stop Rejected';
    global static final string SUB_STATUS_TEMP_STOP_REJECTED = 'Temp Stop Rejected';
    //End D-0726 02/13/15 April Banaag

    // Start D-2223 02/14/2015 Charles Lin
    global static final string ACCOUNT_STATUS_ACTIVE = 'Active';
    global static final string ACCOUNT_STATUS_INACTIVE = 'Inactive';
    global static final string ESHOP_EMAIL_SUBJECT_SUCCESS = 'Success: Subscription Creation';
    global static final string PAYPAL_2_OTHER_EMAIL_SUBJECT = 'Paypal to Other';
    global static final string ASIA1_SUBSCRIPTION_STATUS_DISABLED = 'Disabled';
    global static final string ASIA1_SUBSCRIPITON_STATUS_ENABLED = 'Enabled';
    // End D-2223 02/14/2015

    //Start D-2227 02/17/2015 ABanaag
    global static final string PRODUCT_TYPE_CHARGE = 'Charge';
    global static final string PRODUCT_CODE_DELCHG = 'DELCHG';
    //End D-2227 02/17/2015 ABanaag
    global static final string PRODUCT_CODE_PRMGFT = 'PRMGFT'; //START END Wenjun 2/25/15 D-2327
    
    //START D-2003 D-1977 D-2134 2/19/15 Added FrancisBenzon
    global static final string CSO_QUEUE = 'CSO Queue';
    //START D-2003 D-1977 D-2134 2/19/15 Added FrancisBenzon
    
    
    //START D-2075/D-2212 02/27/2015 S.Puli/MBG
    global static final string COA_STOP =  'Stop - Change of Address';
    global static final string COA_START =  'Start - Change of Address';
    //End D-2075/D-2212 02/27/2015 S.Puli/MBG
    
    //START D-2393 02/27/2015 S.Puli
    global static final string TS_RESTART =  'Start-Restart';
    global static final string TS_URGENTRESTART =  'Start-Urgent Restart';
    //End D-2393 02/27/2015 S.Puli

    //START UD-0136 3/3/15 FrancisBenzon
    global static final string VENDORSUB_STOPDATE_INVALID = 'Vendor Sub Stop Date Invalid';
    global static final string VENDORSUB_STARTDATE_NULL = 'Vendor Sub Populate Start Date';
    //END UD-0136 3/3/15 FrancisBenzon
    
    //START UD-0224 3/5/15 FrancisBenzon
    global static final string STARTSUB_ASIA1_BULK = 'Bulk';
    //END UD-0224 3/5/15 FrancisBenzon
    
    //START UD-0234 3/5/15 Jean Carino
    global static final string URGENT_START_REJECTED = 'Urgent Start Rejected';
    //END UD-0234 3/5/15 Jean Carino
    
    //START D-2332 3/6/15 FrancisBenzon
    global static final string COS_INVOICEERROR_1 = 'COS Invoice Error1';
    global static final string COS_INVOICEERROR_2 = 'COS Invoice Error2';
    //END D-2332 3/6/15 FrancisBenzon
    
    //START D-2248 03/06/15 Banaag
    global static final string ZUORA_SUBSCRIPTION_OBJ = 'Subscription';
    global static final string ZUORA_SUBSCRIPTION_IDFIELD = 'Id';
    global static final string ZUORA_SUBSCRIPTION_ISINVOICESEPARATE = 'IsInvoiceSeparate';
    //END D-2248 03/06/15 Banaag
    
    
    //START UD-0403 3/13/2015 Charles Lin
    global static final string FREQ_DEFAULT= 'Default';
    global static final string FREQ_MONFRI = 'Mon - Fri';
    global static final string FREQ_MONSAT = 'Mon - Sat';
    global static final string FREQ_SATSUN = 'Sat - Sun';
    global static final string FREQ_FRISUN = 'Fri - Sun';
    global static final string FREQ_MONFRI_DAYS = 'YYYYYNN';
    global static final string FREQ_MONSAT_DAYS = 'YYYYYYN';
    global static final string FREQ_SATSUN_DAYS = 'NNNNNYY';
    global static final string FREQ_FRISUN_DAYS = 'NNNNYYY';
    //END UD-0403 3/13/2015 Charles Lin
    
    //START UD-0289 5/9/15 AddedBy FrancisBenzon : Binary Frequencies
    global static final string FREQ_MONFRI_BIN = '1111100'; 
    global static final string FREQ_MONFRI_SUN = '1111101'; 
    global static final string FREQ_MONSAT_BIN = '1111110'; 
    global static final string FREQ_MONSAT_SUN = '1111111';
    global static final string FREQ_SATSUN_BIN = '0000011'; 
    global static final string FREQ_FRISUN_BIN = '0000111'; 
    //END UD-0289 5/9/15 AddedBy FrancisBenzon : Binary Frequencies
    
    //START D-2105 D-2261 D-2337 D-2349 D-2452 D-2453 Wenjun 16/03/15 - Vendor Credit/Debit
    global Static Final String CREDIT_IND= 'C';
    global Static Final String DEBIT_IND = 'D';
    global Static Final String REASON_CD_COM= 'C';
    global Static Final String REASON_CD_PAGE = 'P';
    global Static Final String REASON_CD_INST= 'I';
    global Static Final String REASON_CD_DEL = 'C5';
    global Static Final String REASON_CD_OTH= 'M';
    
    //Case Record Type Developer Name
    global Static Final String RT_CASE_START = 'Start_Subscription';
    global Static Final String RT_CASE_COA = 'Change_of_Address';
    
    //GST Percentage
    global Static Final decimal GST_PERCENT = 0.07;
    //END D-2105 D-2261 D-2337 D-2349 D-2452 D-2453 Wenjun 16/03/15 - Vendor Credit/Debit
    
    //Start UD-0204 Added by FrancisBenzon 3/18/15
    global static final string CREDIT_CARD = 'Credit Card';
    global static final string OTHER = 'Other';
    global static final string INVOICE = 'Invoice';
    global static final string ERROR_PAYMENTMODE_INVOICE = 'Start_PaymentModeForRecurring';
    global static final string CHECK = 'Check';
    global static final string ENETS = 'eNets';
    global static final string EXTERNAL_PARTIES = 'External Parties';
    global static final string INTERNAL_CHARGE = 'Internal Charge';
    global static final string IPP = 'IPP';
    //End UD-0204 Added by FrancisBenzon 3/18/15
    
    //Start UD-0698 Added by Ronald dagaraga 4/10/2015
    global static final string ERROR_INTERNALPAYMENTMODE_INVOICE = 'Start_InternalPaymentModeForRecurring';
    //Start UD-0698 Added by Ronald dagaraga 4/10/2015
    
    //START UD-0374 3/19/2015 Added by Manolo Valena - This is for CaseTriggerHandler Apex Class
    global static final string DASH = '-';
    global static final string RECALLED = 'Recalled';
    //END UD-0374 3/19/2015 Added by Manolo Valena
    
    // START D-2116 03/12/2015 Added by S.Puli
    global static final string LETTER_TYPE_ACK = 'Acknowledgment_Letter';
    // END D-2116 03/12/2015 Added by S.Puli
    
    //START D-2425 03/20/2015 Added by J.Sarion D-2425 For Usage Proration UOM
    global static final string GRACE_NUMBER_OF_DAY_KEY = 'Grace Number of Days for Temp Stop';
    global static final string CREDIT_COPY = 'Credit Copy';
    global static final string NO_CREDIT_COPY = 'No Credit Copy';
    global static final string TSTOP_FINAL = 'TStop Final';
    global static final string TSTOP_CONVERT = 'TStop Convert';
    global static final string TSTOP_TEMP = 'TStop Temp';
    global static final string ONLINE = 'Online';
    global static final string AIO_ONLINE = 'AIO Online';
    global static final string TABLET = 'Tablet';
    global static final string AIO_TABLET = 'AIO Tablet';
    global static final string SMARTPHONE = 'Smartphone';
    global static final string AIO_SMARTPHONE = 'AIO Smartphone';
    global static final string DIGITAL = 'Digital';
    global static final string COPY = 'Copy';
    global static final string ISSUE = 'Issue';
    global static final string EVERGREEN = 'Evergreen';
    //END D-2425 03/20/2015 Added by J.Sarion
    
    //START MD-61 03/25/2015 S.Puli
    global static final string SUB_STATUS_WAITING_FOR_COA_APPROVAL = 'Waiting for Urgent CoA Approval';
    global static final string SUB_STATUS_WAITING_FOR_URGENT_APPROVAL = 'Waiting for Urgent Approval';
    global static final string SUB_STATUS_COA_REJECTED = 'Urgent CoA Rejected';
    global static final string SUB_STATUS_COA_APPROVED = 'Urgent CoA Approved';
    //END MD-61 03/25/2015 S.Puli
    
    global static final string SUB_STATUS_WAIVING_APPROVAL = 'Waiting for Waiving of Charges Approval'; //START END D-3411 Wenjun 03/Sep/15
    
    //START D-2759 Wenjun 13/04/15
    //Billing Type Values for Order, Order Line Item, Subscription, Main Packages etc
    global static final string BILLING_TYPE_FULL_PRE = 'Full Prepaid';
    global static final string BILLING_TYPE_MR_PRE = 'Recurring Prepaid';
    global static final string BILLING_TYPE_MR_POST = 'Recurring Postpaid';
    global static final string BILLING_TYPE_FULL = 'Full';  // Start/End 30Apr15 JohnD
    global static final string BILLING_TYPE_RECURRING = 'Recurring';    // Start/End 30Apr15 JohnD
    //Billing Account Billing Type Values
    //START D-3159 and D-3160 02-July-2015 Added by Raviteja - Implementing New Splitting Billing Type Scenario - 'Prepaid'and 'Postpaid' no more valid as per new implementaion
    global static final string BA_BILLING_TYPE_PRE = 'Recurring Prepaid';
    global static final string BA_BILLING_TYPE_POST = 'Recurring Postpaid';
    //End D-3159 and D-3160 02-July-2015 Added by Raviteja 
    //END D-2759 Wenjun 13/04/15
    
    //START UD-0648 RReyes 4/27/15 : ErrorMessage
    global static final string FULLPREPAID_EVERGREEN_ERROR = 'Full Prepaid Evergreen';
    //END UD-0648 RReyes 4/27/15 : ErrorMessage
     
   //START UD-1595 AddedBy FBenzon/JTeves : for COS variables
    //START UD-0680 FrancisBenzon 4/28/15 : Formula Status value
    global static final string STATUS_TERMINATED = 'Terminated';
    //END UD-0680 FrancisBenzon 4/28/15 : Formula Status value
   //END UD-1595 AddedBy FBenzon/JTeves : for COS variables
    
    //START:UD-1033 5/5/15 Added by Manolo Valena - Added new variable.
    global static final string SUBSCRIPTION_TYPE_TERMED = 'Termed';
    //END:UD-1033 5/5/15 Added by Manolo Valena
     
    //START D-2877 05/08/2015 Added By S.Puli   
    global static final string DUMMY_CHARGE = 'Dummy Charge';
    //END D-2877
    
    //START D-3015 05/29/2015 Added By S.Puli   
    global static final string INTERNAL = 'Internal';
    global static final string FREE_LIST = 'Free List';
    global static final string FREELIST = 'Freelist';
    //END D-3015
    //Start D-3072 Gdelrosario :adeed for rate plan type
    global static final string RATE_TYPE_BILL_RUN = 'Bill Plan';
    global static final string RATE_TYPE_PRORATION = 'Proration';
    //End
        
   // START : D-3125 6/19/2015 Alyana Navarro
   global static final String REFERENCE_BOTH = 'Both';
   global static final String REFERENCE_HARD_COPY = 'Hard Copy';
   global static final String REFERENCE_EMAIL = 'Email';
   // END : D-3125 6/19/2015 Alyana Navarro   
   
   //Start D-3124 06/18 Added by Jason A.  
   global static final String SMS_Preference = 'SMS';
   global static final String Email_Preference = 'Email';
   //End D-3124 06/18 Added by Jason A.  
   
   //START: UD-0798 18/06/2015 Added by S.Puli
   global static final String DAILY = 'DAILY';
   //END: UD-0798 18/06/2015 Added by S.Puli
   
   //START UD-1595 AddedBy FBenzon/JTeves : for COS variables
   global static final String COS_PACKAGE = 'Change of Subscription Package';
   global static final String COS_QUANTITY = 'Change of Subscription Quantity';
   //END UD-1595 AddedBy FBenzon/JTeves : for COS variables
   
   //START UD-1527 6/23/15 Added by Manolo Valena
   global static final String PASS = 'PASS';
   //END UD-1527 6/23/15 Added by Manolo Valena
   
   //START: UD-1557 11/06/2015 Added by S.Puli
   global static final String CREATE_NEW_BILLACC = 'Create New Billing Account';
   //END: UD-1557 11/06/2015 Added by S.Puli
   
   
   //START D-3227 Rebuild AddedBy Francis Benzon : error Message Strings
   global static final String errorPrepaidToPostpaid = 'COS_PrepaidToPostpaid';
   //END D-3227 Rebuild AddedBy Francis Benzon : error Message Strings
    //START UD-1735 7/3/15 Added by Manolo Valena
   global static final String PAYMENT_TERM = 'PaymentTerm';
   global static final String ACCOUNTSTR = 'Account';
   global static final String MESSAGESTR = 'Message';
   global static final String ACCUPFAILED = 'Account update failed';
   //END UD-1735 7/3/15 Added by Manolo Valena
   //START D-3224 Rebuild AddedBy Francis Benzon : error Message Strings
   global static final String invoiceTargetDateForStop = 'STOP_InvoiceTargetDate';
   //END D-3224 Rebuild AddedBy Francis Benzon : error Message Strings
   //START:UD-1559 7/1/15 Added by Manolo Valena
   global static final String SUB_CHANGESUBSCRIPTION = 'Change_of_Subscription';
   //END:UD-1559 7/1/15 Added by Manolo Valena
   // START : UD-0985 7/6/2015 Alyana Navarro
   global static final String FREQUENCY_MONSAT = 'Mon - Sat';
   global static final string SUB_FREQUENCY_MONFRI = 'Mon - Fri';
   global static final string SUB_FREQUENCY_FRISUN = 'Fri - Sun';
   global static final string SUB_FREQUENCY_SATSUN = 'Sat - Sun';
   global static final String UOM_COPYWEEKDAY = 'Copy Weekday';
   global static final String UOM_COPYSAT = 'Copy Sat';
   global static final String UOM_COPYSUN = 'Copy Sun';
   // END : UD-0985 7/6/2015 Alyana Navarro
   //START: UD-1810 08/07/2015 Added by S.Puli
   global static final String STRING_Y = 'Y';
   global static final String STRING_N = 'N';
   global static final String STRING_A = 'A';
   global static final String STRING_O = 'O';
   global static final String STRING_H = 'H';
   global static final String STRING_M = 'M';
   global static final String STRING_F = 'F';
   global static final String STRING_E = 'E';
   global static final String STRING_NRIC = 'NRIC';
   global static final String STRING_DETAIL = 'Detail';
   global static final String STRING_MASTER = 'Master';
   global static final String STRING_LOCAL = 'Local';
   global static final String STRING_OVERSEAS = 'Overseas';
   global static final String STRING_INTERNAL = 'Internal';
   global static final String STRING_AIRLINE = 'Airline';
   //END: UD-1810 08/07/2015 Added by S.Puli
   
   //START UD-0760 7/14/2015 Added by Manolo Valena
   global static final String STOPDATE_ERROR = 'Stop Request Date should not be greater than the Subscription End Date';
   //END UD-0760 7/14/2015 Added by Manolo Valena
   
   //START:D-3339 8/11/2015 Added by Manolo Valena
   global static final String PERIOD = '.';
   global static final String SPACE = ' ';
   //END:D-3339 8/11/2015 Added by Manolo Valena
   
   //START:D-3330 8/17/15 Added by Manolo Valena
   global static final String COLON = ':';
   //END:D-3330 8/17/15 Added by Manolo Valena
   
   //START:UD-1934 8/19/15 Added by Manolo Valena
   global static final String REJECTED = 'Rejected';
   global static final String REQUEST_RECALLED = 'Request Recalled';
   //END:UD-1934 8/19/15 Added by Manolo Valena
   
   //START UD-2370 8/19/15 addedBy FrancisBenzon : errorMessage variable
   global static final String INVALID_BILLINGCONTACT = 'Invalid Billing Contact Inputted';
   //END UD-2370 8/19/15 addedBy FrancisBenzon : errorMessage variable
   
   //START UD-1906 VPernicia 08/20/15
   //START D-3423 Wenjun 19 Aug 15 : Product Platform
   global static final string PLATFORM_PRINT = 'Print';
   global static final string PLATFORM_ONLINE = 'Online';
   global static final string PLATFORM_TABLET = 'Tablet';
   global static final string PLATFORM_PHONE = 'Smartphone';
   global static final string PLATFORM_AIO = 'All-In-One';
   //END D-3423 Wenjun 19 Aug 15
      
   global static final string PLATFORM_AIO_PUB = 'All in One (AIO)';
   //End UD-1906 VPernicia 08/20/15
   //START:UD-2394 8/20/15 Added by Manolo Valena
   global static final string DELIMITER = '|';
   global static final string PLUS = '+';
   global static final string DEACTIVATE = 'Deactivate';
   global static final string ASIA_ERROR = 'Error updating Asia1 Subscripitions :';
   //END:UD-2394 8/20/15 Added by Manolo Valena
   
   //START UD-2500 08/26/2015 Added by J.Sarion
   global static final string FIELDSNULL = 'COA fields null';
   global static final string CONTACTNULL = 'Please select Contact Name';
   //END UD-2500 08/26/2015 Added by J.Sarion
   
   //START UD-2375 08/28/2015 Added by J.Sarion
   global static final string ARMSBUSINESSPROF = 'ARMS_Business_Profile__c';
   global static final string ARMSDEBTMGT = 'ARMS_Debt_Management__c';
   //END UD-2375 08/28/2015 Added by J.Sarion
   
   //START D-3396 Wenjun 16 Sep 15 
   global static final string SEND_TO_ZUORA_ISSUE = 'Zuora Issue - Subscription Creation';
   global static final string SEND_TO_ZUORA_SUCCESS = 'Sent to Z-Billing';
   //END D-3396 Wenjun 16 Sep 15
   
   //START UD-2819 19-Sept-2015 Added By S.Puli
   global static final string ADJUSTMENT = 'ADJUSTMENT';
   global static final string NO_CREDIT = 'NO CREDIT';
   //END UD-2819 19-Sept-2015 Added By S.Puli

   //START UD-2738 Wenjun 21/Sep/15 : Code Optimization
   global static final string ZUORA_ISSUE_CANCELLATION = 'Zuora Issue - Subscription Cancellation';
   global static final string RT_DEV_NAME_STOP = 'Stop_Subscription';
   global static final string RT_DEV_NAME_COS = 'Change_of_Subscription';
   //END UD-2738 Wenjun 21/Sep/15
   //START UD-2878 24-Sept-2015 Added by S.Puli
   global static final string NON_DELIVERY = 'Non Delivery';
   //END UD-2878 24-Sept-2015 Added by S.Puli
   
   //START: D-4025 12/11/15 Added by Manolo Valena
   global static final string ERR_BATCH_ADD = 'Invoice Billing Account does not have ARMS Id.';
   //END: D-4025 12/11/15 Added by Manolo Valena
   
    
    //START D-4346 1/28/2016 Added by Manolo Valena
    global static final string ACCRECTYPEDI = 'Direct Individual';
    global static final string ACCRECTYPEDC = 'Direct Corporate';
    //END D-4346 1/28/2016 Added by Manolo Valena
    
    //START: UD-3819 1/26/16 Added by Manolo Valena
    global static final string RESPONSE_ENABLE_ACCOUNT = 'Enable-Account';
    global static final string RESPONSE_ERRORS = 'Errors';
    global static final string ASIAONE_CREATED = 'Created';
    //END: UD-3819 1/26/16 Added by Manolo Valena
    
    //START: UD-3473 2/3/16 Added by Manolo Valena
    global static final string ADDON_ERR = 'Please select an Offer Package before adding an Offer Add On Package.';
    //END: UD-3473 2/3/16 Added by Manolo Valena
    //START UD-3652 4Feb2016 FrancisBenzon : error messages new validation rules
    global static final string ERR_ExistingPSTOPOrder = 'ExistingPSTOPOrder';
    global static final string ERR_ExistingCOSOrder = 'ExistingCOSOrder';
    //END UD-3652 4Feb2016 FrancisBenzon : error messages new validation rules
    
    //Start UD-3253 29-Feb-2016 Added By S.Puli
    global static final string GOODWILL_CREDIT = 'Goodwill Credit';
    //End UD-3253 29-Feb-2016 Added By S.Puli
    
    //START PD-0041 FrancisBenzon 16May16 : variables
    global static final string SUBACQUISITIONTYPE_BULKORDERUPLOAD = 'ROAD SHOW';
    //END PD-0041 FrancisBenzon 16May16 : variables
    
    //START PD-0202 FrancisBenzon 20May16 : variables
    global static final string CASESUBSTAT_WAIVEREJECTED = 'Waiving of Charges Rejected';
    global static final string CASESUBSTAT_URGENTREJECTED = 'Urgent Rejected';
    //END PD-0202 FrancisBenzon 20May16 : variables
}