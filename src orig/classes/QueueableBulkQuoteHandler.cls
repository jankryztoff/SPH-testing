public class QueueableBulkQuoteHandler implements Queueable, Database.allowsCallouts {
  
  map<id, map<string, string>> orderId_creditCard = new map<id, map<string, string>>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
  set<id> orderIdSet = new set<id>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
  set<id> urgentOrderIdSet = new set<id>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
  string origin;
  string fileIdentifier;
  integer totalChunks;
  string message;
  
  public QueueableBulkQuoteHandler(set<id> orderIdSetParam, set<id> urgentOrderIdSetParam, map<id, map<string, string>> orderId_creditCardParam, 
      string originParam,  string fileIdentifierParam, integer totalChunksParam) {
    
    this.orderIdSet = orderIdSetParam;
    this.urgentOrderIdSet = urgentOrderIdSetParam;
    this.origin = originParam;
    this.fileIdentifier = fileIdentifierParam;
    this.totalChunks = totalChunksParam;
    this.orderId_creditCard = orderId_creditCardParam;

  }
  
  
  public void execute(QueueableContext context) {
    System.debug('##orderIdSet: ' + orderIdSet);
    System.debug('##urgentOrderIdSet: ' + urgentOrderIdSet);
    System.debug('##origin: ' + origin);
    System.debug('##fileIdentifier: ' + fileIdentifier);
    System.debug('##orderId_creditCard: ' + orderId_creditCard);
    System.debug('##totalChunks: ' + totalChunks);
    System.debug('##context: ' + context);
    BulkQuoteHandler createQuote = new BulkQuoteHandler();
    system.debug(':::ORDERIdSET ' + orderIdSet + ' ' + 'ORIGIN' + origin);
    set<string> quoteNameSet = createQuote.bulkQuoteCreation(orderIdSet, origin);
    system.debug('===>QBQH urgentOrderIdSet: ' + urgentOrderIdSet);
    // start removing urgent order to avoid sending it to zuora
    if (urgentOrderIdSet != null && !urgentOrderIdSet.isEmpty()) {
      for (id orderId : urgentOrderIdSet) {
        orderIdSet.remove(orderId);
      }
    }
    // end removing urgent order to avoid sending it to zuora
    
    SendQuotesToZuoraMultipleAccount batch = new SendQuotesToZuoraMultipleAccount(orderIdSet, quoteNameSet, 'csvupload', orderId_creditCard);
    database.executeBatch(batch);
    
    try {
      
      list<Case> caseList = new list<Case>();
      list<Order__c> orderList = new list<Order__c>();
      
    system.debug('===>QBQH casex: ' + [select Id, Sub_Status__c, Order__c from Case where Order__c in :orderIdSet]);
    
      for (Case casex : [select Id, Sub_Status__c, Order__c from Case where Order__c in :orderIdSet]) {
        
        casex.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        caseList.add(casex);
        
        Order__c orderx = new Order__c();
        orderx.Id = casex.Order__c;
        orderx.Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
        orderList.add(orderx);
      }
      
      if (!caseList.isEmpty()) {
        update caseList;
      }
      
      if (!orderList.isEmpty()) {
        update orderList;
      }
      
      Other__c other = [select Id, Name, Value__c from Other__c where Name = :fileIdentifier];
      integer chunkCounter = integer.valueOf(other.Value__c) + 1;
      
      if (chunkCounter == totalChunks) {
        
        message = 'Quote creation job has been completed.';
        sendEmailNotification();
        
        delete other;
        
      } else {
        
        other.Value__c = string.valueOf(chunkCounter);
        update other;
      }
      
    } catch (exception e) {
      message = 'Error : ' + e.getMessage();
    }
    
  }
  
  
  private void sendEmailNotification() {
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new string[] {Userinfo.getUserEmail()});
        mail.setPlainTextBody(message);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSenderDisplayName('Singapore Press Holdings');
        mail.setSubject('[SPH] ' + fileIdentifier);
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
  }
}