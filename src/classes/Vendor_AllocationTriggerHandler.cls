/**
    * Class Name: Vendor_AllocationTriggerHandler
    * @author: Accenture PDC - James Azana
    * Date: 13.Apr.2015
    * Requirement/Project Name: SF SPH
    * @description: Class that manages Vendor Allocation inserted.
    */

    public class Vendor_AllocationTriggerHandler implements TriggerHandlerInterface{
        
        public static Boolean isBeforeUpdateTriggerCalled = FALSE;
        public static Boolean isBeforeDeleteTriggerCalled = FALSE;
        public static Boolean isBeforeInsertTriggerCalled = FALSE;
        public static Boolean isAfterUpdateTriggerCalled = FALSE;
        public static Boolean isAfterDeleteTriggerCalled = FALSE;
        public static Boolean isAfterInsertTriggerCalled = FALSE;
        
        public static List<Vendor_Allocation__c> ven = new List<Vendor_Allocation__c>();
        public static Set<ID> venAccIdSet = new Set<Id>();
        public static Set<ID> postalCodeIdSet = new Set<Id>();
        public static List<Vendor_Allocation__c> vRecList = new List<Vendor_Allocation__c>();
        
        public Boolean runBeforeInsertTrigger() {
            Boolean returnVar = !Vendor_AllocationTriggerHandler.isBeforeInsertTriggerCalled;
            Vendor_AllocationTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
            return returnVar;        
        }
        
        public Boolean runBeforeUpdateTrigger() {
            Boolean returnVar = !Vendor_AllocationTriggerHandler.isBeforeUpdateTriggerCalled;
            Vendor_AllocationTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
            return returnVar;        
        }
        
        public Boolean runBeforeDeleteTrigger() {
            Boolean returnVar = !Vendor_AllocationTriggerHandler.isBeforeDeleteTriggerCalled;
            Vendor_AllocationTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
            return returnVar;        
        }
        
        public Boolean runAfterInsertTrigger() {
            Boolean returnVar = !Vendor_AllocationTriggerHandler.isAfterInsertTriggerCalled;
            Vendor_AllocationTriggerHandler.isAfterInsertTriggerCalled = TRUE;
            return returnVar;        
        }
        
        public Boolean runAfterUpdateTrigger() {
            Boolean returnVar = !Vendor_AllocationTriggerHandler.isAfterUpdateTriggerCalled;
            Vendor_AllocationTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
            return returnVar;        
        }
        
        public Boolean runAfterDeleteTrigger() {
            Boolean returnVar = !Vendor_AllocationTriggerHandler.isAfterDeleteTriggerCalled;
            Vendor_AllocationTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
            return returnVar;        
        }
            
        public void bulkBefore() {
            if(trigger.isInsert || trigger.isUpdate){
            for(SObject v : trigger.new){
                Vendor_Allocation__c vRec = (Vendor_Allocation__c)v;
                vRecList.add(vRec);
                venAccIdSet.add(vRec.Vendor_Account__c);
                postalCodeIdSet.add(vRec.SingPost_Address__c);
                }
            }
        } 
            
        public void bulkAfter() {
            
        }
        
        public void beforeInsert(SObject so) {
            ven = [SELECT Id, Name, Vendor_Account__c, SingPost_Address__c, SingPost_Address__r.Name FROM Vendor_Allocation__c WHERE Vendor_Account__c IN :venAccIdSet AND SingPost_Address__c IN :postalCodeIdSet];
            if(ven.size() > 0){
                vRecList[0].addError('Duplicate Vendor on Postal Code: ' + ven[0].SingPost_Address__r.Name   +'. Check Vendor Allocation: ' + ven[0].Name);
            }
        }
        
        public void beforeUpdate(SObject oldSo, SObject so) {
            ven = [SELECT Id, Name, Vendor_Account__c, SingPost_Address__c, SingPost_Address__r.Name FROM Vendor_Allocation__c WHERE Vendor_Account__c IN :venAccIdSet AND SingPost_Address__c IN :postalCodeIdSet];
            if(ven.size() > 0 && vRecList[0].id != ven[0].id){ //Start/End UD-0847 04/20/2015 James - allow user to edit existing records
                vRecList[0].addError('Duplicate Vendor on Postal Code: ' + ven[0].SingPost_Address__r.Name   +'. Check Vendor Allocation: ' + ven[0].Name);
            }
        }
        
        public void beforeDelete(SObject so) {
          
        }
        
        public void afterInsert(SObject so) {

        }


        public void afterUpdate(SObject oldSo, SObject so) {

        }

        public void afterDelete(SObject so) {
            
        }

        public void andFinally() {
         
        }
    }