/*
* Class Name: <StringUtility_Test>
* @author: Reszel Garrie Pineda
* Date: 2/05/2015
* Requirement/Project Name: <SPH>
* @description: Test class for StringUtility
* History:  2015/02/05 - Reszel Garrie Pineda - Created Test Class
*           2015/03/06 - Michael Francisco - Modified to include test cases for modifications made to StringUtility.
*/
@isTest (seeAllData= True)
private class StringUtilityTest {
    
    /* @description: This method checks positive scenario of formatValue() method */
    static testmethod void testformatValue()
    {
        Test.startTest();
        
        string padValue = 'foo';
        string padDirection = 'bar';
        
        StringUtility.formatValue(1.5, padValue, padDirection, 1);            
        StringUtility.formatValue(1.5, padValue, 'left', 1);
        System.assertEquals('foo', padValue);
        
        Test.stopTest();
    }//end of testformatValue()
    
    /* @description: This method checks formatDateValue() method */
    static testmethod void testformatDateValue()
    {
        //test of formatDateValue method
        
        date dt = date.today();
        
        Test.startTest();
        
        StringUtility.formatDateValue(dt,'dd.mm.yyyy');
        StringUtility.formatDateValue(dt,'yyyymmdd');
        System.assertEquals(date.today(), dt);
        
        Test.stopTest();
    }//end of testformatDateValue()
    
    /* @description: This method checks negative scenario of formatValue() method */
    static testmethod void testformatValueNeg()
    {
        
        Test.startTest();
        
        string padValue = 'foo';
        string padDirection = 'bar';
        
        
        StringUtility.formatValue(null, padValue, padDirection, 1);
        System.assertEquals('bar' , padDirection);
        
        
        Test.stopTest();
    }//end of testformatValueNeg()
    
    /* @description: This method runs a series of checks for the quoteReplaceStr method of StringUtility */
    static testmethod void testQuoteReplaceStr() {
        Test.startTest();
        String containsComma = 'Last Name, First Name';
        String containsDoubleQuote = 'Firstname "Nickname" Lastname';
        String containsSingleQuote = 'L\'Oreal';
        String nullString = null;
        String emptyString = '';
        
        String check1 = StringUtility.quoteReplaceStr(containsComma);
        String check2 = StringUtility.quoteReplaceStr(containsDoubleQuote);
        String check3 = StringUtility.quoteReplaceStr(containsSingleQuote);
        String check4 = StringUtility.quoteReplaceStr(nullString);
        String check5 = StringUtility.quoteReplaceStr(emptyString);
        
        System.assertEquals(check1, '"Last Name, First Name"');
        System.assertEquals(check2, '"Firstname Nickname Lastname"');
        System.assertEquals(check3, '"LOreal"');
        System.assertEquals(true,check4 == null);
        System.assertEquals(check5, '');
        
        Test.stopTest();
    }
    
    //test for getPublishedDays() 
    static testmethod void testGetPublishedDays(){
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = StringUtility.getPublishedDays('Mon - Fri', 'NNNNNNN');
        pub.Published_Days__c = StringUtility.getPublishedDays('Mon - Sat', 'NNNNNNN');
        pub.Published_Days__c = StringUtility.getPublishedDays('Sat - Sun', 'NNNNNNN');
    }
    
    static testmethod void testformatDate()
    {
        //test of formatDate method
        
        dateTime dt = system.now();
        
        Test.startTest();
        
        StringUtility.formatDate(null);
        StringUtility.formatDate(dt);
        System.assertEquals(system.now(), dt);
        
        Test.stopTest();
    }//end of testformatDate()
    
    static testmethod void testgetAccountingPeriod()
    {
        //test of getAccountingPeriod method
        
        String zBatchRunDate='2003-08-08';
        
        Test.startTest();
        
        String result = StringUtility.getAccountingPeriod(zBatchRunDate);
        System.assertEquals(result, '0803');
        
        result = StringUtility.getAccountingPeriod('08/18/2003');
        
        Date dToday = Date.today();
        Integer iMonth = dToday.month();
        Integer iYear = dToday.year();    
        String zMonth = (iMonth < 10) ? ('0'+iMonth) : String.valueOf(iMonth);
        String zYear = String.valueOf(iYear).substring(2,4);
        String zAccountingPeriod = zMonth + zYear;
        System.assertEquals(zAccountingPeriod, result);
        
        Test.stopTest();
    }//end of testgetAccountingPeriod()
    
    static testmethod void testgetValues()
    {
        //test of getValues method
        
        Test.startTest();
        
        Set<String> str = StringUtility.getValues('values1|values2|values3');
        System.assertEquals(3, str.size());
        
        Test.stopTest();
    }//end of testgetValues()
    
    static testmethod void getCopies()
    {
        //test of getCopies method
        
        Test.startTest();
        
        String str = StringUtility.getCopies('DEFAULT', 3, '123456789');
        str = StringUtility.getCopies('DAY1', 3, '123456789');
        str = StringUtility.getCopies('DAY2', 3, '123456789');
        str = StringUtility.getCopies('DAY3', 3, '123456789');
        str = StringUtility.getCopies('DAY4', 3, '123456789');
        str = StringUtility.getCopies('DAY5', 3, '123456789');
        str = StringUtility.getCopies('DAY6', 3, '123456789');
        str = StringUtility.getCopies('DAY7', 3, '123456789');
        str = StringUtility.getCopies('PHD', 3, '123456789');
        str = StringUtility.getCopies('PHE', 3, '123456789');
        
        Test.stopTest();
    }//end of getCopies()
    
    static testmethod void testvalidate()
    {
        //test of validate method
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Test.startTest();
        
        String str = StringUtility.validate(acc);
        str = StringUtility.validate('Account');
        
        Test.stopTest();
    }//end of testvalidate()
    
     static testmethod void getVendor()
    {
        //test of getVendor method
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Test.startTest();
        
        String str = StringUtility.getVendor('Vendor', 'Code');
        str = StringUtility.getVendor(null, 'Code');
        
        Test.stopTest();
    }//end of testgetVendor()
    
    
}//end of StringUtility_Test