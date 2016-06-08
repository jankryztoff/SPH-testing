/**
 * Class Name: <DateUtilityTest>
 * @author: <JhustinPinoy>
 * Date: <9/27/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for DateUtility>
 */

@isTest (Seealldata = TRUE)
public class DateUtilityTest {
    
    static testMethod void testDateUtilityMethods(){
        //Create a new user with Standard User Profile
        User testUserdut = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarddut@test.com'
        );
        
        System.runAs(testUserdut) {
            
            Test.startTest();
            
            Date dateValue = Date.newInstance(2014, 9, 27);
            
            System.assertEquals(dateValue, DateUtility.convertDate('27/9/2014','/','DMY'));
            System.assertEquals(dateValue, DateUtility.convertDate('9/27/2014','/','MDY'));
            System.assertEquals(null, DateUtility.convertDate('9/27/2014','/','YDM'));
            System.assertEquals(dateValue, DateUtility.convertDate('2014/9/27','/','YMD'));
            
            System.assertEquals(DateUtility.convertDateFromYYYYMMDD('20140927'), dateValue);
            
            System.assertEquals(true, DateUtility.isDateDD_MM_YYYY('27/9/2014','/'));
            System.assertEquals(false, DateUtility.isDateDD_MM_YYYY('32/14/4001','/'));
            
            System.assertEquals(true, DateUtility.isDateYYYYMMDD('20140927'));
            System.assertEquals(false, DateUtility.isDateYYYYMMDD('2xx40AA927'));
            
            System.assertEquals(DateUtility.convertDateFromYYYY_MM_DDtHH_MM_SSz('2014_09_27t11_11_11z'), DateTime.newInstanceGmt(2014, 9, 27, 11, 11, 11));
            System.assertEquals(DateUtility.convertDateFromYYYY_MM_DD_ToMonthStart('2014_09_27'), DateTime.newInstanceGmt(2014, 9, 01, 0, 0, 0));
            System.assertEquals(DateUtility.convertDateFromYYYY_MM_DD_ToMonthEnd('2014_09_27'), DateTime.newInstanceGmt(2014, 09, 30, 23, 59, 59));
            System.assertEquals(DateUtility.convertDateFromYYYY_MM_DD_ToMonthEnd('2014_12_27'), DateTime.newInstanceGmt(2014, 12, 31, 23, 59, 59));
            
            System.assertEquals(DateUtility.convertDateFromYYYY_MM_DD_CustomSettings('2014_09_27t11_11_11z'), DateTime.newInstanceGmt(2014, 09, 27, 11, 11, 11));
            System.assertEquals(DateUtility.convertDateFromYYYY_MM_DD_CustomSettings('2014_09_27t11_11_11z', 'Sample Settings'), DateTime.newInstanceGmt(2014, 09, 27, 11, 11, 11));
            
            BT_CO_Batch_Run_Request__c bt = [SELECT Interface_ID__c FROM BT_CO_Batch_Run_Request__c LIMIT 1];
            System.assertNotEquals(null, DateUtility.getOverrideDate(bt.Interface_ID__c));
            
            System.assertEquals(true, DateUtility.isWorkingDay('Monday'));
            System.assertEquals(false, DateUtility.isWorkingDay('Saturday'));
            
            System.assertEquals('09/27/2014', DateUtility.convertDateToString(Date.newInstance(2014,09,27)));
            System.assertEquals('11/09/2014', DateUtility.convertDateToString(Date.newInstance(2014,11,09)));
            
            System.assertEquals(DateUtility.dayInWeekEEE(Date.newInstance(2015,06,25)), 'Wed');
            System.assertEquals(DateUtility.dayInWeekEEEE(Date.newInstance(2015,06,25)), 'Wednesday');
            
            System.assertNotEquals(null, DateUtility.getFirstPublicationDate(Date.newInstance(2015,06,25), Date.newInstance(2015,07,02), 'YYYYYYYNN'));
            
            System.assertEquals(Date.newInstance(2099, 12, 31), DateUtility.getDefaultEndDate());
            
            Test.stopTest();
            
        }
    }
    
    static testMethod void testgetNthLastWorkingDay(){
        //Create a new user with Standard User Profile
        User testUserdut = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardut2@test.com'
        );
        
        System.runAs(testUserdut) {
            
            Test.startTest();
            
            Date dateValue = Date.newInstance(2014, 9, 27);
            
            DateUtility.getNthLastWorkingDay(dateValue, 9);
            
            Test.stopTest();
            
        }
    }
}