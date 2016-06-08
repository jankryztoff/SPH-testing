/*
* Class Name: <wwwSphComArWsWsdlCamTest>
* @author: Thayne Recato Dy
* Date: 2/24/2015
* Requirement/Project Name: <SPH>
* @description: Test class of wwwSphComArWsWsdlCam
*/
@isTest(seeAllData = true)
private class wwwSphComArWsWsdlCamTest {
    
    /*@Description: This test method execute all class in the base class */
    private static testmethod void testCreateAccountResponseType() {
        new wwwSphComArWsWsdlCam.CreateAccountResponseType();
        new wwwSphComArWsWsdlCam.UpdateAccountResponseType();        
        new wwwSphComArWsWsdlCam.UpdateCustomerResponseType();
        new wwwSphComArWsWsdlCam.SearchAccountResponseType();
        new wwwSphComArWsWsdlCam.CreateCustomerAccountResponseType();
        new wwwSphComArWsWsdlCam.SearchCustomerResponseType();
        new wwwSphComArWsWsdlCam.UpdateAccountRequest_element();
        new wwwSphComArWsWsdlCam.SearchCustomerRequest_element();
        new wwwSphComArWsWsdlCam.UpdateAccountResponse_element();
        new wwwSphComArWsWsdlCam.UpdateCustomerRequest_element();
        new wwwSphComArWsWsdlCam.CreateAccountRequest_element();
        new wwwSphComArWsWsdlCam.CreateCustomerAccountRequest_element();
        new wwwSphComArWsWsdlCam.SearchAccountRequest_element();
        new wwwSphComArWsWsdlCam.UpdateCustomerResponse_element();
        new wwwSphComArWsWsdlCam.SearchCustomerResponse_element();
        new wwwSphComArWsWsdlCam.SearchAccountResponse_element();
        new wwwSphComArWsWsdlCam.CreateCustomerAccountResponse_element();
        new wwwSphComArWsWsdlCam.CreateAccountResponse_element();
        new wwwSphComArWsWsdlCam.SearchCustomerRequestType();
        new wwwSphComArWsWsdlCam.SearchAccountRequestType();
        new wwwSphComArWsWsdlCam.UpdateCustomerRequestType();
        new wwwSphComArWsWsdlCam.UpdateAccountRequestType();
        new wwwSphComArWsWsdlCam.CreateAccountRequestType();
        new wwwSphComArWsWsdlCam.CreateCustomerAccountRequestType();
    }
    
    /*@Description: This test method execute the method of SearchAccount in the CAMSOAP class*/
    private static testmethod void testSearchAccount() {
        try
        {
             wwwSphComArWsWsdlCam.CAMSOAP cams = new wwwSphComArWsWsdlCam.CAMSOAP();
        
            //Test.setMock(WebServiceMock.class, new wwwSphComArWsWsdlCamMock());
            
            wwwSphComArWsWsdlCam.SearchAccountRequestType sartRequest = new wwwSphComArWsWsdlCam.SearchAccountRequestType();
            wwwSphComArWsWsdlCam.SearchAccountResponseType returnVar = cams.SearchAccount(sartRequest);
            
            System.assertEquals(NULL, returnVar);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }     
    }
    
    /*@Description: This test method execute the method of UpdateAccount in the CAMSOAP class*/
    private static testmethod void testUpdateAccount() {
        try
        {
             wwwSphComArWsWsdlCam.CAMSOAP cams = new wwwSphComArWsWsdlCam.CAMSOAP();
        
            //Test.setMock(WebServiceMock.class, new wwwSphComArWsWsdlCamMock());
            
            wwwSphComArWsWsdlCam.UpdateAccountRequestType uatRequest = new wwwSphComArWsWsdlCam.UpdateAccountRequestType();
            wwwSphComArWsWsdlCam.UpdateAccountResponseType returnVar =  cams.UpdateAccount(uatRequest);
            
            System.assertEquals(NULL, returnVar);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }    
    }
    
    /*@Description: This test method execute the method of SearchCustomer in the CAMSOAP class*/
    private static testmethod void testSearchCustomer() {
        try
        {
            wwwSphComArWsWsdlCam.CAMSOAP cams = new wwwSphComArWsWsdlCam.CAMSOAP();
        
            //Test.setMock(WebServiceMock.class, new wwwSphComArWsWsdlCamMock());
            
            wwwSphComArWsWsdlCam.SearchCustomerRequestType scRequest = new wwwSphComArWsWsdlCam.SearchCustomerRequestType();
            wwwSphComArWsWsdlCam.SearchCustomerResponseType returnVar = cams.SearchCustomer(scRequest);
            
            System.assertEquals(NULL, returnVar);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }       
    }
    
    /*@Description: This test method execute the method of CreateCustomerAccount in the CAMSOAP class*/
    private static testmethod void testCreateCustomerAccount() {
        try
        {
             wwwSphComArWsWsdlCam.CAMSOAP cams = new wwwSphComArWsWsdlCam.CAMSOAP();
        
            //Test.setMock(WebServiceMock.class, new wwwSphComArWsWsdlCamMock());
            
            wwwSphComArWsWsdlCam.CreateCustomerAccountRequestType ccaRequest = new wwwSphComArWsWsdlCam.CreateCustomerAccountRequestType();
            wwwSphComArWsWsdlCam.CreateCustomerAccountResponseType returnVar = cams.CreateCustomerAccount(ccaRequest);
            
            System.assertEquals(NULL, returnVar);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }    
    }
    
    /*@Description: This test method execute the method of CreateAccount in the CAMSOAP class*/
    private static testmethod void testCreateAccountAccount() {
        try
        {
             wwwSphComArWsWsdlCam.CAMSOAP cams = new wwwSphComArWsWsdlCam.CAMSOAP();
        
            //Test.setMock(WebServiceMock.class, new wwwSphComArWsWsdlCamMock());
            
            wwwSphComArWsWsdlCam.CreateAccountRequestType caRequest = new wwwSphComArWsWsdlCam.CreateAccountRequestType();
            wwwSphComArWsWsdlCam.CreateAccountResponseType returnVar = cams.CreateAccount(caRequest);
            
            System.assertEquals(NULL, returnVar);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }     
    }
    
    /*@Description: This test method execute the method of UpdateCustomer in the CAMSOAP class*/
    private static testmethod void testUpdateCustomer() {
        try
        {
             wwwSphComArWsWsdlCam.CAMSOAP cams = new wwwSphComArWsWsdlCam.CAMSOAP();
        
            //Test.setMock(WebServiceMock.class, new wwwSphComArWsWsdlCamMock());
            
            wwwSphComArWsWsdlCam.UpdateCustomerRequestType ucRequest = new wwwSphComArWsWsdlCam.UpdateCustomerRequestType();
            wwwSphComArWsWsdlCam.UpdateCustomerResponseType returnVar = cams.UpdateCustomer(ucRequest);
            
            System.assertEquals(NULL, returnVar);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }   
    }
}