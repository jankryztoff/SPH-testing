@isTest
private class ChangeInAddressControllerTest{
    static testMethod void testChangeInAddressController(){
        //start test data
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert (con);
        //end test data
    
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(con);
            ApexPages.currentPage().getParameters().put('RecordType', con.RecordTypeId);
            
            ChangeInAddressController cont = new ChangeInAddressController(controller);
            cont.saveandnew();
        test.stopTest();
    }
}