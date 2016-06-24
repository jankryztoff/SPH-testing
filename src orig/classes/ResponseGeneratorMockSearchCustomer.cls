@isTest //(SeeAllData=true)
global class ResponseGeneratorMockSearchCustomer implements WebServiceMock {

    private Boolean rtnStsInd;

    public ResponseGeneratorMockSearchCustomer(Boolean rtnSts){
        rtnStsInd = rtnSts;
    }

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
            
            wwwSphComArWsSchemaCommonUser.UserType userType = new wwwSphComArWsSchemaCommonUser.UserType();

            wwwSphComArWsSchemaCamSearchcustoR.CusType cusType = new wwwSphComArWsSchemaCamSearchcustoR.CusType();
            cusType.CusM2 = 'MockCusM2';
            cusType.BlkN = 'MockBlkN'; 
            cusType.FlrN = 'MockFlrN'; 
            cusType.UntN = 'MockUntN'; 
            cusType.Str = 'MockStr'; 
            cusType.BldgSec = 'MockBldgSec'; 
            cusType.CusA1 = 'MockCusA1'; 
            cusType.CusA2 = 'MockCusA2'; 
            cusType.CusA3 = 'MockCusA3'; 
            cusType.CusA4 = 'MockCusA4'; 

            wwwSphComArWsSchemaCamSearchcustoR.L_CusType lCusType = new wwwSphComArWsSchemaCamSearchcustoR.L_CusType();
            lCusType.Cus = new List<wwwSphComArWsSchemaCamSearchcustoR.CusType>{cusType};

            wwwSphComArWsSchemaCamSearchcusto.CusSrch_element cusSrchElement = new wwwSphComArWsSchemaCamSearchcusto.CusSrch_element();
            wwwSphComArWsSchemaCommonMessages.MessagesType messageType = new wwwSphComArWsSchemaCommonMessages.MessagesType();
            wwwSphComArWsSchemaCamSearchcustoR.CusSrchResp_element cusSrchRespElement = new wwwSphComArWsSchemaCamSearchcustoR.CusSrchResp_element();
            cusSrchRespElement.L_Cus = lCusType;
            if (rtnStsInd <> NULL && rtnStsInd) cusSrchRespElement.RtnSts = '0';
            else if (rtnStsInd <> NULL && !rtnStsInd) cusSrchRespElement.RtnSts = '1';
            else cusSrchRespElement = null;

            wwwSphComArWsWsdlCam.CAMSOAP CusRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();  


            wwwSphComArWsWsdlCam.SearchCustomerRequestType searchCusReq = new wwwSphComArWsWsdlCam.SearchCustomerRequestType();
            searchCusReq.user_x = userType;
            searchCusReq.CusSrch = cusSrchElement;

            wwwSphComArWsWsdlCam.SearchCustomerRequest_element request_x = new wwwSphComArWsWsdlCam.SearchCustomerRequest_element();
            wwwSphComArWsWsdlCam.SearchCustomerResponseType tempResponse = new wwwSphComArWsWsdlCam.SearchCustomerResponseType();

            tempResponse.user_x = userType; 
            tempResponse.CusSrch = cusSrchElement; 
            tempResponse.CusSrchResp = cusSrchRespElement;
            tempResponse.messages = messageType;

            wwwSphComArWsWsdlCam.SearchCustomerResponse_element response_x = new wwwSphComArWsWsdlCam.SearchCustomerResponse_element(); 
            response_x.response = tempResponse;
            System.debug('***mocktest: ' + response_x);
            response.put('response_x', response_x); 
            
        }
}