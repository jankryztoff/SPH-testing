@isTest 
private class AttachmentTriggerTest {

  @testSetup 
  static void setupData() {
    insert CustomSettingsDataFactory.createError_Messages();  
  }  
    
    static testMethod void deleteAttachment() {
    
    id standardProfileId = [select id from Profile where name = 'Standard User' limit 1].id;
    user testUser = new User(
              Alias = 'stndrd',
              Email='standarduser@test.com', 
              EmailEncodingKey='UTF-8',
              LastName='Test',
              LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US',
              ProfileId = standardProfileId,  
              TimeZoneSidKey='America/Los_Angeles',
              UserName='standard@test.com',
              Validation_Exempted__c = false);
        
        account accountx = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        insert accountx;
        
        attachment att = new attachment();
        att.parentId = accountx.Id;
        att.body = blob.valueOf('attachmenttrigger');
        att.name = string.valueOf(datetime.now());
        
        insert att;
        
        system.runAs(testUser) {
          test.startTest();
          try {
            delete att;
          } catch (exception e) {
            system.assert(e.getMessage().contains('delete'));
          }
          test.stopTest();
        }    
    }
}