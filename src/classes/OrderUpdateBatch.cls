/*
ClassName: OrderUpdateBatch
Author: Karl Wilson L. Tan
Date: 07/23/2015
Description: To update checkbox field if Order Record is Legacy
D-3260
*/

global class OrderUpdateBatch implements Database.batchable<sObject>, Database.Stateful{

global Database.QueryLocator start(Database.BatchableContext bc){

    return database.getQuerylocator('select id,name,isOrderLegacy__c, Order_Legacy_Id__c, Account__r.name  from Order__c WHERE Order_Legacy_Id__c != null AND isOrderLegacy__c = false');
       // return database.getQuerylocator('select id,name,isOrderLegacy__c, Order_Legacy_Id__c, Account__r.name  from Order__c WHERE Order_Legacy_Id__c != null AND Account__r.name LIKE \'%E2E%\'');
    
}
    
   global void execute(Database.batchableContext info, List<Order__c> ordList){ 
       List<Order__c> ordToUpdate = new List<Order__c>(); 
       for(Order__c order : ordList){ 
           order.isOrderLegacy__c = True;
           ordToUpdate.add(order);
       }
       List<database.saveResult> lsdtb = database.update(ordToUpdate, false);
       for(database.saveResult dtb : lsdtb){
           if(!dtb.isSuccess()){
           system.debug('DATABASE ' + dtb);
           }
       }         
   }     
   global void finish(Database.batchableContext info){     
   } 
}