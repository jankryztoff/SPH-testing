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
private class StringUtility_Test {
    
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
    
}//end of StringUtility_Test