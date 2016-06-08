@isTest
global class zLoginMock implements WebServiceMock {
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
        
        //Map<String,String> res = New Map<String,String>();
        //Zuora.zApi zApiInstance = new Zuora.zApi();
        //zApiInstance.zlogin();
        Zuora.zApi.LoginResult res = new Zuora.zApi.LoginResult();
        res.ServerUrl = 'www.zuora.com';
        res.session = 'qwertyuiosdfghjkxcvbnm';
        //res.put('Status','Failed');
        
        response.put('response_x', res);     
    }
}