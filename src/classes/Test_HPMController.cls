public class Test_HPMController {

    public Test_HPMController() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, getSource()));
    }
    
    public String getSource() {
        String iframeSrc;
        String id = ConstantsSLB.getZuoraConfig('ID');
        String tenantId = ConstantsSLB.getZuoraConfig('tenantId');
        String APISecurityKey = ConstantsSLB.getZuoraConfig('APISecurityKey');
        String ZuoraURL = ConstantsSLB.getZuoraConfig('ZuoraURL');

        Datetime cdt = datetime.now();        
        String timestamp= String.valueOf(cdt.getTime());
        Integer len = 32;
        
        String token = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0,len);
        
        String inputString = 'id='+id+'&tenantId='+tenantId+'&timestamp='+timestamp+'&token='+token+APISecurityKey;
        String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(inputString)));
        String signature =  EncodingUtil.base64Encode(Blob.valueOf(md5Coded));
        
        iframeSrc  = 'https://'+ZuoraURL+'/apps/PublicHostedPage.do?method=requestPage&id='+id+'&tenantId='+tenantId+'&timestamp='+timestamp+'&token='+token+'&signature='+signature;
        //iframeSrc += '&field_accountId='+ZuoraAcctId;
        //iframeSrc += '&field_creditCardType=Visa';
        //iframeSrc += '&field_passthrough1='+PaymentMethodId;
        
        return iframeSrc;
    }

}