@isTest
global class zApiTest implements WebServiceMock {
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
        
        ZuoraCallOut z = new ZuoraCallOut();
        z.createMultipleZObject(new List<Map<String,Object>>(),'Refund');
        Map<String,String> res = New Map<String,String>();
        res.put('Status','Failed');
        
        response.put('response_x', res);     
    }
}