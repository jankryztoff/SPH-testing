/**
 * Class Name: SM_SubscriptionHelper
 * @authors: john dacutan
 * Date: 10/06/2014
 * Requirement/Project Name: SPH
 * @description this class contains method from renewal and start subscription apex class that can be reuse. 
 *
 * History: 01/07/2015 Wenjun : Postage Charges
 **/
public virtual class SM_SubscriptionHelper {

    //START UD-2036 07/24/2015 Added by J.Sarion - Added static variable
    public static String enabledServices;
    //END UD-2036 07/24/2015 Added by J.Sarion - Added static variable
    
    static String retrievedAddOnId; // Start/End PD-0035 21Apr16
    
    public class Asia1Wrapper  {
        public string userId { get; set; }
        public string asia1Id { get; set; }
        public list<Asia1SubscriptionWrapper> asia1Subscriptions { get; set; } 
    }
    
    
    public class Asia1SubscriptionWrapper {
        public string serviceFlagId { get; set; }
        public string serviceFlagName { get; set; }
        public string status { get; set; }
        public integer concurrent { get; set; }
    }    

    
    private class RelatedPackageWrapper {
        
        string packageId;
        string packageName;
        string packageType;
        string packageSubscriptionType;
        string packageSubscriptionPeriod;
        decimal packageSubscriptionRate;        
    }
    
  /**
  * @description : This method will generate the query string to be used 
  *  when retrieving the order detail.
  */
  public static string generateOrderSoqlStr() {
  
      // Start D-2157 02/10/2015 JohnD added No_Vendor_Needed__c field and revised the string into set
      // for maintainablity
      string returnValue = 'select Id';
      set<string> orderFields = new set<string>();

    // start order fields
    orderFields.add('Name');
    orderFields.add('Status__c');
    orderFields.add('Acquisition_Type__c');
    orderFields.add('Recipient_Contact__c');
    orderFields.add('Recipient_Contact__r.FirstName');
    orderFields.add('Recipient_Contact__r.LastName');
    orderFields.add('Vendor_Sms_Remarks__c');
    orderFields.add('Cost_Centre__c');
    orderFields.add('Account__c');
    orderFields.add('Total_Full_Prepaid_Charge__c');
    orderFields.add('Total_Monthly_Recurring_Charge__c');
    orderFields.add('Parent_Case__c');
    orderFields.add('Credit_Balance__c');
    orderFields.add('Total_Monthly_Postage_Charge__c');
    orderFields.add('Total_Gift_Charge__c');
    orderFields.add('Delivery_Charge__c');
    orderFields.add('Monthly_Delivery_Charge_for_Full_Payment__c');
    orderFields.add('Full_Prepaid_Inc_Del_Charge__c');
    orderFields.add('Recurring_Inc_Del_Charge__c');
    orderFields.add('Delivery_Charge_Type__c');
    orderFields.add('Subscriber_Charge__c');
    orderFields.add('Vendor_Credit__c');
    orderFields.add('Recipient_Type__c');
    orderFields.add('Check_Issuing_Bank__c');
    orderFields.add('Check_No__c');
    orderFields.add('Check_Dated__c');
    orderFields.add('Check_Amount__c');
    orderFields.add('Remarks_Check__c');
    orderFields.add('PO_Number__c');
    orderFields.add('Payment_Method_ID__c');
    orderFields.add('Payment_Mode__c');
    orderFields.add('Other_Payment_Mode__c');
    orderFields.add('Billing_Account__c');
    orderFields.add('Sponsor__c');
    orderFields.add('Credit_Amount__c');
    orderFields.add('Total_Due_to_SPH__c');
    orderFields.add('Request_for_Waiving_of_Admin_Charge__c');
    orderFields.add('Amount_Paid__c');
    orderFields.add('Billing_Contact__c');
    orderFields.add('Billing_Account_Creation_Mode__c');
    orderFields.add('Total_Due_to_Customer__c');
    orderFields.add('Subscription_Rate__c');
    orderFields.add('Admin_Charge__c');
    orderFields.add('Remarks__c');
    orderFields.add('Creation_Mode__c');
    orderFields.add('Subject__c');
    orderFields.add('Order_Type__c');
    orderFields.add('Reason_for_Waiver__c');
    orderFields.add('Order_Action__c');
    orderFields.add('Reason_Code__c');
    orderFields.add('Business_Profile__c');
    orderFields.add('ARMS_Account_Number__c');
    orderFields.add('ARMS_Credit_Term__c');
    orderFields.add('Credit_Term_Reference__c');
    orderFields.add('Credit_Limit_Internal_Limit__c');
    orderFields.add('Credit_Limit_External_Limit__c');
    orderFields.add('Approved_Debt_Exposure_Amount__c');
    orderFields.add('Debt_Management_Treatment__c');
    orderFields.add('Cust_Giro_Acct_Number__c');
    orderFields.add('Cust_Giro_Bank_Number__c');
    orderFields.add('Business_Sector__c');
    orderFields.add('Company_Code__c');
    orderFields.add('SOA_Suppression_Indicator__c');
    orderFields.add('Transient_Indicator__c');
    orderFields.add('GL_Code__c');
    orderFields.add('Base_Subscription__c');
    orderFields.add('Subscription__c');
    orderFields.add('Total_Subscription_Rate__c');
    orderFields.add('No_Vendor_Needed__c');
    orderFields.add('Total_Line_Item__c');
    orderFields.add('Billing_Type__c');// D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/20/2015
    orderFields.add('FP_Del_Usage__c'); // Start/End D-2693 06Arp15 JohnD
    orderFields.add('Full_Prepaid_Delivery_Charge__c'); // Start/End UD-0715 29Arp15 JohnD
    orderFields.add('Billing_Type__c') ; //START/End D-3159 and D-3160 02-July-2015 Added by Raviteja
    orderFields.add('Recurring_Delivery_Charge__c'); // Start/End UD-0715 29Arp15 JohnD
    orderFields.add('Create_ARMS_Customer_Account__c'); // Start/End UD-1736 04Jun15 Gio/JohnD
    // end order fields
    //START UD-3371 added new field query
    orderFields.add('Latest_Start_Date__c'); 
    orderFields.add('Subscription__r.Order_Number_1__c'); 
    //END UD-3371 added new field query
    // start account fields
    orderFields.add('Account__r.Name');
    orderFields.add('Account__r.AccountNumber');
    // end account fields

    // start billing account fields
    orderFields.add('Billing_Account__r.Billing_Contact__c');
    orderFields.add('Billing_Account__r.Zuora__PaymentMethod_Type__c');
    orderFields.add('Billing_Account__r.Payment_Mode__c');
    orderFields.add('Billing_Account__r.Zuora__External_Id__c'); // Start/End D-2693/UD-678 07Apr15 JohnD/VPernicia

    // end billing account fields
    
    // start contact fields
    orderFields.add('Recipient_Contact__r.Phone');
    orderFields.add('Recipient_Contact__r.HomePhone__c');
    orderFields.add('Recipient_Contact__r.Mobile_Number__c');
    orderFields.add('Recipient_Contact__r.Address__c');
    orderFields.add('Recipient_Contact__r.Address__r.Address_Type__c');
    orderFields.add('Recipient_Contact__r.Address__r.RecordType.Name');
    // end contat fields
  
    // start subscription fields  
    orderFields.add('Subscription__r.Zuora__Zuora_Id__c');
    // end subscription fields
    
    //START UD-1317 06/08/2015 Added by J. Sarion - Added field
    orderFields.add('Total_Full_Prepaid__c');
    //END UD-1317 06/08/2015 Added by J. Sarion - Added field
    //START UD-1595 6/18/15 AddedBy Fritz/Benzon : additional field for query
    orderFields.add('Subscription__r.Zuora__CustomerAccount__c');
    orderFields.add('Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c');
    //END UD-1595 6/18/15 AddedBy Fritz/Benzon : additional field for query
   
    for (string field : orderFields) {
      returnValue += ', ' + field;
    }
    
    returnValue += ' from Order__c';
    
    // End D-2157 02/10/2015 JohnD
    
    
    return returnValue;
  }


  public static Order_Line_Item__c getOrderLineItem(id orderLineItemId) {
    
    Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
    //START UD-1112 05/06/2015 Added by J. Sarion - Added Postage Charge
    //Start <No defect> ABanaag 02/20/2015 - added Is_All_In_One__c to query to avoid exception
    // Start/End D-0127 UAT 01-03-2015 JohnD added Suppress_Vendor_Start_notice__c field
    //START 12/21/15 RReyes - UD-3399 - Added Parent_Account__c, Main_Package_Product_Family__c 
    orderLineItem = [select Id, Ph_d__c, Ph_e__c, Order__c, Order__r.Parent_Case__c, Asia1_Creation_Mode__c, Supressed_Grace_Allocation__c, Auto_Renew__c, Charity__c, Contract_End_Date__c, 
                Delivered_By__c, Earliest_Start_Date__c, End_Date__c, Generate_Invoice__c, Is_Digital__c,  Effective_Date__c, 
                Main_Package_ID__c, New_Contract_Period__c, Admin_Charge__c, Main_Package_ID__r.Name, Main_Package_Sub_Type__c, 
                Penalty_Charge__c, PO_Number__c, Qty__c, Start_Date__c, Total_Subscription_Rate__c, New_Quantity__c,
                Add_On_Package_Subscription_Rate__c, Term_is_discussed__c, Main_Package_Billing_Type__c,   
                Main_Package_Type__c, Main_Package_Subscription_Rate__c, Main_Package_Frequency__c, Main_Package_Period__c,
                Supressed_Acknowledgement_Letter__c, Suppress_Renewal_and_Reminder_Letter__c, Main_Package_Product_Sub_Type__c, 
                Supressed_Vendor_Notification_New_Sub__c, Term_Length__c, Vendor_Conversion__c, Suppress_Vendor_Start_notice__c, 
                Vendor_Subscription_ID__c, Addon_Package__c, Addon_Package__r.Name, Promotion_ID__c, Subscribed_as__c, 
                Direct_Sub_Delivery_Method__c, (select Promotion_Gift__r.Gift__r.Name, Promotion_Gift__r.Gift__r.Gift_Type__c, 
                Promotion_Gift__r.Gift__r.Gift_Cost__c, Promotion_Gift__r.Balance_Quantity__c from Order_Line_Item_Gifts__r), 
                (select Asia1__c, Asia1__r.User_ID_LDAP_ID__c, Service_Access_Flag__c,  
                Service_Access_Flag__r.Name, Status__c, Concurrent__c from Asia1_Subscriptions__r), Is_All_In_One__c, Promotion_ID__r.Contract__c, Total_Postage_Charge__c, Parent_Account__c, Main_Package_Product_Family__c 
                from Order_Line_Item__c where Id = :orderLineItemId];
    //END 12/21/15 RReyes - UD-3399 - Added Parent_Account__c, Main_Package_Product_Family__c 
                
          return orderLineItem;
     
  }
  

    public static list<Order_Line_Item__c> getOrderLineItems(id orderId) {
    //Start UD-0333 03-16-15 ABanaag addded Charity__c
    //START UD-1317 06/08/2015 Added by J. Sarion - Added Main Package, AddOn Package, and Subscription Rates
    //START 12/21/15 RReyes - UD-3399 - Added Parent_Account__c, Main_Package_Product_Family__c
    list<Order_Line_Item__c> orderLineItemList = [select Id, Name, Delivered_By__c, Promotion_ID__r.Name, Main_Package_ID__r.Name, New_Quantity__c, Earliest_Start_Date__c, Charity__c,
                //START:D-3461 10/27/2015 Added by Manolo Valena - Added Vendor_Mailing_Agent__c, Vendor_Mailing_Agent__r.Name, and Order__c.Recipient_Contact__r.Address__r.RecordType.Name.
        Qty__c, Start_Date__c, End_Date__c, Main_Package_Type__c, Main_Package_Billing_Type__c, Total_Subscription_Rate__c, Effective_Date__c,Total_Postage_Charge__c, Vendor_Mailing_Agent__c, Vendor_Mailing_Agent__r.Name, Order__r.Recipient_Contact__r.Address__r.RecordType.Name,
                //END:D-3461 10/27/2015 Added by Manolo Valena
        Addon_Package__r.Package_Code__c, Addon_Package__r.Name, Term_Length__c, Postage_Charge__c, Main_Package_Subscription_Rate__c, Add_On_Package_Subscription_Rate__c, Main_Package_ID__c, Addon_Package__c, Parent_Account__c, Main_Package_Product_Family__c, (select Promotion_Gift__c, Gift_Name__c, Type__c, Price__c, Promotion_Gift__r.Gift__r.One_Time_Charge__c from Order_Line_Item_Gifts__r) 
                from Order_Line_Item__c where Order__c = :orderId]; // Start/End D-2874 09May15 JohnD - added Delivered_By__c field
    //END 12/21/15 RReyes - UD-3399 - Added Parent_Account__c, Main_Package_Product_Family__c
    //END UD-1317 06/08/2015 Added by J. Sarion - Added Main Package, AddOn Package, and Subscription Rates
    //End UD-0333 03-16-15 ABanaag addded Charity__c
    return orderLineItemList;
    //END UD-1112 05/06/2015 Added by J. Sarion - Added Postage Charge
    }
  
  public static date getDtlDate() {
    //date dtlDate = date.today().addDays(1);
    //Start: D-1456 01/07/15 Added by ABanaag - if current time is 2pm or later, set dtl date to today() + 1
    integer currentHour= datetime.now().hour();
    integer currentMin= datetime.now().minute();
    date dtlDate = date.today();
    //Start UD-0314 James 03/24-25-30/2015 - declare variables
    string currentDay = datetime.now().format('E');
    string FRIDAY = ConstantsSLB.getOther('Friday');
    string SATURDAY = ConstantsSLB.getOther('Saturday');
    string SUNDAY = ConstantsSLB.getOther('Sunday');
    //End UD-0314 James 03/24-25-30/2015
        list<string> configuredDtlDate = ConstantsSLB.getOther('DTL').split(':');
        boolean isError = false;
        
        if (configuredDtlDate.size() == 2) {
          
          integer hour;
          integer minute;
          
          try {
            
            hour = integer.valueOf(configuredDtlDate[0]);
            
            try {
              
              minute = integer.valueOf(configuredDtlDate[1]);
              
              if (currentHour > = 0 && currentHour< 24 && currentMin>= 0 && currentMin < 60) {  
                if(currentHour > hour || (currentHour == hour && currentMin > minute)){//START/END PD-0096 30-May-2016 Added By S.Puli
                    //Start UD-0314 James 03/24-25-30/2015 - set DTL Date to next monday if subscription is created on friday
                    if(currentDay == FRIDAY){
                        date nextMonday = date.today().addDays(3);
                        Set<Date> PublicHolidayMondaySet = new Set<Date> {};
                        for(Public_Holiday__c PublicHolidayMonday: [Select Name, Holiday_Date__c from Public_Holiday__c where Holiday_Date__c >= :nextMonday order by Holiday_Date__c limit 30]) {
                            PublicHolidayMondaySet.add(PublicHolidayMonday.Holiday_Date__c);
                        }
                        if(PublicHolidayMondaySet.size() > 0){
                            integer Fri2PM = 3;
                            for(integer counterFri2PM = 0 ; counterFri2PM < 30; counterFri2PM++){
                                if(!PublicHolidayMondaySet.contains(date.today().addDays(Fri2PM)) && datetime.now().addDays(Fri2PM).format('E') != SATURDAY && datetime.now().addDays(Fri2PM).format('E') != SUNDAY){
                                    dtlDate = date.today().addDays(Fri2PM);
                                    break;
                                }else{
                                    Fri2PM++;
                                }
                            }
                            dtlDate = date.today().addDays(Fri2PM);
                        }else{
                            dtlDate = date.today().addDays(3);
                        }
                    }else{
                        date datetoday2PM = date.today();
                        Set<Date> PublicHolidayTodaySet2PM = new Set<Date> {};
                        for(Public_Holiday__c PublicHolidayToday2PM: [Select Name, Holiday_Date__c from Public_Holiday__c where Holiday_Date__c >= :datetoday2PM order by Holiday_Date__c limit 30]) {
                            PublicHolidayTodaySet2PM.add(PublicHolidayToday2PM.Holiday_Date__c);
                        }
                        if(PublicHolidayTodaySet2PM.size() > 0){
                            integer Today2PM = 1;
                            for(integer counter2PM = 0 ; counter2PM < 30; counter2PM++){
                                if (!PublicHolidayTodaySet2PM.contains(date.today().addDays(Today2PM)) && datetime.now().addDays(Today2PM).format('E') != SATURDAY && datetime.now().addDays(Today2PM).format('E') != SUNDAY){
                                    dtlDate = date.today().addDays(Today2PM);
                                    break;
                                }else{
                                    Today2PM++;
                                }
                            }
                            dtlDate = date.today().addDays(Today2PM);
                        }else{
                            dtlDate = date.today().addDays(1);
                        }
                    }
                    
                }else{
                    date datetoday = date.today();
                    Set<Date> PublicHolidayTodaySet = new Set<Date> {};
                    for(Public_Holiday__c PublicHolidayToday: [Select Name, Holiday_Date__c from Public_Holiday__c where Holiday_Date__c >= :datetoday order by Holiday_Date__c limit 30]) {
                        PublicHolidayTodaySet.add(PublicHolidayToday.Holiday_Date__c);
                    }
                    if(PublicHolidayTodaySet.size() > 0){
                        integer Tday = 0;
                        for(integer counterTday = 0 ; counterTday < 30; counterTday++){
                            if (!PublicHolidayTodaySet.contains(date.today().addDays(Tday)) && datetime.now().addDays(Tday).format('E') != SATURDAY && datetime.now().addDays(Tday).format('E') != SUNDAY){
                                dtlDate = date.today().addDays(Tday);
                                break;
                            }else{
                                Tday++;
                            }
                        }
                        dtlDate = date.today().addDays(Tday);
                    }else{
                        dtlDate = date.today();
                    }
                }
                //End UD-0314 James 03/24-25-30/2015
    //End: D-1456 01/07/15 Added by ABanaag - if current time is 2pm or later, set dtl date to today() + 1
              } else {
                isError = true;
              }
              
            } catch (exception em) {
              isError = true;
            }
            
          } catch (exception eh) {
            isError = true;
          }
          
        } else {
          isError = true;
        }
        
        if (isError == true) {
          if (datetime.now().hour() > 14) {
              dtlDate = dtlDate.addDays(1);
          }
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidDTLtime'));
          ApexPages.addMessage(myMsg);
        }
        
        return dtlDate;
  }
  
  
    public static map<string, decimal> getCharges(id contactId, string deliveryChargeType, decimal subCharge, decimal venCredit) {
    
        // Start UD-1147/D-2486/D-2907 10Jun15 JohnD - added logic for vendor credit
        //START 01/07/15 Wenjun - Postage Charges: Remove Zone Charge related as it is no longer valid
        map<string, decimal> charges = new map<string, decimal>();
        decimal subscriberCharge;
        decimal vendorCredit;

        // Start D-2874 09Ma15 JohnD - added variables
        final string AIRLINE = ConstantsSLB.getKeyId('AddAirline');
        final string OVERSEAS = ConstantsSLB.getKeyId('AddOverseas');
        final string LOCAL = ConstantsSLB.getKeyId('AddLocal');
        final string INTERNAL = ConstantsSLB.getKeyId('AddInternal');
        decimal priceInternal;
        decimal priceHDB;
        decimal priceApartment;
        decimal priceLanded;
        // End D-2874 09May15 John - added variables    

        if (contactId != null) {
            
            Contact rc = [select Id, Address__c, Address__r.RecordType.Name, Address__r.Address_Type__c, Zone__c from Contact 
                    where Id = :contactId]; // Start/End D-2874 09May15 JohnD - added RecordType.Name field

            string recipientAddressType = rc.Address__r.Address_Type__c;
            string recipientAddressId = rc.Address__c;
            string addressTypeDeliveryChargeType =  recipientAddressType + deliveryChargeType;
            string defaultDeliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);

            if(recipientAddressType != null && deliveryChargeType != null){ //Start/End UD-0946 04/21/15 ABanaag - prevent null values
                
                // subscriber charge
                // Start D-2874 09Ma15 JohnD - added logic to retrieve the subscriber charge from product rate plan
                
                for (zqu__ProductRatePlanCharge__c prpc : [select Name, sum__c, zqu__ProductRatePlan__r.Name 
                        from zqu__ProductRatePlanCharge__c
                        where zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCode__c = :GlobalVariableClass.PRODUCT_CODE_DELCHG 
                        and (not Name like 'Credit%') and (not Name like 'Dummy%') and zqu__Deleted__c = false]) {

                    if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount'))) {
                        priceInternal = prpc.sum__c;
                    } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE'))) {
                        priceHDB = prpc.sum__c;
                    } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('APT DELIVERY CHARGE'))) {
                        priceApartment = prpc.sum__c;
                    } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('LANDED DELIVERY CHARGE'))) {
                        priceLanded = prpc.sum__c;
                    }       
                }     
    
                if (rc.Address__r.RecordType.Name == INTERNAL) {
                    subscriberCharge = priceInternal;
                } else if (rc.Address__r.RecordType.Name == LOCAL || rc.Address__r.RecordType.Name == AIRLINE) {
                    
                    if (deliveryChargeType == 'N' || deliveryChargeType == '9') { //START/END UD-1826 RemovedBy FrancisBenzon (|| deliveryChargeType == '9'), no VC for '9' //START-END UD-3498 Added by J.Sarion - Set Vendor Credit Based on address type
                        if (defaultDeliveryChargeType == 'H') {
                            vendorCredit = priceHDB;
                        } else if (defaultDeliveryChargeType == 'L') {
                            vendorCredit = priceLanded;
                        } else if (defaultDeliveryChargeType == 'C') {
                            vendorCredit = priceApartment;
                        }
                    } else if (deliveryChargeType == 'Z') {
                        vendorCredit = 0.0;
                    } else if (deliveryChargeType == 'S') {
                        vendorCredit = venCredit; //START/END UD-1826 AddedBy FrancisBenzon : if 'S' then VC = SC // Start/End UD-1958 21Jul15 JohnD
                        
                    }
                               
                    if (deliveryChargeType == 'H') {
                        subscriberCharge = priceHDB;
                        vendorCredit = priceHDB;
                    } else if (deliveryChargeType == 'L') {
                        subscriberCharge = priceLanded;
                        vendorCredit = priceLanded;
                    } else if (deliveryChargeType == 'C') {
                        subscriberCharge = priceApartment;
                        vendorCredit = priceApartment;
                    } else if (deliveryChargeType == 'S' || deliveryChargeType == '9') {
                        subscriberCharge = subCharge;
                    } else if (deliveryChargeType == 'N' || deliveryChargeType == 'Z') {
                        subscriberCharge = 0.0;
                    }
                }             
                
                /* start UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out
                if (subscriberCharge == null) {
                    
                    subscriberCharge = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
                    if (subscriberCharge == 9999.99) {
                        subscriberCharge = subCharge;
                    }
                }
                
                // vendor credit
                vendorCredit = ConstantsSLB.getVendorCredit(addressTypeDeliveryChargeType);
                if (vendorCredit == 9999.99) {
                    vendorCredit = venCredit;
                }
                end UD-1147/D-2486/D-2907 10Jun15 JohnD - commented out */
                
            }  //Start/End UD-0946 04/21/15 ABanaag - prevent null values   
        
        } else {
            subscriberCharge = null;
            vendorCredit = null;
        }
        
        // End UD-1147/D-2486/D-2907 10Jun15 JohnD - added logic for vendor credit
        charges.put('SubscriberCharge', subscriberCharge);
        charges.put('VendorCredit', vendorCredit);         
        //End 01/07/15 Wenjun - Postage Charges

        return charges;
    }
    // START : UD-3510 1/8/2016 Alyana Navarro
    /** @Description: Created for Renewal Letter. 
     ** @return : Map<Id, Map<String, Map<String, Decimal>>> Map of Postage/Delivery Charge per Delivery Charge Type per Recipient Contact
     ** @parameters : Map<Id, Set<String>> Map of Delivery Charge Type Set per Recipient Contact
     **               Map<Id, Contact> Map of Recipient Contact
     **/
    public static Map<Id, Map<String, Map<String, Decimal>>> getChargesForRenewalLetter(Map<Id, Set<String>> contactDelChargeTypeMap, Map<id, Contact> recipientContactMap) {   
        decimal subscriberCharge;
        decimal vendorCredit;       
        decimal priceInternal;
        decimal priceHDB;
        decimal priceApartment;
        decimal priceLanded;
        string recipientAddressType;
        string recipientAddressId;
        string addressTypeDeliveryChargeType;
        string defaultDeliveryChargeType;
        final string AIRLINE = ConstantsSLB.getKeyId('AddAirline');
        final string OVERSEAS = ConstantsSLB.getKeyId('AddOverseas');
        final string LOCAL = ConstantsSLB.getKeyId('AddLocal');
        final string INTERNAL = ConstantsSLB.getKeyId('AddInternal');
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = [SELECT Name, sum__c, zqu__ProductRatePlan__r.Name 
                                                                         FROM zqu__ProductRatePlanCharge__c
                                                                         WHERE zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCode__c = :GlobalVariableClass.PRODUCT_CODE_DELCHG 
                                                                            AND (not Name like 'Credit%') AND (not Name like 'Dummy%') AND zqu__Deleted__c = false];
        Map<Id, Map<String, Map<String, Decimal>>> contactDelChargeTypeChargesMap = new Map<Id, Map<String, Map<String, Decimal>>>();

        for(Contact contactRec : recipientContactMap.values()){
            subscriberCharge = null;
            vendorCredit = null;
            if(contactDelChargeTypeMap.containsKey(contactRec.Id)){
                for(String deliveryChargeType : contactDelChargeTypeMap.get(contactRec.Id)){                
                    recipientAddressType = contactRec.Address__r.Address_Type__c;
                    recipientAddressId = contactRec.Address__c;
                    addressTypeDeliveryChargeType =  recipientAddressType + deliveryChargeType;
                    defaultDeliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);

                    if(recipientAddressType != null && deliveryChargeType != null){
                        for (zqu__ProductRatePlanCharge__c prpc : productRatePlanChargeList) {
                            if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount'))) {
                                priceInternal = prpc.sum__c;
                            } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE'))) {
                                priceHDB = prpc.sum__c;
                            } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('APT DELIVERY CHARGE'))) {
                                priceApartment = prpc.sum__c;
                            } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('LANDED DELIVERY CHARGE'))) {
                                priceLanded = prpc.sum__c;
                            }
                        }

                        if (contactRec.Address__r.RecordType.Name == INTERNAL) {
                            subscriberCharge = priceInternal;
                        } else if (contactRec.Address__r.RecordType.Name == LOCAL || contactRec.Address__r.RecordType.Name == AIRLINE) {                        
                            if (deliveryChargeType == 'N') {
                                if (defaultDeliveryChargeType == 'H') {
                                    vendorCredit = priceHDB;
                                } else if (defaultDeliveryChargeType == 'L') {
                                    vendorCredit = priceLanded;
                                } else if (defaultDeliveryChargeType == 'C') {
                                    vendorCredit = priceApartment;
                                }
                            } else if (deliveryChargeType == 'Z') {
                                vendorCredit = 0.0;
                            } else if (deliveryChargeType == 'S') {
                                vendorCredit = null;
                            }
                            
                            if (deliveryChargeType == 'H') {
                                subscriberCharge = priceHDB;
                                vendorCredit = priceHDB;
                            } else if (deliveryChargeType == 'L') {
                                subscriberCharge = priceLanded;
                                vendorCredit = priceLanded;
                            } else if (deliveryChargeType == 'C') {
                                subscriberCharge = priceApartment;
                                vendorCredit = priceApartment;
                            //START UD-3601, UD-3507 4.2.2016 Gdelrosario 
                            } else if (deliveryChargeType == 'S') {
                                subscriberCharge = null;
                            } else if (deliveryChargeType == 'Z') {
                                subscriberCharge = 0.0;
                            } else if (deliveryChargeType == 'N' || deliveryChargeType == '9') {
                                if (defaultDeliveryChargeType == 'H') {
                                    subscriberCharge = priceHDB;
                                } else if (defaultDeliveryChargeType == 'L') {
                                    subscriberCharge = priceLanded;
                                } else if (defaultDeliveryChargeType == 'C') {
                                    subscriberCharge = priceApartment;
                                }
                            }
                            //END UD-3601, UD-3507 4.2.2016 Gdelrosario
                        }
                    }
                    
                    if(contactDelChargeTypeChargesMap.containsKey(contactRec.Id)){
                        if(!contactDelChargeTypeChargesMap.get(contactRec.Id).containsKey(deliveryChargeType)){
                            contactDelChargeTypeChargesMap.get(contactRec.Id).put(deliveryChargeType, new Map<String, Decimal>{
                                                                                        'SubscriberCharge' => subscriberCharge,
                                                                                        'VendorCredit' => vendorCredit
                                                                                    }
                                                                                  );
                        }
                    } else {
                        contactDelChargeTypeChargesMap.put(
                            contactRec.Id, new Map<String, Map<String, Decimal>>{
                                deliveryChargeType => new Map<String, Decimal>{
                                    'SubscriberCharge' => subscriberCharge,
                                    'VendorCredit' => vendorCredit
                                }
                            }
                        );
                    }
                }
            }
        }

        return contactDelChargeTypeChargesMap;
    }
    // START : UD-3510 1/8/2016 Alyana Navarro
  

    public static map<string, decimal> getPackageSubscriptionRate(set<id> packageIds, string billingType) {
        
        map<string, decimal> packageId_subscriptionCharges = new map<string, decimal>();
        
        // retrieve subscription rate
        map<string, list<string>> packageId_productRatePlanIds = new map<string, list<string>>();
        set<id> productRatePlanIds = new set<id>();
        map<id, decimal> productRatePlanId_TotalCharges = new map<id, decimal>();
        //START JSUAREZ 2/18/2015 code review: check packageIds if null
        if(packageIds.size()>0){
        //END JSUAREZ 2/18/2015 code review: check packageIds if null
            for (Package__c pkg : [select Id, (select Id, Product_Rate_Plan__c from Package_Items__r) from Package__c 
                    where Id in :packageIds]) {
                            
                list<string> productRatePlanIdsTmp = new list<string>();
                
                // retrieve product plan ids
                for (Package_Item__c tmp : pkg.Package_Items__r) {
                    
                    if (tmp.Product_Rate_Plan__c != null) {
                        
                        productRatePlanIdsTmp.add(tmp.Product_Rate_Plan__c);
                        productRatePlanIds.add(tmp.Product_Rate_Plan__c);
                    }
                }
                // end retrieve product plan ids
                packageId_productRatePlanIds.put(pkg.Id, productRatePlanIdsTmp);
            }
        }    
        // retrieve product rate plan charge
        //START JSUAREZ 2/18/2015 code review: check productRatePlanIds if null
        if(productRatePlanIds.size()>0){
        //END JSUAREZ 2/18/2015 code review: check productRatePlanIds if null
            for (zqu__ProductRatePlanCharge__c tmp : [select zqu__ProductRatePlan__c, sum__c from zqu__ProductRatePlanCharge__c 
                    where zqu__ProductRatePlan__c in :productRatePlanIds and zqu__ProductRatePlan__r.BillingType__c = :billingType]) {
                
                decimal charges = 0;    
                if (productRatePlanId_TotalCharges.get(tmp.zqu__ProductRatePlan__c) != null) {
                    charges = productRatePlanId_TotalCharges.get(tmp.zqu__ProductRatePlan__c);
                }

                if (tmp.sum__c != null) {
                    charges += tmp.Sum__c;
                    productRatePlanId_TotalCharges.put(tmp.zqu__ProductRatePlan__c, charges);
                }
                
            }
        }
        // end retrieve product rate plan charge
        
        // traverse on productRatePlanId_TotalChages to map with packgeId_subscriptionCharge
        for (string tmp : packageId_productRatePlanIds.keySet()) {
            
            decimal charges = 0;
            
            if (packageId_subscriptionCharges.get(tmp) != null) {
                charges = packageId_subscriptionCharges.get(tmp);
            }
            
            for (string tmp2 : packageId_productRatePlanIds.get(tmp)) {
                if (productRatePlanId_TotalCharges.get(tmp2) != null) {
                    charges += productRatePlanId_TotalCharges.get(tmp2);
                }
            }
            
            packageId_subscriptionCharges.put(tmp, charges.setScale(2));
            
        }
        // end traverse on productRatePlanId_TotalChages to map with packgeId_subscriptionCharge
        
        // end retrieve subscription rate
        
        return packageId_subscriptionCharges;      
    }
    
    
    public static void deleteRelatedOrderLineItemRelatedObjects(id orderLineItemId) {
        
        //Start MMallorca UD-1043 05/14/2015
        try{
        //End MMallorca UD-1043  05/14/2015        
            delete [select id from Order_Line_Item_Gift__c where Order_Line_Item__c = :orderLineItemId];
        //Start MMallorca UD-1043  05/14/2015
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
        //End MMallorca UD-1043  05/14/2015
        // retrieve and delete corresponding asia1
        list<Asia1_Subscription__c> tmpAsia1Subs = [select Id, Asia1__c from Asia1_Subscription__c 
                where Order_Line_Item__c = :orderLineItemId];
        
        if (tmpAsia1Subs.size() > 0) {
          
          set<id> asia1Ids = new set<id>();
          
          for (Asia1_Subscription__c ta1 : tmpAsia1Subs) {
            asia1Ids.add(ta1.Asia1__c);
          }
                
            delete tmpAsia1Subs;
            
            //START UD-2543 10/26/2015 Added by J.Sarion - check if there's other OLI tied to Asia1
            for(Asia1_Subscription__c asia1Sub :[SELECT Id, Asia1__c FROM Asia1_Subscription__c WHERE Asia1__c IN :asia1Ids]){
                if(asia1Ids.contains(asia1Sub.Asia1__c)){
                    asia1Ids.remove(asia1Sub.Asia1__c);
                }
            }
            //END UD-2543 10/26/2015 Added by J.Sarion - check if there's other OLI tied to Asia1

            delete [select Id from Asia1__c where Id in :asia1Ids and Status__c = 'Pending Creation'];
        }
            // retrieve and delete corresponding asia1
            delete [select id from Order_Line_Item__c where Id = :orderLineItemId];
    }
        

    
    //*** Asia1 functionalities

    public static void deleteRelatedOrderLineItemRelatedObjects(id orderId, boolean isAll) {
        
        delete [select id from Order_Line_Item_Gift__c where Order_Line_Item__r.Order__c = :orderId];
        
        // retrieve and delete corresponding asia1
        list<Asia1_Subscription__c> tmpAsia1Subs = [select Id, Asia1__c from Asia1_Subscription__c 
                where Order_Line_Item__r.Order__c = :orderId];
        
        if (tmpAsia1Subs.size() > 0) {
          
          set<id> asia1Ids = new set<id>();
          
          for (Asia1_Subscription__c ta1 : tmpAsia1Subs) {
            asia1Ids.add(ta1.Asia1__c);
          }
            
            delete tmpAsia1Subs;
            delete [select Id from Asia1__c where Id in :asia1Ids and Status__c = 'Pending Creation'];
        }
        // retrieve and delete corresponding asia1

        delete [select id from Order_Line_Item__c where Order__c = :orderId];
    }    


    public static list<Asia1Wrapper> getAsia1s(list<Asia1_Subscription__c> asia1Subs) {

        list<Asia1Wrapper> tmpAsWrapper = new list<Asia1Wrapper>();
        
        map<id, Asia1Wrapper> asia1Id_asia1Subscriptions = new map<id, Asia1Wrapper>();
        
        for (Asia1_Subscription__c tmp : asia1Subs) {
            
            Asia1Wrapper tmpAw = new Asia1Wrapper();
            list<Asia1SubscriptionWrapper> tmpAsList = new list<Asia1SubscriptionWrapper>();
            Asia1SubscriptionWrapper tmpAs = new Asia1SubscriptionWrapper();
            
            if (asia1Id_asia1Subscriptions.get(tmp.Asia1__r.Id) != null) {
                tmpAw = asia1Id_asia1Subscriptions.get(tmp.Asia1__c);
                tmpAsList = tmpAw.asia1Subscriptions;
            }
            
            tmpAw.userId = tmp.Asia1__r.User_ID_LDAP_ID__c;
            tmpAw.asia1Id = tmp.Asia1__r.Id;
            
            tmpAs.serviceFlagId = tmp.Service_Access_Flag__c;
            tmpAs.serviceFlagName = tmp.Service_Access_Flag__r.Name;
            tmpAs.status = tmp.Status__c;
            if (tmp.Concurrent__c != null) {
                tmpAs.concurrent = integer.valueOf(tmp.Concurrent__c);
            }
            
            tmpAsList.add(tmpAs);
            
            tmpAw.asia1Subscriptions = tmpAsList;
            
            asia1Id_asia1Subscriptions.put(tmp.Asia1__c, tmpAw);
        }
        
        
        for (id tmp : asia1Id_asia1Subscriptions.keySet()) {
            tmpAsWrapper.add(asia1Id_asia1Subscriptions.get(tmp));
        }
        
        return tmpAsWrapper;    
    }


    public static map<string, object> validateAsia1Account(string ldapId, string displayName) {
        
        map<string, object> returnValue = new map<string, object>();
        boolean isUserNameExist = false;
        boolean isDisplayNameExist = false;
        boolean isSuccess = true;
        string uImg = '';
        string dImg = '';
        
        
        if (displayName != null) {
            displayName = displayName.replace(' ', '+');
        }

        // check if existing in sfdc
        for (Asia1__c tmp : [select User_ID_LDAP_ID__c, Display_Name__c from Asia1__c 
                where (User_ID_LDAP_ID__c = :ldapId or Display_Name__c = :displayName) 
                and (Status__c = 'Pending Creation' or Status__c = 'Created')]) {
            
            if (ldapId == tmp.User_ID_LDAP_ID__c && ldapId != null) {
                isUserNameExist = true;
            }
            
            if (displayName == tmp.Display_Name__c && displayName != null) {
                isDisplayNameExist = true;
            }
        }
        // end check if existing in fsdc
        
        // call to asia1 actual
        //START: D-1329 12/22/14 Added by S.Puli
        map<string, Object> isValidUserName = AsiaOneServicesController.validateUserName(ldapId);
        //END: D-1329 12/22/14 Added by S.Puli
      
        if (isValidUserName.get('User-Availability') == 'Success' && ldapId.length() >= 8 && ldapId.length() <= 50 
                && isUserNameExist == false) {       
            uImg = '/resource/check';
        //START: D-1329 12/22/14 Added by S.Puli
        } else if (isValidUserName.get('Message') == 'Not Found') {
            uImg = 'Service is down.';
        //END: D-1329 12/22/14 Added by S.Puli
        } else { 
            isSuccess = false;
            uImg = '/resource/wrong';
        }
        
                //Start: D-1416 01/07/15 Added by ABanaag - display name to be validated in asia1 side when checking for availability
        map<string, Object> isValidDisplayName = AsiaOneServicesController.validateDisplayName(displayName);
        //End: D-1416 01/07/15 Added by ABanaag - display name to be validated in asia1 side when checking for availability
        //Start: D-1546 01/13/15 Added by Marvin Gatchalian - use get('DisplayName-Availability') instead of get('User-Availability') 
        //if (isValidDisplayName.get('User-Availability') == 'Success' && displayName.length() >= 5 && displayName.length() <= 50 & isDisplayNameExist == false) {
        if (isValidDisplayName.get('DisplayName-Availability') == 'Success' && displayName.length() >= 5 && displayName.length() <= 50 & isDisplayNameExist == false) {
        //End: D-1546 01/13/15 Added by Marvin Gatchalian - use get('DisplayName-Availability') instead of get('User-Availability') 
                    
            dImg = '/resource/check';

        } else {
            isSuccess = false;
            dImg = '/resource/wrong';
        } 

        returnValue.put('success', isSuccess);
        returnValue.put('username', dImg);
        returnValue.put('ldap', uImg);
        
        return returnValue;
    }
    
    
    public static void createAsia1Subscription(list<Asia1Wrapper> asia1SubscriptionList, id orderLineItemId) {
        
        list<Asia1_Subscription__c> newAsia1Subscriptions = new list<Asia1_Subscription__c>();
        
        for (Asia1Wrapper asia1Tmp : asia1SubscriptionList) {
            
            for (Asia1SubscriptionWrapper asia1SubscriptionTmp : asia1Tmp.asia1Subscriptions) {
                
                Asia1_Subscription__c as1 = new Asia1_Subscription__c();
                as1.Asia1__c = asia1Tmp.asia1Id;
                as1.Concurrent__c = asia1SubscriptionTmp.concurrent;
                //START UD-2036 07/23/2015 Added by J.Sarion - Status will be based whether Service is already active
                as1.Status__c = asia1SubscriptionTmp.Status;
                //END UD-2036 07/23/2015 Added by J.Sarion - Status will be based whether Service is already active
                as1.Service_Access_Flag__c = asia1SubscriptionTmp.serviceFlagId;
                as1.Order_Line_Item__c = orderLineItemId;
                newAsia1Subscriptions.add(as1);
            }
            
            
        }
        
        try {
            insert newAsia1Subscriptions;
        } catch (exception e) {
            ApexPages.addMessages(e);
        }
    }


    public static list<Asia1Wrapper> createAsia1SubscriptionFromAccessFlag(string ldapId, id asia1Id, string pkgId ) {
        
        list<Asia1Wrapper> asia1WrapperTmp = new list<Asia1Wrapper>();
        Asia1Wrapper newAsia1Subscription = new Asia1Wrapper();
        newAsia1Subscription.userId = ldapId;
        newAsia1Subscription.asia1Id = asia1Id;
        set<id> packageIdSet = new set<id>();   // Start/End PD-0035 21Apr16
        
        list<Asia1SubscriptionWrapper> tmpAsia1Subscriptions = new list<Asia1SubscriptionWrapper>();

        // check if package is from promotion
        // end check if package is from promotion
        // Start D-3374 12Aug15 JohnD - added checking of pkgId
        // Start PD-0035 21Apr16 Added by Kristine Balaoing/ J Dacutan - added add on id to package set
        
        if (pkgId != null && pkgId instanceOf id) {
            packageIdSet.add(pkgId);
        }
        
        if (retrievedAddOnId != null && retrievedAddOnId instanceOf id) {
            packageIdSet.add(retrievedAddOnId);
        }
        // End PD-0035 21Apr16 Added by Kristine Balaoing/ J Dacutan
        
        if (!packageIdSet.isEmpty()) {  // Start/End PD-0035 21Apr16 Added by Kristine Balaoing/J Dacutan
      
            for (Package_Access_Flag__c paf : retrieveServiceFlags(packageIdSet)) {
            
                Asia1SubscriptionWrapper tmpAsia1Sub = new Asia1SubscriptionWrapper();
            
                //START UD-2036 07/24/2015 Added by J.Sarion - Check enabled Services
                tmpAsia1Sub.status = 'Disabled';
                if(enabledServices != null){
                    if(enabledServices.contains((paf.Package_Service_Access_Flag__r.Name).toLowerCase())){
                        tmpAsia1Sub.status = 'Enabled';
                    }
                }
                //END UD-2036 07/24/2015 Added by J.Sarion - Check enabled Services
                tmpAsia1Sub.serviceFlagId = paf.Package_Service_Access_Flag__c;
                tmpAsia1Sub.serviceFlagName = paf.Package_Service_Access_Flag__r.Name;
            
                if (paf.No_of_Concurrent_Users__c != null) {
                    tmpAsia1Sub.concurrent = integer.valueOf(paf.No_of_Concurrent_Users__c);
                }
                //System.assertEquals(null, tmpAsia1Sub);
                tmpAsia1Subscriptions.add(tmpAsia1Sub);
            }
          
            newAsia1Subscription.asia1Subscriptions = tmpAsia1Subscriptions;
          
            asia1WrapperTmp.add(newAsia1Subscription);
        }
        // End D-3374 12Aug15 JohnD - added checking of pkgId
        retrievedAddOnId = null;    // Start/End PD-0035 21Apr16 Added by Kristine Balaoing/J Dacutan
        return asia1WrapperTmp;
        //asia1SubscriptionsTotal = asia1Subscriptions.size();
    }
    
    // Start PD-0035 21Apr16 Added by Kristine Balaoing/J Dacutan - changed parameter
    public static list<Package_Access_Flag__c> retrieveServiceFlags(set<id> pkgIdSetParam) {
        return [select Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, 
                No_of_Concurrent_Users__c from Package_Access_Flag__c where Package__c in :pkgIdSetParam];
    }
    // End PD-0035 21Apr16 Added by Kristine Balaoing/J Dacutan 
    
    // START : D-0964 12/12/14 Alyana Navarro/S.Puli
    //@future(callout = true)
    // END : D-0964 12/12/14 Alyana Navarro/S.Puli     
    public static list<Asia1__c> registerAsia1Accounts(id orderId) {    // Start/End UD-3452 19Jan16 JohnD - changed method to return a value
        
        list<Asia1__c> asia1List = new list<Asia1__c>();
        set<id> asia1IdSet = new set<id>();

        // retrieve asia1 ids
        for (Asia1_Subscription__c tmp : [select Asia1__c from Asia1_Subscription__c 
                where Order_Line_Item__r.Order__c = :orderId and Asia1__r.Status__c = 'Pending Creation']) {
            
            asia1IdSet.add(tmp.Asia1__c);
        }
        // end retrieve asia1 ids
        
        //START JSUAREZ 2/18/2015 code review: check packageIds if null
        if(asia1IdSet.size()>0){
        //END JSUAREZ 2/18/2015 code review: check packageIds if null
        // prepare and register asia1 details for registration
        // Start UD-3452 06Jan16 JohnD - removed Phone field and replaced it with contact reference phones
        for (Asia1__c tmp : [select User_ID_LDAP_ID__c, Display_Name__c, First_Name__c, Last_Name__c, 
                    Contact__r.Mobile_Number__c, Contact__r.HomePhone__c, Contact__r.Office_Number__c, 
                    Contact__r.Phone, Contact__r.HomePhone, Password__c, Email__c, ASIAONE_Legacy_Id__c, Log__c, Status__c,  
                    (select Service_Access_Flag__r.Name from Asia1_Subscriptions__r) 
                    from Asia1__c where Id in :asia1IdSet limit 100]) {
        // End UD-3452 06Jan16 JohnD - removed Phone field and replaced it with contact reference phones        
            string serviceFlags = '';
            integer i = 0;

            for (Asia1_Subscription__c tmp2 : tmp.Asia1_Subscriptions__r) {
                
                if (i > 0) {
                    serviceFlags += '|';    
                }

                if (tmp2.Service_Access_Flag__c != null) {
                    serviceFlags += tmp2.Service_Access_Flag__r.Name;
                    i++;
                }
            }

            // Start UD-3452 06Jan16 JohnD
            string phone = '1234567890';
            if (tmp.Contact__r.Phone != null) {
                phone = tmp.Contact__r.Phone;
            } else if (tmp.Contact__r.HomePhone != null) {
                phone = tmp.Contact__r.HomePhone;
            } else if (tmp.Contact__r.Mobile_Number__c != null) {
                phone = tmp.Contact__r.Mobile_Number__c;
            } else if (tmp.Contact__r.HomePhone__c != null) {
                phone = tmp.Contact__r.HomePhone__c;
            } else if (tmp.Contact__r.Office_Number__c != null){
                phone = tmp.Contact__r.Office_Number__c;
            }
            // End UD-3452 06Jan16 JohnD

            
            map<string, string> asia1newCreate = new map<string, string>();
            //START: D-0964 / 12-16-2014 added by MBG/S.Puli: setting service flag default to "com". this is initially deactive service flag. enabling service flag is happen during subscrtiption sync
            //asia1newCreate.put(GlobalVariableClass.SVC, serviceFlags.toLowerCase());
            asia1newCreate.put(GlobalVariableClass.SVC, 'com');
            //END: D-0964 / 12-16-2014 added by MBG/S.Puli: setting service flag default to "com". this is initially deactive service flag. enabling service flag is happen during subscrtiption sync
                        
            asia1newCreate.put(GlobalVariableClass.USERNAME, tmp.User_ID_LDAP_ID__c);
            asia1newCreate.put(GlobalVariableClass.PASSWORD, tmp.Password__c);
            //START UD-3595 11Jan16 FrancisBenzon : change phone reference
            asia1newCreate.put(GlobalVariableClass.PHONE, phone);
            //END UD-3595 11Jan16 FrancisBenzon : change phone reference            
            asia1newCreate.put(GlobalVariableClass.EMAIL, tmp.Email__c);
            //START: D-1855 / 01-28-2015 modified by Marvin Gatchalian: the value should be 'no' instead of 'false'
            //START: D-0964 / 12-16-2014 added by MBG/S.Puli
            //asia1newCreate.put(GlobalVariableClass.ENABLE, 'false');
            asia1newCreate.put(GlobalVariableClass.ENABLE, 'no');
            //END: D-0964 / 12-16-2014 added by MBG/S.Puli
            //END: D-1855 / 01-28-2015 modified by Marvin Gatchalian: the value should be 'no' instead of 'false'
            asia1newCreate.put(GlobalVariableClass.IP, '');
            
            if (tmp.First_Name__c != null) {
                asia1newCreate.put(GlobalVariableClass.FNAME, tmp.First_Name__c.replace(' ', '+'));
            }
            
            if (tmp.Last_Name__c != null) {
                asia1newCreate.put(GlobalVariableClass.LNAME, tmp.Last_Name__c.replace(' ', '+'));
            }
            
            if (tmp.Display_Name__c != null) {
                asia1newCreate.put(GlobalVariableClass.DISPLAY_NAME, tmp.Display_Name__c.replace(' ', '+'));
            }
            
            map<string, Object> asia1Return = AsiaOneServicesController.createAccount(asia1newCreate);
            
            if (asia1Return.get('Sign-Up') == 'Success') {
                tmp.Status__c = 'Created';
                tmp.ASIAONE_Legacy_Id__c = (string)asia1Return.get('System Id');
                //START: D-1855 / 01-28-2015 modified by Marvin Gatchalian: this piece of code will be moved upon subscription is created
                // START: D-1923 / 01/27/2015 added by Marvin Gatchalian: added setting enable field to true to meet workflow criteria for sending email activation
                // tmp.Enabled__c = true;   // Start/End UD-3427 08Jan16 JohnD - commented out for this filed will be set to "true" through activation link
                // END: D-1923 / 01/27/2015 added by Marvin Gatchalian: added setting enable field to true to meet workflow criteria for sending email activation
                //END: D-1855 / 01-28-2015 modified by Marvin Gatchalian: this piece of code will be moved upon subscription is created
            } else {
                tmp.Status__c = 'Error Creation';
                
                if (asia1Return.get('Error') != null) {
                    tmp.Log__c = string.valueOf(asia1Return.get('Error'));
                    
                } else if (asia1Return.get('Errors') != null) {
                    tmp.Log__c = string.valueOf(asia1Return.get('Errors'));
                }
            }
            
            
            // 12-16-2014 as per Nitin the user account should be enabled upon registration. line of code below is no longer needed.
            //START: D-0964 / 12-16-2014 added by MBG/S.Puli: we need to disable the account upon creation based on FDS the account should be disabled
            //    asia1Return = AsiaOneServicesController.disableUserAccount(tmp.User_ID_LDAP_ID__c);
            //END: D-0964 / 12-16-2014 added by MBG/S.Puli: we need to disable the account upon creation based on FDS the account should be disabled
            
            asia1List.add(tmp);         
        }
        // end prepare and register asia1 details for registration
        }
        
        return asia1List;   // Start/End UD-3452 19Jan16 JohnD - changed "update" to "return"
    }
    
    
    public static void mapSubscriptionToAsia1Subscription(set<id> subscriptionIdSet) {
        
        map<id, id> orderLineItemId_subscriptionId = new map<id, id>();
        list<Asia1_Subscription__c> asia1SubscriptionList = new list<Asia1_Subscription__c>();
        
        //START JSUAREZ 2/18/2015 code review: check subscriptionIdSet if null
        if(subscriptionIdSet.size()>0){
        //END JSUAREZ 2/18/2015 code review: check subscriptionIdSet if null
            for (Zuora__Subscription__c tmp : [select Id, Order_Line_Item_Number_1__c from Zuora__Subscription__c 
                    where Id in :subscriptionIdSet]) {
                
                //START JSUAREZ 2/18/2015 code review: check tmp.Order_Line_Item_Number_1__c, tmp.Id if null
                if(tmp.Order_Line_Item_Number_1__c != NULL || tmp.Id != NULL){
                //END JSUAREZ 2/18/2015 code review: check tmp.Order_Line_Item_Number_1__c, tmp.Id if null
                    orderLineItemId_subscriptionId.put(tmp.Order_Line_Item_Number_1__c, tmp.Id);
                }
            }
        }
        
        for (Asia1_Subscription__c tmp : [select Id, Subscription__c, Order_Line_Item__c, Asia1__r.Status__c 
                from Asia1_Subscription__c where Order_Line_Item__c in :orderLineItemId_subscriptionId.keySet()]) {
            
            tmp.Subscription__c = orderLineItemId_subscriptionId.get(tmp.Order_Line_Item__c);
            
            if (tmp.Asia1__r.Status__c == 'Created') {
            //START: D-0964 / 12-16-2014 removed by S.Puli  
                //tmp.Status__c = 'Disabled';
            //END: D-0964 / 12-16-2014 removed by S.Puli
            }
            
            asia1SubscriptionList.add(tmp);
        }
        
        try {
            update asia1SubscriptionList;
        } catch(exception e ) {
            system.debug('mapSubscriptionToAsia1Subscription error : ' + e);
        }
    }
    

    //*** End Asia1 functionalities







    public static string getRelatedPackages(string promotionId, string billingType) {
        map<string, decimal> packageId_subscriptionCharge = new map<string, decimal>();
        list<RelatedPackageWrapper> relatedPackages = new list<RelatedPackageWrapper>();
        list<SObject> promotionPackages = [select Package_Name__c, Package_Name__r.Name pkgName, Package_Name__r.Package_Type__c pkgType, 
                Package_Name__r.Subscription_Type__c pkgSubType, Package_Name__r.Subscription_Period__c pkgSubPeriod, Package_Name__r.Billing_Type__c pkgBillType  
                from Promotion_Package__c where Promotion__c = :promotionId and Package_Name__r.Billing_Type__c = :billingType 
                group by Package_Name__c, Package_Name__r.Name, Package_Name__r.Package_Type__c, Package_Name__r.Subscription_Type__c, 
                Package_Name__r.Subscription_Period__c, Package_Name__r.Billing_Type__c];
        
        
        set<id> packageIds = new set<id>();
        for (SObject tmp : promotionPackages) {
            packageIds.add((id)tmp.get('Package_Name__c'));
        }
        
        packageId_subscriptionCharge = getPackageSubscriptionRate(packageIds, billingType);
        
        
        
        for (SObject tmp : promotionPackages) {
            
            RelatedPackageWrapper rpw = new RelatedPackageWrapper();
            rpw.packageId = (id)tmp.get('Package_Name__c');
            rpw.packageName = (string)tmp.get('pkgName');
            rpw.packageType = (string)tmp.get('pkgType');
            rpw.packageSubscriptionType = (string)tmp.get('pkgSubType');
            rpw.packageSubscriptionPeriod = (string)tmp.get('pkgSubPeriod');
            rpw.packageSubscriptionRate = packageId_subscriptionCharge.get((id)tmp.get('Package_Name__c'));
            
            relatedPackages.add(rpw);
        }
        return JSON.serialize(relatedPackages);
    }
    
    //START D-2888 5/27/2015 Added by Manolo Valena - Added new parameter 'subscriptionId' in the method.
    // Start D-2157 02/10/2015 JohnD added parameter in the method
    public static string getRelatedPackages(String promotionId, String billingType, String accountId, String action, boolean isVendor, Id subscriptionId) {
    // End D-2157 02/10/2015 JohnD
    //END D-2888 5/27/2015 Added by Manolo Valena
        Set<Id> packIds = new Set<Id>();
        Set<String> packageCodes = new Set<String>();
        Map<String, Set<String>> mapPromoToPackages = new Map<String, Set<String>>();
        Promotion__c Promotion = [SELECT Id, Contract_Period__c, Promotion_Code__c
                                  FROM Promotion__c
                                  WHERE Id = : promotionId];
                                  
        Map<String , Set<String>> singlePromoCodeToContract = new Map<String , Set<String>>();
        if(singlePromoCodeToContract.containsKey(Promotion.Promotion_Code__c)){
            singlePromoCodeToContract.get(Promotion.Promotion_Code__c).add(Promotion.Contract_Period__c);
        }
        else{
            singlePromoCodeToContract.put(Promotion.Promotion_Code__c, new Set<String>{Promotion.Contract_Period__c});
        }
        //calls promoElig Rule to look for eligibile packages
        PromoEligibilityRule promoElig = new PromoEligibilityRule();
        //START D-2888 5/27/2015 Added by Manolo Valena - Added subscriptionId value for Change of Subscription.
        mapPromoToPackages = promoElig.getEligibility(accountId, action, singlePromoCodeToContract, null, subscriptionId, isVendor);
        //mapPromoToPackages = promoElig.getEligibility(accountId, action, singlePromoCodeToContract, null, null, isVendor);
        //END D-2888 5/27/2015 Added by Manolo Valena
        packageCodes = mapPromoToPackages.get(Promotion.Id);
        List<Package__c> packageList = new List<Package__c>();
        //START JSUAREZ 2/18/2015 code review: check packageCodes if null
        if(packageCodes.size()>0){
        //END JSUAREZ 2/18/2015 code review: check packageCodes if null
            packageList = [SELECT Id, Package_Code__c
                           FROM Package__c
                           WHERE Package_Code__c IN :packageCodes];
        }
        for(Package__c pack : packageList){
            packIds.add(pack.Id);
        }
        
        map<string, decimal> packageId_subscriptionCharge = new map<string, decimal>();
        list<RelatedPackageWrapper> relatedPackages = new list<RelatedPackageWrapper>();
        //START JSUAREZ 2/18/2015 code review: check packIds if null
        list<SObject> promotionPackages;
        if(packIds.size()>0){
        //END JSUAREZ 2/18/2015 code review: check packIds if null
            promotionPackages = [select Package_Name__c, Package_Name__r.Name pkgName, Package_Name__r.Package_Type__c pkgType, 
                    Package_Name__r.Subscription_Type__c pkgSubType, Package_Name__r.Subscription_Period__c pkgSubPeriod, Package_Name__r.Billing_Type__c pkgBillType  
                    FROM  Promotion_Package__c 
                    WHERE Promotion__c = :promotionId and Package_Name__r.Billing_Type__c = :billingType and Package_Name__c IN :packIds
                    GROUP BY Package_Name__c, Package_Name__r.Name, Package_Name__r.Package_Type__c, Package_Name__r.Subscription_Type__c, 
                    Package_Name__r.Subscription_Period__c, Package_Name__r.Billing_Type__c];
        }
        
        set<id> packageIds = new set<id>();
        for (SObject tmp : promotionPackages) {
                packageIds.add((id)tmp.get('Package_Name__c'));
        }
        
        packageId_subscriptionCharge = getPackageSubscriptionRate(packageIds, billingType);
        
        
        
        for (SObject tmp : promotionPackages) {
            
            RelatedPackageWrapper rpw = new RelatedPackageWrapper();
            rpw.packageId = (id)tmp.get('Package_Name__c');
            rpw.packageName = (string)tmp.get('pkgName');
            rpw.packageType = (string)tmp.get('pkgType');
            rpw.packageSubscriptionType = (string)tmp.get('pkgSubType');
            rpw.packageSubscriptionPeriod = (string)tmp.get('pkgSubPeriod');
            rpw.packageSubscriptionRate = packageId_subscriptionCharge.get((id)tmp.get('Package_Name__c'));
            
            relatedPackages.add(rpw);
        }

        return JSON.serialize(relatedPackages);
    }
    
    
    public static date getEarliestStartDate(id packageId) {
        
        date returnValue;
        if (packageId != null) {
            set<id> productIds = new set<id>();
            
            try {
                
                Package__c pkg = [select Id, (select Id, Product_Rate_Plan__r.zqu__ZProduct__c from Package_Items__r) 
                      from Package__c where Id = :packageId];
                
                
                for (Package_Item__c tmp : pkg.Package_Items__r) {
                    productIds.add(tmp.Product_Rate_Plan__r.zqu__ZProduct__c);
                }           
    
                // retrieve earliest publication date and direct sub delivery method
                // assumption: all publications related to the package have the same delivery method
                try {
                    //START JSUAREZ 2/18/2015 code review: check productIds if null
                    if(productIds.size()>0){
                    //END JSUAREZ 2/18/2015 code review: check productIds if null
                        Product_Publication__c publicationDetail = [select Publication_Code__r.Earliest_Start_Date__c 
                                from Product_Publication__c where ZProduct__c in :productIds 
                                order by Publication_Code__r.Earliest_Start_Date__c asc limit 1];
                        
                        returnValue = publicationDetail.Publication_Code__r.Earliest_Start_Date__c;
                    }   
                } catch (exception e) {
                    returnValue = null;
                }
                // end retrieve earliest publication date
                
            } catch (exception e) {
                returnValue = null;
            }
        }
        
        return returnvalue;
    }
    
    //START:UD-0451 3/25/15 Added by Manolo Valena - New method for renewal subscription.
    public static string getRelatedPackagesOnProdFam(string promotionId, string billingType, string sPId) 
    {
        map<string, decimal> packageId_subscriptionCharge = new map<string, decimal>();
        list<RelatedPackageWrapper> relatedPackages = new list<RelatedPackageWrapper>();
        
        list<SObject> promotionPackages = [select Package_Name__c, Package_Name__r.Name pkgName, Package_Name__r.Package_Type__c pkgType, 
                Package_Name__r.Subscription_Type__c pkgSubType, Package_Name__r.Subscription_Period__c pkgSubPeriod, Package_Name__r.Billing_Type__c pkgBillType  
                from Promotion_Package__c where Promotion__c = :promotionId and Package_Name__r.Billing_Type__c = :billingType 
                group by Package_Name__c, Package_Name__r.Name, Package_Name__r.Package_Type__c, Package_Name__r.Subscription_Type__c, 
                Package_Name__r.Subscription_Period__c, Package_Name__r.Billing_Type__c];
        
        
        set<id> packageIds = new set<id>();
        for (SObject tmp : promotionPackages) {
            packageIds.add((id)tmp.get('Package_Name__c'));
        }
        
        
        packageId_subscriptionCharge = getPackageSubscriptionRate(packageIds, billingType);
        
        
        set<string> productFams = new set<string>();
        list<Package_Item__c> packItemList;
        for(Package_Item__c p : [SELECT Product_Family2__c FROM Package_Item__c WHERE Package__c =: sPId])
        {
            if(p.Product_Family2__c != null)
            {
                productFams.add(p.Product_Family2__c);
            }
        }
        
        if(productFams.size() > 0)
        {
            packItemList = [SELECT Package__c, Package__r.Name, Package__r.Package_Type__c, 
                                   Package__r.Subscription_Type__c, Package__r.Subscription_Period__c 
                            FROM Package_Item__c 
                            WHERE Package__c IN : packageIds 
                            AND Product_Family2__c IN : productFams];
        
        
           for (Package_Item__c tmp : packItemList) {
                RelatedPackageWrapper rpw = new RelatedPackageWrapper();
                rpw.packageId = (id)tmp.Package__c;
                rpw.packageName = (string)tmp.Package__r.Name;
                rpw.packageType = (string)tmp.Package__r.Package_Type__c;
                rpw.packageSubscriptionType = (string)tmp.Package__r.Subscription_Type__c;
                rpw.packageSubscriptionPeriod = (string)tmp.Package__r.Subscription_Period__c;
                rpw.packageSubscriptionRate = packageId_subscriptionCharge.get((id)tmp.get('Package__c'));
                Integer count = 0;
                if(relatedPackages.size() > 0)
                {
                    for(RelatedPackageWrapper r : relatedPackages)
                    {
                         if(r.packageId == rpw.packageId)
                         {
                             count = 1;
                         }   
                    }
                    if(count != 1)
                    {
                        relatedPackages.add(rpw);
                    }
                }
                else
                {
                    relatedPackages.add(rpw);
                }    
            }
        }
        else
        {
            packItemList = [SELECT Package__c, Package__r.Name, Package__r.Package_Type__c, 
                                   Package__r.Subscription_Type__c, Package__r.Subscription_Period__c 
                            FROM Package_Item__c 
                            WHERE Package__c IN : packageIds];
        
        
            for (Package_Item__c tmp : packItemList) {
                RelatedPackageWrapper rpw = new RelatedPackageWrapper();
                rpw.packageId = (id)tmp.Package__c;
                rpw.packageName = (string)tmp.Package__r.Name;
                rpw.packageType = (string)tmp.Package__r.Package_Type__c;
                rpw.packageSubscriptionType = (string)tmp.Package__r.Subscription_Type__c;
                rpw.packageSubscriptionPeriod = (string)tmp.Package__r.Subscription_Period__c;
                rpw.packageSubscriptionRate = packageId_subscriptionCharge.get((id)tmp.get('Package__c'));
                Integer count = 0;
                if(relatedPackages.size() > 0)
                {
                    for(RelatedPackageWrapper r : relatedPackages)
                    {
                         if(r.packageId == rpw.packageId)
                         {
                             count = 1;
                         }   
                    }
                    if(count != 1)
                    {
                        relatedPackages.add(rpw);
                    }
                }
                else
                {
                    relatedPackages.add(rpw);
                }    
            }
        }
        return JSON.serialize(relatedPackages);
    }
    //END:UD-0451 3/25/15 Added by Manolo Valena  
    
    //START D-2759 Wenjun 13/04/15 - Convert Billing Type
    public static String getBillingTypeForBA(String billingType)
    {
        //START D-3159 and D-3160 02-July-2015 Added by Raviteja - Implementing New Splitting Billing Type Scenario - 'Prepaid'and 'Postpaid' no more valid as per new implementation
         if(billingType == GlobalVariableClass.BILLING_TYPE_FULL_PRE){
            return GlobalVariableClass.BILLING_TYPE_FULL_PRE; 
             } 
          else if(billingType == GlobalVariableClass.BILLING_TYPE_MR_PRE){
            return GlobalVariableClass.BILLING_TYPE_MR_PRE;
            }
        else if(billingType == GlobalVariableClass.BILLING_TYPE_MR_POST)
            return GlobalVariableClass.BILLING_TYPE_MR_POST;   
        //End D-3159 and D-3160 02-July-2015 Added by Raviteja 
        return null;
    }
    //END D-2759 Wenjun 13/04/15
    
    //START D-3224 7/6/15 Rebuild AddedBy FrancisBenzon : compare stop request date is less than Invoice Target Date
    public static Date checkInvoiceTargetDate(Id pubSubId, Date stopRequestDate)
    {
        List<Invoice_Line_Item__c> invoiceLineItem = new List<Invoice_Line_Item__c>();
        Zuora__ZInvoice__c invoiceRec = new Zuora__ZInvoice__c();
        Boolean isBeforeTargetDate = false;
        Date invoiceTargetDate;
        
        try
        {
            invoiceLineItem = [Select Invoice_ID__c From Invoice_Line_Item__c Where Subscription__c = :pubSubId Order By CreatedDate DESC];         
        }
        catch(exception e)
        {
            invoiceLineItem = new List<Invoice_Line_Item__c>();
            system.debug('ERROR' + e);
        }
        
        if(invoiceLineItem != null && !invoiceLineItem.isEmpty())
        {
            try
            {
                invoiceRec = [Select Zuora__TargetDate__c From Zuora__ZInvoice__c Where Zuora__Zuora_Id__c = :invoiceLineItem[0].Invoice_ID__c];
            }
            catch(exception e)
            {
                invoiceRec = new Zuora__ZInvoice__c();
                system.debug('ERROR' + e);
            }
            //START UD-2482 8/27/15 Hotfix By FrancisBenzon : removed previous condition as there is already checking in COSEntryCont
            if(invoiceRec != null)
            {
                invoiceTargetDate = invoiceRec.Zuora__TargetDate__c;
                isBeforeTargetDate = true; 
            }
            //END UD-2482 8/27/15 Hotfix By FrancisBenzon : removed previous condition as there is already checking in COSEntryCont         
        }
        return invoiceTargetDate;       
    }
    //END D-3224 7/6/15 Rebuild AddedBy FrancisBenzon : compare stop request date is less than Invoice Target Date
    //START D-3231 07/07/15 Wenjun : Utility Method to check whether Order Line Items are overlapping
    //This method applies to Termed Subscriptions only
    public static Boolean isPartiallyOverlapping(List<Order_Line_Item__c> orderItemList, Order_Line_Item__c orderLineItem)
    {
        Date periodStart;
        Date periodEnd;
        Date oliEndDate;
        
        if(orderItemList.isEmpty()) return false;
        if(orderLineItem.Delivered_By__c != GlobalVariableClass.VENDOR || orderLineItem.Start_Date__c == NULL 
            || orderLineItem.Term_Length__c == NULL)
            return false;   

        for(Order_Line_Item__c existingOli : orderItemList)
        {
            if(existingOli.Delivered_By__c == GlobalVariableClass.VENDOR)
            {
                if(periodStart == null || periodStart > existingOli.Start_Date__c)
                    periodStart = existingOli.Start_Date__c;
                
                if(periodEnd == null || periodEnd < existingOli.End_Date__c)
                    periodEnd = existingOli.End_Date__c;
            }
        }
        
        if(periodStart == NULL || periodEnd == NULL) return false;  
        
        //Compute Order Line End Date
        oliEndDate = orderLineItem.Start_Date__c.addMonths((Integer)orderLineItem.Term_Length__c).addDays(-1);
        
        if((orderLineItem.Start_Date__c < periodStart && oliEndDate < periodEnd)   
            || (orderLineItem.Start_Date__c > periodStart && oliEndDate > periodEnd))
            return true;
        else 
            return false;
    }
    
    public static Order_Line_Item__c getLongestOrderLineItem(List<Order_Line_Item__c> orderItemList)
    {
        Order_Line_Item__c orderLineItem;
        
        if(orderItemList.isEmpty()) return NULL;
        
        for(Order_Line_Item__c oli : orderItemList)
        {
            if(oli.Delivered_By__c == GlobalVariableClass.VENDOR)
            {
                if(orderLineItem == null) 
                    orderLineItem = oli;
                //START UD-1991 E2E Hotfix Wenjun 20/07/15 
                else if(oli.Start_Date__c == orderLineItem.Start_Date__c && oli.End_Date__c == orderLineItem.End_Date__c)
                    continue;
                else if(oli.Start_Date__c <= orderLineItem.Start_Date__c && oli.End_Date__c >= orderLineItem.End_Date__c)
                    orderLineItem = oli;
                //END UD-1991 E2E Hotfix Wenjun 20/07/15 
            }
        }
        
        return orderLineItem;
    }
    //END D-3231 07/07/15 Wenjun
    //START D-3223 07/07/15 RReyes - checks if the order has billing account before save
    public static Boolean hasBillingAccount(String origin, Order__c thisOrder){
        Boolean hasBillAcct = false;  // Start/End UD-2614 05Sep15 JohnD - replaced true to false
        // String creationMode = '';  // Start/End UD-2614 05Sep15 JohnD - commented out
        if(thisOrder != null){
          
          // Start UD-2614 05Sep15 JohnD - commented out
          /*
            creationMode = thisOrder.Billing_Account_Creation_Mode__c;
            if(thisOrder.Payment_Mode__c == null){
                thisOrder.Payment_Mode__c = '';
            }
            if(creationMode == '' || creationMode == null ){
                if(origin == 'START' || Origin == 'CHANGE'){
                    creationMode = 'Use existing billing account';
                }else{
                    creationMode = 'Create new billing account';
                }
            }
            if(origin == 'START'){
                if(creationMode == 'Use existing Billing Account' && thisOrder.Payment_Mode__c == ''){
                    hasBillAcct = false;
                }
            }
            else if(origin == 'CHANGE'){
                if(creationMode == 'Use existing Billing Account' && thisOrder.Payment_Mode__c == ''){
                    hasBillAcct = false;
            }
            }
            else if(origin == 'RENEWAL'){
                if(creationMode == 'Create New Billing Account' && thisOrder.Payment_Mode__c == ''){
                    hasBillAcct = false;
                }   
            }
            */
            // End UD-2614 05Sep15 JohnD - commented out
            
            // Start UD-2614 05Sep15 JohnD - replaced existing logic
            if (thisOrder.Billing_Account_Creation_Mode__c != null && thisOrder.Payment_Mode__c != null) {
              
              hasBillAcct = true;
              
              if (thisOrder.Billing_Account_Creation_Mode__c == 'Use existing Billing Account' 
                  && thisOrder.Billing_Account__c == null) {
                
                hasBillAcct = false;
              }
            }
            // End UD-2614 05Sep15 JohnD - replaced existing logic
        }
        return hasBillAcct;
    }
    //END D-3223 07/07/15 RReyes - checks if the order has billing account before save
    //START UD-2143 07/30/15 RReyes - SIT Hotfix - added filtering to exclude Asia1 from deletion if being used by Asia1Subscription
    public static void deleteRelatedOrderLineItemRelatedObjects(id orderId, boolean isAll, List<Asia1Wrapper> lstAsia1Wrapper) {
        
        delete [select id from Order_Line_Item_Gift__c where Order_Line_Item__r.Order__c = :orderId];
        List<Asia1_Subscription__c> lstAsia1DoNotDelete = new List<Asia1_Subscription__c>();
        Set<id> setAsia1IdDoNotDelete = new Set<id>();
        list<Asia1_Subscription__c> tmpAsia1Subs = [select Id, Asia1__c, Order_Line_Item__c  from Asia1_Subscription__c 
                where Order_Line_Item__r.Order__c = :orderId];

        for(Asia1_Subscription__c asia1Sub: tmpAsia1Subs){
            for(Asia1Wrapper as1wrap : lstAsia1Wrapper){
                if(as1wrap.asia1id != null)
                {
                    if(asia1Sub.Asia1__c == id.valueOf(as1wrap.asia1id)){   
                        setAsia1IdDoNotDelete.add(asia1Sub.Asia1__c);                   
                    }
                }
            }
        }
        if (tmpAsia1Subs.size() > 0) {
          
          set<id> asia1Ids = new set<id>();

          for (Asia1_Subscription__c ta1 : tmpAsia1Subs) {
            if(setAsia1IdDoNotDelete.size() > 0)
            {   if(!setAsia1IdDoNotDelete.contains(ta1.Asia1__c))
                    asia1Ids.add(ta1.Asia1__c);
            }else{
                asia1Ids.add(ta1.Asia1__c);
            }
          }
            delete tmpAsia1Subs;
            delete [select Id from Asia1__c where Id in :asia1Ids and Status__c = 'Pending Creation'];
        }

        delete [select id from Order_Line_Item__c where Order__c = :orderId];
    }  
    //END UD-2143 07/30/15 RReyes - SIT Hotfix - added filtering to exclude Asia1 from deletion if being used by Asia1Subscription
    
    //START UD-2220 09/15/15 RReyes
    public static boolean checkExistingInvoice(id accountId, string billType){
        List<Zuora__CustomerAccount__c> billAccList = new List<Zuora__CustomerAccount__c>();
        Boolean isError = false;
        
        if(accountId != null && billType != null){
            billAccList = [SELECT Id FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c =: accountId AND Billing_Type__c=:billType AND Other_PaymentMethod__c = 'Invoice' LIMIT 1];
        }
        if(billAccList.size() > 0){
            isError = true;
        }
        
        return isError;
    }
    //END UD-2220 09/15/15 RReyes
    //START UD-3381 12/15/15 RReyes
    public static String checkTStopRestartDates(id baseSubId, date startStopDate, string origin){
        String errorMessage = null;
        List<Temp_Stop__c> lstTStop = new List<Temp_Stop__c>();
        if(baseSubId != null){
            lstTStop = [SELECT Id, Restart_Date__c, Case__c FROM Temp_Stop__c WHERE Case__r.RecordType.Id=:ConstantsSLB.getKeyId(GlobalVariableClass.CASETEMPSTOP) AND Case__r.Status =:GlobalVariableClass.STATUS_CLOSED AND Case__r.Temp_Stop_Sub__c =:baseSubId AND Cancelled__c = false ORDER BY Restart_Date__c DESC NULLS LAST LIMIT 1];
        }
        if(lstTStop.size() > 0 && startStopDate != null){
            if(lstTStop[0].Restart_Date__c != null){
                if(lstTStop[0].Restart_Date__c >= startStopDate){
                    Date errorDate = lstTStop[0].Restart_Date__c.addDays(1);
                    if(origin == GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION ){
                        errorMessage = 'There is a pending Temp Stop for this subscription. You shall either amend / cancel the pending Temp Stop before continuing or change the COS Start Date to ' + errorDate + ' onwards.';    
                    }else if(origin == GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION){
                        errorMessage = 'There is a pending Temp Stop for this subscription. You shall either amend / cancel the pending Temp Stop before continuing or change the Stop Date to ' + errorDate + ' onwards.';
                    }
                }
            }
        }
        return errorMessage;
    }
    public static String validateFutureDatedCOA(id recipientContact, date stopDate, string origin){
        String errorMessage = null;
        Boolean hasError = false;
        List<Address_Assignment__c > lstAddAssign = new List<Address_Assignment__c >();
        if(recipientContact != null){
        lstAddAssign = [SELECT Id, Name, Case__c, Effective_Date__c FROM Address_Assignment__c WHERE Contact__c =: recipientContact AND Effective_Date__c > TODAY AND Active__c  = false AND Case__r.RecordType.Id =: ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGEADD) 
                        AND Case__r.Sub_Category__c =: GlobalVariableClass.SUBCATEGORY_CHANGE_OF_ADDRESS AND Case__r.Status =: GlobalVariableClass.STATUS_CLOSED ORDER BY Effective_Date__c DESC NULLS LAST LIMIT 1];
        }
        if(lstAddAssign.size() > 0){
            if(lstAddAssign[0].Effective_Date__c != null){
                    if(origin == GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION || origin == GlobalVariableClass.RECTYPE_RENEWAL_OF_SUBSCRIPTION ){ //START-END D-4099 K. Tan 12/18/201
                        if(lstAddAssign[0].Effective_Date__c  > Date.TODAY()){
                            hasError = true;
                        }
                    }else if(origin == GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION && stopDate != null){
                       if(lstAddAssign[0].Effective_Date__c  >= stopDate){
                            hasError = true;
                        }
                    }
            }
        }
        if(hasError){
            errorMessage = 'There is a future COA transaction with effective date on ' + lstAddAssign[0].Effective_Date__c + ' for the selected recipient contact. You shall void the existing COA transaction in order to proceed.';    
        }
        return errorMessage;
    }
    //END UD-3381 12/15/15 RReyes
    
    //START: PD-0035 04/19/2016 Added by Kristine Balaoing - added logic for retreieval of add on package id
    public static void retrieveAddOn(String addOnId){ 
        
        retrievedAddOnId = addOnId;
    }
    
    //END: PD-0035 04/19/2016 Added by Kristine Balaoing - added logic for retreieval of add on package id
}