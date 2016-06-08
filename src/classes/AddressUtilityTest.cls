/**
 * Class Name: <AddressUtilityTest>
 * @author: <JhustinPinoy>
 * Date: <9.27/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for AddressUtility>
 */

@isTest (seeAllData= True)
public class AddressUtilityTest {

    static testMethod void testConcatenateAddressFields(){
        
        //Create a new user with Standard User Profile

        User testUserAUT = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='addressutility1@test.com'
        );
        
        String streetName = 'Street Name'; 
        String buildingName = 'Building Name'; 
        String blockHouseNumber = '12345';
        String levelNumber = '12345';
        String unitNumber = '1234'; 
        String postalCode = '12345';
        String floor = '1st';
        
        System.runAs(testUserAUT) {
            Test.startTest();
        
            AddressUtility.concatenateAddressFields(
                streetName, 
                buildingName, 
                blockHouseNumber, 
                levelNumber, 
                unitNumber, 
                postalCode
            );
            
            Test.stopTest();
        }
    }
    
    static testMethod void testConcatenateAddressFields2(){
        
        //Create a new user with Standard User Profile

        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='addressutility2@test.com'
        );
        
        String streetName = 'Street Name'; 
        String buildingName = 'Building Name'; 
        String blockHouseNumber = '12345';
        String levelNumber = '12345';
        String unitNumber = '1234'; 
        String postalCode = '12345';
        String floor = '1st';
        
        System.runAs(testUser) {
            Test.startTest();
            
            AddressUtility.concatenateAddressFields2(
                blockHouseNumber,
                levelNumber,
                unitNumber,
                postalCode
            );
            
            Test.stopTest();
        }
    }
    
    static testMethod void testconstructSingpostUniqueKey(){
        
        //Create a new user with Standard User Profile

        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='addressutility3@test.com'
        );
        
        String streetName = 'Street Name'; 
        String buildingName = 'Building Name'; 
        String blockHouseNumber = '12345';
        String levelNumber = '12345';
        String unitNumber = '1234'; 
        String postalCode = '12345';
        String floor = '1st';
        
        System.runAs(testUser) {
            Test.startTest();
            
            AddressUtility.constructSingpostUniqueKey(
                postalCode,
                floor,
                unitNumber
            );
            
            Test.stopTest();
        }
    }
}