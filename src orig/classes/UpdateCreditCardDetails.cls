public class UpdateCreditCardDetails {

    public String paymentMethodId {get; set;}

    public String getSource() {
            Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance( 'Default' );
            String iframeSrc;
            String id = hpm.Id__c;
            String tenantId = hpm.Tenant_Id__c;
            String APISecurityKey = hpm.Api_Security_Key__c;
            String ZuoraURL = hpm.Zuora_Url__c ;
    
            Datetime cdt = datetime.now();        
            String timestamp= String.valueOf(cdt.getTime());
            Integer len = 32;
            
            String token = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0,len);
            
            String inputString = 'id='+id+'&tenantId='+tenantId+'&timestamp='+timestamp+'&token='+token+APISecurityKey;
            String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(inputString)));
            String signature =  EncodingUtil.base64Encode(Blob.valueOf(md5Coded));
            
            iframeSrc  = ZuoraURL + '/PublicHostedPage.do?method=requestPage&id='+id+'&tenantId='+tenantId+'&timestamp='+timestamp+'&token='+token+'&signature='+signature;
            
            return iframeSrc;
}
}