/*
 * Class Name: PaypalHelper
 * @author: Krithika Dharmarajan / Kevin Evasco
 * Date: 4/15/2014
 * Project/Requirement: Paypal CR
 * @description This class generates Billing Account and Payment Method ID needed for Paypal
 */
  
 public class PaypalHelper{
 
    //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
    public static String KEY_STATUS = 'Status';
    public static String KEY_BILLING_ACCOUNT_ZID = 'Biilling Account ZID';
    public static String KEY_PAYMENT_METHOD_ZID = 'Payment Method ZID';
    public static String VALUE_SUCCESSFUL = 'Successful';
    public static String VALUE_FAILED = 'Failed';
    
    
    public class BillingInformationWrapper {
        public String paypalBAID;
        public String paypalEmail;
        public String firstName;
        public String lastName;
        public String country;
        public String billingType;
    }   
    //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
 
    public class BillingContactWrapper {
        public String accountId;
        public String firstName;
        public String lastName; 
        public String country;
    }
    
    public class BillingAccountWrapper {
        public String name;
        public String batch;
        public Integer billCycleday;
        public String billingType;
        public String billToId;
        public String soldToId;
    }
 
    public static String createBillingContact(BillingContactWrapper billingContactParam){
        String createdId;

        Map<String,Object> recordMap = new Map<String,Object>();
        recordMap.put('AccountId',billingContactParam.accountId);
        recordMap.put('FirstName',billingContactParam.firstName);
        recordMap.put('LastName',billingContactParam.lastName);
        recordMap.put('Country',billingContactParam.country);

        ZuoraCallOut zCallout = new ZuoraCallOut();
        Map<String,String> resultMap = zCallout.createZObject(recordMap,'Contact');

        createdId = resultMap.get('Id');

        System.debug('createBillingContact resultMap' + resultMap);
        return createdId;
    }
 
    public static String createBillingAccount(BillingAccountWrapper billingAccountParam){
        String createdId;

        Map<String,Object> recordMap = new Map<String,Object>();
        recordMap.put('Name',billingAccountParam.name);
        recordMap.put('Batch',billingAccountParam.batch);
        recordMap.put('BillCycleDay',billingAccountParam.billCycleday);
        recordMap.put('AllowInvoiceEdit',true);
        recordMap.put('Currency','SGD');
        recordMap.put('Status','Draft');
        recordMap.put('PaymentGateway', 'PayPal');
        recordMap.put('BillToId', billingAccountParam.billToId);
        recordMap.put('SoldToId', billingAccountParam.soldToId);
        recordMap.put('Billing_Type__c', billingAccountParam.billingType); //START/END 05/08/2015 D-2859 Kevin Evasco - Make billing type a parameter when creating Billing Accounts

        ZuoraCallOut zCallout = new ZuoraCallOut();
        Map<String,String> resultMap = zCallout.createZObject(recordMap,'Account');

        createdId = resultMap.get('Id');
        
        System.debug('createBillingAccount resultMap' + resultMap);
        return createdId;
    }
    
    public static String createPaymentMethodId(string BaId,string PaypalEmail,String AccntId){      
        String createdId;

        Map<String,Object> recordMap = new Map<String,Object>();
        recordMap.put('PaypalBaid', BaId);
        recordMap.put('PaypalEmail',PaypalEmail);
        recordMap.put('AccountId',AccntId);
        recordMap.put('Type','PayPal');  
        
        ZuoraCallOut zCallout = new ZuoraCallOut();
        Map<String,String> resultMap = zCallout.createZObject(recordMap,'PaymentMethod');

        createdId = resultMap.get('Id');
        
        System.debug('createPaymentMethodId resultMap' + resultMap);

        return createdId;
    }
    
    //START 05 January 2015 D-4111 Kevin Evasco - Set the default payment method
    public static void updateBillingAccount(String billingAccountParam, String billingContactParam, String defaultPaymentMethodIdParam){
        Map<String,Object> recordMap = new Map<String,Object>();
        recordMap.put('BillToId', billingContactParam);
        recordMap.put('SoldToId', billingContactParam);     
        recordMap.put('Status', 'Active');      
        recordMap.put('PaymentTerm', 'Due upon receipt');   
        recordMap.put('DefaultPaymentMethodId', defaultPaymentMethodIdParam);   
        
        ZuoraCallOut zCallout = new ZuoraCallOut();
        Map<String,String> resultMap = zCallout.updateZObject(recordMap,'Account',billingAccountParam);
        
        System.debug('updateBillingAccount resultMap: ' + resultMap);
    }
    //END 05 January 2015 D-4111 Kevin Evasco - Set the default payment method
    
    public static void linkZAccountToSF(String billingAccountParam, String crmAccountIdParam){
        Map<String,Object> recordMap = new Map<String,Object>();    
        recordMap.put('CrmId', crmAccountIdParam);  
        
        ZuoraCallOut zCallout = new ZuoraCallOut();
        Map<String,String> resultMap = zCallout.updateZObject(recordMap,'Account',billingAccountParam);
        
        System.debug('linkZAccountToSF resultMap: ' + resultMap);
    }
    
    //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
    public static Map<String,String> createPaypal(BillingInformationWrapper billingInfoParam){
        Map<String,String> resultMap = new Map<String,String>();
        Boolean isSuccessful = true;
        
        PaypalHelper.BillingAccountWrapper billingAccountZInstance = new PaypalHelper.BillingAccountWrapper();
        billingAccountZInstance.name = billingInfoParam.firstName + billingInfoParam.lastName;
        billingAccountZInstance.batch = 'Batch19';
        billingAccountZInstance.billCycleday = 1;
        billingAccountZInstance.billingType = billingInfoParam.billingType;
        
        String newBillingAccountZID = PaypalHelper.createBillingAccount(billingAccountZInstance);       
        
        PaypalHelper.BillingContactWrapper billingContactZInstance = new PaypalHelper.BillingContactWrapper();
        billingContactZInstance.accountId = newBillingAccountZID;
        billingContactZInstance.firstName = billingInfoParam.firstName;
        billingContactZInstance.lastName = billingInfoParam.lastName;      
        
        Country__c countryRecord = NewSubscriptionService.getCountry(billingInfoParam.country);      
        if(countryRecord != null)
            billingContactZInstance.country = countryRecord.Country_Name__c;
        else
            billingContactZInstance.country = 'Singapore';
        
        
        String newBillingContactZID = PaypalHelper.createBillingContact(billingContactZInstance);
        
        //START 05 January 2015 D-4111 Kevin Evasco - Set Billing Account default payment method
        //PaypalHelper.updateBillingAccount(newBillingAccountZID,newBillingContactZID);
        
        String newPaymentMethodZID = PaypalHelper.createPaymentMethodId(billingInfoParam.paypalBAID,billingInfoParam.paypalEmail,newBillingAccountZID);       
        
        PaypalHelper.updateBillingAccount(newBillingAccountZID,newBillingContactZID,newPaymentMethodZID);
        //END 05 January 2015 D-4111 Kevin Evasco - Set Billing Account default payment method
        
        if(newBillingAccountZID != null && newPaymentMethodZID != null){
            resultMap.put(KEY_STATUS, VALUE_SUCCESSFUL);
            resultMap.put(KEY_BILLING_ACCOUNT_ZID, newBillingAccountZID);
            resultMap.put(KEY_PAYMENT_METHOD_ZID, newPaymentMethodZID);
        }
        else {
            resultMap.put(KEY_STATUS, VALUE_FAILED);
        }
        
        return resultMap;             
    }
    //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
}