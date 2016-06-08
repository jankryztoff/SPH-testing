public with sharing class INT_PageRestToolController {

    public INT_PageRestToolController () {
        selectedFilter = '';
        query = '';
        fullReturn = '';
    }

public String myReturn {get;set;}
public String sig {get;set;}
public String myBody {get;set;}
public String gen {get;set;}
public String gen1 {get;set;}
public String Method {get;set;}
public String LogId {get;set;}
public String recordId {get;set;}

public Datetime myDateTime;
public String mydtstring = '';        
public String toReplace = '';
public String updateDate = '';
public String replaceGen = '';

//---------------APIKEy and Shared Secret for Staging and Integration1---------------------
String apiKey = ConstantsSLB.getZuoraConfig('apiKey');
String sharedSecret = ConstantsSLB.getZuoraConfig('sharedSecret');

//---------------APIKEy and Shared Secret for Production---------------------
//String apiKey = 'z5auw4wav3kpn67s9jywry24';
//String sharedSecret = 'nbP9qWqE3RA29MC4G4na5J2q';


    
String Uri;
ApexPages.StandardController controller;

     public PageReference myStart () {
        uri = '?api_key=' + apiKey + '&sig=' + sig;
        
        //---------------ENDPOINT for Production---------------------
        //myReturn  = 'https://mrdr.accenture.com/1033_MRDR/Production/BusinessPartners/CustomerSalesForceW/Query/Details/1.0.0/OData/CustomerSalesforceEntities?%24top=1&%24format=json';
        
        //---------------ENDPOINT for Staging---------------------
        //myReturn  = 'https://mrdr.accenture.com/1033_MRDR/Stage/BusinessPartners/CustomerSalesForceW/Query/Details/1.0.0/OData/CustomerSalesforceEntities?%24top=1&%24format=json'; 
        
        //---------------ENDPOINT for Integration1---------------------
        myReturn  = ConstantsSLB.getZuoraConfig('myReturn');
        return null;
    }
    
    public void computeSig(){
        Long timeDiff = Datetime.now().getTime()/1000;
        Blob cryptoBlob = Crypto.generateDigest('SHA-256', Blob.valueOf(apiKey + sharedSecret + String.valueOf(timeDiff)));
        sig = EncodingUtil.urlEncode(EncodingUtil.convertToHex(cryptoBlob), 'UTF-8'); 
    }
    
    public void sendR() {
        computeSig();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response   = new HttpResponse();
        uri = '?$format=json&api_key=' + apiKey + '&sig=' + sig; 
       // myReturn  = gen1 + uri;
        //myReturn   = 'https://api.zuora.com/v1/accounts/A00000321';
        myReturn  = gen1;
        request.setEndpoint(myReturn);
        request.setBody(gen);
        request.setHeader('apiAccessKeyId', 'marvin_apiuser@sph.com.sg');
        request.setHeader('apiSecretAccessKey', 'Accenture01');
        request.setHeader('content-type', 'application/json');
        //request.setHeader('content-type', 'application/json', 'apiAccessKeyId', 'marvin.b.gatchalian@accenture.com', 'apiSecretAccessKey', 'Accenture01');
        
        request.setMethod(Method);
       
       //Blob headerValue = Blob.valueOf(username + ':' + password);
       //String authorizationHeader = 'BASIC '+EncodingUtil.base64Encode(headerValue);
       //request.setHeader('Authorization', authorizationHeader);
       //request.setHeader('Accept', 'application/json;charset=utf-8');
       //request.setCompressed(true); // otherwise we hit a limit of 32000
        
        response  = http.send(request);

        myBody = response.getbody() + '1 ... ' + response.getStatusCode();
        //system.assertequals(myBody ,'sdf');
        
        if (string.valueof(response.getStatusCode()) == '201' || string.valueof(response.getStatusCode()) == '204' && RecordId <> null) {
            //CH_ErrorLogDML.updateIsResolve(recordId, true);
        }
    }     
    
   /* public void RetryFromLogs() {
    
        ErrorLog__c myErrorLogRec = [select Endpoint_URL__c, Method__c, RecordDetails__c, RecordId__c from ErrorLog__c 
                                        where name =:LogId];
        
        gen = myErrorLogRec.RecordDetails__c;

        if(gen != null || gen != '') {        
            myDateTime = datetime.now();
            myDateTime = myDateTime.addHours(1);
            mydtstring = myDateTime.format('yyyy-MM-dd HH:mm:ss','America/Chicago');        
            toReplace = '"UpdateDateTime" : "' + mydtstring +'"';
            updateDate = gen.substring(gen.IndexOf('"UpdateDateTime" : '),gen.IndexOf('"UpdateDateTime" : ')+40);
            
            replaceGen = gen.replacefirst(updatedate,toReplace);
            
            gen = replaceGen;
        } 


        //gen1 = myErrorLogRec.Endpoint_URL__c;
        //Method = myErrorLogRec.Method__c;
        //recordId = myErrorLogRec.RecordId__c;
        //myBody='';
        //sig ='';
        //myReturn ='';
    } */
 
 ///////////////////////////////////========================================
    public class SynchResult {
        // public ErrorLog__c errorLog;
        public Boolean isSuccess;
        public String returnCode;
        public String returnMessage;
    }
 
    public String selectedFilter {get;set;}
    public String query {get;set;}
    //public List<ErrorLog__c> logs {get;set;}
    private List<SynchResult> results = new List<SynchResult>();
    public String emailForReport {get;set;}
    public Boolean hasQuery {get;set;}
    public String stringBuilder {get;set;}
    public Set<String> forUpdateOfIsResolved = new Set<String>();
    
    /* public void runQueryAutoSync(){
        String queryString = 'SELECT Name, RecordId__c, Method__c, ErrorMessage__c, ErrorType__c, IsResolve__c, Endpoint_URL__c, Interface__c, CreatedDate, RecordDetails__c FROM ErrorLog__c WHERE IsResolve__c = FALSE AND (ErrorType__c <> \'BatchSizeError\' AND ErrorType__c <> \'Filtered Record\') AND Endpoint_URL__c <> \'\'  ' + selectedFilter + ' ORDER BY Name ASC, SortLevel__c ASC LIMIT 100';
        Map<String, ErrorLog__c> logMap = new Map<String, ErrorLog__c>();
        for(ErrorLog__c el : Database.query(queryString)){
           logMap.put(el.RecordId__c, el);
        }
        
        logs = logMap.values();
        logs.sort();
        
        if(logs.size() > 1){
            hasQuery = true;
        }
        query = 'Log Size:' + logs.size();
        
    } */
    
    private Integer index = 0;
    public String fullReturn {get;set;}
    public Integer callCount = 0;
    //private List<ErrorLog__c> updateLogtoPost = new List<ErrorLog__c>();
    //List<ErrorLog__c> updateEm = new List<ErrorLog__c>();
    
    
   /* public void startSync(){
        
            String endPointUrl = '';
            String wsMethod = '';
            String urlAppend = '';
            
            computeSig();
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response   = new HttpResponse();
            urlAppend = '?$format=json&api_key=' + apiKey + '&sig=' + sig; 
          
            // wsMethod = logs[index].Method__c;
            // endpointUrl = logs[index].Endpoint_URL__c;
            
            request.setEndpoint((endpointUrl + urlAppend).replace('Production','Stage'));
            //request.setBody(logs[index].RecordDetails__c);
            request.setHeader('content-type', 'application/json');
            request.setMethod(wsMethod);
            
            response  = http.send(request);

            //fullReturn += logs[index].Name + ' = ' + response.getStatusCode() + ' ===== ';
            if(response.getStatusCode() == 201 || response.getStatusCode() == 204){
                //forUpdateOfIsResolved.add(logs[index].RecordId__c);
                logs.remove(index);
                index--;
            } else if (response.getStatusCode() == 404 && logs[index].Method__c == 'PUT') {
                logs[index].Method__c = 'POST';
                logs[index].Endpoint_URL__c = logs[index].Endpoint_URL__c.substring(0, logs[index].Endpoint_URL__c.indexOf('('));
                updateLogToPost.add(logs[index]);
            }
            
          /*  if(index < logs.size() && callCount < 9){
                callCount++;
                index++;
                try{
                    startSync();    
                }catch(System.ListException e){
                    for(ErrorLog__c el : [SELECT Id, IsResolve__c FROM ErrorLog__c WHERE RecordId__c IN :forUpdateOfIsResolved]){
                        el.IsResolve__c = true;
                        updateEm.add(el);
                    }
                    callCount = 0;
                    index = 0;
                    update updateEm;
                    updateEm.clear();               
                    update updateLogToPost;
                    updateLogToPost.clear();
                    runQueryAutoSync();    
                }
            } else {
                for(ErrorLog__c el : [SELECT Id, IsResolve__c FROM ErrorLog__c WHERE RecordId__c IN :forUpdateOfIsResolved]){
                    el.IsResolve__c = true;
                    updateEm.add(el);
                }
                callCount = 0;
                index = 0;
                update updateEm;
                updateEm.clear();               
                update updateLogToPost;
                updateLogToPost.clear();
                runQueryAutoSync();
            } 
            query ='Log Size:' + logs.size();
    } */
    
    
}