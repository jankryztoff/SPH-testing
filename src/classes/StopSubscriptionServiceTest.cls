/**
   @Author Christopher Manawatao
   @Name StopSubscriptionServiceTest
   @CreateDate 2/10/2015
   @Description Test Class for StopSubscriptionService
   @Version 1.0
   @reference StopSubscriptionService
**/
@isTest
private class StopSubscriptionServiceTest{
    public class StartSubscriptionServiceRequest {
        AccountWrapper subscriberAccount;      
    }
        
    public class AccountWrapper {
        String accountName;
        String accountNumber; 
        String recordType;
    }
    static testmethod void stopSubService(){
        Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acc.Name = 'Acc Name';
        insert acc;
        
        AccountWrapper aw = new AccountWrapper();
        aw.accountName = acc.Name;
        aw.recordType = 'Direct Corporate';
        StartSubscriptionServiceRequest ssr = new StartSubscriptionServiceRequest();
        ssr.subscriberAccount = aw;
        Test.startTest();
        String JSonStr = JSON.serialize(ssr);
        StopSubscriptionService.StartSubscriptionServiceRequest reqPar2 = new StopSubscriptionService.StartSubscriptionServiceRequest();
        StopSubscriptionService.AccountWrapper aw2 = new StopSubscriptionService.AccountWrapper();
        StopSubscriptionService.StartSubscriptionServiceRequest reqPar = (StopSubscriptionService.StartSubscriptionServiceRequest) JSON.deserialize(JsonStr, StopSubscriptionService.StartSubscriptionServiceRequest.class);
        StopSubscriptionService sss = new StopSubscriptionService();
        StopSubscriptionService.processRequest(reqPar);
        Test.stopTest();
    }
    static testmethod void stopSubService2(){
        Account acc = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        acc.Name = 'Acc Name';
        insert acc;
        
        AccountWrapper aw = new AccountWrapper();
        aw.accountName = acc.Name;
        aw.recordType = 'Direct Individual';
        StartSubscriptionServiceRequest ssr = new StartSubscriptionServiceRequest();
        ssr.subscriberAccount = aw;
        Test.startTest();
        String JSonStr = JSON.serialize(ssr);
        StopSubscriptionService.StartSubscriptionServiceRequest reqPar = (StopSubscriptionService.StartSubscriptionServiceRequest) JSON.deserialize(JsonStr, StopSubscriptionService.StartSubscriptionServiceRequest.class);
        StopSubscriptionService sss = new StopSubscriptionService();
        StopSubscriptionService.processRequest(reqPar);
        Test.stopTest();
    }
}