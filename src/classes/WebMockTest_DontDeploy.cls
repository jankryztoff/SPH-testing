@isTest(SeeAllData=true)
public class WebMockTest_DontDeploy {
    
    public testmethod static void testWebCallOutSearchCustomer(){

        Test.setMock(WebServiceMock.class, new ResponseGeneratorMock());
        
        Test.startTest();   
        
        wwwSphComArWsWsdlCam.CAMSOAP cams = new wwwSphComArWsWsdlCam.CAMSOAP();        
        wwwSphComArWsWsdlCam.SearchCustomerRequestType startReqType = new wwwSphComArWsWsdlCam.SearchCustomerRequestType();
        wwwSphComArWsWsdlCam.SearchCustomerResponseType returnVar = cams.SearchCustomer(startReqType);
        System.debug('***Test: ' + returnVar);
        Test.stopTest();
        
    }
    
    public testmethod static void testWebCallOutSearchAccount(){

        Test.setMock(WebServiceMock.class, new ResponseGeneratorMock());
        
        Test.startTest();   
        
        wwwSphComArWsWsdlCam.CAMSOAP cams = new wwwSphComArWsWsdlCam.CAMSOAP();        
        wwwSphComArWsWsdlCam.SearchAccountRequestType startReqType = new wwwSphComArWsWsdlCam.SearchAccountRequestType();
        wwwSphComArWsWsdlCam.SearchAccountResponseType returnVar = cams.SearchAccount(startReqType);
        System.debug('***Test: ' + returnVar);
        Test.stopTest();
        
    }
    
}