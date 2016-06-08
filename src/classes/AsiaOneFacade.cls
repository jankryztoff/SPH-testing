public class AsiaOneFacade{

    public AsiaOneServiceResponsetVO delegateAsiaOneCall(AsiaOneServiceRequestVO requestVO){ 
        AsiaOneServiceResponsetVO aOneSvcResp;
        String JSONString = JSON.serializePretty(requestVO);   
        System.debug('JSONSTRING' + JSONString);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        Map<String,String> responseMap = new Map<String,String>(); 

        req.setEndpoint(ConstantsSLB.getIntegrationSettings(GlobalVariableClass.ENDPOINTDELEGATOR));
        req.setMethod('POST');
        req.setHeader('content-type','application/json');
        req.setBody(JSONString);

        try
        { 
            
            res = http.send(req); 
            if(res.getStatusCode() == 200)
            {                 
                System.debug(res.getBody());
                Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                Map<String,Object> respValueObjectMap = (Map<String,Object>)respMap.get('respValueObject');            
                String temp = '';

                for(string s:respValueObjectMap.keyset())
                {

                    if(s.equals('Errors')){
                        // Start UD-3363 05Dec15 JohnD
                        List<Object> l = new list<Object>();
                        try {
                            l = (List<Object>)respValueObjectMap.get(s);
                        } catch (exception e) {
                            l.add((string)respValueObjectMap.get(s));
                        }
                        Iterator<Object> i = l.iterator();
                        while(i.hasNext()){
                            temp =  temp +(String)i.next();
                        }
                        // End UD-3363 05Dec15 JohnD
                        
                    //KRITHIKA 19/11/2015 START D-3879
                        responseMap.put(s,temp);
                    }
                     //KRITHIKA 19/11/2015 END D-3879
                    else{
                            System.debug(s + ' : ' + (string)respValueObjectMap.get(s));
                            responseMap.put(s,(string)respValueObjectMap.get(s));
                  
                    }
                }
            }
            else
            {
                responseMap.put('Status','Failed');
                responseMap.put('Message',res.getStatus());          
            }
            // system.debug('responsemap'+responseMap); // Start/End UD-3363 05Dec15 JohnD - commented out
            aOneSvcResp = new AsiaOneServiceResponsetVO(responseMap,'');    
        }
        catch(Exception e)
        { 
            system.debug('Error:'+e);
            
        } 
        return aOneSvcResp;
    }
    

}