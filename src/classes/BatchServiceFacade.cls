/**
     * Class Name: BatchServiceFacade
     * @author: Krithika D
     * Date: 2/10/2014
     * Requirement/Project Name: CRSM Project
     * @description Main function is to insert record into the table
     * 
 */
public class BatchServiceFacade{

    public BatchServiceResponsetVO delegateBatchCall(BatchServiceRequestVO requestVO){
        BatchServiceResponsetVO batchSvcResp;//START-END 2/10/2014 D-2153 Added by Krithika D
        String JSONString = JSON.serializePretty(requestVO);   
        System.debug('JSONSTRING' + JSONString);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        Map<String,String> responseMap = new Map<String,String>(); 

        req.setEndpoint(ConstantsSLB.getBatchIntegrationSettings(GlobalVariableClass.ENDPOINTDELEGATOR));//START-END 2/10/2014 D-2153 Added by Krithika D
        req.setMethod('POST');
        req.setHeader('content-type','application/json');
        req.setBody(JSONString);

		//START D-3810 23-Oct-2015 LISEN - add log if callout failed
        Logger logger = new Logger(LoggerTest.class.getName(), requestVO.getJobId());
        try
        { 
            res = http.send(req); 
            if(res.getStatusCode() == 200)
            {                 
                System.debug(res.getBody());
                Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                System.debug(respMap);
                responseMap.put('ServiceStatus','SUCCESS');
                responseMap.put('Message','DB update SUCCESSFUL');
            }
            else
            {
                responseMap.put('ServiceStatus','Failed');
                responseMap.put('Message',res.getStatus());   
                logger.log(false, 'Update Control M failed. Message: ' + res.getStatus());
            }
            System.debug('responsemap'+responseMap);
            batchSvcResp = new BatchServiceResponsetVO(responseMap,'');    //START-END 2/10/2014 D-2153 Added by Krithika D        
        }
        catch(Exception e)
        { 
        	// Start D-3478 28Sep15 JohnD - added log
        	logger.log(e);
            // System.debug('Error:'+e); // commented out
            // End D-3478 28Sep15 JohnD - added log
        }finally{
			logger.save();
		}
		//END D-3810 23-Oct-2015 LISEN - add log if callout failed
        return batchSvcResp;//START-END 2/10/2014 D-2153 Added by Krithika D
    }
}