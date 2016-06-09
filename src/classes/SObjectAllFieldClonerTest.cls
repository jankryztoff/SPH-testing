/*
 * Class Name: SObjectAllFieldClonerTest 
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * Project/Requirement: 
 * @description: to test SObjectAllFieldClonerclass
 */
 
@isTest (seeAllData= True)
private class SObjectAllFieldClonerTest {
    
    /**
    *  To test SObjectAllFieldCloner
    *  @name testFieldCloner
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testFieldCloner(){
        
        //Create a new user with Standard User Profile
        
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(u) {
            SObjectAllFieldCloner SOCloner = new SObjectAllFieldCloner();
            test.startTest();
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            List<Contact> con = TestDataFactory.createContact(3);
            con[0].Address__c = addressRec.Id;
            //START: CCB002 Added by April Banaag - to apply changes to contact record type
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END: CCB002 Added by April Banaag - to apply changes to contact record type
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            insert con;  
            system.assertNotEquals(null, con);             
            
            List<Id> sObjectIds = new List<Id>();
            for(Contact co:con){
            sObjectIds.add(co.id);
            }
            
            
            Contact contactclone = new Contact();
            contact clone = (Contact) SObjectAllFieldCloner.cloneObject(con[0], con[0].getSObjectType());
            List<Contact> conclone =  SObjectAllFieldCloner.cloneObjects(con, con[0].getsObjectType()); 
            
            Map<Id, sOBject> conclone2 =  SObjectAllFieldCloner.cloneObjects(sObjectIds, con[0].getsObjectType());             
     
            test.stopTest();
        }
    }
}