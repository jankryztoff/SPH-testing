@isTest                         
global class BatchServiceFacadeMockFail2Test implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, Map<String, String>> resMap = new Map<String, Map<String, String>>();
        Map<String, String> resM = new Map<String, String>();
        resM.put('Success','Ok');
        resM.put('Enable-Account','Error');
        resM.put('Password-Reset','Error');
        resM.put('User-Availability','Error');
        resM.put('DisplayName-Availability','Error');
        resM.put('Activate', 'Error');  
        resM.put('Deactivate', 'Error');
        resM.put('Sign-Up', 'Error');
        resM.put('Error', 'Error');
        resMap.put('respValueObject', resM);

        //res.setBody('{"respValueObject":{"Success":"Ok","Enable-Account":"Success","Password-Reset":"Success"}');
         res.setBody(JSON.serialize(resMap));        
        //res.setbody(resMap);
        res.setStatusCode(200);
        return res;
    }
}