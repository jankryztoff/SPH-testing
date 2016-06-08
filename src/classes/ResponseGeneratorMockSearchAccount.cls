@isTest //(SeeAllData=true)
global class ResponseGeneratorMockSearchAccount implements WebServiceMock {

    private String rtnStsInd;

    public ResponseGeneratorMockSearchAccount(String rtnSts){
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
            wwwSphComArWsSchemaCamSearchaccou.AccSrch_element accSrchElement = new wwwSphComArWsSchemaCamSearchaccou.AccSrch_element();
            wwwSphComArWsSchemaCommonMessages.MessagesType messageType = new wwwSphComArWsSchemaCommonMessages.MessagesType();


            wwwSphComArWsSchemaCamSearchaccouR.AccType accType = new wwwSphComArWsSchemaCamSearchaccouR.AccType ();
            accType.AccN = 'TestMock AccN';
            accType.AccTyp = ConstantsSLB.getOther('ARMS_AccTyp');
            accType.AccCreDte = 'TestMock AccCreDte';
            accType.CrTrm = 'TestMock CrTrm';
            accType.CrTrmRef = 'TestMock CrTrmRef';
            accType.DbtStrt = 'TestMock DbtStrt';
            accType.CoyCd = 'TestMock CoyCd';
			accType.CrLmtInt = '123456.12';
			accType.CrLmtExt = '123456.12';
			accType.DbtExp = '123456.12';
			accType.CusGrAccN = 'TestMock CusGrAccN';
			accType.CusGrBnkN = 'TestMock CusGrBnkN';
			accType.BizSctr = 'TestMock BizSctr';

            wwwSphComArWsSchemaCamSearchaccouR.L_AccType lAccType = new wwwSphComArWsSchemaCamSearchaccouR.L_AccType();
            lAccType.Acc = new List<wwwSphComArWsSchemaCamSearchaccouR.AccType>{accType};

            wwwSphComArWsSchemaCamSearchaccouR.AccSrchResp_element accSrchRespElement = new wwwSphComArWsSchemaCamSearchaccouR.AccSrchResp_element();
            accSrchRespElement.L_Acc = lAccType;

            if (rtnStsInd == '0') {accSrchRespElement.RtnSts = '0'; accSrchRespElement.SysId = ConstantsSLB.getOther('ARMS_SysId');}
            else if (rtnStsInd == '1') accSrchRespElement.RtnSts = '1';
            else if (rtnStsInd == '8') accSrchRespElement.RtnSts = '8';
            else if (rtnStsInd == 'n' ) accSrchRespElement.RtnSts = 'n';
            else accSrchRespElement = null;


            wwwSphComArWsWsdlCam.CAMSOAP AccRespCAM = new wwwSphComArWsWsdlCam.CAMSOAP();  

          	wwwSphComArWsWsdlCam.SearchAccountRequestType searchAccReq = new wwwSphComArWsWsdlCam.SearchAccountRequestType();
            searchAccReq.user_x = userType;
            searchAccReq.AccSrch = accSrchElement;

            wwwSphComArWsWsdlCam.SearchAccountRequest_element request_x = new wwwSphComArWsWsdlCam.SearchAccountRequest_element();
            wwwSphComArWsWsdlCam.SearchAccountResponseType tempResponse = new wwwSphComArWsWsdlCam.SearchAccountResponseType();
            tempResponse.user_x = userType;
            tempResponse.AccSrch = accSrchElement;
            tempResponse.AccSrchResp = accSrchRespElement;
            tempResponse.messages = messageType;

			wwwSphComArWsWsdlCam.SearchAccountResponse_element response_x = new wwwSphComArWsWsdlCam.SearchAccountResponse_element();
            response_x.response = tempResponse;
            System.debug('***mocktest: ' + response_x);
            response.put('response_x', response_x); 
  
        }
}