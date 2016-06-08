@isTest                         
global class BatchServiceFacadeMockErrorTest implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, Map<String,String>> resMap = new Map<String, Map<String,String>>();
        Map<String,String> rMap = new Map<String,String>();
        rMap.put('Enable-Account','Error');
        rMap.put('Errors','Boom is already enabled');
        resMap.put('respValueObject', rMap);
        String JSONStr = JSON.serializePretty(resMap);
//        res.setBody('{"respValueObject":{"Success":"Ok","Enable-Account":"Success"}}');
//OLD   res.setBody('{"respValueObject":[{"Enable-Account":"Error"},{"Errors":"Boom is already enabled"}]}');
        res.setBody('{"respValueObject":{"Enable-Account":"Error","Errors":["Boom is already enabled"]}}');
//        res.setBody(JSONStr);
        res.setStatusCode(200);
        return res;
    }
}