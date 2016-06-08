/**
 * 
 */
@isTest(SeeAllData=True)
private class EmailToCaseHelperTest {

    static testMethod void myUnitTest() {
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Email = 'test@a.com';
        database.insert(con);
        
        List<Case> cas = TestDataFactory.createCase(1, 'Enquiry');
        cas[0].SuppliedEmail = con.Email;
        database.insert(cas);
        
        test.startTest();
        
        EmailToCaseHelper.populateFields(cas);
        
        con.Email_Secondary__c = 'test@a.com';
        con.Email = null;
        database.update(con);
        
        EmailToCaseHelper.populateFields(cas);
        
        test.stopTest();
    }
}