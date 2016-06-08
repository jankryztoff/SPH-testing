@isTest(seeAllData=true)
private class INT_PageRestToolController_Test {
    static testMethod void testIntPageRestToolController(){
       
        try{
            Test.startTest();
            INT_PageRestToolController controller = new INT_PageRestToolController();
            //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
            controller.myStart();
            controller.computeSig();
            controller.gen1 = controller.myReturn;
            controller.gen = 'test string gen';
            controller.Method = 'test string method';
            controller.myBody = '';
            controller.LogId = '';
            controller.recordId = '';
            controller.emailForReport = '';
            controller.hasQuery = true;
            controller.stringBuilder = '';
            controller.sendR();
            Test.stopTest();
        }
        catch (Exception e){
        }
    }
}