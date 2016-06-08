@isTest(SeeAllData=true)

private class VDC_CREDITNOTE_TriggerHandlerTest{
        static testMethod void testVDC_CREDITNOTE_TriggerHandlerSingle(){
        VDC_CREDITNOTE__c vdc = TestDataFactory.createVDC_CREDITNOTE(1)[0];
        vdc.Credit_Note_Number__c = 123;
        
        test.startTest();
        
        VDC_CREDITNOTE_TriggerHandler vdcAction = new VDC_CREDITNOTE_TriggerHandler();
        VDC_CREDITNOTE_TriggerHandler.latestCreditNoteNumber = 19999999;
        
        database.insert(vdc);
        vdcAction.beforeInsert(vdc);
        vdcAction.afterInsert(vdc);
        
        vdc.Name = 'updateSample';
        database.update(vdc);
        vdcAction.beforeUpdate(vdc,vdc);
        vdcAction.afterUpdate(vdc,vdc);
        
        database.delete(vdc);
        vdcAction.beforeDelete(vdc);
        vdcAction.afterDelete(vdc);
        
        test.StopTest();
    }
    
    static testMethod void testVDC_CREDITNOTE_TriggerHandlerBulk(){
        List<VDC_CREDITNOTE__c> vdc = TestDataFactory.createVDC_CREDITNOTE(200);
        Integer count = 0;
        for(VDC_CREDITNOTE__c v : vdc){
            v.Credit_Note_Number__c = 123+count;
            count++;
        }
        
        test.startTest();
        
        database.insert(vdc);
        vdc[0].Name = 'updateSample';
        database.update(vdc);
        database.delete(vdc);
        
        VDC_CREDITNOTE_TriggerHandler vdcAction = new VDC_CREDITNOTE_TriggerHandler();
        vdcAction.runBeforeInsertTrigger();
        vdcAction.runBeforeUpdateTrigger();
        vdcAction.runBeforeDeleteTrigger();
        vdcAction.runAfterInsertTrigger();
        vdcAction.runAfterUpdateTrigger();
        vdcAction.runAfterDeleteTrigger();
        
        vdcAction.bulkBefore();
        vdcAction.bulkAfter();
        vdcAction.andFinally();
        
        test.StopTest();
    }
}