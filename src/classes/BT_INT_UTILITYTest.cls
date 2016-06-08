/**
   @Author Val Lu
   @name BT_INT_UTILITYTest
   @CreateDate 02/26/2015
   @Description To test BT_INT_UTILITY class
   @Version <1.0>
  */
@isTest (seeAllData= True)
private class BT_INT_UTILITYTest {
    
    /**
    *  To test testCreateSimpleQuery method
    *  @name testCreateSimpleQuery
    *  @param none
    *  @return none
    *  @throws na
    */
    static testmethod void testCreateSimpleQuery(){
        
        //Create a new user with Standard User Profile
        User testUserBIU = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='btintutility@test.com'
        );  
        
        string interfaceName = 'ESH1003DX';
        string whereClause = '1=1'; 
        
        System.runAs(testUserBIU) {
            Test.startTest();
            
            string query = BT_INT_UTILITY.createSimpleQuery(interfaceName, whereClause);
            
            system.assertNotEquals(null, query);
            
            Test.stopTest();
        }
    }

    /**
    *  To test testCreateSimpleQuery method
    *  @name testGetQueryFields
    *  @param none
    *  @return none
    *  @throws na
    */    
    static testmethod void testGetQueryFields(){
        
        
        //Create a new user with Standard User Profile
        User testUserBIU = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='btintutility1@test.com'
        );
        
        string interfaceName = 'ESH1003DX';
        
        System.runAs(testUserBIU) {
            Test.startTest();
            
            List<String> utility = BT_INT_UTILITY.getQueryFields(interfaceName);
            
            system.assertNotEquals(null, utility);
            
            Test.stopTest();
        }
        
    }
}