public class ResponseUtility {

    public static boolean usedNegativeResponse = false;
    public static string zuoraAccountId;
    
    public List<Zuora.zApi.SaveResult> getZuoraNegativeResults () {
        Zuora.zObject error = new Zuora.zObject('Error');
        Zuora.zObject[] errors = new List<Zuora.zObject>();
        error.setValue ('Code', 'test error');
        error.setValue ('Message', 'test message');
        errors.add(error);
                
        List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
        Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
        res.Success = false; 
        res.id = null;
        res.Errors = errors;
        results.add(res);
        return results;
    }
    
    public List<Zuora.zApi.SaveResult> getZuoraPositiveResults () {
         
        List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
        system.debug('xxxJohnxxx : ' + usedNegativeResponse);
        if (!usedNegativeResponse) {            
            Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
            res.Success = true; 
            res.id = generateExternalId();
            res.Errors = null;
            results.add(res );
        } else {
            results = getZuoraNegativeResults();
        }
        
        usedNegativeResponse = false;
        return results;
    }
    
    public Zuora.zApi.AmendResult getZuoraPositiveAmendResults () {
        Zuora.zApi.AmendResult res = new Zuora.zApi.AmendResult();
        res.Success = true;
        res.amendmentIds = null;
        res.Errors = null;
        //res.invoiceDatas = null;
        res.InvoiceId = generateExternalId();
        res.paymentTransactionNumber = 'NA';
        res.SubscriptionId = generateExternalId();

        return res;
    }
    
    public List<Zuora.zObject> getMockZObjectResponse(string queryStr){
        String mySOQL = queryStr;
        List <String> fromSplit;
        List <String> whereSplit;
        List <String> selectSplit;
        String myObject;
        List <String> fields;
        List<Zuora.zObject> returnResult = new List<Zuora.zObject>();
        
        fromSplit = mySOQL.split('From ');
        if (fromSplit.size() <= 1) {
            fromSplit = mySOQL.split('from ');
            if (fromSplit.size() <= 1) {
                fromSplit = mySOQL.split('FROM ');
            }
        }
        
        whereSplit = fromSplit[1].split(' ');
        myObject = whereSplit[0];
        
        selectSplit = fromSplit[0].split('Select ');
        if (selectSplit.size() <=1 ) {
            selectSplit = fromSplit[0].split('select ');    
            if (selectSplit.size() <=1 ) {
                selectSplit = fromSplit[0].split('SELECT ');            
            }
        }
        fields = selectSplit[1].split(',');
        //system.assertequals(fields, null);
        //system.assertequals(1, 2);
        Zuora.zObject responseObject = new Zuora.zObject(myObject.trim());
        for (String field :fields) {
            if (field.trim() == 'Balance') {
                responseObject.setValue(field.trim(), 10);
            } else if (field.trim() == 'Amount') {
              responseObject.setValue(field.trim(), 10);
            } else if (field.trim() == 'ChargeAmount') {
                responseObject.setValue(field.trim(), 105);
            }else if (field.trim() == 'TaxAmount') {
                responseObject.setValue(field.trim(), 10);
            } 
            else {
                responseObject.setValue(field.trim(), 'test data');
            }
        }
        
        if (zuoraAccountId != null)
          responseObject.setValue('AccountId', zuoraAccountId);
        returnResult.add(responseObject);
        zuoraAccountId = null;
        return returnResult;
    }
    
    public Zuora.zApi.QueryResult getMockQueryResultPositive(String queryStr, Boolean isDone){
        Zuora.zApi.QueryResult mockQueryResult = new Zuora.zApi.QueryResult();
        mockQueryResult.records = getMockZObjectResponse(queryStr);
        mockQueryResult.size = 1;
        mockQueryResult.done = isDone;
        mockQueryResult.queryLocator = '2c92c0f8540e25a501541a6db7b32bab-20';
        return mockQueryResult;
    }
    
    public Zuora.zApi.QueryResult getMockQueryMoreResultPositive(String queryStr, Boolean isDone){
        Zuora.zApi.QueryResult mockQueryResult = new Zuora.zApi.QueryResult();
        mockQueryResult.records = getMockZObjectResponse(queryStr);
        mockQueryResult.size = 1;
        mockQueryResult.done = isDone;
        mockQueryResult.queryLocator = null;
        return mockQueryResult;
    }
    
    public Zuora.zApi.LoginResult getMockLoginResult() {
        Zuora.zApi.LoginResult mockLoginResult = new Zuora.zApi.LoginResult();
        mockLoginResult.ServerUrl = 'www.zuora.com';
        mockLoginResult.session = 'qwertyuiosdfghjkxcvbnm';
        return mockLoginResult;
    }

    public static string generateExternalId() {
        blob hash = Crypto.generateDigest('MD5', Blob.valueOf(string.valueof(datetime.now())));
        return EncodingUtil.convertToHex(hash).substring(0, 18);
    }

}