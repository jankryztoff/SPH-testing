@isTest
private class ChangeOfParticularsTest2{
    static testMethod void testChangeOfParticulars(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Language__c = 'English';
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.Account = acc;
        database.insert(con);
        //end test data
    
        test.startTest();
            PageReference currentPage = page.UpdateContact_COP;
            ApexPages.currentPage().getParameters().put('ContactId', con.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(con);
            
            ChangeOfParticulars cont = new ChangeOfParticulars(controller);
            cont.aContact = con;
            cont.saveContact();
        test.stopTest();
    }
    
    static testMethod void testChangeOfParticularsInternal(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Language__c = 'English';
        database.insert(acc);
        
        SPH_Location__c location = new SPH_Location__c();
        database.insert(location);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Internal'].Id;
        add.Location_Code__c = location.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.Account = acc;
        database.insert(con);
        //end test data
    
        test.startTest();
            PageReference currentPage = page.UpdateContact_COP;
            ApexPages.currentPage().getParameters().put('ContactId', con.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(con);
            
            ChangeOfParticulars cont = new ChangeOfParticulars(controller);
            cont.aContact = con;
            cont.aContact.Address__r = add;
            cont.saveContact();
        test.stopTest();
    }
    
    static testMethod void testChangeOfParticularsAirline(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Language__c = 'English';
        database.insert(acc);
        
        SPH_Location__c location = new SPH_Location__c();
        database.insert(location);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Airline'].Id;
        add.Location_Code__c = location.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.Account = acc;
        database.insert(con);
        //end test data
    
        test.startTest();
            PageReference currentPage = page.UpdateContact_COP;
            ApexPages.currentPage().getParameters().put('ContactId', con.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(con);
            
            ChangeOfParticulars cont = new ChangeOfParticulars(controller);
            cont.aContact = con;
            cont.aContact.Address__r = add;
            cont.saveContact();
        test.stopTest();
    }
    
    static testMethod void testChangeOfParticularsNull(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Language__c = 'English';
        database.insert(acc);
        
        SPH_Location__c location = new SPH_Location__c();
        database.insert(location);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType='Address__c' AND Name='Airline'].Id;
        add.Location_Code__c = location.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = add.Id;
        con.Account = acc;
        database.insert(con);
        //end test data
    
        test.startTest();
            PageReference currentPage = page.UpdateContact_COP;
            ApexPages.currentPage().getParameters().put('ContactId', null);
            ApexPages.StandardController controller = new ApexPages.StandardController(con);
            
            ChangeOfParticulars cont = new ChangeOfParticulars(controller);
            cont.saveContact();
        test.stopTest();
    }
}