global class Misc_LetterPrintRequestPatcher implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext bc){    
            return Database.getQueryLocator([SELECT Id, Record_ID__c, Downloaded__c FROM Letter_Print_Request__c where LastModifiedDate < 2015-09-14T00:00:00.000Z and LastModifiedDate > 2015-09-13T00:00:00.000Z and Printable__c = true AND Letter_Type__c = 'Invoice_Letter']);   
    }     
    
    global void execute(Database.BatchableContext BC, List<Letter_Print_Request__c> scope){             
        Set<Id> invoiceIdList = new Set<Id>();
        Set<Id> printableInvoices = new Set<Id>();
        for(Letter_Print_Request__c lprElem : scope) {
            invoiceIdList.add(lprElem.Record_ID__c);
        }
        
        List<Zuora__ZInvoice__c> invoiceList = [SELECT Id FROM Zuora__ZInvoice__c WHERE Id IN :invoiceIdList AND (Zuora__BillingAccount__r.Other_PaymentMethod__c = 'Invoice' OR Zuora__Account__r.GST_Invoice__c = 'Yes')];
        for(Zuora__ZInvoice__c invoiceElem : invoiceList) {
            printableInvoices.add(invoiceElem.Id);
        }
        for(Letter_Print_Request__c lprElem : scope) {
            if(printableInvoices.contains(lprElem.Record_ID__c)) {
                lprElem.Downloaded__c = false;
            } else {
                lprElem.Printable__c = false;
            }
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){        
    }    
}