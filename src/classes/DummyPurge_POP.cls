global class DummyPurge_POP implements Database.Batchable<sObject>  {
    global final String query;
    
    global DummyPurge_POP (String strInput)
    {
        this.query = strInput;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Vendor_POP_Batch__c> lstRecords) {
        for(Vendor_POP_Batch__c popRecord : lstRecords){
            popRecord.Publication_Issue_Date__c = popRecord.Publication_Issue_Date__c.addYears(-1);
        }
        
        update lstRecords;
    }        
               
    global void finish(Database.BatchableContext BC) {
    }
}