@isTest
private class CustomHpmControllerTest {
    static testMethod void testCustomHpmController() { 
        test.startTest();
            CustomHpmController controller = new CustomHpmController();
            controller.getBackUrl();
            controller.getNextUrl();
            controller.getPageRef();
        test.stopTest();
    }
}