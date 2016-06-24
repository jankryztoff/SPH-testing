global class TEST_PdfCreationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    /*
     *  Created By: Accenture -  Jeffrey Teves
     *  Created Date: June 25, 2014
     *  Purpose:
     *      - POC Batch Class for creating bulk PDF documents
     *  Considerations:
     *      1. Since we are performing callouts to insert records, we will need to limit transaction to only process 10 records at a time - maximum of 10 calouts per executemethod invocation
     *    2. Current implementation: One callout per record - one attachment is created per callout.
   *    3. We could update the WebService class to handle/create multiple records per invocation - thus limiting the number of total batch chunks and callouts
   *    4. Possible Enhancement: Capture success/failures in Webservice class and relay back to the batch apex for processing.
     *  History: 10/02/14 Kevin Evasco - Updated to implement recursive batch execution.
     */
    
    Date printLetterBatchRunDate;
    String query, endpointUrl, userName, password, sessionId;
    public final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    public final String NS_SF = 'urn:partner.soap.sforce.com';
    
    global TEST_PdfCreationBatch(String userName, String password) {
       this.userName = userName;
       this.password = password;
       endpointUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/insertPdf';
    }
    
    global TEST_PdfCreationBatch(String sessionId, Date printLetterBatchRunDate) {
        this.printLetterBatchRunDate = printLetterBatchRunDate;
        this.sessionId = sessionId;
        endpointUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/insertPdf';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name FROM Account WHERE Name LIKE 'Print Letter Batch Test%' AND Print_Letter_Batch_Run_Date__c != :printLetterBatchRunDate LIMIT 2000]); 
    }
     
    global void execute(Database.BatchableContext BC, List<Account> scope){
    
        //String sessionId = login();
        
        List<String> parentIdList = new List<String>();         
        
        integer index = 0;
        
        for(Account batchObject : scope)
        {
            parentIdList.add(batchObject.Id);
        
            if(parentIdList.size() == 10 || index == scope.size()-1)
            {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpointUrl);
                req.setMethod('POST');
                req.setHeader('Authorization', 'OAuth ' + sessionId);
                req.setHeader('Content-Type','application/json');        
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('parentIdList');
                gen.writeStartArray();
                for(String parentId : parentIdList)
                {
                gen.writeString(parentId);    
                }
                gen.writeEndArray();
                String reqBody = gen.getAsString();
        
                req.setBody(reqBody);
                Http http = new Http();
                HttpResponse response = http.send(req);
                
                parentIdList = new List<String>();
            }
            
            batchObject.Print_Letter_Batch_Run_Date__c = printLetterBatchRunDate;
            
            index++;
        }

        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        //List<Daily_Vendor_Publication_Data__c> consolidatedDataToInsert = new List<Daily_Vendor_Publication_Data__c>();
        
        Integer pendingAccounts = [SELECT COUNT() FROM Account WHERE Name LIKE 'Print Letter Batch Test%' AND Print_Letter_Batch_Run_Date__c != :printLetterBatchRunDate LIMIT 2000];
        
        if(pendingAccounts != 0)
        {
            TEST_PdfCreationBatch batchableInstance = new TEST_PdfCreationBatch(this.sessionId, this.printLetterBatchRunDate);        
            Database.executeBatch(batchableInstance,100);
        }        
    }
    
}