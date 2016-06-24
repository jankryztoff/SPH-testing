@isTest(SeeAllData=True)

private class BT_CO_Infoprint_Status_TriggerHndlrTest{
    static testMethod void testBT_CO_Infoprint_Status_TriggerHandlerSingle(){
        Letter_Print_Request__c letter = new Letter_Print_Request__c();
        letter.Filename__c  = 'Sample';
        letter.Attachment_ID__c = '123';
        letter.status__c ='Successful';
        database.insert(letter);
    
        BT_CO_Infoprint_Status__c bt = new BT_CO_Infoprint_Status__c();
        bt.Filename__c = 'Sample';
        bt.Attachment_ID__c = '123'; 
        
        test.startTest();
        
        database.insert(bt);
        
        bt.Name = 'New Name';
        bt.Filename__c = 'Update Name';
        database.update(bt);
        
        //database.delete(bt);
        
        test.stopTest();
    }
    
    static testMethod void testBT_CO_Infoprint_Status_TriggerHandlerBulk(){
        Letter_Print_Request__c letter = new Letter_Print_Request__c();
        letter.Filename__c  = 'Sample0';
        letter.Attachment_ID__c = '1230';
        letter.status__c ='Successful';
        database.insert(letter);
    
        List<BT_CO_Infoprint_Status__c> bt = new List<BT_CO_Infoprint_Status__c>();
        
        Integer i;
        for(i=0; i<200; i++){
            BT_CO_Infoprint_Status__c btCo = new BT_CO_Infoprint_Status__c();
            btCo.Filename__c = 'Sample'+i;
            btCo.Attachment_ID__c = '123'+i;   
            bt.add(btCo); 
        }
        
        test.startTest();
        
        database.insert(bt);
        
        bt[0].Name = 'New Name';
        bt[0].Filename__c = 'Update Name';
        database.update(bt);
        
        //database.delete(bt);
        
        BT_CO_Infoprint_Status_TriggerHandler btTrigger = new BT_CO_Infoprint_Status_TriggerHandler();
        btTrigger.runBeforeInsertTrigger();
        btTrigger.runBeforeUpdateTrigger();
        btTrigger.runBeforeDeleteTrigger();
        btTrigger.runAfterInsertTrigger();
        btTrigger.runAfterUpdateTrigger();
        btTrigger.runAfterDeleteTrigger();
        
        test.stopTest();
    }
    
  /*  static testMethod void testBT_CO_Infoprint_Status_TriggerHandlerDelete(){
        Letter_Print_Request__c letter = new Letter_Print_Request__c();
        letter.Filename__c  = 'Sample0';
        letter.Attachment_ID__c = '1230';
        database.insert(letter);
    
        List<BT_CO_Infoprint_Status__c> bt = new List<BT_CO_Infoprint_Status__c>();
        
        Integer i;
        for(i=0; i<200; i++){
            BT_CO_Infoprint_Status__c btCo = new BT_CO_Infoprint_Status__c();
            btCo.Filename__c = 'Sample'+i;
            btCo.Attachment_ID__c = '123'+i;   
            bt.add(btCo); 
        }
      
        database.insert(bt);
        
        system.assertEquals(bt.size(),200);
        
        test.startTest();
        
        database.delete(bt);
       
        test.stopTest();
    } */
}