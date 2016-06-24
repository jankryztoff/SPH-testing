@isTest
global class zUpdateMock implements WebServiceMock {
	//private Boolean isSuccess;

 //   public zUpdateMock(Boolean resSuccess){
 //       isSuccess = resSuccess;
 //   }
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
        
        Zuora.zObject error = new Zuora.zObject('Error');
        Zuora.zObject[] errors = new List<Zuora.zObject>();
        error.setValue ('Code', 'test error');
        error.setValue ('Message', 'test message');
        errors.add(error);
                
        Zuora.zApi.SaveResult ress = new Zuora.zApi.SaveResult();
        ress.Success = true; 
        ress.id = '1234';
        ress.Errors = errors;

        //wwwSphComArWsWsdlCam.CreateCustomerAccountResponse_element res = new wwwSphComArWsWsdlCam.CreateCustomerAccountResponse_element();
        //wwwSphComArWsWsdlCam.CreateCustomerAccountResponseType resType = new wwwSphComArWsWsdlCam.CreateCustomerAccountResponseType();
        //wwwSphComArWsSchemaCamCreatecustoR.CusAccCreResp_element CusAccCreRes = new wwwSphComArWsSchemaCamCreatecustoR.CusAccCreResp_element();
        //CusAccCreRes.SysId = 'SysId';
        //CusAccCreRes.RtnSts = 'RtnSts';
        //CusAccCreRes.RtnMsg = 'RtnMsg';
        //CusAccCreRes.Syno = 'Syno';
        //CusAccCreRes.UniqId = 'UniqId';
        //CusAccCreRes.CusN = 'CusN';
        //CusAccCreRes.CreDte = 'CreDte';
        //CusAccCreRes.BLInd = 'CreDte';
        //CusAccCreRes.BLClrCd = 'BLClrCd';
        //CusAccCreRes.BLRsn = 'BLRsn';
        //CusAccCreRes.CrRskRtg = 'CrRskRtg';
        //CusAccCreRes.AccN = 'AccN';
        //CusAccCreRes.AccCreDte = 'AccCreDte';
        //resType.CusAccCreResp = CusAccCreRes;
        //res.response = resType;

        //response.put('response_x', res);    
        response.put('response_x', ress);   
    }
}