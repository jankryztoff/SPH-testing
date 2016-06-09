/*
* Class Name: <MigrationContactTriggerHandlerTest>
* @author: Ana Fe Dumangas
* Date: 8/4/15
* Requirement/Project Name: <SPH>
* @description: This is the test class for MigrationContactTriggerHandler
*/

@isTest(seeAllData = false)
private class MigrationContactTriggerHandlerTest{
    static testmethod void testMigrationContactTriggerHandler(){
        Integer counter = 0;
        
        Country__c country = TestDataFactory.createCountry(1)[0];
        database.insert(country);
        
        City__c city = TestDataFactory.createCity(1)[0];
        city.Flight_Number_1__c = '123';
        database.insert(city);
        
        List<Address__c> ad = TestDataFactory.createAddress(4);
        for(Address__c a : ad){
            if(counter==0){
                a.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName='Local'].Id;
                //a.RecordType.DeveloperName = 'Local';
                a.RecordType = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName='Local'];
            }
            else if(counter==1){
                a.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName='Overseas'].Id;
                //a.RecordType.DeveloperName = 'Overseas';
                a.RecordType = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName='Overseas'];
                a.Country__c = country.Id;
            }
            else if(counter==2){
                a.RecordTypeId = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName='Airline'].Id;
                a.RecordType = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName='Airline'];
                a.City__c = city.Id;
            }
            else if(counter==3){
                a.RecordTypeId = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName='Internal'].Id;
                a.RecordType = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType='Address__c' AND DeveloperName='Internal'];
            }
            counter++;
        }
        database.insert(ad);
        
        system.assertEquals(ad[0].RecordType.DeveloperName, 'Local');
        system.assertEquals(ad[1].RecordType.DeveloperName, 'Overseas');
        
        counter=0;
        
        List<Contact> cons = TestDataFactory.createContactRecType(4, 'Customer Contact');
        for(Contact con : cons){
            if(counter==0){
                con.Address__c = ad[0].Id;
            }
            else if(counter==1){
                con.Address__c = ad[1].Id;
            }
            else if(counter==2){
                con.Address__c = ad[2].Id;
            }
            else if(counter==3){
                con.Address__c = ad[3].Id;
            }
            counter++;
        }
        database.insert(cons);
        
        Map<Id, Contact> conMap = new Map<Id, Contact>();
        for(Contact c : cons){
            conMap.put(c.Id, c);
        }
    
        test.startTest();
            MigrationContactTriggerHandler mct = new MigrationContactTriggerHandler();
            mct.doBeforeInsert(cons);
            mct.doBeforeUpdate(cons,conMap,cons,conMap);
            cons[0].Address__c = null;
            update(cons);
            mct.doBeforeUpdate(cons,conMap,cons,conMap);
        test.stopTest();
    }
}