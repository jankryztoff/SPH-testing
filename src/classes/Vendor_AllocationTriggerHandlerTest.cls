@isTest(SeeAllData=True)
private class Vendor_AllocationTriggerHandlerTest{
     static testmethod void testVendor_AllocationTriggerHandler(){
         Vendor_AllocationTriggerHandler vendAlloc = new Vendor_AllocationTriggerHandler();
         vendAlloc.runBeforeInsertTrigger(); 
         vendAlloc.runBeforeUpdateTrigger();
         vendAlloc.runBeforeDeleteTrigger();
         vendAlloc.runAfterInsertTrigger();
         vendAlloc.runAfterUpdateTrigger();
         vendAlloc.runAfterDeleteTrigger();
     }
}