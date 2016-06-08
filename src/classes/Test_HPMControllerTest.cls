@isTest 
private Class Test_HPMControllerTest
{
    Static testMethod void newTest_Test_HPMController(){ 
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        test.startTest();
        //PageReference pageRef = page.HPM;
        //test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('accountId', acc.id);
        
        Test_HPMController tHPM = new Test_HPMController();
        tHPM.getSource();
        test.stopTest();   
    }
}