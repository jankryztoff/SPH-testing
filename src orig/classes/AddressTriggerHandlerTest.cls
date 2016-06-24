@isTest(seeAllData = true)
public class AddressTriggerHandlerTest {
    static testmethod void test01(){
        AddressTriggerHandler ath = new AddressTriggerHandler();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
        
        Country__c country = new Country__c();
        country.Name = 'ZZ';
        country.Code__c = 'ZZ';
        country.Country_Name__c = 'ZZambia';
        insert country;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = country.Id;
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        insert addressRec;
        
        ath.runBeforeInsertTrigger();
        ath.runBeforeUpdateTrigger();
        ath.runBeforeDeleteTrigger();
        ath.runAfterInsertTrigger();
        ath.runAfterUpdateTrigger();
        ath.runAfterDeleteTrigger();
        
        //ath.bulkBefore();
        ath.bulkAfter();
        
       	ath.beforeInsert(addressRec);
        ath.beforeUpdate(addressRec, addressRec);
        ath.beforeDelete(null);
        
        ath.afterInsert(null);
        ath.afterUpdate(null, null);
        ath.afterDelete(null);
        
        ath.andFinally();
        
    }
}