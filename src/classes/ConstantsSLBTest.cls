/*
 * Class Name: ConstantsSLBTest
 * @author: Accenture IDC
 * Date: 24/02/2015
 * @Author Shruti Kishore
 * @Version <2.0> 
 */

@isTest
private class ConstantsSLBTest {
   
    /**
    * Test method for getKeyId method where key id is null
    * @name <testgetKeyIdForNull>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetKeyIdForNull() {        

        String test_keyIdName = '';
        
        test.startTest();
        ConstantsSLB.getKeyId(test_keyIdName);
        
        test.stopTest();        
    } 
    
     /**
    * Test method for getKeyId method where key id is not null
    * @name <testgetKeyId>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
     static testmethod void testgetKeyId() {        

        String test_keyIdName = 'ASFHG';
        
        test.startTest();
        ConstantsSLB.getKeyId(test_keyIdName);
        
        test.stopTest();        
    } 
    
    /**
    * Test method that calls getIntegrationSettings method
    * @name <testgetIntegrationSettings>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetIntegrationSettings(){
        String test_integrationSettings = '';     
        test.startTest();
        ConstantsSLB.getIntegrationSettings(test_integrationSettings);
        test.stopTest();
    }    
    
    /**
    * Test method that calls getUOM method
    * @name <testgetUOM>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetUOM(){
        String test_UOM = '';
        
        test.startTest();
        ConstantsSLB.getUOM(test_UOM);        
        test.stopTest();
    }
    
    /**
    * Test method that calls getErrorMessage method
    * @name <testgetErrorMessage>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetErrorMessage(){
        String test_errorMessageName = '';
        test.startTest();
        ConstantsSLB.getErrorMessage(test_errorMessageName);
        test.stopTest();
    }
    
    /**
    * Test method that calls getZuoraConfig method
    * @name <testgetZuoraConfig>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetZuoraConfig(){
        String test_zuoraConfig = '';
        
        test.startTest();
        ConstantsSLB.getZuoraConfig(test_zuoraConfig);
        test.stopTest();
    }
    
    /**
    * Test method that calls getProductFrequency method
    * @name <testgetProductFrequency>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetProductFrequency(){
        String test_name = '';
        test.startTest();
        ConstantsSLB.getProductFrequency(test_name);
        test.stopTest();
    }
    
    /**
    * Test method that calls getChargeAmount method
    * @name <testgetChargeAmount>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetChargeAmount(){
        String test_chargeName = '';
        test.startTest();
        ConstantsSLB.getChargeAmount(test_chargeName);
        test.stopTest();
    }
    
    /**
    * Test method that calls getSubscriberCharge method
    * @name <testgetSubscriberCharge>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetSubscriberCharge(){
        String test_AddressTypeDeliverChargeType = '';
        test.startTest();
        ConstantsSLB.getSubscriberCharge(test_AddressTypeDeliverChargeType);
        test.stopTest();
    }
    
    /**
    * Test method that calls getVendorCredit method
    * @name <testgetVendorCredit>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetVendorCredit(){
        String test_AddressTypeDeliverChargeType = '';
        test.startTest();
        ConstantsSLB.getVendorCredit(test_AddressTypeDeliverChargeType);
        test.stopTest();
    }
    
    /**
    * Test method that calls getDefaultDeliveryChargeType method
    * @name <testgetDefaultDeliveryChargeType>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetDefaultDeliveryChargeType(){
        string test_addressType = '';
        test.startTest();
        ConstantsSLB.getDefaultDeliveryChargeType(test_addressType);
        test.stopTest();
    }
    
    /**
    * Test method that calls getPostageCharge method
    * @name <testgetPostageCharge>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetPostageCharge(){
        string test_zone = ''; 
        test.startTest();
        ConstantsSLB.getPostageCharge(test_zone);
        test.stopTest();                                      
    }
    
    /**
    * Test method that calls getZuoraUrl method
    * @name <testgetZuoraUrl>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetZuoraUrl(){        
        //create test data
        Zuora_HPM_Settings__c zhs = new Zuora_HPM_Settings__c(); 
        zhs.Name = 'Default'; 
        zhs.Zuora_Url__c = 'apisandbox.zuora.com'; 
        zhs.Tenant_Id__c = '12213'; 
        zhs.Id__c = '2c92c0f9479f7eb10147aadd21634797'; 
        zhs.Api_Security_Key__c = '7rAtGAFh0vXd0yLqtN1Q4NXJsizOvApONvuLw-HT6pY='; 
        insert zhs; 
        
        test.startTest();
        ConstantsSLB.getZuoraUrl('Default');
        test.stopTest();
    }
    
    /**
    * Test method that calls getEmail method
    * @name <testgetEmail>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetEmail(){
        string test_emailName = '';
        test.startTest();
        ConstantsSLB.getEmail(test_emailName);
        test.stopTest();
    }
    
    /**
    * Test method that calls getOther method
    * @name <testgetOther>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetOther(){
        string test_name = ''; 
        test.startTest();
        ConstantsSLB.getOther(test_name);
        test.stopTest();
    }
    
    /**
    * Test method that calls testgetCourierFee method
    * @name <testgetCourierFee>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetCourierFee(){
        string test_dayOfWeek = '';
        test.startTest();
        ConstantsSLB.getCourierFee(test_dayOfWeek);
        test.stopTest();
    }
    
    /**
    * Test method that calls getBatchControlSetting method
    * @name <getBatchControlSetting>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetBatchControlSetting(){
        string test_name = ''; 
        test.startTest();
        ConstantsSLB.getBatchControlSetting(test_name);
        test.stopTest();
    }
    
    /**
    * Test method that calls getProductRatePlanDeliveryCharge method
    * @name <testgetProductRatePlanDeliveryCharge>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetProductRatePlanDeliveryCharge(){
        string test_deliveryName = '';
        test.startTest();
        ConstantsSLB.getProductRatePlanDeliveryCharge(test_deliveryName);
        test.stopTest();
    }
    
    /**
    * Test method that calls getBillingBatch method
    * @name <testgetBillingBatch>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetBillingBatch(){
        string test_paymentMethod = '';
        test.startTest();
        ConstantsSLB.getBillingBatch(test_paymentMethod);
        test.stopTest();
    }
    
    /**
    * Test method that calls testgetAsiaOnePassword method
    * @name <testgetAsiaOnePassword>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetAsiaOnePassword(){
        string test_password = ''; 
        test.startTest();
        ConstantsSLB.getAsiaOnePassword(test_password);
        test.stopTest();
    }
    
    /**
    * Test method that calls getBatchIntegrationSettings method
    * @name <testgetBatchIntegrationSettings>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetBatchIntegrationSettings()
    {
        string test_batch = '';
        test.startTest();
        ConstantsSLB.getBatchIntegrationSettings(test_batch);
        test.stopTest();
    }
    
    /**
    * Test method that calls getArmsIntegrationSettings method
    * @name <testgetArmsIntegrationSettings>
    * @param <none>
    * @return <parameter> - <none>
    * @throws exception-<none>
    * @see 
    */
    static testmethod void testgetArmsIntegrationSettings()
    {
        string test_arms = '';
        test.startTest();
        ConstantsSLB.getArmsIntegrationSettings(test_arms);
        test.stopTest();
    }
    
}