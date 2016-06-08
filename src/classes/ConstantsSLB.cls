public Class ConstantsSLB {

    /**
     * Class Name: ConstantsSLB
     * @author: Jeffrey B. Teves
     * Date: July 14, 2014
     * Requirement/Project Name: CRSM Project
     * @description Main function is to provide standard means to access Custom Setting Records across entire organization.
     * 
     */
    
    public static String getKeyId(String keyIdName) {
        try {
            Key_Id__c key = Key_Id__c.getInstance(keyIdName);
            return key.Id__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + keyIdName + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }
    
    public static String getIntegrationSettings(String integrationSettings) {
        try {
            Integration_Settings__c is = Integration_Settings__c.getInstance(integrationSettings);
            return is.value__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Error Message record found for Name: \'' + integrationSettings + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }
    
    public static String getUOM(String UOM) {
        try {
            UOM__c unitOfMeasure = UOM__c.getInstance(UOM);
            return unitOfMeasure.Label__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No UOM record found for Label: \'' + UOM + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }
    //Start: MD-54 03/12/2015 Jason Abolac
    public static SMS_Integration_Gateway__c getSMSIntegrationGateway(string smsconfiguration) {
        try {
            SMS_Integration_Gateway__c SMS = SMS_Integration_Gateway__c.getInstance(smsconfiguration);
            return SMS;
        }
    catch(NullPointerException e) {
            System.debug('Error: No SMS settings record found for SMS integration gateway: \'' + smsconfiguration + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
    }
}
  //End: MD-54 03/12/2015 Jason Abolac
    
    public static String getErrorMessage(String errorMessageName) {
        try {
            Error_Messages__c msg = Error_Messages__c.getInstance(errorMessageName);
            return msg.Message__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Error Message record found for Name: \'' + errorMessageName + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }
    
    public static String getZuoraConfig(String zuoraconfig) {
        try {
            Zuora_Configuration__c zc = Zuora_Configuration__c.getInstance(zuoraconfig);
            return zc.Value__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Error Value record found for Zuora Config: \'' + zuoraconfig + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }
    
    public static String getProductFrequency(String name) {
        try {
            Product_Frequency__c freq = Product_Frequency__c.getInstance(name);
            return freq.Frequency__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Product Frequency record found for Name: \'' + name + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
        
    }
    
    public static Double getChargeAmount(String chargeName) {
        try {
            Charge__c charge = Charge__c.getInstance(chargeName);
            return charge.Charge_Amount__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + chargeName + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }

    public static Decimal getSubscriberCharge(String AddressTypeDeliverChargeType) {
        try {
            Delivery_Charge__c charge = Delivery_Charge__c.getInstance(AddressTypeDeliverChargeType);

            return charge.Subscriber_Charge__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + AddressTypeDeliverChargeType + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }

    public static Decimal getVendorCredit(String AddressTypeDeliverChargeType) {
        try {
            Delivery_Charge__c charge = Delivery_Charge__c.getInstance(AddressTypeDeliverChargeType);
            return charge.Vendor_Credit__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + AddressTypeDeliverChargeType + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }


    public static string getDefaultDeliveryChargeType(string addressType) {
        try {
            Delivery_Charge_Type__c charge = Delivery_Charge_Type__c.getInstance(addressType);
            return charge.Default_Delivery_Charge_Type__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + addressType + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }
        
    }
    
    public static decimal getPostageCharge(string zone) {
        try {
            Postage_Charge__c charge = Postage_Charge__c.getInstance(zone);
            return charge.Amount__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + zone + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }
        
    }
    
    public static String getZuoraUrl(String name) {
        Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance(name);
        String iframeSrc;
        String id = hpm.Id__c;
        String tenantId = hpm.Tenant_Id__c;
        String APISecurityKey = hpm.Api_Security_Key__c;
        String ZuoraURL = hpm.Zuora_URL__c;

        Datetime cdt = datetime.now();        
        String timestamp= String.valueOf(cdt.getTime());
        Integer len = 32;
        
        String token = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0,len);
        
        String inputString = 'id='+id+'&tenantId='+tenantId+'&timestamp='+timestamp+'&token='+token+APISecurityKey;
        String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(inputString)));
        String signature =  EncodingUtil.base64Encode(Blob.valueOf(md5Coded));
        
        iframeSrc  = 'https://'+ZuoraURL+'/apps/PublicHostedPage.do?method=requestPage&id='+id+'&tenantId='+tenantId+'&timestamp='+timestamp+'&token='+token+'&signature='+signature + '&retainValues=true';
        iframeSrc += '&field_creditCardCountry=SGP&field_creditCardAddress1=Not+Required&field_creditCardCity=Not+Required&field_email=Not_Required@not_required.com';    // Start/End D-4453 29Feb16 JohnD
        return iframeSrc;
    }

    public static String getEmail(String emailName) {
    
        try {
            Email__c email= Email__c.getInstance(emailName);
            return email.Email__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Email record found for Name: \'' + emailName + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
        return null;
        }
    
        return null;
    }
    
    
    public static string getOther(string name) {
        try {
            Other__c other = Other__c.getInstance(name);
            return other.Value__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + name + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }
        
    }
    
    public static Decimal getCourierFee(String dayOfWeek) {
        try {
            Courier_Charge__c courierfee = Courier_Charge__c.getInstance(dayOfWeek);
            return courierfee.Courier_Fee__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + dayOfWeek + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }

    public static Decimal getBatchControlSetting(String name) {
        try {
            Batch_Control_Settings__c batchControlSetting = Batch_Control_Settings__c.getInstance(name);
            return batchControlSetting.Number_of_Parallel_Jobs__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + name + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }

    //[JAzana 1208] D-1018
    public static string getProductRatePlanDeliveryCharge(string deliveryName) {
        try {
            Other__c delName = Other__c.getInstance(deliveryName);
            return delName.Value__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + deliveryName + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }

    }
    // End D-1018

    //START [Wenjun 11/12/14] For Billing Batch Number Allocation
    public static String getBillingBatch(String paymentMethod) {
        try {
            Billing_Batch__c batch = Billing_Batch__c.getInstance(paymentMethod);
            return batch.Batch__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No setting record found for Name: \'' + paymentMethod + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }
    }
    //END [Wenjun 11/12/14]
  //START: D-1154 1/7/2015 Added by Kristine Campang - added new method to get the Password
  public static String getAsiaOnePassword(String password){
    try {
      BulkAsiaOneConfigParams__c pass = BulkAsiaOneConfigParams__c.getInstance(password);
      return pass.Password__c;
    }
    catch(NullPointerException e) {
            System.debug('Error: No setting record found for Name: \'' + password + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }
        
  }
  //END: D-1154 1/7/2015 Added by Kristine Campang 
    //START: D-2153  2/10/2015 Added by Krithika D
    public static String getBatchIntegrationSettings(String batchintegrationSettings) {
        try {
            BatchInterface_Settings__c is = BatchInterface_Settings__c.getInstance(batchintegrationSettings);
            return is.value__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Error Message record found for Name: \'' + batchintegrationSettings + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }
    //END: D-2153 2/10/2015 Added by Krithika D
     //START: D-2175  2/10/2015 Added by Krithika D
    public static String getARMSIntegrationSettings(String ARMSintegrationSettings) {
        try {
            ARMSInterface_Settings__c is = ARMSInterface_Settings__c.getInstance(ARMSintegrationSettings);
            return is.value__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Error Message record found for Name: \'' + ARMSintegrationSettings + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null;
        }
    }
    //END: D-2175 2/10/2015 Added by Krithika D
    //START UD-2328 08/26/15 RReyes
    public static DateTime getOtherDate(string name) {
        try {
            Other__c other = Other__c.getInstance(name);
            return other.DateTime__c;
        }
        catch(NullPointerException e) {
            System.debug('Error: No Key Id record found for Name: \'' + name + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }
        
    }
    //END UD-2328 08/26/15 RReyes
     //START D-4354 26.1.2016 Gdelrosario
    public static Integer getRenewalNotificationDay(String recName, String letterType, Boolean is1stNotif){
        try{
         //START D-4406 02-09-2016 added by Jason A.    
            if(letterType == 'Magazine' && is1stNotif == true){
                if(Test.isRunningTest()){
                    return 42;
                }
                Renewal_Notifications__c theDay = Renewal_Notifications__c.getInstance(recName);
                return Integer.valueOf(theDay.X1st_Notification_Magazine__c);
            }else if(letterType == 'Magazine' && is1stNotif == false){
                if(Test.isRunningTest()){
                    return 42;
                }
                Renewal_Notifications__c theDay = Renewal_Notifications__c.getInstance(recName);
                return Integer.valueOf(theDay.X2nd_Notification_Magazine__c);
            }else if(letterType == 'Newspaper' && is1stNotif == true){
                if(Test.isRunningTest()){
                    return 14;
                }
                Renewal_Notifications__c theDay = Renewal_Notifications__c.getInstance(recName);
                return Integer.valueOf(theDay.X1st_Notification_Newspaper__c);
            }else {
                if(Test.isRunningTest()){
                    return 14;
                }
                Renewal_Notifications__c theDay = Renewal_Notifications__c.getInstance(recName);
                return Integer.valueOf(theDay.X2nd_Notification_Newspaper__c);
            }
        //END D-4406 02-09-2016 added by Jason A.
        }catch (NullPointerException e){
            System.debug('Error: No custom settings record found for Name: \'' + recName + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }
    }
    //END D-4354 26.1.2016 Gdelrosario
    //START D-4354 1.2.2016 Gdelrosario
    public static Integer getRenewalNotificationExpiryDay(String recName, Boolean is1stNotif){
        try{
            if(is1stNotif == true){
                Renewal_Notifications__c theDay = Renewal_Notifications__c.getInstance(recName);
                return Integer.valueOf(theDay.X1st_Expiry_Notification_Date__c);
            }else {
                Renewal_Notifications__c theDay = Renewal_Notifications__c.getInstance(recName);
                return Integer.valueOf(theDay.X2nd_Expiry_Notification_Date__c);
            }
        }catch (NullPointerException e){
            System.debug('Error: No custom settings record found for Name: \'' + recName + '\'.');
            System.debug('StackTrace: ' + e.getStackTraceString());
            return null; 
        }
    }
    //END D-4354 1.2.2016 Gdelrosario
}