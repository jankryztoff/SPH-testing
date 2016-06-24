@isTest
global class zCreateAccountMock implements WebServiceMock {
    
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
        
        //Map<String,String> res = New Map<String,String>();
        // Zuora.zApi zApiInstance = new Zuora.zApi();
        // zApiInstance.zlogin();
        wwwSphComArWsWsdlCam.CreateCustomerAccountResponse_element res = new wwwSphComArWsWsdlCam.CreateCustomerAccountResponse_element();
        wwwSphComArWsWsdlCam.CreateCustomerAccountResponseType resType = new wwwSphComArWsWsdlCam.CreateCustomerAccountResponseType();
        wwwSphComArWsSchemaCamCreatecustoR.CusAccCreResp_element CusAccCreRes = new wwwSphComArWsSchemaCamCreatecustoR.CusAccCreResp_element();
        CusAccCreRes.SysId = 'SysId';
        CusAccCreRes.RtnSts = 'RtnSts';
        CusAccCreRes.RtnMsg = 'RtnMsg';
        CusAccCreRes.Syno = 'Syno';
        CusAccCreRes.UniqId = 'UniqId';
        CusAccCreRes.CusN = 'CusN';
        CusAccCreRes.CreDte = 'CreDte';
        CusAccCreRes.BLInd = 'CreDte';
        CusAccCreRes.BLClrCd = 'BLClrCd';
        CusAccCreRes.BLRsn = 'BLRsn';
        CusAccCreRes.CrRskRtg = 'CrRskRtg';
        CusAccCreRes.AccN = 'AccN';
        CusAccCreRes.AccCreDte = 'AccCreDte';
        resType.CusAccCreResp = CusAccCreRes;
        res.response = resType;
        //res.put('Status','Failed');
        
        response.put('response_x', res);     
    }
}