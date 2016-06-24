@isTest(seeAllData = true)
public class AddressTriggerHandlerTest {
    static testmethod void test01(){
        AddressTriggerHandler ath = new AddressTriggerHandler();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '100044';
        postal.House_Block_Number__c = '45';
        postal.Address_Type__c = 'A';
        postal.Street_Name__c = 'TELOK BLANGAH DRIVE 1';
        postal.Building_Name__c = '';
        insert postal;
        
        Address_Details__c adDetail = new Address_Details__c();
        adDetail.Postal_Code__c = postal.Id;
        adDetail.Level__c = '09';
        adDetail.Unit__c = '53';
        insert adDetail;
              
        Country__c country = new Country__c();
        country.Name = 'SG';
        country.Code__c = 'SIN';
        country.Country_Name__c = 'Singapore';
        insert country;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'H';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='44';
        addressRec.Level_Number__c ='09';
        addressRec.Unit_Number__c = '53';
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