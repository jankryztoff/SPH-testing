/**
   @Author <CV Manawatao>
   @name <BatchServiceFacadeMockTest >
   @Description <Test class for BatchServiceFacade>
   @CreateDate <2/2/2015>
   @Version <1.0>
  */
@isTest                         
global class BatchServiceFacadeMockTest implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, Map<String, String>> resMap = new Map<String, Map<String, String>>();
        Map<String, String> resM = new Map<String, String>();
        resM.put('Success','Ok');
        resM.put('Enable-Account','Success');
        resM.put('Password-Reset','Success');
        resM.put('User-Availability','Success');
        resM.put('DisplayName-Availability','Success');
        resM.put('Activate', 'Success');  
        resM.put('Deactivate', 'Success');
        resM.put('Sign-Up', 'Success');
        resM.put('Error', 'Error');
        resMap.put('respValueObject', resM);

        //res.setBody('{"respValueObject":{"Success":"Ok","Enable-Account":"Success","Password-Reset":"Success"}');
         res.setBody(JSON.serialize(resMap));        
        //res.setbody(resMap);
        res.setStatusCode(200);
        return res;
    }
}