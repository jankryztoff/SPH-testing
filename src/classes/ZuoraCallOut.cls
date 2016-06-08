/**
 * Class Name: ZuoraCallOut 
 * @author: Jb Domingo
 * Date: 8/29/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Utility Class for Zuora Callouts
 * @History MD-28 : 01-July-15 Wenjun Enhance Error Handling 
 */
public class ZuoraCallOut
{
    public Zuora.zApi zApiInstance;
    public ZuoraCallOut()
    {
        zApiInstance = new Zuora.zApi();
            
            //START D-1011 MD-28 01/07/15 Wenjun: Throw exception to Calling Application for Error Handling
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
            }
            /*
            else {
                ResponseUtility RU = new ResponseUtility();
                RU.getMockLoginResult();           
            }
            */
            //END D-3268 Modified By C.I.Salas - Test Coverage
            
            //END D-1011 MD-28 01/07/15 Wenjun
        }
    public Map<String,String> createZObject(Map<String, Object> objectMap, String obj)
    {
    
    
    
        Map<String,String> resultMap = new Map<String,String>();
        String createdId;    
        try
        {       
            Zuora.zObject zObj = new Zuora.zObject(obj);
            for(String key:objectMap.keyset()) 
            {
                zObj.setValue(key,objectMap.get(key));
            }
            List<Zuora.zObject> objs = new List<Zuora.zObject>{zObj};
            List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
            
            if (!Test.isRunningTest()) {
                results = zApiInstance.zcreate(objs);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                results = RU.getZuoraPositiveResults();
            }
            
            
            for (Zuora.zApi.SaveResult result : results)
            {
                if(result.Success)
                {
                    createdId = result.Id;
                    resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                    resultMap.put('Id',createdId);
                }
                else
                {
                    Zuora.zObject[] errors = result.errors;

                    for(Zuora.zObject error : errors) 
                    {
                        String errorCode = (String)error.getValue('Code');
                        String message = (String)error.getValue('Message'); 
                        resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                        resultMap.put('Code',errorCode);    
                        resultMap.put('Message',message);
                    }
                }
            }
            
        }
        catch(Zuora.zRemoteException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zAPIException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zForceException ex)       
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);        
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        } 
        return resultMap;
    }
    
    public Map<String,String> createMultipleZObject(List<Map<String,Object>> listMap, String obj)
    {
        Map<String,String> resultMap = new Map<String,String>();
        String createdId; 
        Integer counter = 0;
        try
        {   
            List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
            for (Map<String,Object> mapValue: listMap)
            {
                // zObjectList = new List<Zuora.zObject>(); // Start/End D-4463 22Mar16 JohnD - commented out
                Zuora.zObject zObj = new Zuora.zObject(obj);
                for(String key:mapValue.keyset()) 
                {
                    zObj.setValue(key,mapValue.get(key));
                }
                zObjectList.add(zObj);
                counter++;
                if(((math.mod(counter, GlobalVariableClass.MAX_NO_OF_RECORD_50)) == 0) || (counter == listMap.size())) {
                    List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
                    
                    if (!Test.isRunningTest()) {
                        results = zApiInstance.zcreate(zObjectList);
                    }
                    else {
                        ResponseUtility RU = new ResponseUtility();
                        results = RU.getZuoraPositiveResults();
                    }
                   
                    for (Zuora.zApi.SaveResult result : results)
                    {
                        if(result.Success)
                        {
                            createdId = result.Id;
                            resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                            resultMap.put('Id',createdId);
                        }
                        else
                        {
                            Zuora.zObject[] errors = result.errors;

                            for(Zuora.zObject error : errors) 
                            {
                                String errorCode = (String)error.getValue('Code');
                                String message = (String)error.getValue('Message'); 
                                resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                                resultMap.put('Code',errorCode);    
                                resultMap.put('Message',message);
                            }
                        }
                    }
                    
                    zObjectList.clear(); // Start/End D-4463 22Mar16 JohnD
                }   
            }
        }
        catch(Zuora.zRemoteException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zAPIException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zForceException ex)       
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun          
        }   
        return resultMap;
    }
    
    
    public List<Zuora.zObject> queryZObject(String queryStr)
    {   //START D-4076 Gdelrosario : added instantiation
        List<Zuora.zObject> zobjList = new List<Zuora.zObject>();
        //END D-4076 Gdelrosario : added instantiation
        try 
        {
            if (!Test.isRunningTest()) {
                zobjList = zApiInstance.zquery(queryStr);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                zobjList = RU.getMockZObjectResponse(queryStr);
            }
            
        } 
        catch(Zuora.zRemoteException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
        } 
        catch (Zuora.zAPIException ex) 
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
        } 
        catch(Zuora.zForceException ex) 
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);        
        }   
        return zobjList;
    }

    public Map<String,String> updateZObject(Map<String,Object> objectMap, String obj, String objId)
    {
        Map<String,String> resultMap = new Map<String,String>();    
        String updatedId;    
        try
        {       
            Zuora.zObject zObj = new Zuora.zObject(obj);
            zObj.setValue('Id',objId);            
            for(String key:objectMap.keyset()) 
            {
                zObj.setValue(key,objectMap.get(key));
            } 
            List<Zuora.zObject> objs = new List<Zuora.zObject>{zObj};
            List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
            
            if (!Test.isRunningTest()) {
                results = zApiInstance.zupdate(objs);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                results = RU.getZuoraPositiveResults();
            }
            
            for (Zuora.zApi.SaveResult result : results)
            {
                if(result.Success)
                {
                    updatedId = result.Id;
                    resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                    resultMap.put('Id',updatedId);
                }
                else
                {
                    Zuora.zObject[] errors = result.errors;

                    for(Zuora.zObject error : errors) 
                    {
                        String errorCode = (String)error.getValue('Code');
                        String message = (String)error.getValue('Message');
                        resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                        resultMap.put('Code',errorCode);    
                        resultMap.put('Message',message);                        
                    }
                }
            }
            
        }
        catch(Zuora.zRemoteException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zAPIException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zForceException ex)       
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);        
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }   
        return resultMap;   
    }
    
    public Map<String,String> generateInvoice(Map<String,Object> objectMap)
    {
        Map<String,String> resultMap = new Map<String,String>();    
        String generatedId;    
        
        try
        {   
        List<Zuora.zObject> invoiceList = new List<Zuora.zObject>();
 
        Zuora.zObject invoice = new Zuora.zObject('Invoice');
        for(String key:objectMap.keyset()) 
        {
            invoice.setValue(key,objectMap.get(key));
        }
        invoiceList.add(invoice);
         
        List<Zuora.zApi.SaveResult> generateResult = new List<Zuora.zApi.SaveResult>();
        
        if (!Test.isRunningTest()) {
            generateResult = zApiInstance.zgenerate(invoiceList);
        }
        else {
            ResponseUtility RU = new ResponseUtility();
            generateResult = RU.getZuoraPositiveResults();
        }
                    
        for (Zuora.zApi.SaveResult result : generateResult)
            {
                if(result.Success)
                {
                    generatedId = result.Id;
                    resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                    resultMap.put('Id',generatedId);
                }
                else
                {
                    Zuora.zObject[] errors = result.errors;

                    for(Zuora.zObject error : errors) 
                    {
                        String errorCode = (String)error.getValue('Code');
                        String message = (String)error.getValue('Message');
                        resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                        resultMap.put('Code',errorCode);    
                        resultMap.put('Message',message);                        
                    }
                }
            }
            
        }
        catch(Zuora.zRemoteException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zAPIException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zForceException ex)       
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);        
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            resultMap = createExceptionResultMap(ex);
            //END D-1011 MD-28 01/07/15 Wenjun
        }   
        return resultMap; 
    }
    
    public List<Map<String,String>> loadZObjects(List<Map<String,Object>> listMap, String obj) {
        
        
        List<Map<String,String>> returnVar = new List<Map<String,String>>();
        Map<String,String> resultMap;
        String createdId;
        Integer counter = 0;
        try {   
            List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
            
            for (Map<String,Object> mapValue: listMap)
            {
                Zuora.zObject zObj = new Zuora.zObject(obj);
                for(String key:mapValue.keyset()) 
                {
                    zObj.setValue(key,mapValue.get(key));
                }
                
                zObjectList.add(zObj);
                counter++;
            
                if(((math.mod(counter, GlobalVariableClass.MAX_NO_OF_RECORD_50)) == 0) || (counter == listMap.size())) {
                    List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
                    
                    if (!Test.isRunningTest()) {
                        results = zApiInstance.zcreate(zObjectList);
                    }
                    else {
                        ResponseUtility RU = new ResponseUtility();
                        results = RU.getZuoraPositiveResults();
                    }
                    
                    system.debug(':::ZCallOutResults ' + results);
                    for (Zuora.zApi.SaveResult result : results) {
                        resultMap = new Map<String,String>();
                        if(result.Success) {
                            createdId = result.Id;
                            resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                            resultMap.put('Id',createdId);
                        }
                        else {
                            Zuora.zObject[] errors = result.errors;
                            system.debug(':::zErrors ' + errors);
                            for(Zuora.zObject error : errors) {
                                String errorCode = (String)error.getValue('Code');
                                String message = (String)error.getValue('Message'); 
                                resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                                resultMap.put('Code',errorCode);    
                                resultMap.put('Message',message);
                            }
                        }
                        returnVar.add(resultMap);
                    }
                    
                    zObjectList.clear();    // Start/End D-4463 22Mar16 JohnD
                }
            }
        }
        catch(Zuora.zRemoteException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zAPIException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zForceException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun          
        }   
        return returnVar;
    }
    
    public List<Map<String,String>> amendZObjects(List<Map<String,Object>> listMap) {
        List<Map<String,String>> returnVar = new List<Map<String,String>>();
        Map<String,String> resultMap;  
        try {   
            for (Map<String,Object> mapValue: listMap) {
                Zuora.zObject amendment = new Zuora.zObject('Amendment');
                Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
                for(String key:mapValue.keyset()) 
                {
                    amendment.setValue(key,mapValue.get(key));
                }
                Zuora.zObject[] amendments = new List < Zuora.zObject > {amendment};
                amendRequest.amendments = amendments;
                //START: D-0597 2/9/2015 / K. Tan / to cater Electronic Payment Validation
            
                Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
                amendmentOption.GenerateInvoice = false;
                amendmentOption.ProcessPayments = false;
                amendRequest.AmendOptions = amendmentOption;
                //END: D-0597 2/9/2015 / K. Tan / to cater Electronic Payment Validation

                Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
                if (!Test.isRunningTest()) {
                    result = zApiInstance.zamend(new List < Zuora.zApi.AmendRequest > {amendRequest});
                }
                else {
                    ResponseUtility RU = new ResponseUtility();
                    result = RU.getZuoraPositiveAmendResults ();
                }
                
                resultMap = new Map<String,String>();
                if(result.Success) {
                    resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                    resultMap.put('SubId', result.SubscriptionId);
                }
                else {
                    Zuora.zObject[] errors = result.errors;
                    system.debug(GlobalVariableClass.ZUORA_ERROR+errors);
                    
                    //START D-3537 Hotfix Wenjun 10/Sep/15: Return Error Result
                    for(Zuora.zObject error : errors) {
                        String errorCode = (String)error.getValue('Code');
                        String message = (String)error.getValue('Message'); 
                        resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                        resultMap.put('Code',errorCode);    
                        resultMap.put('Message',message);
                    }
                    //END D-3537 Hotfix Wenjun 10/Sep/15
                }
                returnVar.add(resultMap);
            }
        }
        catch(Zuora.zRemoteException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zAPIException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zForceException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);        
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }   
        return returnVar;
    }
    
    public List<Map<String,String>> updateZObjects(List<Map<String,Object>> listMap, String obj) {
        List<Map<String,String>> returnVar = new List<Map<String,String>>();
        Map<String,String> resultMap;
        String createdId;
        Integer counter = 0;
        try {   
            List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
            for (Map<String,Object> mapValue: listMap)
            {
                Zuora.zObject zObj = new Zuora.zObject(obj);
                for(String key:mapValue.keyset()) 
                {
                    zObj.setValue(key,mapValue.get(key));
                }
                zObjectList.add(zObj);
                counter++;
                
                if(((math.mod(counter, GlobalVariableClass.MAX_NO_OF_RECORD_50)) == 0) || (counter == listMap.size())) {
                    List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
                    
                    if (!Test.isRunningTest()) {
                        results = zApiInstance.zupdate(zObjectList);
                    }
                    else {
                        ResponseUtility RU = new ResponseUtility();
                        results = RU.getZuoraPositiveResults();
                    }

                    for (Zuora.zApi.SaveResult result : results) {
                        resultMap = new Map<String,String>();
                        if(result.Success) {
                            createdId = result.Id;
                            resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                            resultMap.put('Id',createdId);
                        }
                        else {
                            Zuora.zObject[] errors = result.errors;

                            for(Zuora.zObject error : errors) {
                                String errorCode = (String)error.getValue('Code');
                                String message = (String)error.getValue('Message'); 
                                resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                                resultMap.put('Code',errorCode);    
                                resultMap.put('Message',message);
                            }
                        }
                        returnVar.add(resultMap);
                    }
                    
                    zObjectList.clear(); // Start/End D-4463 22Mar16 JohnD
                }   
            }
        }
        catch(Zuora.zRemoteException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zAPIException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zForceException ex) {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);        
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }   
        return returnVar;
    }
    
    public List<Map<String,String>> generateInvoiceList(List<Map<String,Object>> objectMap) {
        List<Map<String,String>> returnVar = new List<Map<String,String>>();
        Map<String,String> resultMap;  
        String createdId;    
        
        try {
            List<Zuora.zObject> invoiceList = new List<Zuora.zObject>();
     
            for(Map<String,Object> mapValue :objectMap) 
            {
                Zuora.zObject invoice = new Zuora.zObject('Invoice');
                
                for(String key :mapValue.keyset()) 
                {
                    invoice.setValue(key,mapValue.get(key));
                }
                invoiceList.add(invoice);
            }
            
            List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
            if (!Test.isRunningTest()) {
                results = zApiInstance.zgenerate(invoiceList);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                results = RU.getZuoraPositiveResults();
            }
            
            for (Zuora.zApi.SaveResult result : results) {
                resultMap = new Map<String,String>();
                if(result.Success) {
                    createdId = result.Id;
                    resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                    resultMap.put('Id',createdId);
                }
                else {
                    Zuora.zObject[] errors = result.errors;

                    for(Zuora.zObject error : errors) {
                        String errorCode = (String)error.getValue('Code');
                        String message = (String)error.getValue('Message'); 
                        resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                        resultMap.put('Code',errorCode);    
                        resultMap.put('Message',message);
                    }
                }
                returnVar.add(resultMap);
            }
        }
        catch(Zuora.zRemoteException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zAPIException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        catch(Zuora.zForceException ex)       
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);        
            //START D-1011 MD-28 01/07/15 Wenjun:return error result if exception occurs
            returnVar.add(createExceptionResultMap(ex));
            //END D-1011 MD-28 01/07/15 Wenjun
        }
        
        return returnVar; 
    }
    
    public List<Zuora.zObject> zquerymore(String inv) {
        List<Zuora.zObject> zObjList = new List<Zuora.zObject>();
        //Set ZOQL for query request
        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
        qr.zoql = 'SELECT AccountingCode, AppliedToInvoiceItemId, ChargeAmount, ChargeDate,'+
                              'ChargeDescription, ChargeName, ChargeNumber, CreatedById,'+
                              'CreatedDate, Id, InvoiceId, ProcessingType, ProductDescription, ProductId,'+
                              'ProductName, Quantity, RatePlanChargeId, RevRecCode, RevRecStartDate,'+
                              'RevRecTriggerCondition, ServiceEndDate, ServiceStartDate, SKU, SubscriptionId,'+
                              'SubscriptionNumber, TaxAmount, TaxCode, TaxExemptAmount, TaxMode, UnitPrice,'+
                              'UOM, UpdatedById, UpdatedDate FROM InvoiceItem Where InvoiceId=:\'' + inv + '\'';
        //Set query options
        Zuora.zApi.QueryOptions qo = new Zuora.zApi.QueryOptions();
        qo.batchSize = 20;
        qo.caseSensitive = false;
        qr.queryOptions = qo;

        // Call zquery() to get initial results
        Zuora.zApi.QueryResult queryResult = new Zuora.zApi.QueryResult();
        if (!Test.isRunningTest()) {
            queryResult = zApiInstance.zquery(qr);
        }
        else {
            ResponseUtility RU = new ResponseUtility();
            queryResult = RU.getMockQueryResultPositive(qr.zoql, false);
        }
        
        
        if (queryResult.size > 0) {
            zObjList.addAll(queryResult.records);
        }
        // If the result set is not complete, call zqueryMore() to get more records
        Zuora.zApi.QueryResult queryMoreResult;
        if(!queryResult.done){
            Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
            qmr.queryLocator = queryResult.queryLocator;
           
            if (!Test.isRunningTest()) {
                queryMoreResult = zApiInstance.zqueryMore(qmr);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                queryMoreResult = RU.getMockQueryMoreResultPositive(qr.zoql, false);
            }
            
            if (queryMoreResult.size > 0) {
                zObjList.addAll(queryMoreResult.records);
            }
        }
        if (queryMoreResult != null) {
        while(!queryMoreResult.done){
            Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
            qmr.queryLocator = queryResult.queryLocator;
            
            
            if (!Test.isRunningTest()) {
                queryMoreResult = zApiInstance.zqueryMore(qmr);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                queryMoreResult = RU.getMockQueryMoreResultPositive(qr.zoql, true);
            }
            
            if (queryMoreResult.size > 0) {
                zObjList.addAll(queryMoreResult.records);
            }
        }
        }
        return zObjList;
    }
    //D-0812 Query Invoice
    public List<Zuora.zObject> zquerymoreInvoice(String inv) {
        List<Zuora.zObject> zObjList = new List<Zuora.zObject>();
        //Set ZOQL for query request
        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
        qr.zoql = 'SELECT AccountId, Balance, Id FROM Invoice Where Id =:\'' + inv + '\'';
        //Set query options
        Zuora.zApi.QueryOptions qo = new Zuora.zApi.QueryOptions();
        qo.batchSize = 20;
        qo.caseSensitive = false;
        qr.queryOptions = qo;

        // Call zquery() to get initial results
        Zuora.zApi.QueryResult queryResult = new Zuora.zApi.QueryResult();
        
        if (!Test.isRunningTest()) {
            queryResult = zApiInstance.zquery(qr);
        }
        else {
            ResponseUtility RU = new ResponseUtility();
            queryResult = RU.getMockQueryResultPositive(qr.zoql, false);
        }
        
        if (queryResult.size > 0) {
            zObjList.addAll(queryResult.records);
        }
        // If the result set is not complete, call zqueryMore() to get more records
        Zuora.zApi.QueryResult queryMoreResult;
        if(!queryResult.done){
            Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
            qmr.queryLocator = queryResult.queryLocator;
            
            
            if (!Test.isRunningTest()) {
                queryMoreResult = zApiInstance.zqueryMore(qmr);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                queryMoreResult = RU.getMockQueryMoreResultPositive(qr.zoql, false);
            }
            
            if (queryMoreResult.size > 0) {
                zObjList.addAll(queryMoreResult.records);
            }
        }
        if (queryMoreResult != null) {
        while(!queryMoreResult.done){
            Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
            qmr.queryLocator = queryResult.queryLocator;
            
            
            if (!Test.isRunningTest()) {
                queryMoreResult = zApiInstance.zqueryMore(qmr);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                queryMoreResult = RU.getMockQueryMoreResultPositive(qr.zoql, true);
            }
            
            if (queryMoreResult.size > 0) {
                zObjList.addAll(queryMoreResult.records);
            }
        }
        }
        return zObjList;
    }
    
    //START UD-0790 4/22/2015 Added by Manolo Valena - Query Amount, Id, InvoiceNumber for creation of Credit Balance Adjustment.
    public List<Zuora.zObject> zquerymoreInvoices(String invs) {
        List<Zuora.zObject> zObjList = new List<Zuora.zObject>();
        //Set ZOQL for query request
        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
        qr.zoql = 'SELECT AccountId, Balance, Id, Amount, InvoiceNumber FROM Invoice Where Id =:\'' + invs + '\'';
        //Set query options
        Zuora.zApi.QueryOptions qo = new Zuora.zApi.QueryOptions();
        qo.batchSize = 20;
        qo.caseSensitive = false;
        qr.queryOptions = qo;

        // Call zquery() to get initial results
        Zuora.zApi.QueryResult queryResult = new Zuora.zApi.QueryResult();
        
        if (!Test.isRunningTest()) {
            queryResult = zApiInstance.zquery(qr);
        }
        else {
            ResponseUtility RU = new ResponseUtility();
            queryResult = RU.getMockQueryResultPositive(qr.zoql, false);
        }
            
        if (queryResult.size > 0) {
            zObjList.addAll(queryResult.records);
        }
        // If the result set is not complete, call zqueryMore() to get more records
        Zuora.zApi.QueryResult queryMoreResult;
        if(!queryResult.done){
            Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
            qmr.queryLocator = queryResult.queryLocator;
            
            
            if (!Test.isRunningTest()) {
                queryMoreResult = zApiInstance.zqueryMore(qmr);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                queryMoreResult = RU.getMockQueryMoreResultPositive(qr.zoql, false);
            }
            
            if (queryMoreResult.size > 0) {
                zObjList.addAll(queryMoreResult.records);
            }
        }
        if (queryMoreResult != null) {
            while(!queryMoreResult.done){
                Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
                qmr.queryLocator = queryResult.queryLocator;
                
                if (!Test.isRunningTest()) {
                    queryMoreResult = zApiInstance.zqueryMore(qmr);
                }
                else {
                    ResponseUtility RU = new ResponseUtility();
                    queryMoreResult = RU.getMockQueryMoreResultPositive(qr.zoql, true);
                }
            

                if (queryMoreResult.size > 0) {
                    zObjList.addAll(queryMoreResult.records);
                }
            }
        }
        return zObjList;
    }
    //END UD-0790 4/22/2015 Added by Manolo Valena
        //START D-1011 MD-28 01/07/15 Wenjun:Utility Method
        //Utility Method for Create Exception Return Map
        private Map<String,String> createExceptionResultMap(Exception exception1) 
        {
            Map<String,String> resultMap = new Map<String,String>();
            resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);  
            resultMap.put('Code',exception1.getTypeName());
            resultMap.put('Message',exception1.getMessage());
            return resultMap;
        }
    
    // START : UD-1419 7/20/2015 Alyana Navarro
    public Map<String,String> createMultipleZObjectForRefund(List<Map<String,Object>> listMap, String obj) {
        Map<String,String> resultMap = new Map<String,String>();
        String createdId; 
        Integer counter = 0;
        try
        {   
            List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
            for (Map<String,Object> mapValue: listMap){
                //zObjectList = new List<Zuora.zObject>();  // Start/End D-4463 22Mar16 JohnD - commented out
                Zuora.zObject zObj = new Zuora.zObject(obj);
                for(String key:mapValue.keyset()) 
                {
                    zObj.setValue(key,mapValue.get(key));
                }
                zObjectList.add(zObj);
                counter++;
                if(((math.mod(counter, GlobalVariableClass.MAX_NO_OF_RECORD_50)) == 0) || (counter <= listMap.size())) {
                    List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
                    System.debug('Zuora Result: ' + results);
                    
                    if (!Test.isRunningTest()) {
                        results = zApiInstance.zcreate(zObjectList);
                    }
                    else {
                        ResponseUtility RU = new ResponseUtility();
                        results = RU.getZuoraPositiveResults();
                    }
                    
                    for (Zuora.zApi.SaveResult result : results)
                    {
                        if(result.Success)
                        {
                            createdId = result.Id;
                            resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                            resultMap.put('Id',createdId);
                        }
                        else
                        {
                            Zuora.zObject[] errors = result.errors;
    
                            for(Zuora.zObject error : errors) 
                            {
                                String errorCode = (String)error.getValue('Code');
                                String message = (String)error.getValue('Message'); 
                                resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                                resultMap.put('Code',errorCode);    
                                resultMap.put('Message',message);
                            }
                        }
                    }
                    
                    zObjectList.clear();    // Start/End D-4463 22Mar16 JohnD
                }
            }
        }
        catch(Zuora.zRemoteException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);                
            resultMap = createExceptionResultMap(ex);                
        }
        catch(Zuora.zAPIException ex)
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);                
            resultMap = createExceptionResultMap(ex);                
        }
        catch(Zuora.zForceException ex)       
        {
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex);                
            resultMap = createExceptionResultMap(ex);                     
        }   
        
        return resultMap;
    }
    // END : UD-1419 7/20/2015 Alyana Navarro
    //START UD-2854 10/05/15 RReyes - cater for quering multiple invoices
    public List<Zuora.zObject> bulkQueryInvoices(Set<String> setInvId) {
        if(setInvId == null || setInvId.isEmpty()) return new List<Zuora.zObject>();
        
        //Prepare Query String
        String queryStr = '';
        for(String invoiceID : setInvId)
            queryStr += ' OR ID=\'' + invoiceID + '\''; //rom
        queryStr = queryStr.substring(4);

        String zoqlString = 'SELECT AccountId, Balance, Id, Amount, InvoiceNumber FROM Invoice Where ' + queryStr;//START/END UD-3676 01/20/16 RReyes - added Amount,InvoiceNumber in query
        System.debug('*143* zoqlString: ' + zoqlString);
        return bulkQueryZObjects(zoqlString);
    }
    
    public List<Zuora.zObject> bulkQueryPayMet(Set<String> setBAId) {
        if(setBAId == null || setBAId.isEmpty()) return new List<Zuora.zObject>();
        
        //Prepare Query String
        String queryStr = '';
        for(String BAId : setBAId)
            queryStr += ' OR ID=\'' + BAId + '\''; //rom
        queryStr = queryStr.substring(4);

        String zoqlString = 'SELECT Id, DefaultPaymentMethodId FROM Account Where ' + queryStr;
        System.debug('*143* billAcc: ' + zoqlString);
        return bulkQueryZObjects(zoqlString);
    }
    
    //START UD-2549 3/15/2016 Added by J.Sarion - Added param
    //START UD-3002 12/11/2015 Added by J.Sarion - query Invoice Items for multiple Invoices
    public List<Zuora.zObject> bulkQueryForInvoiceItem(Set<String> objIdSet, String objName) {
        if(objIdSet == null || objIdSet.isEmpty()) return new List<Zuora.zObject>();
        
        //Prepare Query String
        String queryStr = '';
        
        for(String objId : objIdSet) {
            if(objName == 'invoice') {
                queryStr += ' OR InvoiceId=\'' + objId + '\''; //rom
            }
            else if(objName == 'subscription') {
                queryStr += ' OR SubscriptionNumber=\'' + objId + '\'';
            }
        }
        queryStr = queryStr.substring(4);

        String zoqlString = 'SELECT Id, SubscriptionId, InvoiceId FROM InvoiceItem Where ' + queryStr;
        System.debug('*143* zoqlString: ' + zoqlString);
        return bulkQueryZObjects(zoqlString);
    }
    //END UD-3002 12/11/2015 Added by J.Sarion - query Invoice Items for multiple Invoices
    
    public List<Zuora.zObject> bulkQueryForAccount(Set<String> objIdSet) {
        if(objIdSet == null || objIdSet.isEmpty()) return new List<Zuora.zObject>();
        
        //Prepare Query String
        String queryStr = '';
        
        for(String objId : objIdSet) {
            queryStr += ' OR Id=\'' + objId + '\'';
        }
        queryStr = queryStr.substring(4);

        String zoqlString = 'SELECT Id, AccountNumber FROM Account Where ' + queryStr;
        System.debug('*143* zoqlString: ' + zoqlString);
        return bulkQueryZObjects(zoqlString);
    }
    
    //END UD-2549 3/15/2016 Added by J.Sarion - Added param
    
    public List<Zuora.zObject> bulkQueryZObjects(String zoqlStr)
    {
        List<Zuora.zObject> zObjList = new List<Zuora.zObject>();

        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
        qr.zoql = zoqlStr;
        Zuora.zApi.QueryOptions qo = new Zuora.zApi.QueryOptions();
        qo.batchSize = 200; 
        qo.caseSensitive = false;
        qr.queryOptions = qo;

        // Call zquery() to get initial results
        Zuora.zApi.QueryResult queryResult = new Zuora.zApi.QueryResult();
        
        
        if (!Test.isRunningTest()) {
            queryResult = zApiInstance.zquery(qr);
        }
        else {
            ResponseUtility RU = new ResponseUtility();
            queryResult = RU.getMockQueryResultPositive(zoqlStr, false);
        }
                    
        if (queryResult.size > 0) {
            zObjList.addAll(queryResult.records);
        }
        
        // If the result set is not complete, call zqueryMore() to get more records
        Zuora.zApi.QueryResult queryMoreResult;
        if(!queryResult.done){
            Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
            qmr.queryLocator = queryResult.queryLocator;
            
            
            if (!Test.isRunningTest()) {
                queryMoreResult = zApiInstance.zqueryMore(qmr);
            }
            else {
                ResponseUtility RU = new ResponseUtility();
                queryMoreResult = RU.getMockQueryMoreResultPositive(zoqlStr, false);
            }
        

            if (queryMoreResult.size > 0) {
                zObjList.addAll(queryMoreResult.records);
            }
        }
        
        if (queryMoreResult != null) {
            while(!queryMoreResult.done){
                Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
                qmr.queryLocator = queryResult.queryLocator;
                
                if (!Test.isRunningTest()) {
                    queryMoreResult = zApiInstance.zqueryMore(qmr);
                }
                else {
                    ResponseUtility RU = new ResponseUtility();
                    queryMoreResult = RU.getMockQueryMoreResultPositive(zoqlStr, true);
                }
            
                if (queryMoreResult.size > 0) {
                    zObjList.addAll(queryMoreResult.records);
                }
            }
        }
        return zObjList;
    }
    
    public List<Map<String,String>> bulkCreateZObjects(List<Map<String,Object>> listMap, String obj)
    {
        List<Map<String,String>> returnVar = new List<Map<String,String>>();
        Integer counter = 0;
        
        try
        {   
            List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
            for (Map<String,Object> mapValue: listMap)
            {
                // zObjectList = new List<Zuora.zObject>(); // Start/End D-4463 22Mar16 JohnD - commented out
                Zuora.zObject zObj = new Zuora.zObject(obj);
                for(String key:mapValue.keyset()) 
                {
                    zObj.setValue(key,mapValue.get(key));
                }
                zObjectList.add(zObj);
                counter++;
                
                if(((math.mod(counter, GlobalVariableClass.MAX_NO_OF_RECORD_50)) == 0) || (counter == listMap.size())) {
                    List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
                    
                    if (!Test.isRunningTest()) {
                        results = zApiInstance.zcreate(zObjectList);
                    }
                    else {
                        ResponseUtility RU = new ResponseUtility();
                        results = RU.getZuoraPositiveResults();
                    }
                    
                    for (Zuora.zApi.SaveResult result : results)
                    {
                        Map<String,String> resultMap = new Map<String,String>();
                        if(result.Success)
                        {
                            resultMap.put('Status',GlobalVariableClass.ZUORA_SUCCESS);
                            resultMap.put('Id',result.Id);
                        }
                        else {
                            Zuora.zObject[] errors = result.errors;

                            for(Zuora.zObject error : errors) {
                                String errorCode = (String)error.getValue('Code');
                                String message = (String)error.getValue('Message'); 
                                resultMap.put('Status',GlobalVariableClass.ZUORA_FAILED);
                                resultMap.put('Code',errorCode);    
                                resultMap.put('Message',message);
                            }
                        }
                        returnVar.add(resultMap);
                    }
                    
                    zObjectList.clear();    // Start/End D-4463 22Mar16 JohnD
                }   
            }
        }
        catch(Zuora.zRemoteException ex)
        {
            System.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            returnVar.add(createExceptionResultMap(ex));
        }
        catch(Zuora.zAPIException ex)
        {
            System.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            returnVar.add(createExceptionResultMap(ex));
        }
        catch(Zuora.zForceException ex)       
        {
            System.debug(GlobalVariableClass.ZUORA_ERROR+ex);
            returnVar.add(createExceptionResultMap(ex));        
        }   
        return returnVar;
    }
     //END UD-2854 10/05/15 RReyes - cater multiple invoices
    

      
     
}