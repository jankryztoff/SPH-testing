/**
@Author <Jensar Joey Z. Sayson>
@name <BT_AB_DATAPOOL_DeleteRecords_Test>
@Base Class: BT_AB_DATAPOOL_DeleteRecords
@CreateDate <07/02/2015>
@Description <Test Class for RenewalController>
@Version <1.0>
*/
@isTest
private class BT_AB_DATAPOOL_DeleteRecords_Test
{

    static void setData() {
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
    }

    static List<String> interfaceIds = new List<String>{           
        'AGD042DX',  'ARM063DX',   'ARM064DX',    'ARM065DX',    'ARM066DX', 
        'ARM067DX',  'CMI087DX',   'DIR094DX',    'HDS036DX',    'HDS037DX',  
        'HDS038DX',  'HDS039DX',   'HDS039DX_CR', 'HDS039DX_DB', 'INET052DX', 
        'INET054DX', 'MIRO055DX',  'PPS056DX',    'REW031DX',    'REW040DX',   
        'SAP072DX',  'VBS103DX',   'VSS088DX',    'VSS089DX',    'VSS090DX',   
        'VSS093DX',  'ESH1001DX',  'ESH1002DX',   'ESH1003DX',   'ESH1004DX',
        'ESH1005DX', 'ARM067DX_2', 'SMS104DX',    'CMI101DX',    'ARM068DX', 
        'CMI102DX',  'DIR105DX'
    };
    
    static testmethod void unitTest01() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[0]);
        System.assertEquals('AGD042DX', batch.getInterfaceId());
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    }
    
    static testmethod void unitTest02() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[1]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    
    static testmethod void unitTest03() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[2]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest04() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[3]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest05() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[4]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest06() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[5]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    
    static testmethod void unitTest07() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[6]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    /*
    static testmethod void unitTest08() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[7]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest09() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[8]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }*/
    
    
    static testmethod void unitTest10() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[9]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    
    static testmethod void unitTest11() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[10]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest12() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[11]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }

    
    static testmethod void unitTest13() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[12]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest14() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[13]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest15() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[14]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest16() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[15]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    
    static testmethod void unitTest17() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[16]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    
    static testMethod void unitTest18() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[17]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest19() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[18]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest20() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[19]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    
    static testmethod void unitTest21() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[20]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest22() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[21]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest23() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[22]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest24() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[23]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    /*
    static testmethod void unitTest25() {
        
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[24]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest26() {
        
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[25]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    /*
    static testmethod void unitTest27() {
        
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[26]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }*/
    
    static testmethod void unitTest28() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[27]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    /*
    static testmethod void unitTest29() {
        
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[28]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    
    static testmethod void unitTest30() {
        
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[29]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    }
    
    
    
    static testmethod void unitTest31() {
        
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[30]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    */
    
    static testmethod void unitTest32() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[31]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest33() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[32]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest34() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[33]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest35() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[34]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    
    static testmethod void unitTest36() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[35]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
    static testmethod void unitTest37() {
        setData();
        BT_AB_DATAPOOL_DeleteRecords batch = new BT_AB_DATAPOOL_DeleteRecords();        
        batch.setInterfaceId(interfaceIds[36]);        
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
    
    }
}