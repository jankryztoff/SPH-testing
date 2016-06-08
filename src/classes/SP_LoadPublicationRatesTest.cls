@isTest
private class SP_LoadPublicationRatesTest{

    static testmethod void unitTest1(){
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        insert pub;
        
        System.assertNotEquals(null, pub.id);
        
        Publication_Commission_Rates__c  pubComRate = new Publication_Commission_Rates__c ();
        pubComRate.Effective_Start_Date__c = Date.today();
        pubComRate.Publication__c = pub.id;
        insert pubComRate;
        
        System.assertNotEquals(null, pubComRate.id);
        
        SP_LoadPublicationRates batch = new SP_LoadPublicationRates();
        ID batchprocessid = Database.executeBatch(batch,200);
        System.assertNotEquals(null, batchprocessid);
    }
    
    static testmethod void unitTest2(){
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        insert pub;
        
        System.assertNotEquals(null, pub.id);
        
        Publication_Commission_Rates__c  pubComRate = new Publication_Commission_Rates__c ();
        pubComRate.Effective_Start_Date__c = Date.today();
        pubComRate.Publication__c = pub.id;
        insert pubComRate;
        
        System.assertNotEquals(null, pubComRate.id);
        
        SP_LoadPublicationRates batch = new SP_LoadPublicationRates(Date.today());
        ID batchprocessid = Database.executeBatch(batch,200);
        System.assertNotEquals(null, batchprocessid);
    }
}